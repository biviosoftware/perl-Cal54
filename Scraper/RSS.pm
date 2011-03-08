# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::RSS;
use strict;
use Bivio::Base 'Scraper.RegExp';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_import {
    my($self) = @_;
    my($xml) = $self->internal_parse_xml(
	$self->get('scraper_list')->get('Website.url'));
    my($cleaner) = b_use('Bivio.HTMLCleaner')->new;

    foreach my $item (@{$xml->{channel}->{item}}) {
	$item->{description} = ${$cleaner->clean_html(
	    \($item->{description}),
	    $item->{link},
	)} if $item->{description} =~ /\<.*\>/;
	my($current) = {
	    summary => $item->{title},
	    url => $item->{link},
	};
	$self->extract_once_fields($self->get_scraper_aux,
            \($item->{description}), $current);

	if ($self->get_scraper_aux->{repeat}) {
	    $self->extract_repeat_fields($self->get_scraper_aux,
	        \($item->{description}), $current, sub {
		    my($self, $args, $current) = @_;
		    _add_event($self, $current);
		    return;
	        });
		
	}
	else {
	    _add_event($self, $current);
	}
    }
    return;
}

sub _add_event {
    my($self, $current) = @_;
    push(@{$self->get('events')}, {
	%{$self->internal_collect_data($current)},
    }) if $current->{summary};
    return;
}

1;
