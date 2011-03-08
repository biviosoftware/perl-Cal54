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

sub eval_scraper_aux {
    my($self, $aux) = @_;
    $aux ||= $self->get('scraper_list')->get('Scraper.scraper_aux')
	|| b_die('scraper missing scraper_aux');
    my($date) = qr{\b(\d+/\d+/\d{4})\b};
    my($year) = qr/\b(20[1-2][0-9])\b/;
    my($time_ap) = qr/\b([0,1]?[0-9](?:\:[0-5][0-9])?\s*(?:a|p)\.?m\.?)\b/i;
    my($time) = qr/\b([0,1]?[0-9](?:\:[0-5][0-9])?)\b/i;
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
    my($self, $cfg, $text, $current) = @_;

    foreach my $info (@{$cfg->{once} || $cfg->{global} || []}) {
	my($regexp, $args) = @$info;
	_add_field_values($self, $args->{fields}, $current)
	    if $$text =~ /$regexp/;
    }
    return;
}

sub internal_collect_data {
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
    return $rec;
}

sub internal_import {
    my($self) = @_;
    _process_url($self, $self->get_scraper_aux,
        $self->get('scraper_list')->get('Website.url'), {});
    return;
}

sub month_as_int {
    my($self, $name) = @_;
    return $_MONTHS->{lc($name)}
	|| b_die('invalid month value: ', $name);
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

sub _date {
    my($self, $type, $current) = @_;
    # month, day, year, start_time, end_time, start_time_pm, end_time_pm
    my($time) = $current->{$type . '_time'} || $current->{$type . '_time_pm'};
    return undef unless $time;

    unless ($time =~ /(a|p)\.?m\.?$/i) {
	b_die('time missing a/pm: ', $time, ' ', $current)
	    unless $current->{$type . '_time_pm'};
	my($hour) = $time =~ /^(\d+)/;
	return undef unless $hour && $hour > 3 && $hour < 12;
	$time .= 'pm';
    }
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
	b_die('missing "month" or "month_day": ', $current);
    }
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

sub _month_regexp {
    my($regexp) = join('|', keys(%$_MONTHS));
    return qr/\b(${regexp})\b/i;
}

sub _process_url {
    my($self, $cfg, $url, $current) = @_;
    my($cleaner) = b_use('Bivio.HTMLCleaner')->new;
    my($text) = $cleaner->clean_html($self->c4_scraper_get($url), $url);
    $self->extract_once_fields($cfg, $text, $current);

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

	    if ($args->{follow_link}) {
		my($url) = $cleaner->unsafe_get_link_for_text(
		    $current->{link} || $current->{summary});

		if ($url) {
		    _process_url($self, $args->{follow_link}, $url, $current);
		    $current->{url} ||= $url;
		}
	    }
	    if ($args->{summary_from_description} && $current->{description}) {
		($current->{summary}) = $current->{description} =~
		    $args->{summary_from_description};
	    }
	    if ($current->{url}) {
		$current->{url} = $cleaner->get_link_for_text(
		    $current->{url})
		    if $current->{url} =~ /\{/;
	    }
	    else {
		$current->{url} =
		    $cleaner->unsafe_get_link_for_text($current->{summary})
		    if $current->{summary};
	    }
	    push(@{$self->get('events')}, 
		$self->internal_collect_data($current))
		if $current->{summary};
	    delete($current->{summary});
	    delete($current->{description});
	    delete($current->{link});
	    delete($current->{url});
	}
    }

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
