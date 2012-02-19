# Copyright (c) 2010-2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::Home;
use strict;
use Bivio::Base 'View.HomeBase';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');
my($_HTML) = b_use('Bivio.HTML');
my($_F) = b_use('UI.Facade');

#TODO: If there is no event page, then render the description in a little popup window

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
    view_put(
	home_base_html_tag_attrs => ' xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://www.facebook.com/2008/fbml" xmlns:og="http://ogp.me/ns#" xml:lang="en_US" lang="en_US"',
	home_base_head => Join([
	    Title(['CAL54', ['Model.HomeList', '->c4_title']]),
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
	]),
    );
    return $self->internal_body(Join([
	Form({
	    form_class => 'HomeQueryForm',
	    class => 'c4_form',
	    STYLE => 'z-index:1000',
	    form_method => 'get',
	    want_hidden_fields => 0,
	    value => IfMobile(
		DIV_c4_mobile_header(
		    Join([
			$self->internal_logo,
			_form(),
		    ]),
		),
		Grid([[
		    $self->internal_logo
			->put(cell_class => 'c4_left'),
		    _form()->put(cell_class => 'c4_right'),
		]], {
		    class => 'c4_grid',
		}),
	    ),
	}),
	_list($self),
    ]));
}

sub _abs_uri {
    return URI({
	uri => shift,
	require_absolute => 1,
	facade_uri => 'cal54',
    });
}

sub _form {
    return DIV_c4_query(
	Join([
	    Hidden('when'),
	    Text('what', {class => 'c4_what', size => 50}),
	    INPUT({
		TYPE => 'submit',
		VALUE => 'Search',
		class => 'submit',
	    }),
	    vs_unless_robot(IfMobile('', C4HomePager(0))),
	]),
    );
}

sub _list {
    my($self) = @_;
    return Join([
	vs_unless_robot(
	    IfMobile(
		Link(
		    String(vs_text('previous_button')),
		    ['Model.HomeList', '->format_uri', 'PREV_LIST'],
		    {
			class => 'c4_prev_button',
			control => [['Model.HomeList', '->get_query'], 'has_prev']
		    },
		),
	    ),
	),
	DIV_c4_list(Join([
	    IfMobile('', DIV_c4_home_list_title(vs_text('c4_home_list_title'))),
	    Grid([[
		List(HomeList => [
		    DIV_date(['month_day']),
		    DIV_item(Join([
			DIV_line(Join([
			    If(
				vs_unless_robot(1, ['->c4_has_this']),
				UserTrackingLink(
				    SPAN(
					String(['RealmOwner.display_name']),
					{
					    ITEMPROP => 'name',
					},
				    ),
				    Or(['CalendarEvent.url'], ['calendar.Website.url']),
				    {
					class => 'title',
					ITEMPROP => 'url',
				    },
				),
				Link(
				    SPAN(
					String(['RealmOwner.display_name']),
					{
					    ITEMPROP => 'name',
					},
				    ),
				    ['->c4_format_uri'],
				    {
					class => 'title',
					ITEMPROP => 'url',
				    },
				),
			    ),
			])),
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
		    cell_expand => 1,
		    cell_align => 'top',
		}),
	    ]]),
	])),
	Link(
	    String(vs_text('next_button')),
	    ['Model.HomeList', '->format_uri', 'NEXT_LIST'],
	    {
		class => 'c4_next_button',
		control => [['Model.HomeList', '->get_query'], 'has_next'],
	    },
	),
	$self->internal_footer,
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

1;
