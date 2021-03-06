# Copyright (c) 2010 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::Venue;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

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
	tools => TaskMenu([qw(
	    ADM_VENUE_LIST_CSV
	    ADM_VENUE_FORM
	)]),
	body => vs_paged_list(VenueList => [
	    ['RealmOwner.display_name', {
		wf_list_link => {
		    task => 'ADM_VENUE_FORM',
		    query => 'THIS_DETAIL',
		},
	    }],
	    ['Address.street1', {
		column_heading => String('Address'),
		column_widget => Join([
		    String(['Address.street1']),
		    If(Not(Equals(
			['Address.city'],
			'Boulder')),
		       Join([
			   ', ',
			   String(['Address.city']),
		       ]),
		    ),
		]),
	    }],
	    ['calendar.Website.url', {
		uri => ['calendar.Website.url'],
	    }],
	]),
    );
}

sub list_csv {
    return shift->internal_body(CSV(VenueList => [
	qw(
	    RealmOwner.display_name
	    RealmOwner.creation_date_time
	    Address.street1
	    Address.street2
	    Address.city
	    Address.state
	    Address.zip
	    Phone.phone
	    Website.url
	),
    ], {
	want_iterate_start => 1,
    }));
}

sub suggest_venue_mail {
    return shift->internal_put_base_attr(
	map(($_ => Mailbox(
	    [sub {
	        my($source) = @_;
		return b_use('Model.RealmOwner')->new($source->req)
		    ->unauth_load_or_die({
			realm_id => $_C->get_value(
			    'site_contact_realm_id',
			    $source->req,
			),
		    })->format_email;
	    }],
	)), qw(to from)),
	subject => Prose("Suggestion from If([qw(Model.SuggestSiteForm email)], [qw(Model.SuggestSiteForm email)], 'anonymous');"),
	body => Join([
	    ['Model.SuggestSiteForm', 'suggestion'],
	    "\n",
	]),
    );
    return;
}

1;
