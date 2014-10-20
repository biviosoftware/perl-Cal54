# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::RSS;
use strict;
use Bivio::Base 'Scraper.RegExp';


sub clean_description {
    my($self, $item) = @_;
    my($cleaner) = b_use('Bivio.HTMLCleaner')->new;
    $item->{title} = $self->internal_clean($item->{title});
    my($use_raw_description) = ref($self)
	? $self->get_scraper_aux->{use_raw_description}
	: 0;

    if (! $item->{description} && $item->{'content:encoded'}) {
	$item->{description} = $item->{'content:encoded'};
    }

    if ($item->{description} =~ /\<.*\>/ && ! $use_raw_description) {
	$item->{description} = ${$cleaner->clean_html(
	    \($item->{description}),
	    $item->{link},
	)};
    }
    else {
	$item->{description} =  $self->internal_clean($item->{description});
    }
    $item->{description} = join(
	"\n",
	$self->internal_clean($item->{title} || ''),
	$item->{description},
    );
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
	$self->internal_parse_item($item, $current);
    }
    return;
}

sub internal_parse_item {
    my($self, $item, $current) = @_;
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
