# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::CalendarEventScraperList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
        want_date => 1,
	date => 'CalendarEvent.dtend',
	primary_key => ['CalendarEvent.calendar_event_id'],
	other => [
	    $self->field_decl_from_property_model('CalendarEvent'),
	],
	auth_id => 'CalendarEvent.realm_id',
    });
}

1;
