# Copyright (c) 2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Cal54::Delegate::TaskId;
use strict;
use Bivio::Base 'Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    my($proto) = @_;
    return $proto->merge_task_info(@{$proto->standard_components}, [
	{
	    name => 'SITE_ROOT',
	    items => [
		'View.Home->list',
	    ],
	},
	[qw(
	    VENUE_HOME
	    501
	    VENUE
	    ANYBODY
	    Action.Error
	)],
#TODO: This should be some other perm besides FEATURE_SITE_ADMIN
	[qw(
	    VENUE_LIST
	    502
	    FORUM
	    DATA_READ&FEATURE_SITE_ADMIN
	    Model.VenueList->execute_load_page
	    View.Venue->list
        )],
	[qw(
	    VENUE_FORM
	    503
	    FORUM
	    DATA_READ&DATA_WRITE&FEATURE_SITE_ADMIN
	    Model.VenueForm
	    View.Venue->form
	    next=VENUE_LIST
        )],
    ]);
}

1;
