# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::RSS;
use strict;
use Bivio::Base 'Bivio.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_import {
    my($self) = @_;
    my($xml) = $self->internal_parse_xml(
	$self->get('venue_list')->get('calendar.Website.url'));
    my($cleaner) = b_use('Bivio.HTMLCleaner')->new;

    foreach my $item (@{$xml->{channel}->{item}}) {
	$item->{description} = ${$cleaner->clean_html(
	    \($item->{description}),
	    $item->{link},
	)};
	my($date) = _extract_date($self, $item->{description});
	my($start, $end, $ap) =
	    _extract_start_end($self, $item->{description});
	next unless $date && $ap;
	push(@{$self->get('events')}, {
	    summary => $item->{title},
	    description => $item->{description},
	    dtstart => $self->internal_date_time("$date $start$ap"),
	    dtend => $self->internal_date_time("$date $end$ap"),
	    time_zone => $self->get('time_zone'),
	    url => $item->{link},
	});
    }
    return;
}

sub _extract_date {
    my($self, $str) = @_;
    $str =~ m{(\d+/\d+/\d{4})};
    return $1;
}

sub _extract_start_end {
    my($self, $str) = @_;
    my($start, $end, $ap) = $str =~ /([\d:]+)\s*\-\s*([\d:]+)\s*((?:a|p)m)/i;
    return ($start, $end, $ap);
}

1;
