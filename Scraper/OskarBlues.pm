# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::OskarBlues;
use strict;
use Bivio::Base 'Scraper.RegExp';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub c4_scraper_get {
    my($self) = @_;
    my($res) = shift->SUPER::c4_scraper_get(@_);
    # <span style="background-color:#cc9966;">
    $$res =~ s/(\<span style="background-color\:(.*?)\;"\>)/$1 color$2 /g
	|| b_die();
    return $res;
}

1;
