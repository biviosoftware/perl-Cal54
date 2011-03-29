# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
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
    CSS => [
	[c4_query_what => 'width: 14em;'],
	[c4_form => ''],
	[c4_list => ''],
	[c4_home_bottom_pager => ''],
    ],
    Font => [
	[c4_home => ['family=Arial, Helvetica, sans-serif', '100%']],
	[[qw(c4_logo_tag c4_logo_name)] => [qw(bold uppercase 120%)]],
	[c4_query_what => ['100%']],
	[c4_query_submit => ['100%']],
	[c4_pager_month => ['70%', 'uppercase']],
	[c4_pager_a => ['70%']],
    ],
});

1;
