# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Cal54::HTMLCleaner;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use HTML::Parser ();
use URI ();

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
    my($self, $html, $url) = @_;
    my($fields) = $self->[$_IDI] = {
    	text => '',
	links => [],
	url => $url,
    };
    b_die('invalid url: ', $url) unless $url =~ m{\://};
    my($parser) = b_use('Ext.HTMLParser')->new($self);
    $parser->{__PACKAGE__} = $self;
    # register text handler, includes whitespace
    $parser->handler(text => \&_parse_text, 'self,text');
    $parser->unbroken_text(1);
    $parser->ignore_elements(qw(script noscript object style xml));
    {
	# ignore utf warnings
	local($SIG{__WARN__}) = sub {};
        $parser->parse($$html);
    }
    $fields->{text} =~ s/( )+$//mg;
    $fields->{text} =~ s/(\n{3})\n+/$1/g;
    $fields->{text} =~ s/(\w)\s([,.;]\s)/$1$2/g;
    delete($parser->{__PACKAGE__});
    return \($fields->{text} . "\n");
}

sub get_link_for_text {
    my($self, $text) = @_;
    my($url) = $self->unsafe_get_link_for_text($text);
    b_die('no links for text: ', $text)
	unless $url;
    return $url;
}

sub html_parser_comment {
    return;
}

sub html_parser_end {
    my($self, $tag) = @_;
    my($fields) = $self->[$_IDI];

    if ($_END_NEWLINE_TAG->{$tag} && ! $fields->{href}) {
	$fields->{text} .= "\n";
	$fields->{text} .= "\n"
	    if $tag eq 'p';
	$fields->{soft_newline} = 0;
    }
    if ($tag eq 'a') {

	if ($fields->{href} && $fields->{text} !~ /(\n|\})$/s) {
	    my($index) = scalar(@{$fields->{links}});
	    push(@{$fields->{links}}, $fields->{href});
	    $fields->{text} =~ s/\s+$//;
	    _append_text($self, '{' . $index . '}');
	    $fields->{soft_newline} = 1;
	}
	$fields->{href} = undef;
    }
    if ($tag eq 'span') {
	_append_text($self, ' ')
	    unless $fields->{soft_newline};
    }
    return;
}

sub html_parser_start {
    my($self, $tag, $attrs) = @_;
    my($fields) = $self->[$_IDI];

    if ($_START_NEWLINE_TAG->{$tag} && ! $fields->{href}) {
	$fields->{text} .= "\n";
	$fields->{soft_newline} = 0;
    }
    if ($tag eq 'a' && $attrs->{href}) {
	$fields->{href} = $attrs->{href};
	$fields->{text} .= "\n"
	    unless $fields->{text} =~ /\n$/s;
    }
    if ($tag eq 'span') {
	_append_text($self, ' ')
	    unless $fields->{soft_newline};
    }
    return;
}

sub unsafe_get_link_for_text {
    my($self, $text) = @_;
    my($fields) = $self->[$_IDI];
    my($index) = $text =~ /.*?\{(\d+)\}/;
    return undef
	unless defined($index) && $index < @{$fields->{links}};
    my($url) = $fields->{links}->[$index];
    return $url if $url =~ m{\://};
    return URI->new_abs($url, $fields->{url})->as_string;
}

sub _append_text {
    my($self, $text) = @_;
    my($fields) = $self->[$_IDI];
    $text =~ s/\s+/ /g;
    my($leading_white) = $text =~ /^(\s+)/;
    my($trailing_white) = $text =~ /\S(\s+)$/;
    if ($fields->{soft_newline} && $fields->{text} !~ /\n$/s) {
	$fields->{text} .= "\n";
	$fields->{soft_newline} = 0;
    }
    my($value) = join('',
	$fields->{text} =~ /\s$/ || $fields->{text} eq ''
	    ? ''
	    : ($leading_white ? ' ' : ''),
	${$_S->canonicalize_charset($_HTML->unescape($text))},
	$trailing_white ? ' ' : '',
    );
    $fields->{text} .= $value;
    return;
}

sub _parse_text {
    my($parser, $text) = @_;
    my($self) = $parser->{__PACKAGE__};
    _append_text($self, $text);
}

1;
