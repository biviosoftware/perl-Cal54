# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::PopularList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    return {
	version => 1,
	primary_key => [
	    {
		name => 'item',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	],
    };
}

sub internal_load_rows {
    my($self, $query, $where, $params, $sql_support) = @_;
    return [map(
	+{item => $_},
	qw(
	    Music
	    Free
	    Kids
	    Jazz
	),
    )];
}

sub search_query {
    my($self) = @_;
    return {
	what => $self->get('item'),
	when => $self->req('Model.HomeList')->get_query->unsafe_get('when'),
    };
}

1;
