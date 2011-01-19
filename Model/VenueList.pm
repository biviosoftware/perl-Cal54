# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::VenueList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub EDITABLE_FIELD_LIST {
    return qw(
	RealmOwner.display_name
	Website.url
	calendar.Website.url
	Venue.scraper_type
	Email.email
	Phone.phone
	Address.street1
	Address.street2
	Address.city
	Address.state
	Address.zip
	Address.country
	SearchWords.value
    );
}

sub LOCATION_EQUIVALENCE_LIST {
    return (
	map(
	    ["$_.location", [b_use("Model.$_")->DEFAULT_LOCATION]],
	    qw(Address Email Phone Website),
	),
	['calendar.Website.location', [b_use('Type.Location')->CALENDAR]],
    );
}

sub PRIMARY_KEY_EQUIVALENCE_LIST {
    return qw(
	Venue.venue_id
	Address.realm_id
	Email.realm_id
	Phone.realm_id
	RealmOwner.realm_id
	calendar.Website.realm_id
	Website.realm_id
	SearchWords.realm_id
    );
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        primary_key => [[$self->PRIMARY_KEY_EQUIVALENCE_LIST, 'RealmDAG.child_id']],
	order_by => ['RealmOwner.display_name'],
	other => [
	    $self->EDITABLE_FIELD_LIST,
	    $self->LOCATION_EQUIVALENCE_LIST,
	    ['RealmDAG.realm_dag_type', [b_use('Type.RealmDAG')->PARENT_IS_AUTHORIZED_ACCESS]],
	],
	auth_id => [qw(RealmDAG.parent_id)],
    });
}

1;
