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
	$line =~ s/^\s+|\s+$//g;

	if ($_MONTHS->{lc($line)}) {
	    $current = {
		month => $_MONTHS->{lc($line)}->as_int,
		description => '',
	    };
	    $state = 'MONTH';
	    next;
	}
	if ($state eq 'MONTH' && $line =~ /^\d+$/
	    && $line >= 1 && $line <= 31) {
	    $current->{day} = $line;
	    $state = 'DAY';
	    next;
	}
	if ($state eq 'DAY' && $line) {
	    _parse_title_and_time($self, $current, $line);
	    $state = 'DESCRIPTION';
	    next;
	}
	if ($state eq 'DESCRIPTION' && $line eq '') {
	    push(@{$self->get('events')}, {
		summary => $current->{title},
		description => $current->{description},
		time_zone => $self->get('time_zone'),
		dtstart => $current->{dtstart},
		dtend => $current->{dtend},
	    });
	    $current = {
		month => $current->{month},
		description => '',
	    };
	    $state = 'MONTH';
	    next;
	}
	if ($state eq 'DESCRIPTION') {
	    $current->{description} .= $line . "\n";
	    next;
	}
    }
    return;
}

sub _parse_title_and_time {
    my($self, $row, $str) = @_;
    my($title, $time, $am) = $str =~ m,^(.*?)\,\s*(\d+)\s*(am|pm)$,i;
    b_die('invalid title/time: ', $str)
	unless $time && $time >= 1 && $time <= 12;
    $row->{title} = $title;
    $row->{dtstart} = $self->internal_date_time(
	join('/', $row->{month}, $row->{day},
	     $self->internal_compute_year($row->{month}))
	. ' ' . $time . $am);
    $row->{dtend} = $row->{dtstart};
    return;
}

1;
