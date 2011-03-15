# Copyright (c) 2010-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::Home;
use strict;
use Bivio::Base 'View.Method';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('HTMLFormat.DateTime');
my($_D) = b_use('Type.Date');

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
	    body => Join([
#		ABTest()->choice_links(qw(x2 x3 x4 x5)),
		_body(),
	    ]),
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
    return ABTest(
	x5 => Join([
	    Form({
		form_class => 'HomeQueryForm',
		class => 'c4_form',
		form_method => 'get',
		want_hidden_fields => 0,
		value => Grid([[
		    _logo()->put(cell_class => 'c4_left'),
		    _form()->put(cell_class => 'c4_right'),
		]], {
		    class => 'c4_grid',
		}),
	    }),
	    DIV_x5_list(_list()),
	]),
	Form({
	    form_class => 'HomeQueryForm',
	    class => 'c4_form',
	    form_method => 'get',
	    want_hidden_fields => 0,
	    value => ABTest(
		x1 => Grid(
		    [
			[
			    _logo()->put(cell_class => 'c4_left'),
			    _form()->put(cell_class => 'c4_right'),
			],
			[
			    _sidebar()
				->put(cell_class => 'c4_left c4_list'),
			    _list()->put(
				cell_class => 'c4_right c4_list',
				cell_colspan => 2,
			    ),
			],
		    ],
		    {class => 'c4_grid'},
		),
		x2 => Grid(
		    [
			[
			    _logo()->put(cell_class => 'c4_left'),
			    _form()->put(cell_class => 'c4_right'),
			],
			[
			    _list()->put(
				cell_class => 'c4_right c4_list',
				cell_colspan => 2,
			    ),
			],
		    ],
		    {class => 'c4_grid'},
		),
		Join([
		    Grid([[
			_logo()->put(cell_class => 'c4_left'),
			_form()->put(cell_class => 'c4_right'),
		    ]], {
			class => 'c4_grid',
		    }),
		    _list(),
		]),
	    ),
	}),
    );
}

sub _body_mobile {
    return Join([
	_form_mobile(),
	_list_mobile(),
    ]);
}

sub _form {
    return DIV_c4_query(
	Join([
	    Hidden('when'),
	    ABTest()->hidden_form_field(),
	    Text('what', {class => 'c4_what', size => 50}),
	    INPUT({
		TYPE => 'submit',
		VALUE => 'Search',
		class => 'submit',
	    }),
	    ABTest(x5 => [\&_x5_pager]),
	]),
    );
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
    return Join([
	DIV_c4_list(List(HomeList => [
	    DIV_date(['month_day']),
	    DIV_item(Join([
		DIV_line(Join([
		    Link(
			String(['RealmOwner.display_name']),
			Or(['CalendarEvent.url'], ['calendar.Website.url']),
			'title',
		    ),
		])),
		ABTest(
		    qr{x1|x2} => Join([
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
		    ]),
		    Join([
			SPAN_time(String(['start_end_am_pm'])),
			' ',
			SPAN_excerpt(String(['excerpt'])),
			DIV_line(Join([
			    Link(
				String(['venue.RealmOwner.display_name']),
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
		    ]),
		),
	    ])),
	], {
	    empty_list_widget => DIV_c4_empty_list(
		q{Your search didn't match any results.  Try a different query.},
	    ),
	})),
	ABTest(
	    x3 => DIV_c4_pager(Join([
		Link('<< Earlier', '#', 'back'),
		SPAN_c4_month('March'),
		map(Link($_, '#', 'c4_day'), qw(29 30 31)),
		SPAN_c4_month('April'),
		map(Link($_, '#', 'c4_day'), qw(1 2 3 4)),
		Link('Later >>', '#', 'next'),
	    ])),
	    x4 => DIV_c4_pager(Join([
		_month(3),
		_month(4),
		_month(5),
	    ])),
	),
	DIV_c4_copy(Prose(
	    "&copy; @{[__PACKAGE__->use('Type.DateTime')->now_as_year]} SPAN_c4_site_name('CAL 54&trade;'); Boulder's Calendar&trade;")),
    ]);
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

sub _logo {
    return ABTest(
	x1 => Image({
	    src => 'logo',
	    alt_text => 'CAL 54',
	    class => 'c4_logo',
	}),
	x2 => DIV_c4_logo_text(
	    Join([
		SPAN_c4_logo_name('CAL 54'),
		SPAN_c4_logo_tag(q{Boulder's Calendar}),
	    ]),
	),
	DIV_c4_logo_text(
	    Join([
		SPAN_c4_logo_name('CAL 54'),
		SPAN_c4_logo_tag(q{Boulder's Calendar}),
	    ]),
	),
    );
}

sub _month {
    my($which) = @_;
    my($now) = $_D->local_today;
    my($d) = $_D->date_from_parts(1, $which, 2011);
    my($name) = $_D->english_month($_D->get_parts($d, 'month'));
    my($bom) = $d;
    my($eom) = $_D->set_end_of_month($bom);
    $d = $_D->set_beginning_of_week($bom);
    my($eow) = $_D->set_end_of_week($eom);
    my($done) = 0;
    return Grid(
	[
	    [
		String(
		    $name,
		    {
			cell_class => 'c4_month_name',
			cell_colspan => 7,
		    },
		),
	    ],
	    [
		map(
		    String($_, {cell_class => 'c4_day_name c4_day'}),
		    qw(S M T W T F S),
		),
	    ],
	    map(
		$done ? () : [
		    map(
			{
			    my($res) = ' ';
			    my($class) = 'c4_day_none';
			    unless ($done || $_D->is_less_than($d, $bom)) {
				if ($_D->is_greater_than($d, $eom)) {
				    $done = 1;
				}
				else {
				    $res = $_D->get_parts($d, 'day');
				    $class = $_D->is_less_than($d, $now)
					? 'c4_day_disabled'
					: 'c4_day_link';
				}
			    }
			    $d = $_D->add_days($d, 1);
			    $class eq 'c4_day_link'
				? Link(
				    String($res),
				    URI({
					query => {
					    when => $_D->to_string($d),
					    what => [qw(->ureq query what)],
					},
				    }),
				    {cell_class => "$class c4_day"},
				)
				: String(
				    $res,
				    {
					cell_class => "$class c4_day",
					hard_spaces => 1,
				    },
				);
			}
			1 .. 7,
		    ),
		],
		1 .. 6,
	    ),
	],
	{class => 'c4_month'},
    ),
}

sub _sidebar {
    return Join([
	DIV_c4_sidebar_title(String('When')),
	Join([
	    DIV_c4_sidebar_list(List(
		'WhenList',
		[Link(
		    ['item'],
		    URI({
			query => ['->search_query'],
		    }),
		)],
	    )),
	    SCRIPT({
		TYPE => 'text/javascript',
		SRC => '/b/mattkruse/CalendarPopup.js',
		tag_if_empty => 1,
		value => '',
	    }),
	    SCRIPT({
		TYPE => 'text/javascript',
		value => q{var cal1x = new CalendarPopup("c4_cal_popup"); cal1x.setCssPrefix("c4_cal_"); var now = new Date();(now.setDate(now.getDate() - 1)); cal1x.addDisabledDates(null, now.toLocaleDateString());},
	    }),
	    INPUT({
		TYPE => 'text',
		NAME => 'date1x',
		VALUE => '',
		SIZE => '12',
		class => 'c4_cal_input',
	    }),
	    Simple(q{<A HREF="#" onClick="cal1x.select(document.forms[0].date1x,'anchor1x','MM/dd/yyyy'); return false;" NAME="anchor1x" ID="anchor1x">&#9660;</A>}),
	    DIV({
		tag_if_empty => 1,
		value => '',
		id => 'c4_cal_popup',
	    }),
	    DIV_c4_sidebar_spacer(''),
	]),
	DIV_c4_sidebar_title(String('Popular Searches')),
	DIV_c4_sidebar_list(List(
	    'PopularList',
	    [Link(
		['item'],
		URI({
		    query => ['->search_query'],
		}),
	    )],
	)),
    ]);
}

sub _when_uri {
    my($date) = @_;
    $date = $_D->to_string($date);
    return URI({
	query => {
	    when => $date,
	    what => Join([
		[
		    sub {
			my(undef, $what) = @_;
			$what = ''
			    unless defined($what);
			$what =~ s{(\d+/\d+(?:/\d+)?)\s+}{};
			return $what;
		    },
		    [qw(->ureq query what)],
		],
	    ]),
	},
    });
}

sub _x5_pager {
    my($source) = @_;
    my($now) = $_D->local_today;
    my($when) = ($_D->from_literal($source->ureq(qw(query when))))[0]
	|| $now;
    my($start) = $_D->set_beginning_of_week($when);
    my($prev) = $_D->add_days($start, -21);
    $prev = $now
	if $_D->is_less_than($prev, $now);
    my($first) = 1;
    return SPAN_c4_x5_pager(
	Join([
	    $_D->is_less_than($start, $now) ? ()
		: Link(
		    '<<',
		    _when_uri($prev),
		    'c4_x5_prev',
		),
	    map(
		{
		    my($week) = $_;
		    (
			$first ? () : SPAN_c4_x5_spacer(''),
			map(
			    {
				my($d) = $_D->add_days($start, $week * 7 + $_);
				my($selected) = $_D->is_equal($d, $when) ? ' selected' : '';
				my($day) = $_D->get_parts($d, 'day');
				my($wday) = $_D->english_day_of_week($d);
				my($weekend) = $_D->english_day_of_week($d) =~ /^s/i
				    ? ' c4_x5_weekend' : ''; 
				my($month) = [];
				if ($first || $day == 1) {
				    $month = [
					$first ? () : SPAN_c4_x5_spacer(''),
					SPAN_c4_x5_month(
					    $_D->english_month3($_D->get_parts($d, 'month')),
					),
				    ];
				    $first = 0;
				}
				(
				    @$month,
				    $_D->is_less_than($d, $now) ? ()
					: Link(
					    $day,
					    _when_uri($d),
					    {
						class => "c4_x5_day$selected$weekend",
						TITLE => $_D->english_day_of_week($d),
					    },
					),
				);
			    }
			    0 .. 6,
			),
		    );
		}
		0 .. 2,
	    ),
	    Link(
		'>>',
		_when_uri($_D->add_days($start, +21)),
		'c4_x5_next',
	    ),
	]),
    );
}

1;
