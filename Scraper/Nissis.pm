# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::Nissis;
use strict;
use Bivio::Base 'Bivio.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_DT) = b_use('Type.DateTime');
my($_HTML) = b_use('Bivio.HTML');
my($_S) = b_use('Type.String');

sub html_parser_end {
    my($self, $tag) = @_;
    return
	unless $tag eq 'a';
    my($fields) = $self->[$_IDI];
    $fields->{in_a} = 0;
    return;
}

sub html_parser_start {
    my($self, $tag, $attr) = @_;
    my($fields) = $self->[$_IDI];
    push(@{$fields->{items}}, $fields->{item} = {})
	if ($attr->{class} || '') eq 'calmainact';
    if ($tag eq 'a' && $fields->{item}) {
	push(@{$fields->{item}->{links} ||= []}, $self->abs_uri($attr->{href}));
	$fields->{in_a} = 1;
    }
    return;
}

sub html_parser_text {
    my($self, $text) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{item}->{desc} .= $text . ' ';
    $fields->{item}->{title} = $text . ' '
	if $fields->{in_a} && !$fields->{item}->{title};
    return;
}

sub internal_import {
    my($self) = @_;
    $self->[$_IDI] = {};
    foreach my $uri (_do_main($self)) {
	$self->internal_catch(
	    sub {_do_month($self, $uri, $self->c4_scraper_get($uri))},
	);
    }
    return;
}

sub _do_cell {
    my($self, $text) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{items} = [];
    # Sometimes there are blank links; This will confuse html_parser_start
    $text =~ s{<a\b^[^>]+>(?:\s+|<br\s*/?>)</a>}{}is;
    $fields->{in_a} = undef;
    $fields->{item} = undef;
    $self->parse_html(\$text);
    return @{$fields->{items}};
}

sub _do_cells {
    my($self, $content) = @_;
    return map(
	$_ =~ m{>\s*(\d+)\s*<.*CalContent}is ? [
	    $1 + 0,
	    $_ =~ m{name="CalContent.*?-->(.+?)<!--\s*InstanceEnd}is,
	] : (),
	split(m{name="CalNumber}is, $$content),
    );
}

sub _do_desc {
    my($self, $text) = @_;
    return undef
	unless $text;
    $text = ${$_S->canonicalize_newlines(
	$_S->canonicalize_charset(
	    $_HTML->unescape($text),
	),
    )};
    $text =~ s/\s+/ /sg;
    return undef
	unless $text =~ /\S/ && $text !~ /\b(?:private\s+(?:party|event)|tba|closed for)\b/is;
    return $text;
}

sub _do_main {
    my($self) = @_;
    return map(
	$_ =~ /lmcalendar/ ? () : $self->abs_uri($_),
	${$self->c4_scraper_get($self->get('venue_list')->get('calendar.Website.url'))}
	    =~ /href="?(lmcal[^"\s]+\.html)/isg,
    );
}

sub _do_month {
    my($self, $uri, $content) = @_;
    my($year, $mon) = _do_year_mon(
	$self,
	$$content =~ m{name="CalendarTitle.*?>([^<]+)}is,
    );
    my($date_time) = $self->get('date_time');
    my($extra) = undef;
    my($events) = $self->get('events');
    my($append_extra) = sub {
	my($prev) = $events->[$#$events];
	return
	    unless $prev && $extra;
	$prev->[0]->{description}
	    = _join($prev->[0]->{description}, $extra->{title}, $extra->{desc});
	$extra = undef;
    };
    foreach my $cell (_do_cells($self, $content)) {
	my($mday, $text) = @$cell;
	$extra = undef;
	$self->put(last_text => $text);
	foreach my $item (_do_cell($self, $text)) {
	    my($desc) = $item->{desc};
	    # Clean phone number from desc, because may run into time
	    $desc =~ s/2757(?=\d)//
		if $desc;
	    my($start, $end) = $desc ? _do_times($self, \$desc, $year, $mon, $mday) : ();
	    $end = $_DT->add_seconds($end, 12 * 60 * 60)
		if $start && $end && $_DT->is_greater_than($start, $end);
	    $desc = _do_desc($self, $desc);
	    my($title) = _do_desc($self, $item->{title});
	    next
		unless $desc || $title;
	    ($title, $desc) = ($desc, '')
		unless $title;
	    $append_extra->()
		if $item->{links};
	    unless ($start) {
		$extra ||= {};
		$extra->{desc} = _join($extra->{desc}, $desc);
		$extra->{title} = _join($extra->{title}, $title);
		$extra->{url} ||= ($item->{links} || [])->[0];
		next;
	    }
  	    push(
		@$events,
		[
		    {
			dtstart => $start,
			dtend => $end || $start,
			description => _join($extra->{desc}, $desc),
			url => ($extra || {})->{url} || ($item->{links} || [])->[0] || $uri,
			modified_date_time => $date_time,
			time_zone => $self->get('time_zone'),
		    },
		    {
			display_name => _join($extra->{title}, $title),
		    },
		],
	    );
	    $extra = undef;
	}
	$append_extra->();
    }
    return;
}

sub _do_time {
    my($self, $year, $mon, $mday, $time) = @_;
    return undef
	unless defined($time);
    my($hour, $min) = $time =~ m{(\d+)}g;
    $hour += 12
	unless $hour >= 12;
    # Sometimes people typo; this is just a guess.
    $mday =~ s/^\d(?=\d\d)//s;
    return $self->get('time_zone')->date_time_to_utc(
	$_DT->from_parts_or_die(0, $min, $hour, $mday, $mon, $year),
    );
}

sub _do_times {
    my($self, $desc, @date) = @_;
    return map(_do_time($self, @date, $_), $1, $2)
	if $$desc =~ s{(\d{1,2}:\d{1,2})\s*-\s*(\d{1,2}:\d{1,2})}{}is;
    return map(_do_time($self, @date, $_), $1)
	if $$desc =~ m{\b(\d{1,2}\:\d{1,2})\b};
    return map(_do_time($self, @date, $_), "$1:00")
	if $$desc =~ m{\b(\d{1,2})?:\s*p\.?m\.\?\b}is;
    return;
}

sub _do_year_mon {
    my($self, $value) = @_;
    b_die($value, ': could not find MONTH Year')
	unless $self->strip_tags_and_whitespace($value) =~ m{([a-z]+)\s+(20\d+)}is;
    return ($2, $_DT->english_month_to_int(substr($1, 0, 3)));
}

sub _join {
    return join(' ', grep($_, @_)) || '';
}

1;
