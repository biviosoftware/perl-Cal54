# Copyright (c) 2011 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::Scraper::RegExp;
use strict;
use Bivio::Base 'Bivio.Scraper';
b_use('IO.Trace');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_MONTHS) = {
    map((
	(lc($_->get_name) => $_->as_int),
	(lc(substr($_->get_name, 0, 3)), $_->as_int),
	(lc(substr($_->get_name, 0, 4)), $_->as_int),
    ), b_use('Type.Month')->get_list),
};
my($_DAY_NAMES) = [
    map((lc($_), lc(substr($_, 0, 3)), lc(substr($_, 0, 4))),
	$_DT->english_day_of_week_list),
];
our($_TRACE);

sub eval_scraper_aux {
    my($self, $aux) = @_;
    $aux ||= $self->get('scraper_list')->get('Scraper.scraper_aux')
	|| b_die('scraper missing scraper_aux');
    my($date) = qr{\b(\d+/\d+/\d{4})\b};
    my($year) = qr/\b(20[1-2][0-9])\b/;
    my($time_ap) = qr/\b((?:[0,1]?[0-9](?:\:[0-5][0-9])?\s*(?:a|p)\.?m\.?)|noon|midnight)/i;
    my($time) = qr/\b((?:[0,1]?[0-9](?:\:[0-5][0-9])?)|noon|midnight)\b/i;
    my($time_span) = qr/$time\s*\-\s*$time_ap/i;
    my($day_name) = _day_name_regexp();
    my($month) = _month_regexp();
    my($month_day) = qr{\b([0,1]?[0-9]/[0-3]?[0-9])\b};
    my($day) = qr/\b([0-3]?[0-9])(?:st|nd|rd|th)?\b/i;
    my($line) = qr/([^\n]+)\n/;
    my($res) = eval($aux);
    b_die('eval failed: ', $@)
	if $@;
    return $res;
}

sub extract_once_fields {
    my($self, $cfg, $text, $current, $op) = @_;

    if ($cfg->{default_values}) {
	foreach my $f (keys(%{$cfg->{default_values}})) {
	    $current->{$f} = $cfg->{default_values}->{$f};
	}
    }

    foreach my $info (@{$cfg->{once} || $cfg->{global} || []}) {
	my($regexp, $args) = @$info;
	next unless $$text =~ /$regexp/;
	_add_field_values($self, $args->{fields}, $current);
	$op->($self, $args, $current)
	    if $op;
    }
    return;
}

sub extract_repeat_fields {
    my($self, $cfg, $text, $current, $op) = @_;

    foreach my $info (@{$cfg->{repeat} || []}) {
	my($regexp, $args) = @$info;
	my($size) = length($$text);

	while ($$text =~ s/$regexp/_save_text($self, $args->{fields})/e) {

	    if (length($$text) == $size) {
		b_warn('no text change on repeat');
		last;
	    }
	    $size = length($$text);
	    _add_field_values($self, $args->{fields}, $current);
	    $op->($self, $args, $current);
	}
    }
    return;
}

sub internal_collect_data {
    my($self, $current) = @_;

    foreach my $v (values(%$current)) {
	next unless $v;
	$v =~ s/\{\d+\}//g;
    }
    my($start_time, $end_time) =
	$self->internal_parse_times($current, $self->get_scraper_aux);
    my($rec) = {
	summary => _clean($current->{summary}),
	description => _clean($current->{description}),
	url => $current->{url}
	    || $self->get('scraper_list')->get('Website.url'),
	dtstart => _date($self, $current, $start_time),
	dtend => _date($self, $current, $end_time),
	location => $current->{location},
    };
    return $rec;
}

sub internal_import {
    my($self) = @_;
    _process_url($self, $self->get_scraper_aux,
        $self->get('scraper_list')->get('Website.url'), {});
    return;
}

sub internal_parse_times {
    my($self, $current, $aux) = @_;
    my($start, $start_ap) = _normalize_time($self, 'start', $current);
    return undef unless $start;
    my($end, $end_ap) = _normalize_time($self, 'end', $current);
    my($start_hour) = $start =~ /^(\d+)/;

    if ($aux->{max_start_hour}) {
	$start_ap = $start_hour > $aux->{max_start_hour}
	    ? 'am' : 'pm';
    }

    unless ($start_ap) {
	b_die('missing start time am/pm: ', $current)
	    unless $end_ap;
	my($end_hour) = $end =~ /^(\d+)/;
	b_die('time missing start or end hour: ', $current)
	    unless $end_hour && $start_hour;
	$start_ap = ($start_hour > $end_hour)
	    || ($end_hour eq '12' && $start_hour ne '12')
		? ($end_ap eq 'pm' ? 'am' : 'pm')
		: $end_ap;
    }
    return (
	$start . $start_ap,
	$end
	    ? ($end . $end_ap)
	    : undef
    );
}

sub month_as_int {
    my($self, $name) = @_;
    return $_MONTHS->{lc($name)}
	|| b_die('invalid month value: ', $name);
}

sub pre_parse_html {
    my($self, $cfg, $html) = @_;
    return
	unless $cfg->{pre_parse_html};
    $cfg->{pre_parse_html}->($html);
    return;
}

sub _add_field_values {
    my($self, $fields, $values) = @_;
    my(@v) = ($1, $2, $3, $4, $5, $6, $7, $8, $9);

    foreach my $f (@$fields) {
	b_die('invalid field: ', $f)
	    if ref($f);
	my($str) = shift(@v);
	next unless defined($str) && length($str);
	next if $f eq 'save';
	$values->{$f} = $str;
	_trace($f, ' --> ', $str) if $_TRACE;
    }
    return $values;
}

sub _clean {
    my($str) = @_;
    return $str unless $str;
    $str =~ s/\s+/ /g;
    $str=~ s/^\s+|\s+$//g;
    $str =~ s/^[^A-Z0-9"]+//i;;
    return $str;
}

sub _date {
    my($self, $current, $time) = @_;
    return undef
	unless $time;
    my($month);

    if ($current->{date}) {
    }
    elsif ($current->{month}) {
	$month = $self->month_as_int($current->{month});
    }
    elsif ($current->{month_day}) {
	($month, $current->{day}) = split('/', $current->{month_day});
    }
    else {
	_trace('missing "month" or "month_day": ', $current) if $_TRACE;
	return undef;
    }
    return undef
	unless $current->{date} || $current->{day};
    my($date) = $current->{date} || join('/',
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

sub _fixup_url {
    my($self, $current, $cleaner, $url) = @_;

    if ($current->{url}) {
	$current->{url} = $cleaner->get_link_for_text($current->{url})
	    if $current->{url} =~ /\{/;
    }
    elsif ($current->{summary}) {
	$current->{url} ||=
	    $cleaner->unsafe_get_link_for_text($current->{summary})
	    || $url;
    }
    return;
}

sub _follow_link {
    my($self, $current, $cleaner, $cfg) = @_;
    my($url) = $cleaner->unsafe_get_link_for_text(
	$current->{link} || $current->{summary});

    if ($url) {
	_process_url($self, $cfg, $url, $current);
    }
    return;
}

sub _month_regexp {
    my($regexp) = join('|', keys(%$_MONTHS));
    return qr/\b(${regexp})\b/i;
}

sub _normalize_time {
    my($self, $type, $current) = @_;
    my($time) = $current->{"${type}_time"} || $current->{"${type}_time_pm"};
    return undef unless $time;

    if (lc($time) eq 'midnight') {
	return qw(12 am);
    }
    elsif (lc($time) eq 'noon') {
	return qw(12 pm);
    }
    elsif ($time =~ /(a|p)/i) {
	my($ap) = $1;
	$time =~ s/\s*(a|p).*$//i;
	return ($time, lc($ap) . 'm');
    }
    elsif ($current->{"${type}_time_pm"}) {
	return ($time, $time =~ /^12/ ? 'am' : 'pm');
    }
    return ($time, '');
}

sub _process_url {
    my($self, $cfg, $url, $current) = @_;
    my($html) = $self->c4_scraper_get($url);
    $self->pre_parse_html($cfg, $html);
    my($cleaner) = b_use('Bivio.HTMLCleaner')->new;
    my($text) = $cleaner->clean_html($html, $url);
    $self->extract_once_fields($cfg, $text, $current, sub {
        my($self, $args, $current) = @_;				   
	_fixup_url($self, $current, $cleaner, $url);
	_follow_link($self, $current, $cleaner, $args->{follow_link})
	    if $args->{follow_link};
	return;
    });
    my($once) = {%$current};
    $self->extract_repeat_fields($cfg, $text, $current, sub {
        my($self, $args, $current) = @_;
	if ($args->{summary_from_description} && $current->{description}) {
	    ($current->{summary}) = $current->{description} =~
		$args->{summary_from_description};
	}
	_fixup_url($self, $current, $cleaner, $url);
	_follow_link($self, $current, $cleaner, $args->{follow_link})
	    if $args->{follow_link};

	if ($current->{summary}) {
	    push(@{$self->get('events')}, 
	        $self->internal_collect_data($current));
	}

	foreach my $field (keys(%$current)) {
	    next if $field eq 'month';
	    $current->{$field} = $once->{$field};
	}
	return;
    });

    if ($cfg->{pager} && --$cfg->{pager}->{page_count} > 0) {
	my($regexp) = $cfg->{pager}->{link};
	my($link) = $$text =~ /$regexp/;
	_process_url($self, $cfg, $cleaner->get_link_for_text($link), {})
	    if $link;
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

1;
