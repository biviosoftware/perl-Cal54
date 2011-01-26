# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::RegExp;
use strict;
use Bivio::Base 'Bivio.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_MONTHS) = {
    map((
	(lc($_->get_name) => $_->as_int),
	(lc(substr($_->get_name, 0, 3)), $_->as_int),
    ), b_use('Type.Month')->get_list),
};
my($_DAY_NAMES) = [
    map((lc($_), lc(substr($_, 0, 3))), $_DT->english_day_of_week_list),
];

sub internal_import {
    my($self) = @_;
    my($venue) = $self->get('venue_list')->get_model('Venue');
    b_die('venue missing scraper_aux: ', $venue)
	unless $venue->get('scraper_aux');
#TODO: parse scraper_aux before evaling to prevent malicious code
    _process_url($self, _eval_regexp($self, \($venue->get('scraper_aux'))),
        $self->get('venue_list')->get('calendar.Website.url'), {});
    return;
}

sub _add_field_values {
    my($self, $fields, $values) = @_;
    my(@v) = ($1, $2, $3, $4, $5, $6, $7, $8, $9);

    foreach my $f (@$fields) {
	my($str) = shift(@v);
	next unless defined($str) && length($str);
	next if $f eq 'save';
	$values->{$f} = $str;
    }
    return $values;
}

sub _clean {
    my($str) = @_;
    return $str unless $str;
    $str =~ s/\s+/ /g;
    $str=~ s/^\s+|\s+$//g;
    return $str;
}

sub _collect_data {
    my($self, $current) = @_;

    foreach my $v (values(%$current)) {
	next unless $v;
	$v =~ s/\{\d+\}//g;
    }
    my($rec) = {
	summary => _clean($current->{summary}),
	description => _clean($current->{description}),
	$current->{url} ? (url => $current->{url}) : (),
	dtstart => _date($self, 'start', $current),
	dtend => _date($self, 'end', $current),
    };
    $rec->{dtend} ||= $rec->{dtstart};
    return $rec;
}

sub _date {
    my($self, $type, $current) = @_;
    # month, day, year, start_time, end_time, start_time_pm, end_time_pm
    my($time) = $current->{$type . '_time'} || $current->{$type . '_time_pm'};
    return undef unless $time;

    unless ($time =~ /(a|p)m$/i) {
	b_die('time missing a/pm: ', $time)
	    unless $current->{$type . '_time_pm'};
	my($hour) = $time =~ /^(\d+)\:/;
	return undef unless $hour && $hour > 3 && $hour < 12;
	$time .= 'pm';
    }
    my($month);

    if ($current->{month}) {
	$month = $_MONTHS->{lc($current->{month})}
	    || b_die('invalid month value: ', $current->{month});
    }
    elsif ($current->{month_day}) {
	($month, $current->{day}) = split('/', $current->{month_day});
    }
    else {
	b_die('missing "month" or "month_day"');
    }
    my($date) = join('/',
        $month,
	$current->{day},
	$current->{year} || $self->internal_compute_year($month),
    );
    return $self->internal_date_time($date . ' ' . $time);
}

sub _day_name_regexp {
    my($regexp) = join('|', @$_DAY_NAMES);
    return qr/\b(${regexp})\b/i;
}

sub _eval_regexp {
    my($self, $cfg) = @_;
    my($year) = qr/\b(20[1-2][0-9])\b/;
    my($time_ap) = qr/\b([0,1]?[0-9](?:\:[0-5][0-9])?\s*(?:a|p)m)\b/i;
    my($time) = qr/\b([0,1]?[0-9]\:[0-5][0-9])\b/i;
    my($day_name) = _day_name_regexp();
    my($month) = _month_regexp();
    my($month_day) = qr{\b([0,1]?[0-9]/[0-3]?[0-9])\b};
    my($day) = qr/\b([1-3]?[0-9])(?:st|nd|rd|th)?\b/i;
    my($line) = qr/(.*?)\n/;
    my($description) = qr/(.*?)\n\n/;
    my($res) = eval($$cfg);
    b_die('eval failed: ', $@)
	if $@;
    return $res;
}

sub _month_regexp {
    my($regexp) = join('|', keys(%$_MONTHS));
    return qr/\b(${regexp})\b/i;
}

sub _process_url {
    my($self, $cfg, $url, $current) = @_;
    my($cleaner) = b_use('Bivio.HTMLCleaner')->new;
    my($text) = $cleaner->clean_html($self->c4_scraper_get($url));

    foreach my $info (@{$cfg->{global} || []}) {
	my($regexp, $args) = @$info;
	_add_field_values($self, $args->{fields}, $current)
	    if $$text =~ /$regexp/;
    }

    foreach my $info (@{$cfg->{repeat} || []}) {
	my($regexp, $args) = @$info;

	while ($$text =~ s/$regexp/_save_text($self, $args->{fields})/e) {
	    _add_field_values($self, $args->{fields}, $current);

	    if ($args->{follow_link}) {
		_process_url($self, $args->{follow_link},
		    $cleaner->get_link_for_text(
			$current->{link} || $current->{summary}),
		    $current);
	    }
	    if ($args->{summary_from_description} && $current->{description}) {
		($current->{summary}) = $current->{description} =~
		    $args->{summary_from_description};
	    }
	    $current->{url} ||= _url($self,
	        $cleaner->unsafe_get_link_for_text($current->{summary}))
		if $current->{summary};
	    push(@{$self->get('events')}, {
		time_zone => $self->get('time_zone'),
		%{_collect_data($self, $current)},
	    }) if $current->{summary};
	    delete($current->{summary});
	    delete($current->{description});
	    delete($current->{link});
	    delete($current->{url});
	}
    }
    return;
}

sub _save_text {
    my($self, $fields) = @_;
    my($str) = '';

    foreach my $i (0 .. scalar(@$fields) - 1) {
	next unless $fields->[$i] eq 'save';
	$str .= '$' . ($i + 1);
    }
    return $str ? eval('"' . $str . '"') : '';
}

sub _url {
    my($self, $page) = @_;
    return undef unless $page;
    return $page
	if $page =~ m{\://};
    $page =~ s{^/}{};
#TODO: change to stripped calendar url?
    return $self->get('venue_list')->get('Website.url') . '/' . $page;
}

1;
