# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::Venue;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub form {
    return shift->internal_body(
	vs_simple_form(VenueForm => [
	    map("VenueForm.$_", b_use('Model.VenueList')->EDITABLE_FIELD_LIST),
	]),
    );
}

sub list {
    return shift->internal_put_base_attr(
	tools => TaskMenu([
	    'ADM_VENUE_FORM',
	]),
	body => vs_paged_list(VenueList => [
	    ['RealmOwner.display_name', {
		wf_list_link => {
		    task => 'ADM_VENUE_FORM',
		    query => 'THIS_DETAIL',
		},
	    }],
	    'Address.street1',
	    ['calendar.Website.url', {
		uri => ['calendar.Website.url'],
	    }],
	]),
    );
}

sub scraper {
    return shift->internal_body(
	vs_simple_form(VenueScraperForm => [
	    H1(String([['Model.Venue', '->get_model', 'RealmOwner'],
		       'display_name'])),
	    'VenueScraperForm.Venue.scraper_type',
	    ['VenueScraperForm.Venue.scraper_aux', {
		cols => 80,
		rows => 25,
	    }],
	]),
    );
}

1;
