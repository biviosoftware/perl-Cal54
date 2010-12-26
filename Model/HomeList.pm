# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::HomeList;
use strict;
use Bivio::Base 'Model.CalendarEventList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_HFDT) = b_use('HTMLFormat.DateTime');
my($_VL) = b_use('Model.VenueList');
my($_TDT) = b_use('Type.DateTime');
my($_DEFAULT_TZ) = b_use('Type.TimeZone')->AMERICA_DENVER;
my($_IDI) = __PACKAGE__->instance_data_index;
my($_S) = b_use('Type.String');

sub execute {
    return shift->execute_load_page(@_);
}

sub internal_initialize {
    my($self) = @_;
    my($info) = $self->SUPER::internal_initialize;
    return $self->merge_initialize_info($info, {
        version => 1,
	can_iterate => 0,
	order_by => [
	    $self->field_decl(
		delete($info->{order_by}),
		{sort_order => 1},
	    ),
	],
	other => [
	    [
		qw(CalendarEvent.realm_id),
		_exclude_realm_owner($_VL->PRIMARY_KEY_EQUIVALENCE_LIST),
	    ],
	    _exclude_realm_owner($_VL->EDITABLE_FIELD_LIST),
	    $_VL->LOCATION_EQUIVALENCE_LIST,
	    $self->field_decl(
		[qw(
		    start_end_am_pm
		    month_day
		    address
		    excerpt
		)],
		'Text',
	    ),
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    my($fields) = $self->[$_IDI];
# b_info $row->{'RealmOwner.display_name'};
# b_info $row->{'CalendarEvent.dtstart'};
# b_info $row->{'CalendarEvent.dtend'};
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
    $row->{month_day} = $_HFDT->get_widget_value(
	$row->{dtend_tz},
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
    $row->{excerpt} = ${$_S->canonicalize_and_excerpt(
	$row->{'CalendarEvent.description'} || '',
    )};
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    $self->[$_IDI] = {month_day => ''};
    $self->new_other('TimeZoneList')->load_all;
    my($dt) = $query->unsafe_get('begin_date');
    $dt = $_DEFAULT_TZ->date_time_to_utc($_TDT->set_beginning_of_day($dt))
	if $dt;
    $dt ||= $_TDT->now;
    $stmt->where(
#TODO: Need to deal with recurring events
#TODO: Need to only show those recurring events that are valid for the day
	$stmt->GTE('CalendarEvent.dtstart', [$dt]),
#	$stmt->GTE('CalendarEvent.dtend', [b_debug $_TDT->now]),
    );
    # Don't call SUPER, because we want all events
    return;
}

sub _exclude_realm_owner {
    return grep($_ !~ /RealmOwner/, @_);
}

1;
