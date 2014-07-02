# Copyright (c) 2010 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::Test::Cal54;
use strict;
use Bivio::Base 'TestLanguage.HTTP';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub login_as_adm {
    my($self) = @_;
    $self->home_page('admin.cal54');
    $self->follow_link('Login');
    $self->submit_form('1#0', {
	email => 'adm',
	password => 'password'
    });
    return;
}

1;
