# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Facade::Cal54Base;
use strict;
use Bivio::Base 'UI.FacadeBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_c4_text {
    return [
	[site_name => q{CAL54, Inc.}],
	[site_copyright => q{CAL54, Inc.}],
    ];
}

sub internal_c4_color {
    return [
	[c4_event_hidden_background => 0xefe98a],
    ];
}

1;
