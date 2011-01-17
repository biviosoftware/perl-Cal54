# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::Chautauqua;
use strict;
use Bivio::Base 'Bivio.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');

# right now parsing upcoming events page
# alternatively, could parse three separate events pages:
# music and dance, films, forums & family events

sub internal_import {
    my($self) = @_;
    my($text) = b_use('Bivio.HTMLCleaner')->new->clean_html(
	$self->c4_scraper_get($self->get('venue_list')
            ->get('calendar.Website.url')));
    my($current) = {
	summary => '',
    };
    my($state) = 'DATE_TIME';

    foreach my $line (split("\n", $$text)) {
	$line =~ s/^\s+|\s+$//g;

	if ($state eq 'DATE_TIME') {
	    my($month, $day, $year, $time) =
		$line =~ /^\s*\w+\,\s+(\w+)\s+(\d+)\,\s+(\d+)\,\s+(([\d\:]+)\s*(a|p)m)/i;
	    if ($time) {
		$month = $_DT->english_month3_to_int($month);
		$current->{dtstart} = $self->internal_date_time(
		    join('/', $month, $day, $year) . ' ' . $time);
		$current->{dtend} = $current->{dtstart};
		$current->{description} = '';
		$state = 'NEXT_BLANK_LINE';
		next;
	    }
	    if ($line) {
		$current->{summary} .= ' ' . $line;
		next;
	    }
	    $current->{summary} = '';
	    next;
	}
	if ($state eq 'NEXT_BLANK_LINE') {
	    if ($line eq '') {
		$state = 'DESCRIPTION';
		next;
	    }
	}
	if ($state eq 'DESCRIPTION') {
	    if ($line eq '') {
		push(@{$self->get('events')}, {
		    time_zone => $self->get('time_zone'),
		    map(($_ => $current->{$_}),
			qw(summary description dtstart dtend)),
		});
		$current = {
		    summary => '',
		};
		$state = 'DATE_TIME';
		next;
	    }
	    $current->{description} .= $line;
	    next;
	}
    }
    return;
}

1;
