# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::WhenList;
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
	    Today
	    Tomorrow
	),
    )];
}

sub search_query {
    my($self) = @_;
    return {
	when => $self->get('item'),
	what => $self->req('Model.HomeList')->get_query->unsafe_get('what'),
    };
}

1;
