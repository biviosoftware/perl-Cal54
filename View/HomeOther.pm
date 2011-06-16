# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::HomeOther;
use strict;
use Bivio::Base 'View.HomeBase';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub error_default {
    return shift->internal_body(
	vs_text_as_prose('title', [[qw(->req task_id)], '->get_name']),
	b_use('View.Error')->default_body,
    );
}

sub internal_body {
    my($self, $title, $body) = @_;
    return $self->SUPER::internal_body(Join([
	Grid([[
	    $self->internal_logo->put(cell_class => 'c4_left'),
	    DIV_c4_home_title($title)
		->put(cell_class => 'c4_right'),
	]], {
	    class => 'c4_grid c4_suggest_site',
	}),
	DIV_c4_home_other($body),
	$self->internal_copy,
    ]));
}

sub suggest_site {
    return shift->internal_body(
	vs_text_as_prose('title.C4_HOME_SUGGEST_SITE'),
	vs_simple_form('SuggestSiteForm', [
	    map({"SuggestSiteForm.$_"} qw(suggestion email)),
	]),
    );
}

1;
