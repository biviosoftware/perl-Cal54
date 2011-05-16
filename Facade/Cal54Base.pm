# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Facade::Cal54Base;
use strict;
use Bivio::Base 'UI.FacadeBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_c4_text {
    return [
	[site_name => q{CAL 54, Inc.}],
	[site_copyright => q{CAL 54, Inc.}],
    ];
}

1;
