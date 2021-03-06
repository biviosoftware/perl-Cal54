# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::AdmCalendarEventList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_DT) = b_use('Type.DateTime');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	primary_key => [['CalendarEvent.calendar_event_id', 'RealmOwner.realm_id', 'SearchWords.realm_id']],
	other => [
	    $self->field_decl_from_property_model('CalendarEvent'),
	    grep($_ !~ 'realm_id', $self->field_decl_from_property_model('RealmOwner')),
	    'SearchWords.value',
	],
	order_by => [
	    {
		name => 'CalendarEvent.dtstart',
		sort_order => 1,
	    },
	    'RealmOwner.display_name',
	],
    });
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    $stmt->where(
	$stmt->GT(
	    'CalendarEvent.dtend',
	    [$query->unsafe_get('begin_date') || $_DT->now],
	),
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
