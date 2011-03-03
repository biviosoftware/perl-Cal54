# Copyright (c) 2010-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Cal54::Facade::Cal54;
use strict;
use Bivio::Base 'Bivio::UI::FacadeBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_SELF) = __PACKAGE__->new({
    uri => 'cal54',
    http_host => 'www.cal54.com',
    mail_host => 'cal54.com',
    Color => [
	[[qw(c4_site_name c4_site_tag c4_right_title)]=> 0xee3333],
	[[qw(c4_item_a_visited c4_item_a c4_item_a_hover c4_sidebar_list)] => 0x3333aa],
	[[qw(c4_date c4_time)] => 0xff7733],
    ],
    Constant => [
	[ThreePartPage_want_ForumDropDown => 1],
	[ThreePartPage_want_dock_left_standard => 1],
	[robots_txt_allow_all => 0],
	[my_site_redirect_map => sub {[
 	    [qw(site-admin 0 ADM_VENUE_LIST)],
	]}],
	[xlink_adm_venue_list => sub {
	     return {
		 realm => shift->get_value('site_admin_realm_name'),
		 task_id => 'ADM_VENUE_LIST',
	     };
	 }],
	[xlink_adm_calendar_event_list_form => sub {
	     return {
		 realm => shift->get_value('site_admin_realm_name'),
		 task_id => 'ADM_CALENDAR_EVENT_LIST_FORM',
	     };
	 }],
    ],
    Font => [
	[c4_home => ['family=Arial, Helvetica, sans-serif', 'medium']],
	[c4_site_name => ['family=Times', 'bold']],
	[c4_right_title => ['family=Times', 'bold', '200%']],
	[c4_query_what => '120%'],
	[c4_excerpt => ['80%']],
	[[qw(c4_item_a c4_sidebar_list)] => []],
	[[qw(c4_query_label c4_query_submit c4_item_a_title)] => 'bold'],
	[c4_item_a_visited => []],
	[c4_item_a_hover => ['underline']],
	[[qw(c4_date c4_time)] => ['bold']],
	[c4_events_item => []],
	[c4_sidebar_title => 'bold'],
	[c4_venue => ['90%']],
	[c4_copy => ['80%', 'center']],
	[c4_site_tag => ['family=Times', 'bold']],
	[c4_tm => ['60%', 'style=vertical-align: top; line-height: 90%']],
    ],
    Task => [
	[ADM_CALENDAR_EVENT_LIST_FORM => '?/events'],
	[ADM_VENUE_FORM => '?/edit-venue'],
	[ADM_VENUE_LIST => '?/venues'],
	[ADM_VENUE_SCRAPER => '?/scraper'],
	[ADM_SCRAPER_PREVIEW => '?/scraper-preview'],
 	[SITE_ROOT_MOBILE => 'mobile'],
    ],
    Text => [
	[site_name => q{CAL 54, Inc.}],
	[c4_site_tag => q{SPAN(q{The Web's Calendar});SPAN_c4_tm('&trade;');}],
	[site_copyright => q{bivio Software, Inc.}],
	[home_page_uri => '/bp'],
	[[qw(title xlink)] => [
	    ADM_VENUE_LIST => 'Venues',
	    ADM_CALENDAR_EVENT_LIST_FORM => 'Events',
	    ADM_VENUE_FORM => 'Edit Venue',
	    ADM_VENUE_SCRAPER => 'Scraper Definition',
	    ADM_SCRAPER_PREVIEW => 'Scraper Preview',
	]],
	['task_menu.title' => [
	    ADM_VENUE_FORM => 'Add Venue',
	]],
	[Venue => [
	    scraper_type => 'Scraper',
	    scraper_aux => 'Scraper Aux',
	]],
	[[qw(VenueList VenueForm)] => [
	    'Website.url' => 'Home Page',
	    'calendar.Website.url' => 'Calendar Link',
	    'RealmOwner.display_name' => 'Full Name',
	    'RowTag.value' => 'Tags',
	    'Venue.scraper_type.desc' => q{
                If(['Model.VenueForm', '->is_edit'],
                    Link(vs_text('title.ADM_VENUE_SCRAPER'), URI({
                        task_id => 'ADM_VENUE_SCRAPER',
                        query => ['Model.Venue', '->format_query_for_this'],
                    })),
                );
            }
	]],
	[SearchWords => [
	    value => 'Search Words',
	]],
	[[qw(CalendarEventFilterList AdmCalendarEventList AdmCalendarEventListForm)] => [
	    'RealmOwner.display_name' => 'Title',
	    'RowTag.value' => 'Tags',
	]],
	[VenueScraperForm => [
	    test_scraper_button => 'Run Scraper',
	]],
    ],
});

1;
