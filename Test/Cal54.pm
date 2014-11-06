# Copyright (c) 2010 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::Test::Cal54;
use strict;
use Bivio::Base 'TestLanguage.HTTP';


sub find_page_with_text {
    my($self, $pattern) = @_;
    $self->follow_link(qr/^_1$/)
	until $self->text_exists($pattern);
    return;
}

sub login_as_adm {
    my($self) = @_;
    $self->home_page('admin.cal54');
    $self->follow_link('Login');
    $self->submit_form('Login', {
	email => 'adm',
	password => 'password'
    });
    return;
}

1;
