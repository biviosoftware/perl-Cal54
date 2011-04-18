# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::HomeList;
use strict;
use Bivio::Base 'Model.CalendarEventList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_DEFAULT_TZ) = b_use('Type.TimeZone')->get_default;
my($_DT) = b_use('Type.DateTime');
my($_HFDT) = b_use('HTMLFormat.DateTime');
my($_HTML) = b_use('Bivio.HTML');
my($_TS) = b_use('Type.String');
my($_S) = b_use('Bivio.Search');
my($_VL) = b_use('Model.VenueList');
my($_D) = b_use('Type.Date');

sub EXCLUDE_HIDDEN_ROWS {
    return 1;
}

sub PAGE_SIZE {
    return b_use('Widget.IfMobile')->is_mobile(shift->req) ? 20 : 50;
}

sub execute {
    return shift->execute_load_page(@_);
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
	    [_exclude_realm_owner($_VL->PRIMARY_KEY_EQUIVALENCE_LIST)],
	    _exclude_realm_owner($_VL->EDITABLE_FIELD_LIST),
	    [qw(Venue.venue_id venue.RealmOwner.realm_id)],
	    'venue.RealmOwner.display_name',
	    $_VL->LOCATION_EQUIVALENCE_LIST,
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
	other_query_keys => [qw(where what when)],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    my($fields) = $self->[$_IDI];
    my($start, $end) = map(
	{
	    my($x) = $_HFDT->get_widget_value($row->{$_}, 'HOUR_MINUTE_AM_PM_LC', 1);
	    $x =~ s/(:00|\s)//g;
	    $x;
	}
	qw(dtstart_tz dtend_tz),
    );
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
	);
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
		Phone.phone
	    ),
	),
    );
    $row->{excerpt} = ${$_TS->canonicalize_and_excerpt(
	$row->{'CalendarEvent.description'} || '',
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
    return 1;
}

sub internal_pre_load {
    my($self) = @_;
    return $self->EXCLUDE_HIDDEN_ROWS
	# much faster than a left join...
	? ' NOT EXISTS (
            SELECT primary_id FROM row_tag_t
            WHERE primary_id = calendar_event_t.calendar_event_id
        ) '
	: '';
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    $self->new_other('PopularList')->load_all;
    $self->new_other('WhenList')->load_all;
    $self->[$_IDI] = {month_day => ''};
    $self->new_other('TimeZoneList')->load_all;
    my($dt) = $query->unsafe_get('begin_date')
	|| $query->unsafe_get('when');
#TODO: when is less than now
    $dt = ($_D->from_literal($dt))[0];
    my($now) = $_DT->now;
    $dt = $_DEFAULT_TZ->date_time_to_utc($_DT->set_beginning_of_day($dt))
	if $dt;
    $dt = $_DT->now
	if !$dt || $_DT->is_greater_than($now, $dt);
    $stmt->where(
	$stmt->GTE('CalendarEvent.dtend', [$dt]),
    );
    # Don't call SUPER, because we want all events
    my($s) = ($_TS->from_literal($query->unsafe_get('what')))[0];
    return
	unless defined($s);
    my($when) = $s =~ s{(\d+/\d+(?:/\d+)?)}{}g ? $1 : undef;
    $s =~ s/^\s+|\s+$//;
    return
	unless length($s);
    my($rows) = $_S->query({
	phrase => $s,
	offset => 0,
	length => 2000,
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
    $stmt->where(
	$stmt->IN(
	    'CalendarEvent.calendar_event_id',
	    b_debug [map(
		$_->{primary_id},
		@$rows > $n ? splice(@$rows, 0, $n) : @$rows,
	    )],
	),
    );
    return;
}

sub _exclude_realm_owner {
    return grep($_ !~ /RealmOwner/, @_);
}

1;
