# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::FoxTheatre;
use strict;
use Bivio::Base 'Bivio.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_import {
    my($self) = @_;
    my($parser) = b_use('Bivio.HTMLCleaner')->new;
    my($text) = $parser->clean_html(
	$self->c4_scraper_get($self->get('venue_list')
            ->get('calendar.Website.url')));
    my($state) = 'EVENTS';

    foreach my $line (split("\n", $$text)) {
	$line =~ s/^\s+|\s+$//g;

	if ($state eq 'EVENTS' && $line eq 'Events') {
	    $state = 'NEWLINE';
	    next;
	}
	if ($state eq 'NEWLINE') {
	    if ($line) {
		$state = 'EVENTS';
	    }
	    else {
		$state = 'DATE';
	    }
	    next;
	}
	if ($state eq 'DATE') {
	    last if ! $line && @{$self->get('events')};
	    next unless $line;
	    my($month, $day, $summary) = $line =~ m,^(\d+)/(\d+)\s+(.*?)\s*$,;
	    b_die($line) unless $summary;
	    my($start_time, $description, $url) =
		_parse_detail($self, $parser->get_link_for_text($line));
	    next unless $url;
	    my($event) = {
		time_zone => $self->get('time_zone'),
		summary => $summary,
		dtstart => $self->internal_date_time(
		    join('/',
			 $month,
			 $day,
			 $self->internal_compute_year($month),
		    ) . ' ' . $start_time),
		description => $description,
		url => $url,
	    };
	    $event->{dtend} = $event->{dtstart};
	    push(@{$self->get('events')}, $event);
	}
    }
    return;
}

sub _parse_detail {
    my($self, $url) = @_;
    $url = $url =~ '/'
	? $self->get('venue_list')->get('Website.url') . '/' . $url
	: $url;
    my($text) = b_use('Bivio.HTMLCleaner')->new
	->clean_html($self->c4_scraper_get($url));
    my($state) = 'TIME';
    my($time, $description);

    foreach my $line (split("\n", $$text)) {
	$line =~ s/^\s+|\s+$//g;

	if ($state eq 'TIME' && $line =~ /show\:\s+([\d\:]+)\s*(a|p)m/i) {
	    $time = uc($1 . ' ' . $2 . 'M');
	    $state = 'ABOUT';
	    next;
	}
	if ($state eq 'ABOUT' && $line =~ /about this show/i) {
	    $state = 'DESCRIPTION';
	    $description = '';
	    next;
	}
	if ($state eq 'DESCRIPTION') {
	    $description .= ' ' . $line;
	    next;
	}
    }
    return unless $time;
    return ($time, $description, $url);
}

1;
