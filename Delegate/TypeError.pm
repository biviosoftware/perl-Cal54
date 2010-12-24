# Copyright (c) 2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Cal54::Delegate::TypeError;
use strict;
use Bivio::Base 'Delegate.SimpleTypeError';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    return [
	@{shift->SUPER::get_delegate_info(@_)},
	YOUR_ERROR_HERE => [
	    501,
	    undef,
	    'Your error description here.',
	],
    ];
}

1;
