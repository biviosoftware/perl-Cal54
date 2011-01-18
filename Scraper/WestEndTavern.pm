# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::WestEndTavern;
use strict;
use Bivio::Base 'Bivio.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_M) = b_use('Type.Month');
my($_MONTHS) = {
    map((lc($_->get_name) => $_), $_M->get_list),
};

sub internal_import {
    my($self) = @_;
    my($text) = b_use('Bivio.HTMLCleaner')->new->clean_html(
	$self->c4_scraper_get($self->get('venue_list')
            ->get('calendar.Website.url')));
    my($current);
    my($state) = '';

    foreach my $line (split("\n", $$text)) {

	if ($_MONTHS->{lc($line)}) {
	    $current = {
		month => $_MONTHS->{lc($line)}->as_int,
		description => '',
	    };
	    $state = 'DAY';
	    next;
	}
	if ($state eq 'DAY' && $line =~ /^\d+$/
	    && $line >= 1 && $line <= 31) {
	    $current->{date} = join('/',
	        $current->{month},
	        $line,
		$self->internal_compute_year($current->{month}),
	    );
	    $state = 'SUMMARY';
	    next;
	}
	if ($state eq 'SUMMARY' && $line) {
	    _parse_summary_and_time($self, $current, $line);
	    $state = 'DESCRIPTION';
	    next;
	}
	if ($state eq 'DESCRIPTION' && $line eq '') {
	    push(@{$self->get('events')}, {
		time_zone => $self->get('time_zone'),
		map(($_ => $current->{$_}),
		    qw(summary description dtstart dtend)),
	    });
	    $current = {
		month => $current->{month},
		description => '',
	    };
	    $state = 'DAY';
	    next;
	}
	if ($state eq 'DESCRIPTION') {
	    $current->{description} .= $line . "\n";
	    next;
	}
    }
    return;
}

sub _parse_summary_and_time {
    my($self, $row, $str) = @_;
    my($summary, $time, $am) = $str =~ m,^(.*?)\,\s*(\d+)\s*(am|pm)$,i;
    b_die('invalid summary/time: ', $str)
	unless $time && $time >= 1 && $time <= 12;
    $row->{summary} = $summary;
    $row->{dtstart} = $self->internal_date_time(
	$row->{date} . ' ' . $time . $am);
    $row->{dtend} = $row->{dtstart};
    return;
}

1;
