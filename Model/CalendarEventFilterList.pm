# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::CalendarEventFilterList;
use strict;
use Bivio::Base 'Model.AdmCalendarEventList';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	auth_id => 'CalendarEvent.realm_id'
    });
}

1;
