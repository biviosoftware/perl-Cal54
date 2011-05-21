# Copyright (c) 2010 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::Venue;
use strict;
use Bivio::Base 'Model.RealmOwnerBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub add_realm_prefix {
    my($proto, $name) = @_;
    return $name unless $name;
    $name = 'v-' . $name
	unless $name =~ /^v-/;
    return $name;
}

sub create_realm {
    my($self, $venue, $realm, @rest) = @_;
    $realm->{name} = $self->add_realm_prefix($realm->{name})
	if $realm->{name};
    ($self, @rest) = $self->create($venue)->SUPER::create_realm($realm, @rest);
    $self->new_other('RowTag')->create({
	%$venue,
	primary_id => $self->get('venue_id'),
    });
    $self->new_other('RealmDAG')->create({
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
	auth_id => 'venue_id',
	other => [
	    [qw(venue_id RealmOwner.realm_id)],
	],
    });
}

sub strip_realm_prefix {
    my($self, $name) = @_;
    return $name unless $name;
    $name =~ s/^v-//;
    return $name;
}

1;
