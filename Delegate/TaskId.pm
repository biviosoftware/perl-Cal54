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
	    ADM_SCRAPER_FORM
	    505
	    FORUM
	    DATA_READ&FEATURE_SITE_ADMIN&TEST_TRANSIENT
	    Action.AssertClient
	    Model.ScraperForm
	    Model.VenueList->execute_load_all
	    View.Scraper->form
	    next=ADM_SCRAPER_LIST
        )],
	[qw(
	    ADM_SCRAPER_PREVIEW
	    506
	    FORUM
	    DATA_READ&FEATURE_SITE_ADMIN&TEST_TRANSIENT
	    Action.AssertClient
	    Action.ScraperPreview
	    View.Scraper->preview
        )],
	[qw(
	    SITE_ROOT_MOBILE
	    507
	    GENERAL
	    ANYBODY
	    Model.MobileQueryForm
	    Model.HomeList
	    View.Home->list_mobile
	    next=SITE_ROOT_MOBILE
        )],
	[qw(
	    ADM_SCRAPER_LIST
	    508
	    FORUM
	    DATA_READ&FEATURE_SITE_ADMIN
	    Model.ScraperList->execute_load_page
	    View.Scraper->list
        )],
	[qw(
	    SCRAPER_HOME
	    509
	    VENUE
	    ANYBODY
	    Action.Error
	)],
	[qw(
	    ADM_EVENT_REVIEW_LIST
	    510
	    FORUM
	    DATA_READ&FEATURE_SITE_ADMIN
	    Model.ScraperList->execute_load_all
	    Model.AdmEventQueryForm
	    Model.AdmEventReviewList->execute_load_page
	    View.Scraper->review_list
	    next=ADM_EVENT_REVIEW_LIST
        )],
    ]);
}

1;
