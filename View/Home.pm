# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::Home;
use strict;
use Bivio::Base 'View.Method';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
	FORM_c4_query({
	    value => Join([
		Image({
		    src => 'logo',
		    alt_text => 'CAL 54',
		    class => 'c4_logo',
		}),
		DIV_item(Join([
		    SPAN('Where are you?'),
		    INPUT({
			VALUE => 'Denver',
		    }),
		])),
		DIV_item(Join([
		    SPAN('What kind of event?'),
		    INPUT({
			VALUE => 'music',
		    }),
		])),
		DIV_item(Join([
		    SPAN('When are you free?'),
		    INPUT({
			VALUE => 'now',
		    }),
		])),
		DIV_item(Join([
		    INPUT({
			TYPE => 'submit',
			VALUE => "Let's go!",
		    }),
		])),
		Link('My Site', 'MY_SITE'),
	    ]),
	}),
	DIV_c4_list(Join([
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
	    DIV_c4_copy(Prose(
		"&copy; @{[__PACKAGE__->use('Type.DateTime')->now_as_year]} SPAN_c4_site_name('CAL 54');")),
	])),
    ]);
}

sub _list {
    my($self) = @_;
    return vs_list(CalendarEventMonthList => [
	['RealmOwner.name', {
	    column_widget => Join([
		Link(
		    Join([
			SPAN_title(String(['CalendarEvent.title'])),
			SPAN_description(String(['CalendarEvent.description'])),
		    ]),
		    ['CalendarEvent.url'],
		),
	    ]),
	}],
    ]);
    return;
}

1;
