# Copyright (c) 2010 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::View::Base;
use strict;
use Bivio::Base 'View.ThreePartPage';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub VIEW_SHORTCUTS {
    return 'Cal54::ViewShortcuts';
}

1;
