# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::Boulderado;
use strict;
use Bivio::Base 'Bivio.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_DAYS) = {
    map((lc($_) => 1), $_DT->english_day_of_week_list),
};

sub internal_import {
    my($self) = @_;
    my($text) = b_use('Bivio.HTMLCleaner')->new->clean_html(
	$self->c4_scraper_get($self->get('venue_list')
            ->get('calendar.Website.url')));
    my($current);
    my($state) = 'TIME';

    foreach my $line (split("\n", $$text)) {

	if ($state eq 'TIME'
		&& $line =~ /music\s+([\d:]+)(a|p)m\-([\d:]+)(a|p)m/i) {
	    $current = {
		start_time => $1 . $2 . 'm',
		end_time => $3 . $4 . 'm',
		description => '',
	    };
	    $state = 'DATE';
	    next;
	}
	if ($state eq 'DATE' && $line =~ /^(\w*?),/ && $_DAYS->{lc($1)}) {
	    my($month, $day, $summary) =
		$line =~ m,\,\s*(\w+)\s+(\d+).*?\~\s*(.*)$,;
	    b_die($line) unless $summary;
	    $month = $_DT->english_month3_to_int($month);
	    my($date) = join('/', $month, $day,
	        $self->internal_compute_year($month));
	    $current->{dtstart} = $self->internal_date_time(
		$date . ' ' . $current->{start_time});
	    $current->{dtend} = $self->internal_date_time(
		$date . ' ' . $current->{end_time});
	    $current->{summary} = $summary;
	    $state = 'DESCRIPTION';
	    next;
	}
	if ($state eq 'DESCRIPTION' && $line eq '') {
	    $current->{description} =~ s/^\(|\)$//g;
	    push(@{$self->get('events')}, {
		time_zone => $self->get('time_zone'),
		map(($_ => $current->{$_}),
		    qw(summary description dtstart dtend)),
	    });
	    $current = {
		start_time => $current->{start_time},
		end_time => $current->{end_time},
		description => '',
	    };
	    $state = 'DATE';
	    next;
	}
	if ($state eq 'DESCRIPTION') {
	    $current->{description} .= $line . "\n";
	    next;
	}
    }
    return;
}

1;
