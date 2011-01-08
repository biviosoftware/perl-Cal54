# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::Nissis;
use strict;
use Bivio::Base 'HTML.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_A) = b_use('IO.Alert');
my($_DT) = b_use('Type.DateTime');
my($_F) = b_use('IO.File');
my($_FP) = b_use('Type.FilePath');
my($_IS_TEST) = b_use('IO.Config')->is_test;
my($_L) = b_use('IO.Log');
my($_HTML) = b_use('Bivio.HTML');
my($_S) = b_use('Type.String');
#TODO: Make a RowTag
my($_TZ) = b_use('Type.TimeZone')->AMERICA_DENVER;
my($_CE) = b_use('Model.CalendarEvent');
my($_T) = b_use('Agent.Task');

sub do_all {
    my($self, $venue_list) = @_;
    my($date_time) = $_DT->now;
    $venue_list->do_rows(
	sub {
	    my($it) = @_;
	    return 1
		unless $it->get('scraper_type')->eq_nissis;
	    $_A->reset_warn_counter;
	    b_info($self->do_one($it, $date_time));
	    return 1;
	},
    );
    return;
}

sub do_one {
    my($proto, $venue_list, $date_time) = @_;
    my($self) = $proto->new({req => $venue_list->req});
    my($fields) = $self->[$_IDI] = {
	venue_list => $venue_list,
        log_stamp => $_DT->to_file_name($date_time),
	date_time => $date_time,
	log_index => 1,
	events => [],
	failures => 0,
	tz => $_TZ,
    };
    $self->req->with_realm(
	$venue_list->get('Venue.venue_id'),
	sub {
	    return _catch(
		$self,
		sub {
		    _do($self);
		    _update($self);
		    return;
		},
	    );
	},
    );
    return b_debug $venue_list->get_model('RealmOwner')->as_string
	. ': '
	. @{$fields->{events}}
	. ' events and '
	. $fields->{failures}
	. ' failures';
}

sub get_request {
    return shift->get('req');
}

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

sub _catch {
    my($self, $op) = @_;
    return
	unless my $die = b_catch($op);
    my($fields) = $self->[$_IDI];
    _log(
	$self,
	\(join(
	    "\n",
	    $die->as_string,
	    $fields->{last_text} || '',
	    $self->unsafe_get('last_uri') || '',
	    $fields->{last_log} || '',
	    $die->get_or_default('stack', ''),
	)),
	'.err',
    );
    $fields->{failures}++;
    return;
}

sub _do {
    my($self) = @_;
    foreach my $uri (_do_main($self)) {
	_catch(
	    $self,
	    sub {_do_month($self, $uri, _get($self, $uri))},
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
    my($fields) = $self->[$_IDI];
    return map(
	$_ =~ /lmcalendar/ ? () : $self->abs_uri($_),
	${_get($self, $fields->{venue_list}->get('calendar.Website.url'))}
	    =~ /href="?(lmcal[^"\s]+\.html)/isg,
    );
}

sub _do_month {
    my($self, $uri, $content) = @_;
    my($year, $mon) = _do_year_mon(
	$self,
	$$content =~ m{name="CalendarTitle.*?>([^<]+)}is,
    );
    my($fields) = $self->[$_IDI];
    my($date_time) = $fields->{date_time};
    my($extra) = undef;
    my($append_extra) = sub {
	my($prev) = $fields->{events}->[$#{$fields->{events}}];
	return
	    unless $prev && $extra;
b_info($prev);
b_debug	$prev->[0]->{description}
	    = _join($prev->[0]->{description}, $extra->{title}, $extra->{desc});
	$extra = undef;
    };
    foreach my $cell (_do_cells($self, $content)) {
	my($mday, $text) = @$cell;
	$extra = undef;
	$fields->{last_text} = $text;
	foreach my $item (_do_cell($self, $text)) {
	    my($desc) = $item->{desc};
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
		@{$fields->{events}},
		[
		    {
			dtstart => $start,
			dtend => $end || $start,
			description => _join($extra->{desc}, $desc),
			url => ($extra || {})->{url} || ($item->{links} || [])->[0] || $uri,
			modified_date_time => $date_time,
#TODO: Do not hardwire
			time_zone => $_TZ,
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
    my($fields) = $self->[$_IDI];
    my($hour, $min) = $time =~ m{(\d+)}g;
    $hour += 12
	unless $hour >= 12;
    return $fields->{tz}->date_time_to_utc(
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

sub _get {
    my($self, $uri) = @_;
    my($log) = _log($self);
    return $self->extract_content($self->http_get($uri, $log))
	unless $_IS_TEST && -f $log;
    $self->put(last_uri => $self->abs_uri($uri));
    return $self->read_file($log)
}

sub _join {
    return join(' ', grep($_, @_)) || '';
}

sub _log {
    my($self, $content, $suffix) = @_;
    $suffix ||= '.html';
    my($fields) = $self->[$_IDI];
    my($file) = $_L->file_name(
	$_FP->join(
	    $self->simple_package_name,
	    $fields->{log_stamp},
	    $fields->{venue_list}->get('Venue.venue_id'),
	    sprintf('%04d', $fields->{log_index}++) . $suffix,
	),
	$self->req,
    );
    $fields->{last_log} = $file;
    return $file
	unless defined($content);
    $_F->write($file, $content);
    return;
}

sub _update {
    my($self) = @_;
    my($ce) = $_CE->new($self->req);
    my($fields) = $self->[$_IDI];
    my($date_time) = $fields->{date_time};
    foreach my $event (@{$fields->{events}}) {
	unless ($ce->unsafe_load({dtstart => $event->[0]->{dtstart}})) {
	    $ce->create_realm(@$event);
	    next;
	}
	if ($_DT->is_equal($ce->get('modified_date_time'), $date_time)) {
	    b_warn($event, ': duplicate dtstart just inserted: ', $ce->get_shallow_copy);
	    next;
	}
	$ce->update($event->[0]);
	$ce->new_other('RealmOwner')
	    ->unauth_load_or_die({realm_id => $ce->get('calendar_event_id')})
	    ->update($event->[1]);
    }
    $_T->commit($self->req);
    return;
}

1;
