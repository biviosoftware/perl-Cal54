# Copyright (c) 2010-2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::Home;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_DT) = b_use('Type.DateTime');

sub error_default {
    return _title_and_body(
	shift,
	vs_text_as_prose('title', [[qw(->req task_id)], '->get_name']),
	b_use('View.Error')->default_body,
    );
}

sub list {
    my($self) = @_;
    view_pre_execute(sub {
	# Facebook only checks once a day so setting to an hour for "this"
	# pages is reasonable.  Setting the search page to one minute allows
	# us to avoid multiple hits from facebook on /search.
        my($req) = shift->req;
        $req->get('reply')
	    ->set_cache_max_age(
		$req->get('Model.HomeList')->c4_has_cursor ? 60 * 60 : 60,
		$req,
	    );
	return;
    });
    view_unsafe_put(
	xhtml_adorned_title => _head_title_and_meta($self),
	xhtml_title => '',
	xhtml_dock_left => _nav_bar($self),
    );
    return $self->internal_body(Join([
	LocalFileAggregator({
	    view_values => [
		InlineJavaScript(Simple(<<'EOF')),
$(function () {
    'use strict';
    $('#bivio_search_field').click(function () {
        if (window.innerWidth < 767) {
            var that = this;
            setTimeout(function() {
                that.setSelectionRange(0, 9999);
            }, 1);
            $('html, body').animate({
                scrollTop: $('#bivio_search_field').offset().top - 5
            }, 500);
        }
    });
});
EOF
	    ],
	}),
	DIV_row(
	    DIV(
		_list($self),
		'col-lg-offset-2 col-lg-8 col-md-offset-1 col-md-9',
	    ),
	),
    ]));
}

sub suggest_site {
    my($self) = @_;
    return _title_and_body(
	$self,
	vs_text_as_prose('title.C4_HOME_SUGGEST_SITE'),
	vs_placeholder_form('SuggestSiteForm', [
	    map({"SuggestSiteForm.$_"} qw(suggestion email)),
	    '*ok_button',
	]),
    );
}

sub wiki_view {
    view_unsafe_put(
	xhtml_title => '',
    );
    return _title_and_body(
	shift,
	vs_text_as_prose('wiki_view_topic'),
	Wiki(),
    );
}

sub _abs_uri {
    return URI({
	uri => shift,
	require_absolute => 1,
	facade_uri => 'cal54',
    });
}

sub _event_name_link {
    my($self) = @_;
    return UserTrackingLink(
	H4(
	    String(['RealmOwner.display_name']),
	    {
		ITEMPROP => 'name',
	    },
	),
	IfRobot(
	    If(
		['->c4_has_this'],
		Or(['CalendarEvent.url'], ['calendar.Website.url']),
		['->c4_format_uri'],
	    ),
	    Or(['CalendarEvent.url'], ['calendar.Website.url']),
	),
	{
	    class => 'text-info',
	    ITEMPROP => 'url',
	},
    );
}

sub _head_title_and_meta {
    return Join([
	Title(['CAL54', vs_text('c4_home_title')]),
	map(_meta(@$_),
	    [title => ['Model.HomeList', '->c4_title']],
	    [site_name => vs_site_name()],
	    [image => _abs_uri(['UI.Facade', 'Icon', '->get_uri', 'fb-logo'])],
	    [type => 'activity'],
	    [url => _abs_uri(['Model.HomeList', '->c4_format_uri'])],
	    [app_id => '237465832943306'],
	    [locale => 'en_US'],
	),
	META({
	    NAME => 'robots',
	    CONTENT => 'noarchive',
	    control => ['Model.HomeList', '->c4_noarchive'],
	}),
	If(
	    ['Model.HomeList', '->c4_has_cursor'],
	    Join([
		map(_meta(@$_),
		    [description => ['Model.HomeList', '->c4_description']],
		    ['street-address' => ['Model.HomeList', 'Address.street1']],
		    ['locality' => ['Model.HomeList', 'Address.city']],
		    ['region' => ['Model.HomeList', 'Address.state']],
		    ['postal-code' => ['Model.HomeList', 'Address.zip']],
		    ['country-name' => ['Model.HomeList', 'Address.country']],
		    ['phone_number' => ['Model.HomeList', 'Phone.phone']],
		),
	    ]),
	),
	If(
	    [['Model.HomeList', '->get_query'], 'has_next'],
	    LINK({
		REL => 'next',
		HREF => URI({
		    require_absolute => 1,
		    query => ['Model.HomeList', '->format_query', 'NEXT_LIST'],
		}),
	    }),
	),
	If(
	    [['Model.HomeList', '->get_query'], 'has_prev'],
	    LINK({
		REL => 'prev',
		HREF => URI({
		    require_absolute => 1,
		    query => ['Model.HomeList', '->format_query', 'PREV_LIST'],
		}),
	    }),
	),
    ]);
}

sub _list {
    my($self) = @_;
    return Join([
	DIV_c4_list(Join([
	    H3(vs_text('c4_home_list_title'))->put(
		class => 'text-primary hidden-xs',
	    ),
	    Grid([[
		List(HomeList => [
		    DIV_date(['month_day']),
		    DIV_item(Join([
			DIV_line(_event_name_link($self)),
			Join([
			    _meta_dates(),
			    SPAN_time(String(['start_end_am_pm'])),
			    ' ',
			    SPAN_excerpt(
				String(['excerpt']),
				{
				    ITEMPROP => 'description',
			        },
			    ),
			    DIV_line(Join([
				UserTrackingLink(
				    SPAN(
					String(['venue.RealmOwner.display_name']),
					{
					    ITEMPROP => 'name',
					},
				    ),
				    ['Website.url'],
				    {
					class => 'venue',
					ITEMPROP => 'url',
				    },
				),
				' ',
				SPAN(
				    Join([
					UserTrackingLink(
					    String(['address']),
					    ['map_uri'],
					    {
						class => 'address',
						ITEMPROP => 'maps',
					    },
					),
					_meta_address(),
				    ]),
				    {
					ITEMPROP  => 'address',
					ITEMTYPE => 'http://schema.org/PostalAddress',
					ITEMSCOPE => 'itemscope',
				    },
				),
				If(['Phone.phone'],
				    Join([
					' ',
					SPAN_phone(
					    String(['Phone.phone']),
					    {
						ITEMPROP => 'telephone',
					    },
					),
				    ]),
				),
			    ]), {
				ITEMPROP => 'location',
				ITEMSCOPE => 'itemscope',
				ITEMTYPE => 'http://schema.org/LocalBusiness',
			    }),
			]),
		    ]), {
			ITEMSCOPE => 'itemscope',
			ITEMTYPE => 'http://schema.org/Event',
		    }),
		], {
		    empty_list_widget => DIV_c4_empty_list(
			q{Your search didn't match any results.  Try a different query.},
		    ),
		    cell_align => 'top',
		}),
	    ]]),
	])),
	Link(
	    String(vs_text('next_button')),
	    ['Model.HomeList', '->format_uri', 'NEXT_LIST'],
	    {
		class => 'btn btn-primary btn-lg c4_next_button',
		control => [['Model.HomeList', '->get_query'], 'has_next'],
		REL => 'next',
	    },
	),
    ]);
}

sub _meta {
    my($n, $v) = @$_;
    return META({
	PROPERTY => ($n eq 'app_id' ? 'fb' : 'og') . ":$n",
	# May be unitialized, and Join doesn't like that
	CONTENT => Or($v, ''),
    });
}

sub _meta_address {
    return map(
	META(
	    {
		CONTENT => ["Address.$_->[0]"],
		ITEMPROP => $_->[1],
	    },
	),
	[qw(street1 streetAddress)],
	[qw(city addressLocality)],
	[qw(state addressRegion)],
	[qw(zip postalCode)],
	[qw(country addressCountry)],
    );
}

sub _meta_dates {
    return map(
	META(
	    {
		CONTENT => [
		    sub {$_DT->to_xml($_[1])},
		    ["CalendarEvent.dt$_"],
		],
		ITEMPROP => $_ . 'Date',
	    },
	),
	qw(start end),
    );
}

sub _nav_bar {
    return NAV(
	DIV_container(	    
	    DIV_row(Join([
		DIV(
		    Link(
			Image('logo'),
			'C4_HOME_LIST',
		    ),
		    'col-md-3 col-md-offset-1 col-sm-4 c4_logo_holder',
		),
		DIV(
		    Form(
			'HomeQueryForm',
			Join([
			    DIV(
				Join([
				    Text('what', {
					ID => 'bivio_search_field',
					size => 50,
					class => 'form-control input-lg',
				    }),
				    SPAN(
					BUTTON('Search', {
					    class => 'btn btn-default btn-lg',
					    TYPE => 'submit',
					}),
					'input-group-btn'
				    ),
				]),
				'input-group',
			    ),
			    IfRobot(
				BR(),
				DIV(
				    C4HomePager(0),
				    'hidden-xs',
				),
			    ),
			]),
		    )->put(
			class => 'navbar-form',
			form_method => 'get',
			want_hidden_fields => 0,
		    ),
		    'col-sm-8 col-md-7',
		),
	    ]),	
	)),
    )->put(class => 'navbar navbar-default navbar-static-top');
}

sub _title_and_body {
    my($self, $title, $body) = @_;
    view_unsafe_put(
	xhtml_dock_left => NAV(DIV_container(	    
	    DIV_row(Join([
		DIV(
		    Link(
			Image('logo'),
			'C4_HOME_LIST',
		    ),
		    'c4_logo_subform',
		),
	    ])),
	))->put(class => 'navbar navbar-default navbar-static-top'),
    );
    return $self->internal_body(Join([
	DIV_c4_home_other($body),
    ]));
}

1;
