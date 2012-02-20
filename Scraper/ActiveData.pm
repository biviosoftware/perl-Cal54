# Copyright (c) 2011 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::Scraper::ActiveData;
use strict;
use Bivio::Base 'Bivio.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');

sub internal_import {
    my($self) = @_;
    my($start) = $_D->add_days($self->get('date_time'), -1);
    my($end) = $_D->add_months($start, 6);
    my($webhost) = _parse_webhost($self);
    return unless _parse_event_xml($self, $webhost, $start, $end);
    _add_event_urls($self, $webhost, $start, $end);
    return;
}

sub _add_event_urls {
    my($self, $webhost, $start, $end) = @_;
    my($xml) = $self->internal_parse_xml(
	'http://' . $webhost . '/RSSSyndicator.aspx?'
	. join('&',
	    'category=',
	    'location=',
	    'type=N',
	    'starting=' . $_D->to_string($start),
	    'ending=' . $_D->to_string($end),
	    'binary=Y'));

    unless ($xml->{channel} && $xml->{channel}->{item}) {
	b_warn('missing channel/item');
	return;
    }
    my($links_by_start_time) = {};

    foreach my $item (@{$xml->{channel}->{item}}) {
	# pubDate has the GMT start time
	my($title) = _strip_trailing_parens($self,
            $self->internal_clean($item->{title}));
	($links_by_start_time->{$_DT->from_literal_or_die($item->{pubDate})}
	    ||= {})->{$title} = $item->{link};
    }

    foreach my $event (@{$self->get('events')}) {
	my($dtstart) = $event->{dtstart};
	my($summary) = _strip_trailing_parens($self, $event->{summary});

	unless ($links_by_start_time->{$dtstart}
	    && $links_by_start_time->{$dtstart}->{$summary}) {
	    b_warn('missing url for event: ', $dtstart, ' ', $summary);
	    next;
	}
	$event->{url} = $links_by_start_time->{$dtstart}->{$event->{summary}};
    }
    return;
}

sub _date_time {
    my($self, $event, $type) = @_;
    return $self->internal_date_time(
	$event->{$type . 'Date'} . ' ' . $event->{$type . 'Time'});
}

sub _parse_event_xml {
    my($self, $webhost, $start, $end) = @_;
    my($xml) = $self->internal_parse_xml(
	'http://' . $webhost . '/Eventlist.aspx?'
        . join('&',
	    'fromdate=' . $_D->to_string($start),
	    'todate=' . $_D->to_string($end),
	    'type=public',
	    'download=download',
	    'dlType=XML'
	));

    # iterate events, taking Address1 which match the current venue
    foreach my $event (@{$xml->{Event}}) {
	next unless ref($event) eq 'HASH';
#TODO: change to accept_event config?
	next if $self->is_canceled($event->{Status} || '');
	next if ($event->{ExternalField1} || '') =~ /students|alumni/i;
	next unless $event->{StartDate} && $event->{StartTime}
	    && $event->{EndDate};
	push(@{$self->get('events')}, {
	    location => $event->{Address1} || $event->{Building},
	    summary => $self->internal_clean($event->{EventName}),
	    description => $self->internal_clean($event->{EventDescription}),
	    dtstart => _date_time($self, $event, 'Start'),
	    dtend => $event->{EndTime}
		? _date_time($self, $event, 'End')
		: undef,
	});
    }
    return @{$self->get('events')} ? 1 : 0;
}

sub _parse_webhost {
    my($self) = @_;
    # first parse calendar for "/eventlistsyndicator.aspx", use that host
    # otherwise look for "EventList.aspx" and use current host
    my($url) = $self->get('scraper_list')->get('Website.url');
    my($html) = $self->c4_scraper_get($url);
    my($host) = $$html =~ m,://(.*?)/(EventListSyndicator|displaymedia).aspx,;
    return $host if $host;
    b_die('unparsed host value')
	unless $$html =~ /("|')EventList.aspx\?/;
    ($host) = $url =~ m,http://(.*?)/,;
    return $host || b_die('host not found in calendar website');
}

sub _strip_trailing_parens {
    my($self, $value) = @_;

    while ($value =~ m,\(.*?\)\s*$,) {
	$value =~ s,\s*\(.*?\)\s*$,,;
    }
    return $value;
}

1;
