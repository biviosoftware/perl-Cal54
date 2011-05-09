# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::XHTMLWidget::UserTrackingLink;
use strict;
use Bivio::Base 'XHTMLWidget.Link';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put(event_handler => UserTrackingHandler());
    return shift->SUPER::initialize(@_);
}

1;
