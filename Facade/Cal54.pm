# Copyright (c) 2010-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Cal54::Facade::Cal54;
use strict;
use Bivio::Base 'UI.FacadeBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_SELF) = __PACKAGE__->new({
    uri => 'cal54',
    http_host => 'www.cal54.com',
    mail_host => 'cal54.com',
    Color => [
	[[qw(c4_site_name c4_site_tag c4_query_what)]=> 0x0],
	[[qw(c4_item_a c4_item_a_hover b_mobile_toggler_a)] => 0x2200C1],
        [c4_item_a_visited => 0x551A8B],
	[[qw(c4_date c4_time c4_query_submit_background c4_query_background)] => 0x0088ce],
	[[qw(c4_pager c4_pager_selected_border)] => 0xffffff],
	[[qw(c4_pager_weekend c4_query_submit_border c4_query_submit)] => 0xf8f8f8],
	[[qw(c4_pager_a)]=> 0xe8e8e8],
	[b_mobile_toggler_selected => 0x0],
    ],
    Constant => [
	[ThreePartPage_want_ForumDropDown => 1],
	[ThreePartPage_want_dock_left_standard => 1],
	[robots_txt_allow_all => 0],
	[my_site_redirect_map => sub {[
 	    [qw(site-admin 0 ADM_VENUE_LIST)],
 	    [qw(site-admin 0 ADM_SCRAPER_LIST)],
	]}],
	[xlink_adm_venue_list => sub {
	     return {
		 realm => shift->get_value('site_admin_realm_name'),
		 task_id => 'ADM_VENUE_LIST',
	     };
	 }],
	[xlink_adm_scraper_list => sub {
	     return {
		 realm => shift->get_value('site_admin_realm_name'),
		 task_id => 'ADM_SCRAPER_LIST',
	     };
	 }],
	[xlink_adm_calendar_event_list_form => sub {
	     return {
		 realm => shift->get_value('site_admin_realm_name'),
		 task_id => 'ADM_CALENDAR_EVENT_LIST_FORM',
	     };
	 }],
    ],
    CSS => [
	[c4_query_what => 'width: 25em;'],
        [c4_form => q{IfUserAgent(
            '!is_msie_6_or_before',
            '
                position: fixed;
		top: 0;
		left: 0;
		right: 0;
            ',
        );}],
	[c4_grid => q{
	    width: 50em;
	    margin: auto;
	}],
	[c4_list => q{IfUserAgent(
		'!is_msie_6_or_before',
		'padding-top: 13ex;',
	    );
	    width: 49.5em;
	    padding-left: .5em;
	    margin: auto;
        }],
	[c4_home_bottom_pager => q{
            width: 50em;
            margin: auto;
        }],
    ],
    Font => [
	[body => []],
	[b_mobile_toggler_selected => []],
	[b_mobile_toggler_a => []],
	[c4_home => ['family=Arial, Helvetica, sans-serif', 'medium']],
	[c4_query_submit => ['size=18px']],
	[c4_logo_name => [qw(uppercase bold 48px)]],
	[c4_logo_tag => [qw(uppercase bold 80%)]],
	[c4_site_name => ['bold']],
	[c4_excerpt => ['80%']],
	[c4_query_what => '120%'],
	[c4_pager_weekend => 'bold'],
	[c4_time => [qw(80% bold)]],
	[c4_date => ['90%', 'bold']],
	[c4_item_a => []],
	[c4_item_a_title => 'bold'],
	[c4_item_a_visited => []],
	[c4_item_a_hover => ['underline']],
	[c4_events_item => []],
	[c4_venue => ['80%']],
	[c4_copy => ['80%']],
	[c4_site_tag => ['bold']],
	[c4_tm => ['60%', 'style=vertical-align: top; line-height: 90%']],
	[c4_pager => ['left']],
	[c4_pager_month => ['80%', 'uppercase']],
	[c4_pager_a => ['80%']],
    ],
    Task => [
	[ADM_CALENDAR_EVENT_LIST_FORM => '?/events'],
	[ADM_VENUE_FORM => '?/edit-venue'],
	[ADM_VENUE_LIST => '?/venues'],
	[ADM_SCRAPER_FORM => '?/scraper'],
	[ADM_SCRAPER_PREVIEW => '?/scraper-preview'],
 	[SITE_ROOT_MOBILE => 'mobile'],
	[ADM_SCRAPER_LIST => '?/scrapers'],
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
	    ADM_SCRAPER_FORM => 'Add Scraper',
	    ADM_SCRAPER_PREVIEW => 'Scraper Preview',
	    ADM_SCRAPER_LIST => 'Scrapers',
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
	[[qw(CalendarEventFilterList AdmCalendarEventList AdmCalendarEventListForm)] => [
	    'RealmOwner.display_name' => 'Title',
	    'RowTag.value' => 'Tags',
	]],
	[ScraperForm => [
	    test_scraper_button => 'Run Scraper',
	]],
    ],
});

1;
