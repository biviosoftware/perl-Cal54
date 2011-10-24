# Copyright (c) 2010 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::ViewShortcuts;
use Bivio::Base 'Bivio::UI::XHTML::ViewShortcuts';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub vs_unless_robot {
    my(undef, $widget, $else) = @_;
    return If(['!', ['->req', 'Type.UserAgent'], '->is_robot'], $widget, $else);
}

1;
