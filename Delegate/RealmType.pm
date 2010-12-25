# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Delegate::RealmType;
use strict;
use Bivio::Base 'Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    return [
	@{shift->SUPER::get_delegate_info(@_)},
	VENUE => 21,
    ];
}

1;
