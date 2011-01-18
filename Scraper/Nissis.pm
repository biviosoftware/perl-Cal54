# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::Nissis;
use strict;
use Bivio::Base 'Bivio.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_M) = b_use('Type.Month');
my($_MONTHS) = {
    map((lc($_->get_name) => $_), $_M->get_list),
};

sub internal_import {
    my($self) = @_;
    my($cleaner) = b_use('Bivio.HTMLCleaner')->new;
    my($text) = $cleaner->clean_html(
	$self->c4_scraper_get($self->get('venue_list')
            ->get('calendar.Website.url')));
    my($state) = 'CALENDAR';

    foreach my $line (split("\n", $$text)) {
	if ($line eq 'CALENDAR') {
	    $state = 'MONTH';
	    next;
	}
	if ($state eq 'MONTH' && $line =~ /^(\w+)\b/) {
	    _parse_detail($self, $cleaner->get_link_for_text($line))
		if $_MONTHS->{lc($1)};
	}
    }
    return;
}

sub _parse_detail {
    my($self, $page) = @_;
    my($cleaner) = b_use('Bivio.HTMLCleaner')->new;
    my($text) = $cleaner->clean_html(
	$self->c4_scraper_get(_url($self, $page)));
    my($current_year) = $_D->get_parts($self->get('date_time'), 'year');
    my($state) = 'MONTH';
    my($current);

    foreach my $line (split("\n", $$text)) {
	if ($state eq 'MONTH' && $line =~ /^(\w+) (\d+)\b/) {
	    my($month, $year) = ($1, $2);
	    next unless $_MONTHS->{lc($month)}
		&& $year >= $current_year
		    && $year <= $current_year + 1;
	    $current = {
		month => $_MONTHS->{lc($month)}->as_int,
		year => $year,
	    };
	    $state = 'DAY';
	    next;
	}
	if ($state eq 'NOT_NUMBER_DESCRIPTION') {
	    if ($line =~ /^\d+$/ || $line =~ /^Gathering Place/) {
		push(@{$self->get('events')}, {
		    time_zone => $self->get('time_zone'),
		    map(($_ => $current->{$_}),
			qw(summary description dtstart dtend url)),
		}) if $current->{description} && $current->{summary};
		$current = {
		    month => $current->{month},
		    year => $current->{year},
		};
		$state = 'DAY';
		# fall through
	    }
	    elsif ($line) {
		$current->{description} .= $line . ' ';

		unless ($current->{summary}) {
		    my($url) = $cleaner->unsafe_get_link_for_text($line);
		    if($url && $url !~ m,/,) {
			$current->{url} = _url($self, $url);
			$current->{summary} = $line;
		    }
		}
	    }
	}
	if ($state eq 'DAY' && $line =~ /^(\d+)$/) {
	    my($day) = $1;
	    next unless $day >=1 && $day <= 31;
	    $current->{date} = join('/',
	        $current->{month},
	        $day,
		$current->{year},
	    );
	    $state = 'TIME_PM';
	    next;
	}
	if ($state eq 'TIME_PM') {
	    next unless $line;
	    if ($line =~ /^([\d\:]+)\s*\-\s*([\d\:]+)\b$/) {
		my($start, $end) = ($1, $2);
		$current->{dtstart} = $self->internal_date_time(
		    $current->{date} . ' ' . $start . 'PM');
		$current->{dtend} = $self->internal_date_time(
		    $current->{date} . ' ' . $end . 'PM');
		if ($_D->compare($current->{dtstart}, $current->{dtend}) > 0) {
		    $current->{dtend} = $_D->add_days(
			$self->internal_date_time(
			    $current->{date} . ' ' . $end . 'AM'), 1);
		}
		$current->{description} = '';
		$state = 'NOT_NUMBER_DESCRIPTION';
		next;
	    }
	    $state = 'DAY';
	    next;
	}
    }
    return;
}

sub _url {
    my($self, $page) = @_;
    b_die('invalid page: ', $page)
	if $page =~ m,^/,;
    return $self->get('venue_list')->get('Website.url') . '/' . $page;
}

1;
