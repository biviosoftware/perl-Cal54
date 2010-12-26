# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::Home;
use strict;
use Bivio::Base 'View.Method';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('HTMLFormat.DateTime');

#TODO: Deal with not found URIs.  SITE_ROOT must have uri /*, but we don't want to find any page to be this page.

sub list {
    my($self) = @_;
    view_class_map('XHTMLWidget');
    view_shortcuts(b_use('View.ThreePartPage')->VIEW_SHORTCUTS);
    view_main(
	Page3({
	    style => RealmCSS(),
	    body_class => 'c4_home',
	    head => Title(['CAL 54']),
	    body => _body(),
	    xhtml => 1,
	}),
    );
    return;
}

sub pre_compile {
    return;
}

sub _body {
    return Join([
	_dummy_form(),
	DIV_c4_list(
	    List(HomeList => [
		DIV_date(['month_day']),
		DIV_item(Join([
		    DIV_line(
			Link(
			    Join([
				String(['start_end_am_pm']),
				', ',
				String(['RealmOwner.display_name']),
			    ]),
			    Or(['CalendarEvent.url'], ['calendar.Website.url']),
			),
		    ),
		    DIV_line(Join([
			Link(
			    String(['owner.RealmOwner.display_name']),
			    ['Website.url'],
			),
			String(', '),
			Link(
			    String(['address']),
			    ['map_uri'],
			),
		    ])),
		    DIV_excerpt(String(['excerpt'])),
		])),
	    ]),
	),
	DIV_c4_copy(Prose(
	    "&copy; @{[__PACKAGE__->use('Type.DateTime')->now_as_year]} SPAN_c4_site_name('CAL 54');")),
    ]);
}

sub _dummy_form {
    return FORM_c4_query({
	value => Join([
	    Image({
		src => 'logo',
		alt_text => 'CAL 54',
		class => 'c4_logo',
	    }),
	    DIV_item(Join([
		SPAN('Where are you?'),
		INPUT({
		    VALUE => 'Boulder',
		    DISABLED => 1,
		}),
	    ])),
	    DIV_item(Join([
		SPAN('What kind of event?'),
		INPUT({
		    VALUE => 'music',
		    DISABLED => 1,
		}),
	    ])),
	    DIV_item(Join([
		SPAN('When are you free?'),
		INPUT({
		    VALUE => 'now',
		    DISABLED => 1,
		}),
	    ])),
	    DIV_item(Join([
		INPUT({
		    TYPE => 'submit',
		    DISABLED => 1,
		    VALUE => "Let's go!",
		}),
	    ])),
	    XLink('venue_list'),
	]),
    });
}

sub _dummy_list {
    return DIV_c4_list(Join([
	DIV_date('December 13, 2010'),
	DIV_item(Join([
	    Link(String(qq{9pm, Jeff Jenkins' Piano Conversations}), '/jj', 'c4_go'),
	    Link(String(qq{Dazzle Jazz, 930 Lincoln St, Denver, CO 80203, 303.839.5100}), '/dazzlejazz.com', 'c4_go'),
	    DIV_excerpt(String(q{Think Marian McPartland's piano jazz, only live!  Jeff Jenkins, one of the country's premier pianists, will be bringing in different guests every week to play and converse with.})),
	])),
	DIV_item(Join([
	    Link(String(qq{9pm, Jeff Jenkins' Piano Conversations}), '/', 'c4_go'),
	    Link(String(qq{Dazzle Jazz, 930 Lincoln St, Denver, CO 80203, 303.839.5100}), '/dazzlejazz.com', 'c4_go'),
	    DIV_excerpt(String(q{Think Marian McPartland's piano jazz, only live!  Jeff Jenkins, one of the country's premier pianists, will be bringing in different guests every week to play and converse with.})),
	])),
	DIV_date('December 14, 2010'),
	DIV_item(Join([
	    Link(String(qq{9pm, Jeff Jenkins' Piano Conversations}), '/', 'c4_go'),
	    Link(String(qq{Dazzle Jazz, 930 Lincoln St, Denver, CO 80203, 303.839.5100}), '/dazzlejazz.com', 'c4_go'),
	    DIV_excerpt(String(q{Think Marian McPartland's piano jazz, only live!  Jeff Jenkins, one of the country's premier pianists, will be bringing in different guests every week to play and converse with.})),
	])),
    ]));
}

1;
