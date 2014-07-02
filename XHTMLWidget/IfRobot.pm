# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::XHTMLWidget::IfRobot;
use strict;
use Bivio::Base 'Widget.If';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	control => [['->req', 'Type.UserAgent'], '->is_robot'],
    );
    return shift->SUPER::initialize(@_);
}

sub NEW_ARGS {
    return [qw(control_on_value ?control_off_value)];
}

1;
