# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::AdmEventQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';


sub internal_query_fields {
    my($self) = @_;
    return [
	[qw(scraper Line)],
    ];
}

1;
