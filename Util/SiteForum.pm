# Copyright (c) 2011-2012 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Util::SiteForum;
use strict;
use Bivio::Base 'ShellUtil';


sub init_realms {
    my($self) = @_;
    my(@res) = shift->SUPER::init_realms(@_);
    my($req) = $self->initialize_fully;
    $self->model('EmailAlias')->create({
	incoming => $req->format_email('external', $req),
    	outgoing => $self->CONTACT_REALM,
    });
    $self->model('EmailAlias')->create({
	incoming => $req->format_email('jmrukkers', $req),
    	outgoing => 'jmrukkers@gmail.com',
    });
    return @res;
}

1;
