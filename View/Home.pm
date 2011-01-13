# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::Home;
use strict;
use Bivio::Base 'View.Method';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('HTMLFormat.DateTime');

#TODO: Deal with not found URIs.  SITE_ROOT must have uri /*, but we don't want to find any page to be this page.
#TODO: If there is no event page, then render the description in a little popup window

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
	_form(),
	_list(),
    ]);
}

sub _form {
    return Form({
	form_class => 'HomeQueryForm',
	form_method => 'get',
	class => 'c4_query',
	want_hidden_fields => 0,
	value => Join([
	    Image({
		src => 'logo',
		alt_text => 'CAL 54',
		class => 'c4_logo',
	    }),
	    DIV_c4_site_desc(vs_text_as_prose('c4_site_desc')),
	    DIV_item(Join([
		SPAN('Where are you?'),
		Text('where', {is_read_only => 1, size => 50}),
	    ])),
	    DIV_item(Join([
		SPAN('What kind of event?'),
		Text('what', {size => 50}),
	    ])),
	    DIV_item(Join([
		SPAN('When are you free?'),
		Text('when', {is_read_only => 1, size => 50}),
	    ])),
	    DIV_item(Join([
		INPUT({
		    TYPE => 'submit',
		    VALUE => "Let's go!",
		}),
	    ])),
	    DIV_c4_home_admin(Join([
		XLink('adm_calendar_event_list_form'),
		XLink('adm_venue_list'),
	    ])),
	]),
    });
}

sub _list {
    return DIV_c4_list(Join([
	DIV_c4_site_tag(vs_text_as_prose('c4_site_tag')),
	List(HomeList => [
	    DIV_date(['month_day']),
	    DIV_item(Join([
		DIV_line(Join([
		    SPAN_time(String(['start_end_am_pm'])),
		    ' ',
		    Link(
			String(['RealmOwner.display_name']),
			Or(['CalendarEvent.url'], ['calendar.Website.url']),
			'title',
		    ),
		])),
		DIV_line(Join([
		    Link(
			String(['owner.RealmOwner.display_name']),
			['Website.url'],
			'venue',
		    ),
		    ' ',
		    Link(
			String(['address']),
			['map_uri'],
			'address',
		    ),
		])),
		DIV_excerpt(String(['excerpt'])),
	    ])),
	], {
	    empty_list_widget => DIV_c4_empty_list(
		q{Your search didn't match any results.  Try a different query.},
	    ),
	}),
	DIV_c4_copy(Prose(
	    "&copy; @{[__PACKAGE__->use('Type.DateTime')->now_as_year]} SPAN_c4_site_name('CAL 54');")),
    ]));
}

1;
