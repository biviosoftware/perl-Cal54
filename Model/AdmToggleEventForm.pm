# Copyright (c) 2011 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::Model::AdmToggleEventForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub execute_empty {
    my($self) = @_;
    $self->req->with_realm($self->req(
	qw(Model.AdmEventReviewList CalendarEvent.calendar_event_id)),
	sub {
	    my($rt) = $self->new_other('RowTag');
	    if ($rt->get_value('C4_HIDDEN_CALENDAR_EVENT')) {
		$rt->delete;
	    }
	    else {
		$rt->replace_value(C4_HIDDEN_CALENDAR_EVENT => 1);
	    }
	});
    return $self->internal_redirect_next;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
    });
}

1;
