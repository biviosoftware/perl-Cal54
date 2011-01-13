# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::Google;
use strict;
use Bivio::Base 'Bivio.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');
my($_JSON) = b_use('MIME.JSON');
my($_MC) = b_use('MIME.Calendar');
my($_RR) = b_use('MIME.RRule');

sub internal_import {
    my($self) = @_;
    my($start) = $_D->add_days($_D->local_today, -1);
    my($end) = $_D->add_months($start, 6);
    my($html) = $self->c4_scraper_get(
	$self->get('venue_list')->get('calendar.Website.url'));
    my($cal_id) =
	$$html =~ m,www\.google\.com/calendar/embed\?src=(.*?)(\&|"),;
    b_die('failed to parse cal_id: ', $html)
	unless $cal_id;
    return unless _parse_ics($self, $cal_id, $start, $end);
    _add_event_urls($self, $cal_id, $start, $end);
    return;    
}

sub _add_event_urls {
    my($self, $cal_id, $start, $end) = @_;
    my($json) = $_JSON->from_text($self->c4_scraper_get(
	'https://www.google.com/calendar/feeds/' . $cal_id . '/public/embed?'
	    . join('&',
#TODO: use the venue tz		   
	        'ctz=America%2FDenver',
		'singleevents=true',
		'start-min=' . $_D->to_xml($start) . 'T00:00:00',
		'start-max=' . $_D->to_xml($end) . 'T00:00:00',
		'max-results=1000',
		'alt=json')));

    unless (ref($json) eq 'HASH' && $json->{feed} && $json->{feed}->{entry}) {
	b_warn('missing feed/entry');
	return;
    }
    my($url_by_id) = {};

    foreach my $entry (@{$json->{feed}->{entry}}) {

	foreach my $link (@{$entry->{link}}) {
	    next unless $link->{rel} eq 'alternate';
	    # ex. 2011-01-21T21:00:00.000-07:00
	    my($v) = $entry->{'gd$when'}->[0]->{startTime};
	    my($year, $mon, $day, $h, $m, $sign, $h_offset, $m_offset) =
		$v =~ /^(\d{4})\-(\d{2})\-(\d{2})T(\d{2})\:(\d{2}).*([-+])(\d{2})\:(\d{2})$/;
	    next unless defined($m_offset);
	    my($dt) = $_DT->from_parts_or_die(0, $m, $h, $day, $mon, $year);
	    $dt = $_DT->add_seconds($dt,
	        - ($sign eq '-' ? -1 : 1) * 60 * ($h_offset * 60 + $m_offset));
	    my($id) = $entry->{id}->{'$t'};
	    $id =~ s/\_.*$//;
	    $url_by_id->{$id . '-' . $_DT->to_string($dt)} = $link->{href};
	    last;
	}
    }

    foreach my $event (map($_->[0], @{$self->get('events')})) {
	my($uid) = delete($event->{uid});
	$uid =~ s/\@.*$//;
	$event->{url} = $url_by_id->{$uid . '-'
	    . $_DT->to_string($event->{dtstart})};

	unless ($event->{url}) {
	    b_warn('missing url for uid: ', $uid, ' ',
	        $_DT->to_ical($event->{dtstart}));
	}
    }
    return;
}

sub _explode_event {
    my($self, $vevent, $end) = @_;
    return [$vevent] unless $vevent->{rrule};
    return [
	map(+{
	    %$vevent,
	    %$_,
	}, @{$_RR->process_rrule($vevent, $end)}),
    ];
}

sub _local_date {
    my($self, $event) = @_;
    return '' unless $event->{time_zone};
    return $_D->to_file_name($event->{time_zone}
        ->date_time_from_utc($event->{dtstart}));
}

sub _parse_ics {
    my($self, $cal_id, $start, $end) = @_;
    my($recurrences) = {};

    foreach my $vevent (reverse(
	@{$_MC->from_ics($self->c4_scraper_get(
	    'http://www.google.com/calendar/ical/' . $cal_id
		. '/public/basic.ics'
	    ))})) {

	if ($vevent->{'recurrence-id'}) {
	    $recurrences->{_recurrence_id($vevent, 'recurrence-id')} = 1;
	}
	next if $_D->is_date($vevent->{dtstart});
	next if ($vevent->{status} || '') eq 'CANCELLED';
	next unless ($vevent->{class} || 'PUBLIC') eq 'PUBLIC';

	foreach my $v (@{_explode_event($self, $vevent, $end)}) {
	    next if $v->{rrule} && $recurrences->{_recurrence_id($v)};
	    next if $_DT->compare($v->{dtstart}, $start) < 0;
	    push(@{$self->get('events')}, [
		{
		    map(($_ => $v->{$_}),
			qw(description dtend dtstart time_zone uid)),
		},
		{
		    display_name => $v->{summary},
		},
	    ]);
	}
    }
    return @{$self->get('events')} ? 1 : 0;
}

sub _recurrence_id {
    my($vevent, $date_field) = @_;
    return join('-',
        map($vevent->{$_}, qw(uid sequence), $date_field || 'dtstart'));
}

1;
