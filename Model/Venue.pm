# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::Venue;
use strict;
use Bivio::Base 'Model.RealmOwnerBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create_realm {
    my($self, @rest) = shift->create({})->SUPER::create_realm(@_);
    $self->new_other('RealmDAG')
	->create({
	    parent_id => $self->req('auth_id'),
	    child_id => $self->get('venue_id'),
	    realm_dag_type => b_use('Type.RealmDAG')->PARENT_IS_AUTHORIZED_ACCESS,
	});
    return ($self, @rest);
}

sub internal_create_realm_administrator_id {
    return undef;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'venue_t',
	columns => {
	    venue_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	},
    });
}

1;
