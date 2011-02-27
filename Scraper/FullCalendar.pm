# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::FullCalendar;
use strict;
use Bivio::Base 'Bivio.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');
my($_RE) = b_use('Cal54::Scraper::RegExp');

sub internal_import {
    my($self) = @_;
    my($start) = $_D->add_days($self->get('date_time'), -1);
    my($end) = $_D->add_months($start, 3);
    my($url) = $self->get('venue_list')->get('Website.url');
    $url .= '/'
	unless $url =~ m{/$};
    my($json) = $self->c4_scraper_get($url
        . 'layout/set/popup/content/view/events/(category)/0'
	. '?'
	. join('&',
	    '_=' . $_DT->to_unix($_DT->now) . '000',
	    'start=' . $_DT->to_unix($start),
	    'end=' . $_DT->to_unix($end)));
    my($cleaner) = b_use('Bivio.HTMLCleaner')->new;

    while ($$json =~ m{url\:\s+'([^']+)'}g) {
	my($event_url) = $1;
	_add_event($self, $event_url, $cleaner, $url);
    }
    return;
}

sub _add_event {
    my($self, $event_url, $cleaner, $url) = @_;
    my($html) = $self->c4_scraper_get($url
        . 'layout/set/modal/' . $event_url);
    my($str) = $cleaner->clean_html($html, $url);
    $$str =~ s{\bclose\{\d+\}}{}g;
    my($qr) = $_RE->eval_scraper_aux(
	'qr/(.*)?$day_name\s+$month\s+$day,\s+$year\s*\-\s*$time_ap\s*(?:\-\s*$time_ap)?(.*)$/s');
    my($summary, undef, $month, $day, $year, $start, $end, $desc) =
	$$str =~ $qr;

    unless ($start) {
	b_warn('parse failed: ', $str);
	next;
    }
    my($date) = join('/',
        $_RE->month_as_int($month),
	$day,
	$year);
    push(@{$self->get('events')}, {
	summary => $self->internal_clean($summary),
	description => $self->internal_clean($desc),
	time_zone => $self->get('time_zone'),
	dtstart => $self->internal_date_time($date . ' ' . $start),
	dtend => $end
	    ? $self->internal_date_time($date . ' ' . $end)
	    : undef,
    });
    return;
}

1;
