# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::SearchWords;
use strict;
use Bivio::Base 'Model.RealmBase';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'search_words_t',
	columns => {
	    realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    value => ['LongText', 'NONE'],
	},
    });
}

1;
