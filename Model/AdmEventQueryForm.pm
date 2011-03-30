# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::AdmEventQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_query_fields {
    my($self) = @_;
    return [
	[qw(scraper Line)],
    ];
}

1;
