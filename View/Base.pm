# Copyright (c) 2010 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::View::Base;
use strict;
use Bivio::Base 'View.ThreePartPage';
use Bivio::UI::ViewLanguageAUTOLOAD;

sub VIEW_SHORTCUTS {
    return 'Cal54::ViewShortcuts';
}

1;
