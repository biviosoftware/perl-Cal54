# Copyright (c) 2010 bivio Software, Inc.  All rights reserved.
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
	[[qw(c4_site_name c4_date)]=> 0xff3333],
	[c4_item_a_visited => 0xaa3333],
	[c4_item_a_hover => 0xff0000],
    ],
    Constant => [
	[ThreePartPage_want_ForumDropDown => 1],
	[ThreePartPage_want_dock_left_standard => 1],
	[robots_txt_allow_all => 0],
	[my_site_redirect_map => sub {[
 	    [qw(site-admin 0 VENUE_LIST)],
	]}],
	[xlink_venue_list => sub {
	     return {
		 realm => shift->get_value('site_admin_realm_name'),
		 task_id => 'VENUE_LIST',
	     };
	 }],
    ],
    Font => [
	[c4_home => ['family=Arial, Helvetica, sans-serif', 'medium']],
	[c4_date => ['bold']],
	[c4_site_name => ['family=Times', 'bold']],
	[c4_excerpt => ['size=80%']],
	[c4_item_a => ['underline']],
	[c4_item_a_visited => []],
	[c4_item_a_hover => []],
	[c4_copy => ['size=80%', 'center']],
    ],
    Task => [
	[VENUE_LIST => '?/venues'],
	[VENUE_FORM => '?/edit-venue'],
    ],
    Text => [
	[site_name => q{bivio Software, Inc.}],
	[site_copyright => q{bivio Software, Inc.}],
	[home_page_uri => '/bp'],
	[[qw(title xlink)] => [
	    VENUE_LIST => 'Venues',
	    VENUE_FORM => 'Edit Venue',
	]],
	['task_menu.title' => [
	    VENUE_FORM => 'Add Venue',
	]],
	[[qw(VenueList VenueForm)] => [
	    'Website.url' => 'Home Page',
	    'calendar.Website.url' => 'Calendar Link',
	    'RealmOwner.display_name' => 'Full Name',
	]],
    ],
});

1;
