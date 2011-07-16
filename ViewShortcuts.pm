# Copyright (c) 2010 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::ViewShortcuts;
use Bivio::Base 'Bivio::UI::XHTML::ViewShortcuts';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub vs_unless_robot {
    my(undef, $widget) = @_;
    return If(['!', 'Type.UserAgent', '->eq_browser_robot'], $widget);
}

1;
