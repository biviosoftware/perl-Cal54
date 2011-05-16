# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Facade::Admin;
use strict;
use Bivio::Base 'Facade.Cal54Base';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

__PACKAGE__->new({
    is_production => 1,
    http_host => 'admin.cal54.com',
    mail_host => 'admin.cal54.com',
    uri => 'admin.cal54',
    Constant => [
	[ThreePartPage_want_ForumDropDown => 1],
	[ThreePartPage_want_dock_left_standard => 1],
	[robots_txt_allow_all => 0],
	[my_site_redirect_map => sub {[
 	    [qw(site-admin 0 ADM_VENUE_LIST)],
 	    [qw(site-admin 0 ADM_SCRAPER_LIST)],
	    [qw(0 0 SITE_ROOT)],
	]}],
	map(_site_admin_xlink($_), qw(
            ADM_VENUE_LIST
	    ADM_SCRAPER_LIST
	    ADM_CALENDAR_EVENT_LIST_FORM
	    ADM_EVENT_REVIEW_LIST
	)),
    ],
    Font => [
	[body => ['family=Arial, Helvetica, sans-serif', 'medium']],
    ],
    Task => [
	[ADM_CALENDAR_EVENT_LIST_FORM => '?/events'],
	[ADM_VENUE_FORM => '?/edit-venue'],
	[ADM_VENUE_LIST => '?/venues'],
	[ADM_SCRAPER_FORM => '?/scraper'],
	[ADM_SCRAPER_PREVIEW => '?/scraper-preview'],
	[ADM_SCRAPER_LIST => '?/scrapers'],
	[ADM_EVENT_REVIEW_LIST => '?/event-review'],
	[ADM_TOGGLE_EVENT_VISIBILITY => '?/toggle-event-visibility'],
    ],
    Text => [
	@{__PACKAGE__->internal_c4_text},
	[home_page_uri => '/bp'],
	[[qw(title xlink)] => [
	    ADM_VENUE_LIST => 'Venues',
	    ADM_CALENDAR_EVENT_LIST_FORM => 'Events',
	    ADM_VENUE_FORM => 'Edit Venue',
	    ADM_SCRAPER_FORM => 'Add Scraper',
	    ADM_SCRAPER_PREVIEW => 'Scraper Preview',
	    ADM_SCRAPER_LIST => 'Scrapers',
	    ADM_EVENT_REVIEW_LIST => 'Event Review',
	]],
	['task_menu.title' => [
	    ADM_VENUE_FORM => 'Add Venue',
	]],
	[Scraper => [
	    scraper_type => 'Type',
	    scraper_aux => 'Scraper Aux',
	    default_venue_id => 'Default Venue',
	]],
	[ScraperList => [
	    'default_venue.RealmOwner.display_name' => 'Default Venue',
	]],
	[[qw(VenueList VenueForm)] => [
	    'Website.url' => 'Home Page',
	    'calendar.Website.url' => 'Calendar Link',
	    'RealmOwner.name' => 'Scraper Tag',
	    'RealmOwner.display_name' => 'Full Name',
	    'RowTag.value' => 'Tags',
	]],
	[SearchWords => [
	    value => 'Search Words',
	]],
	[[qw(CalendarEventFilterList AdmCalendarEventList AdmCalendarEventListForm AdmEventReviewList)] => [
	    'RealmOwner.display_name' => 'Title',
	    'RowTag.value' => 'Tags',
	    'CalendarEvent.modified_date_time' => 'Changed',
	    'venue.RealmOwner.display_name' => 'Venue',
	]],
	[ScraperForm => [
	    test_scraper_button => 'Run Scraper',
	]],
	[AdmEventQueryForm => [
	    scraper => 'Scraper',
	]],
    ],
});

sub _site_admin_xlink {
    my($task) = @_;
    return ['xlink_' . lc($task) => sub {
        return {
	    realm => shift->get_value('site_admin_realm_name'),
	    task_id => $task,
	};
    }];
}

1;
