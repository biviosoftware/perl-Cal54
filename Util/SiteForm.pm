# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Util::SiteForm;
use strict;
use Bivio::Base 'ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub init_realms {
    my($self) = @_;
    my(@res) = shift->SUPER::init_realms(@_);
    my($req) = $self->initialize_fully;
    $self->model('EmailAlias')->create({
	$req->format_email('external', $req),
    	outgoing => $self->CONTACT_REALM,
    });
    $self->model('EmailAlias')->create({
	$req->format_email('jmrukkers', $req),
    	outgoing => 'jmrukkers@gmail.com',
    });
    return @res;
}

1;
