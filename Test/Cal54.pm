# Copyright (c) 2010 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::Test::Cal54;
use strict;
use Bivio::Base 'TestLanguage.HTTP';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub login_as_adm {
    my($self) = @_;
    return $self->login_as('adm', undef, 'admin.cal54');
}

1;
