# Copyright (c) 2010-2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::HomeList;
use strict;
use Bivio::Base 'Model.CalendarEventList';

use URI ();
my($_IDI) = __PACKAGE__->instance_data_index;
my($_DEFAULT_TZ) = b_use('Type.TimeZone')->get_default;
my($_DT) = b_use('Type.DateTime');
my($_HFDT) = b_use('HTMLFormat.DateTime');
my($_HTML) = b_use('Bivio.HTML');
my($_TS) = b_use('Type.String');
my($_S) = b_use('Bivio.Search');
my($_VL) = b_use('Model.VenueList');
my($_D) = b_use('Type.Date');
my($_UA) = b_use('Type.UserAgent');
my($_THIS_DETAIL) = b_use('Biz.QueryType')->THIS_DETAIL;
my($_HIDE_ROWS_QUERY) = <<"EOF";
    NOT EXISTS (
	SELECT primary_id FROM row_tag_t
	WHERE row_tag_t.primary_id = calendar_event_t.calendar_event_id
	AND row_tag_t.key = @{[b_use('Type.RowTagKey')->C4_HIDDEN_CALENDAR_EVENT->as_sql_param]}
	AND row_tag_t.value = '1'
    )
EOF

sub EXCLUDE_HIDDEN_ROWS {
    return 1;
}

sub PAGE_SIZE {
    # return b_use('Widget.IfMobile')->is_mobile(shift->req) ? 20 : 50;
    return 20;
}

sub c4_description {
    my($self) = @_;
    return $self->c4_has_cursor
	? $self->get('excerpt')
	: q{The complete calendar of events, activities, fun things to do for Boulder and Denver, CO.};
}

sub c4_first_date {
    return shift->[$_IDI]->{first_date};
}

sub c4_format_uri {
    my($self) = @_;
    my($chc) = $self->c4_has_cursor;
    return $self->req->format_uri({
	$chc && $self->c4_noarchive
	    ? (seo_uri_prefix => _seo_prefix_value($self))
	    : (),
	path_info => undef,
	task_id => 'C4_HOME_LIST',
	query => $chc ? {
	    'ListQuery.this' => $self->get('CalendarEvent.calendar_event_id'),
	} : undef,
    });
}

sub c4_has_cursor {
    my($self) = @_;
    return $self->has_cursor || $self->c4_has_this ? 1 : 0;
}

sub c4_has_this {
    my($self) = @_;
    return $self->get_query->unsafe_get('this') && $self->set_cursor_or_die(0) ? 1 : 0;
}

sub c4_noarchive {
    return shift->[$_IDI]->{is_robot_search};
}

sub c4_title {
    my($self) = @_;
    return $self->c4_has_cursor
	? join(' ', $self->get(qw(RealmOwner.display_name month_day start_end_am_pm)))
	: b_use('FacadeComponent.Text')->get_value('c4_home_title', $self->req);
}

sub execute {
    my($proto, $req) = @_;
    my($self) = shift->new($req);
    my($query) = $self->parse_query_from_request;
    my($this) = $query->unsafe_get('this');
    if ($this) {
	if ($self->unsafe_load_this($query)) {
	    # don't let search engines revisit expired events
	    b_die('NOT_FOUND', 'expired event')
		if $_DT->is_greater_than(
		    $_DEFAULT_TZ->date_time_from_utc($_DT->now),
		    $self->get('dtend_tz'),
		);
	    return;
	}
	else {
	    b_die('NOT_FOUND', 'event not found');
	}
	$query->put(this => undef);
    }
    $self->load_page($query);
    return
	if $self->get_result_set_size > 0
	|| !$self->req(qw(Model.HomeQueryForm is_search_click));
    $self->req->put(query => undef);
    $self->load_page({});
    return;
}

sub format_date_time {
    my($proto, $dt) = @_;
    my($res) = $_HFDT->get_widget_value($dt, 'HOUR_MINUTE_AM_PM_LC', 1);
    $res =~ s/(:00|\s)//g;
    return $res;
}

sub internal_initialize {
    my($self) = @_;
    my($info) = $self->SUPER::internal_initialize;
    return $self->merge_initialize_info($info, {
        version => 1,
	can_iterate => 0,
	want_page_count => 0,
	order_by => [
	    $self->field_decl(
		delete($info->{order_by}),
		{sort_order => 1},
	    ),
	],
	other => [
	    [qw(CalendarEvent.calendar_event_id VenueEvent.calendar_event_id)],
	    [qw(Venue.venue_id VenueEvent.venue_id)],
	    [_exclude_unused($_VL->PRIMARY_KEY_EQUIVALENCE_LIST)],
	    _exclude_unused($_VL->EDITABLE_FIELD_LIST),
	    [qw(Venue.venue_id venue.RealmOwner.realm_id)],
	    'venue.RealmOwner.display_name',
	    _exclude_unused($_VL->LOCATION_EQUIVALENCE_LIST),
	    $self->field_decl(
		[
		    qw(
			start_end_am_pm
			month_day
			address
			excerpt
		    ),
		    [qw(map_uri HTTPURI)],
		],
		'Text',
	    ),
	],
	other_query_keys => [qw(what when)],
    });
}

sub internal_load_rows {
    my($self, $query) = @_;
    my(@res) = shift->SUPER::internal_load_rows(@_);
    my($fields) = $self->[$_IDI];
    $query->put(
	defined($fields->{next_page}) ? (
	    has_next => 1,
	    next_page => $fields->{next_page},
	) : (),
	defined($fields->{prev_page}) ? (
	    has_prev => 1,
	    prev_page => $fields->{prev_page},
	) : (),
    );
    return @res;
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    my($fields) = $self->[$_IDI];
    unless ($fields->{row_tag_sentinel}++) {
	my($hqf) = $self->ureq('Model.HomeQueryForm');
	$hqf->row_tag_replace_what
	    if $hqf;
    }
    my($start, $end) = map(
	$self->format_date_time($row->{$_}),
	qw(dtstart_tz dtend_tz),
    );
#TODO: add in "tonight" and "tomorrow" and "evening" and "today" for robots on first page
    if ($start eq $end) {
	$row->{start_end_am_pm} = $start;
    }
    else {
	$end =~ s/(?:am|pm)//
	    unless $start =~ /pm/ xor $end =~ /pm/;
	$row->{start_end_am_pm} = "$start - $end";
    }
    $row->{month_day}
	= $_DT->english_day_of_week($row->{dtstart_tz})
	. ' '
	. $_HFDT->get_widget_value(
	    $row->{dtstart_tz},
	    'MONTH_NAME_AND_DAY_NUMBER',
	    1,
	)
	. ', '
	. $_DT->get_parts($row->{dtstart_tz}, 'year');
    if ($row->{month_day} eq $fields->{month_day}) {
	$row->{month_day} = '';
    }
    else {
	$fields->{month_day} = $row->{month_day};
    }
    $row->{address} = join(
	', ',
	map(
	    $row->{$_} ? $row->{$_} : (),
	    qw(
	        Address.street1
		Address.city
	    ),
	),
    );
    $row->{excerpt} = ${$_TS->canonicalize_and_excerpt(
	$row->{'CalendarEvent.description'} || '',
	# COUPLING: View.Home sets robots => noarchive if search robot so we don't
	# give away this data to the world.  Of course, people will be able to scrape
	# by saying they are google bot.  We could also check IPs of search bots.

	$fields->{is_robot_search}
	    ? 1_000_000
	    : $fields->{has_this} ? 200 : undef,
    )};
    $row->{map_uri} = 'http://maps.google.com/maps?q='
	. $_HTML->escape_query(
	    join(
		' ',
		map(
		    $row->{$_} ? $row->{$_} : (),
		    qw(
			venue.RealmOwner.display_name
			Address.street1
			Address.street2
			Address.city
			Address.state
			Address.zip
			Address.country
		    ),
		),
	    ),
	);
    $fields->{first_date} = $_D->from_datetime($row->{dtstart_tz})
	unless $fields->{first_row_seen}++;
    return 1;
}

sub internal_pre_load {
    my($self) = @_;
    return $self->EXCLUDE_HIDDEN_ROWS ? $_HIDE_ROWS_QUERY : '';
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    my($fields) = $self->[$_IDI] = {
	is_robot_search => $_UA->is_robot_search_verified($self->req),
	month_day => '',
	prev_page => undef,
	next_page => undef,
	first_row_seen => 0,
	has_this => $query->unsafe_get('this'),
    };
    $self->new_other('TimeZoneList')->load_all;
    return _prepare_this($self, $stmt, $query)
	if $query->unsafe_get('this');
    my($dt) = $query->unsafe_get('begin_date')
	|| $query->unsafe_get('when');
#TODO: when is less than now
    $dt = ($_D->from_literal($dt))[0];
    $dt = $_DT->add_seconds($_DEFAULT_TZ->date_time_to_utc($_DT->set_beginning_of_day($dt)), 1)
	if $dt;
    my($now) = $_DT->now;
    my($date_field);
    if (!$dt || $_DT->is_greater_than($now, $dt)) {
	$dt = $now;
	$date_field = 'CalendarEvent.dtend';
    }
    else {
	$date_field = 'CalendarEvent.dtstart';
    }
    $fields->{first_date} = $_D->from_datetime($_DEFAULT_TZ->date_time_from_utc($dt));
    $stmt->where($stmt->GTE($date_field, [$dt]));
    # Don't call SUPER, because we want all events
    my($s) = ($_TS->from_literal($query->unsafe_get('what')))[0];
    return
	unless defined($s);
    $s =~ s/^\s+|\s+$//g;
    return
	unless length($s);
    my($offset) = ($query->get('page_number') - 1) * $query->get('count');
    my($rows) = $_S->query({
	phrase => $s,
	offset => 0,
	length => 2000 + $offset,
	simple_class => 'CalendarEvent',
	req => $self->req,
#TODO: "where" will constrain the realms so we won't want all public, just those venues
	want_all_public => 1,
	no_model => 1,
    });
    my($n) = $query->get('count');
    $rows = [sort(
	{
	    $_DT->compare($a->{modified_date_time}, $b->{modified_date_time});
	}
	grep(
	    $_DT->is_greater_than_or_equals($_->{modified_date_time}, $dt),
	    @$rows,
	),
    )];
    splice(@$rows, 0, $offset);
    $fields->{next_page} = $query->get('page_number') + 1
	if my $has_next = @$rows > $n;
    $fields->{prev_page} = $query->get('page_number') - 1
	if $offset;
    $query->put(
	has_prev => 1,
	has_next => $has_next,
    );
    $stmt->where(
	$stmt->IN(
	    'CalendarEvent.calendar_event_id',
	    [map(
		$_->{primary_id},
		$has_next ? splice(@$rows, 0, $n) : @$rows,
	    )],
	),
    );
    return;
}

sub _exclude_unused {
    return grep((ref($_) ? $_->[0] : $_) !~ /RealmOwner|SearchWord|Email/, @_);
}

sub _prepare_this {
    my($self, $stmt, $query) = @_;
    $stmt->where(
	$stmt->EQ(
	    'CalendarEvent.calendar_event_id',
	    $query->get('this'),
        ),
    );
    return;
}

sub _seo_prefix_value {
    my($self) = @_;
    my($val) = join(
	' ',
	$self->get(qw(RealmOwner.display_name venue.RealmOwner.display_name)),
    );
    # don't let value exceed Apache2 file name size
    if (length($val) > 255) {
	$val = substr($val, 0, 255);
	$val =~ s/\s\S+\s*$//;
    }
    return $val;
}

1;
