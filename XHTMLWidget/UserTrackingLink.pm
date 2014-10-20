# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::XHTMLWidget::UserTrackingLink;
use strict;
use Bivio::Base 'XHTMLWidget.Link';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub initialize {
    my($self) = @_;
    $self->put(event_handler => UserTrackingHandler());
    return shift->SUPER::initialize(@_);
}

1;
