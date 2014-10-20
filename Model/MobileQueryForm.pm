# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::MobileQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';


sub internal_query_fields {
    return [
	[qw(where Line)],
	[qw(what Line)],
	[qw(when Line)],
    ];
}

1;
