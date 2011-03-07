# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::Scraper;
use strict;
use Bivio::Base 'Model.RealmOwnerBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create_realm {
    my($self, $scraper, @rest) = @_;
    ($self, @rest) = $self->create($scraper)->SUPER::create_realm(@rest);
    return ($self, @rest);
}

sub internal_create_realm_administrator_id {
    return undef;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'scraper_t',
	columns => {
	    scraper_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    scraper_type => ['Scraper', 'NOT_ZERO_ENUM'],
	    scraper_aux => ['Text64K', 'NONE'],
	    default_venue_id => ['Venue.venue_id', 'NONE'],
	},
	auth_id => 'scraper_id',
	other => [
	    [qw(scraper_id RealmOwner.realm_id)],
	],
    });
}

1;
