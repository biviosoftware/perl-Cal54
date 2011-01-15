# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Cal54::HTMLCleaner;
use strict;
use Bivio::Base 'HTML.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_HTML) = b_use('Bivio.HTML');
my($_S) = b_use('Type.String');
my($_IGNORE_TAG_UNTIL_END) = {
    map(($_ => 1), qw(
        script
	noscript
	object
	xml
    )),
};
my($_IGNORE_START_TAG) = {
    map(($_ => 1), qw(
        input
	link
	img
	form
	tr
	td
	div
	span
	font
	p
	strong
	a
    )),
};
my($_END_NEWLINE_TAG) = {
    map(($_ => 1), qw(
        tr
	form
	div
	p
    )),
};
my($_START_NEWLINE_TAG) = {
    map(($_ => 1), qw(
        br
        hr
    )),
};

sub clean_html {
    my($proto, $html) = @_;
    my($self) = $proto->new;
    my($fields) = $self->[$_IDI] = {
    	in_body => 0,
    	wait_for_end_tag => '',
    	table_depth => 0,
    	text => '',
    };
    $self->parse_html($html);
    return \($fields->{text});
}

sub html_parser_end {
    my($self, $tag) = @_;
    my($fields) = $self->[$_IDI];
    return unless $fields->{in_body};

    if ($tag eq 'body') {
	$fields->{in_body} = 0;
	return;
    }
    if ($fields->{wait_for_end_tag}) {
	if ($tag eq $fields->{wait_for_end_tag}) {
	    $fields->{wait_for_end_tag} = '';
	}
	return;
    }
    if ($tag eq 'table') {
	$fields->{table_depth} = $fields->{table_depth} - 1;
	b_die() if $fields->{table_depth} < 0;
	return;
    }
    if ($_END_NEWLINE_TAG->{$tag}) {
	_append($self, "\n");
	return;
    }
    if ($tag eq 'td') {
	_append($self, '  ');
	return;
    }
    return;
}

sub html_parser_start {
    my($self, $tag, $attr) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{wait_for_end_tag};
    return if $_IGNORE_START_TAG->{$tag};

    if ($tag eq 'body') {
	b_die('body already found')
	    if $fields->{in_body};
	$fields->{in_body} = 1;
	return;
    }
    return unless $fields->{in_body};

    if ($_IGNORE_TAG_UNTIL_END->{$tag}) {
	$fields->{wait_for_end_tag} = $tag;
	return;
    }
    if ($tag eq 'table') {
	$fields->{table_depth} = $fields->{table_depth} + 1;
	return;
    }
    if ($_START_NEWLINE_TAG->{$tag}) {
	_append($self, "\n");
	return;
    }
    b_warn('unhandled tag: ', $tag);
    return;
}

sub html_parser_text {
    my($self, $text) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{wait_for_end_tag};
    _append($self, ${$_S->canonicalize_charset($_HTML->unescape($text))});
    return;
}

sub _append {
    my($self, $text) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{text} .= $text;
    return;
}

1;
