# Copyright (c) 2011 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::Action::ScraperPreview;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($self) = shift->new(@_);
    $self->put(text => '');
    my($uri) = ($self->req('query') || {})->{x};
    return unless $uri;
    my($scraper) = b_use('HTML.Scraper')->new;
    my($cleaner) = b_use('Bivio.HTMLCleaner')->new;
    $self->put(
	cleaner => $cleaner,
	text => ${$cleaner->clean_html(
	    $scraper->extract_content($scraper->http_get($uri)), $uri)},
    );
    return;
}

1;
