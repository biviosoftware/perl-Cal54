# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::HomeBase;
use strict;
use Bivio::Base 'View.Method';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');

sub internal_body {
    my(undef, $body) = @_;
    view_put(
	home_base_body => $body,
    );
    return;
}

sub internal_copy {
    return DIV_c4_copy(Prose(
	"&copy; @{[$_DT->now_as_year]} SPAN_c4_site_name('CAL 54&trade;'); Boulder's Calendar&trade;"));
    
}

sub internal_logo {
    return Link(
	Join([
	    SPAN_c4_logo_name('CAL 54'),
	    SPAN_c4_logo_tag(q{Boulder's Calendar}),
	]),
	'C4_HOME_LIST',
	'c4_logo_text',
    );
}

sub xhtml {
    view_class_map('XHTMLWidget');
    view_shortcuts(b_use('View.ThreePartPage')->VIEW_SHORTCUTS);
    view_put(
	home_base_body => '',
    );
    view_main(
	Page3({
	    style => RealmCSS('HomeCSS->site_css'),
	    body_class => IfMobile(
		'c4_mobile c4_home',
		'c4_home',
	    ),
	    head => Join([
		Title(['CAL 54', q{Boulder's Calendar}, 'Events, Concerts, Lectures']),
		MobileDetector(),
		IfMobile(
		    META({
			NAME => 'viewport',
			CONTENT => 'width=device-width',
		    }),
		),
	    ]),
	    body => view_widget_value('home_base_body'),
	    xhtml => 1,
	}),
    );
    return;
}

sub pre_compile {
    my($self) = @_;
    view_parent('HomeBase->xhtml')
	unless $self->get('view_name') eq 'xhtml';
    return;
}

1;
