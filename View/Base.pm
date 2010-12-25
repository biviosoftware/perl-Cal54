# Copyright (c) 2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Cal54::View::Base;
use strict;
use Bivio::Base 'View.ThreePartPage';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub VIEW_SHORTCUTS {
    return 'Cal54::ViewShortcuts';
}

sub internal_xhtml_adorned {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_xhtml_adorned(@_);
    return @res;
}

1;
