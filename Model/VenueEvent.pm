# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::VenueEvent;
use strict;
use Bivio::Base 'Biz.PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'venue_event_t',
        columns => {
	    calendar_event_id => ['CalendarEvent.calendar_event_id', 'PRIMARY_KEY'],
	    venue_id => ['Venue.venue_id', 'NOT_NULL'],
	},
	auth_id => 'calendar_event_id',
	other => [
	    [qw(venue_id Venue.venue_id RealmOwner.realm_id)],
	    [qw(calendar_event_id CalendarEvent.calendar_event_id)],
	],
    });
}

1;
