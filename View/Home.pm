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

sub list_mobile {
    my($self) = @_;
    view_class_map('XHTMLWidget');
    view_shortcuts(b_use('View.ThreePartPage')->VIEW_SHORTCUTS);
    view_main(
	Page3({
	    style => RealmCSS(),
	    body_class => 'c4_home_mobile',
	    head => Join([
		Title(['CAL 54']),
		Simple('<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0"/>'),
	    ]),
	    body => _body_mobile(),
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

sub _body_mobile {
    return Join([
	_form_mobile(),
	_list_mobile(),
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
	    DIV_c4_site_tag(vs_text_as_prose('c4_site_tag')),
	    DIV_item(Join([
		SPAN('Where are you?'),
		Text('where', {is_read_only => 1, size => 50}),
	    ])),
	    DIV_item(Join([
		SPAN('When are you free?'),
		Text('when', {is_read_only => 1, size => 50}),
	    ])),
	    DIV_item(Join([
		SPAN('What kind of event?'),
		Text('what', {size => 50}),
	    ])),
	    DIV_item(Join([
		INPUT({
		    TYPE => 'submit',
		    VALUE => "Let's go!",
		}),
	    ])),
	]),
    });
}

sub _form_mobile {
    return DIV_mobile_head(Form({
	form_class => 'MobileQueryForm',
	form_method => 'get',
	class => 'mobile c4_query',
	want_hidden_fields => 0,
	value => Join([
	    Script('toggle_form'),
	    DIV(Join([
		Link(' - ', '#', 'increase_font',
		     {
			 class => 'decrease_font_size',
			 ONCLICK => 'font_size(0);return false'
		     }
		 ),
		DIV_logo_group(
		    Join([
			Image({
			    src => 'logo',
			    alt_text => 'CAL 54',
			    class => 'c4_logo',
			    ONCLICK => If([qw(->req query)], 'toggle_form()'),
			}),
			DIV_c4_site_desc(vs_text_as_prose('c4_site_tag')),
		    ]),
		),
		Link(' + ', '#', 'decrease_font',
		     {
			 class => 'increase_font_size',
			 ONCLICK => 'font_size(1);return false'
		     }
		 ),
	    ])),
	    DIV(Join([
		DIV_item(Join([
		    SPAN('What?'),
		    Text('what', {size => 50}),
		])),
		DIV_item(Join([
		    SPAN('When?'),
		    Text('when', {is_read_only => 1, size => 50}),
		])),
		DIV_item(Join([
		    INPUT({
			TYPE => 'submit',
			VALUE => "Search",
			ONCLICK => 'toggle_form()',
		    }),
		])),
	    ]),
		{
		    id => 'c4_inputs',
		}),
	    If ([qw(->req query)],
		DIV('&#9660;',
		    {
			class => 'toggle arrow',
			id => 'c4_inputs_toggle_button',
			ONCLICK => 'toggle_form()',
		    }),
		DIV('&#9650;',
		    {
			class => 'toggle arrow',
			id => 'c4_inputs_toggle_button',
		    }),
	    ),
	]),
    }));
}

sub _list {
    return DIV_c4_list(Join([
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

sub _list_mobile {
    return If(Simple([sub {defined(shift->req->get('query'))}]),
	      DIV(Join([
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
	      ]),
		  {
		      class => 'mobile c4_list',
		  }
	      ),
	  )
}

1;
