# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::AdmCalendarEventList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	date => 'CalendarEvent.dtend',
	primary_key => [['CalendarEvent.calendar_event_id', 'RealmOwner.realm_id']],
	other => [
	    $self->field_decl_from_property_model('CalendarEvent'),
	    grep($_ !~ 'realm_id', $self->field_decl_from_property_model('RealmOwner')),
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
    my($self, $stmt) = @_;
    $stmt->where($stmt->GT('CalendarEvent.dtend', [$_DT->now]));
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
