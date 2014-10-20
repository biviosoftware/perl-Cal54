# Copyright (c) 2011 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::Action::ScraperPreview;
use strict;
use Bivio::Base 'Biz.Action';

my($_RSS) = b_use('Scraper.RSS');

sub execute {
    my($self) = shift->new(@_);
    $self->put(text => '');
    my($uri) = ($self->req('query') || {})->{x};
    return unless $uri;
    my($cleaner) = b_use('Bivio.HTMLCleaner')->new;
    $self->put(
	cleaner => $cleaner,
	text => _parse_content($self, $uri,
	    $cleaner),
    );
    return;
}

sub _parse_content {
    my($self, $uri, $cleaner) = @_;
    my($scraper) = b_use('HTML.Scraper')->new;
    $scraper->get('user_agent')->parse_head(0);
    $scraper->put(accept_encoding => 1);
    my($content) = $scraper->extract_content($scraper->http_get($uri));

    # rss
    if ($$content =~ /^\s*\<\?xml version/
        && $$content =~ /\<channel\>/) {
	my($xml) = b_use('Bivio.Scraper')->parse_xml($content);
	my($items) = [];

	foreach my $item (@{$xml->{channel}->{item}}) {
	    $_RSS->clean_description($item);
	    push(@$items, {
		description => $item->{description},
		summary => $item->{title},
		url => $item->{link},
	    });
	}
	return ${b_use('IO.Ref')->to_string($items)};
    }
    return ${$cleaner->clean_html($content, $uri)};
}

1;
