# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Cal54::HTMLCleaner;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use HTML::Parser ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_HTML) = b_use('Bivio.HTML');
my($_S) = b_use('Type.String');
my($_END_NEWLINE_TAG) = {
    map(($_ => 1), qw(
        tr
	form
	div
	p
	h1
	h2
	h3
	li
	td
    )),
};
my($_START_NEWLINE_TAG) = {
    map(($_ => 1), qw(
        p			 
        br
        hr
	ul
	table
    )),
};

sub clean_html {
    my($self, $html) = @_;
    my($fields) = $self->[$_IDI];
    my($parser) = b_use('Ext.HTMLParser')->new($self);
    $parser->{__PACKAGE__} = $self;
    # register text handler, includes whitespace
    $parser->handler(text => \&_parse_text, 'self,text');
    $parser->ignore_elements(qw(script noscript object style xml));
    {
	# ignore utf warnings
	local($SIG{__WARN__}) = sub {};
        $parser->parse($$html);
    }
    $fields->{text} =~ s/( )+$//mg;
    delete($parser->{__PACKAGE__});
    return \($fields->{text} . "\n");
}

sub get_link_for_text {
    my($self, $text) = @_;
    my($fields) = $self->[$_IDI];
    $text =~ s/^\s+|\s+$//g;
    my($links) = $fields->{links}->{$text};

    unless ($links) {
	b_warn('no links for text: ', $text);
	return undef;
    }
    if (@$links > 2) {
	b_warn('multiple links for text: ', $text);
    }
    return $links->[0];
}

sub html_parser_comment {
    return;
}

sub html_parser_end {
    my($self, $tag) = @_;
    my($fields) = $self->[$_IDI];

    if ($_END_NEWLINE_TAG->{$tag}) {
	$fields->{text} .= "\n";
	$fields->{text} .= "\n"
	    if $tag eq 'p';
    }
    if ($tag eq 'a') {
	return unless $fields->{link_text} && $fields->{href};
	$fields->{link_text} =~ s/^\s+|\s+$//g;
	push(@{$fields->{links}->{$fields->{link_text}} ||= []},
	     $fields->{href});
	$fields->{href} = $fields->{link_text} = undef;
    }
    return;
}

sub html_parser_start {
    my($self, $tag, $attrs) = @_;
    my($fields) = $self->[$_IDI];

    if ($_START_NEWLINE_TAG->{$tag}) {
	$fields->{text} .= "\n";
    }
    if ($tag eq 'a' && $attrs->{href}) {
	$fields->{href} = $attrs->{href};
    }
    return;
}

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {
    	in_body => 0,
    	wait_for_end_tag => '',
    	table_depth => 0,
    	text => '',
	links => {},
    };
    return $self;
}

sub _parse_text {
    my($parser, $text) = @_;
    my($self) = $parser->{__PACKAGE__};
    my($fields) = $self->[$_IDI];
    my($leading_white) = $text =~ /^(\s+)/;
    my($trailing_white) = $text =~ /\S(\s+)$/;
    my($value) = join('',
	$fields->{text} =~ /\s$/ || $fields->{text} eq ''
	    ? ''
	    : ($leading_white ? ' ' : ''),
	${$_S->canonicalize_charset($_HTML->unescape($text))},
	$trailing_white ? ' ' : '',
    );
    if ($fields->{href}) {
	$fields->{link_text} .= $value;
    }
    $fields->{text} .= $value;
    return;
}

1;
