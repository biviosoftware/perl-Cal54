# Copyright (c) 2010 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::Venue;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = b_use('FacadeComponent.Constant');

sub form {
    return shift->internal_body(
	vs_simple_form(VenueForm => [
	    map("VenueForm.$_",
		b_use('Model.VenueList')->EDITABLE_FIELD_LIST),
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

sub suggest_venue_mail {
    return shift->internal_put_base_attr(
	map(($_ => Mailbox(
	    [sub {
	        my($source) = @_;
		return b_use('Model.RealmOwner')->new($source->req)
		    ->unauth_load_or_die({
			realm_id => $_C->get_value('site_contact_realm_id'),
		    })->format_email;
	    }],
	)), qw(to from)),
	subject => 'Venue Website Suggestion',
	body => Join([
	    'Suggest website: ',
	    ['Model.SuggestSiteForm', 'Website.url'],
	    "\n",
	]),
    );
    return;
}

1;
