# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::HomeBase;
use strict;
use Bivio::Base 'View.Method';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');

sub VIEW_SHORTCUTS {
    return 'Cal54::ViewShortcuts';
}

sub internal_body {
    my(undef, $body) = @_;
    view_put(
	home_base_body => $body,
    );
    return;
}

sub internal_footer {
    return Join([
	vs_unless_robot(
	    Join([
		IfMobile(
		    '',
		    XLink('C4_HOME_SUGGEST_SITE', 'c4_home_suggest_site'),
		),
		MobileToggler(),
	    ]),
	),
	TaskMenu([
	    'c4_about',
	    'C4_HOME_LIST',
	], {
	    class => 'c4_footer_menu task_menu',
	}),
	DIV_c4_copy(Prose(
	"&copy; @{[$_DT->now_as_year]} SPAN_c4_site_name('CAL54&trade;'); SPAN_c4_site_tag('Make a ');SPAN_c4_site_local('local');SPAN_c4_site_tag(' scene.&trade;');")),
    ]);
    
}

sub internal_logo {
    return Link(
	SPAN_c4_logo(''),
	'C4_HOME_LIST',
	'c4_logo',
    );
}

sub xhtml {
    my($proto) = @_;
    view_class_map('XHTMLWidget');
    view_shortcuts($proto->VIEW_SHORTCUTS);
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
		Title(['CAL54', q{Make a LOCAL scene}, 'Events, Concerts, Lectures, Live Music']),
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
