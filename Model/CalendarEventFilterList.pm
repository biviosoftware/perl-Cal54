# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::CalendarEventFilterList;
use strict;
use Bivio::Base 'Model.AdmCalendarEventList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	auth_id => 'CalendarEvent.realm_id'
    });
}

1;
