# Copyright (c) 2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Cal54::Facade::Cal54;
use strict;
use Bivio::Base 'Bivio::UI::FacadeBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_SELF) = __PACKAGE__->new({
    uri => 'cal54',
    http_host => 'www.cal54.com',
    mail_host => 'cal54.com',
    Constant => [
	[ThreePartPage_want_ForumDropDown => 1],
	[ThreePartPage_want_dock_left_standard => 1],
	[ThreePartPage_want_SearchForm => 0],
    ],
    CSS => [
	[table_footer => q{
            margin: .5ex 0 .5ex 0;
	    padding-top: .5ex;
	    padding-bottom: 7ex;
        }],
	[logo_su_logo => q{}],
	[td_header_left => q{}],
	[table_main => q{
	    width: 100%;
	    margin: 0 auto;
        }],
    ],
    Font => [
	[body => ['family=Verdana', 'medium', 'style=margin-top: 0; margin-bottom: 0; margin-right: .5em; margin-left: .5em; min-width: 50em']],
    ],
    Text => [
	[site_name => q{bivio Software, Inc.}],
	[site_copyright => q{bivio Software, Inc.}],
	[home_page_uri => '/bp'],
	[xlink => [
	    xhtml_logo_normal => q{String(' ');},
	]],
    ],
});

1;
