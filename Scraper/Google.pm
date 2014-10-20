# Copyright (c) 2011 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::Scraper::Google;
use strict;
use Bivio::Base 'Scraper.ICalendar';
b_use('IO.Trace');

my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');
my($_JSON) = b_use('MIME.JSON');

sub internal_import {
    my($self) = @_;
    my($start) = $_D->add_days($self->get('date_time'), -1);
    my($end) = $_D->add_months($start, 6);
    my($html) = $self->c4_scraper_get(
	$self->get('scraper_list')->get('Website.url'));
    my($query) = $$html =~ m{www\.google\.com/calendar/embed\?([^"]+)"};
    b_die('failed to parse calendar url: ', $html)
	unless $query;
    my($found_src);

    while ($query =~ m{src=(.*?)(\&|")}g) {
	my($cal_id) = $1;
	$found_src = 1;
	next unless $self->parse_ics($self->c4_scraper_get(
	    'http://www.google.com/calendar/ical/' . $cal_id
		. '/public/basic.ics'), $start, $end);
	_add_event_urls($self, $cal_id, $start, $end);
    }
    b_die('missing src in query: ', $query)
	unless $found_src;
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
		'start-max='
		    . $_D->to_xml($_D->add_days($end, 1)) . 'T00:00:00',
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

    foreach my $event (@{$self->get('events')}) {
	next unless $event->{uid};
	my($uid) = delete($event->{uid});
	$uid =~ s/\@.*$//;
	$event->{url} = $url_by_id->{$uid . '-'
	    . $_DT->to_string($event->{dtstart})};

	unless ($event->{url}) {
	    $event->{summary} = undef;
	    _trace('missing url for uid: ', $uid, ' ', $event->{dtstart})
		if $_TRACE && $_D->compare($event->{dtstart}, $end) < 0;
	}
    }
    return;
}

1;
