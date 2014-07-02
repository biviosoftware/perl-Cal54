# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Facade::Mobile;
use strict;
use Bivio::Base 'Facade.Cal54';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

__PACKAGE__->new({
    clone => 'Cal54',
    is_production => 1,
    http_host => 'm.cal54.com',
    mail_host => 'm.cal54.com',
    uri => 'm.cal54',
    Constant => [
	[robots_txt_allow_all => 0],
    ],
});

1;
