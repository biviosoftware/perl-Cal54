# Copyright (c) 2010 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Delegate::Location;
use strict;
use Bivio::Base 'Delegate.SimpleLocation';


sub get_delegate_info {
    return [
	@{shift->SUPER::get_delegate_info(@_)},
	CALENDAR => 21,
    ];
}

1;
