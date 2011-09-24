# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::RSS;
use strict;
use Bivio::Base 'Scraper.RegExp';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub clean_description {
    my($self, $item) = @_;
    my($cleaner) = b_use('Bivio.HTMLCleaner')->new;
    $item->{title} = $self->internal_clean($item->{title});

    if ($item->{description} =~ /\<.*\>/) {
	$item->{description} = ${$cleaner->clean_html(
	    \($item->{description}),
	    $item->{link},
	)};
    }
    else {
	$item->{description} = $self->internal_clean($item->{description});
    }
    return;
}

sub internal_import {
    my($self) = @_;
    my($xml) = $self->internal_parse_xml(
	$self->get('scraper_list')->get('Website.url'));

    foreach my $item (@{$xml->{channel}->{item}}) {
	$self->clean_description($item);
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
