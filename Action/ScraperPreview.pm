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
    my($content) = $scraper->extract_content($scraper->http_get($uri));

    # rss
    if ($$content =~ /^\s*\<\?xml version/) {
	my($xml) = b_use('Bivio.Scraper')->parse_xml($content);
	my($items) = [];

	foreach my $item (@{$xml->{channel}->{item}}) {
	    $item->{description} = ${$cleaner->clean_html(
	        \($item->{description}),
		$item->{link},
	    )} if $item->{description} =~ /\<.*\>/;
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
