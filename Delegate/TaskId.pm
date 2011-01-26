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
		'Model.HomeQueryForm',
		'Model.HomeList',
		'View.Home->list',
	    ],
	    next => 'SITE_ROOT',
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
	    ADM_VENUE_LIST
	    502
	    FORUM
	    DATA_READ&FEATURE_SITE_ADMIN
	    Model.VenueList->execute_load_page
	    View.Venue->list
        )],
	[qw(
	    ADM_VENUE_FORM
	    503
	    FORUM
	    DATA_READ&DATA_WRITE&FEATURE_SITE_ADMIN
	    Model.VenueForm
	    View.Venue->form
	    next=ADM_VENUE_LIST
        )],
	[qw(
	    ADM_CALENDAR_EVENT_LIST_FORM
	    504
	    FORUM
	    DATA_READ&FEATURE_SITE_ADMIN
	    Model.AdmCalendarEventListForm
	    View.Calendar->adm_list
	    next=ADM_CALENDAR_EVENT_LIST_FORM
        )],
	[qw(
	    ADM_VENUE_SCRAPER_FORM
	    505
	    FORUM
	    DATA_READ&DATA_WRITE&FEATURE_SITE_ADMIN
	    Model.Venue->execute_unauth_load_this
	    Model.VenueScraperForm
	    View.Venue->scraper
	    next=ADM_VENUE_LIST
        )],
	[qw(
	    ADM_SCRAPER_PREVIEW
	    506
	    FORUM
	    DATA_READ&DATA_WRITE&FEATURE_SITE_ADMIN
	    Action.ScraperPreview
	    View.Venue->scraper_preview
	    next=ADM_VENUE_LIST
        )],
    ]);
}

1;
