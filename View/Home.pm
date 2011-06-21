# Copyright (c) 2010-2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::Home;
use strict;
use Bivio::Base 'View.HomeBase';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');

#TODO: If there is no event page, then render the description in a little popup window

sub list {
    my($self) = @_;
    return $self->internal_body(Join([
	Form({
	    form_class => 'HomeQueryForm',
	    class => 'c4_form',
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
	    _no_robots([\&_pager, 0]),
	]),
    );
}

sub _list {
    my($self) = @_;
    return Join([
	IfMobile(
	    Link(
		String(vs_text('previous_button')),
		['Model.HomeList', '->format_uri', 'PREV_LIST'],
		{
		    class => 'c4_prev',
		    control => [['Model.HomeList', '->get_query'], 'has_prev']
		},
	    ),
	),
	DIV_c4_list(List(HomeList => [
	    DIV_date(['month_day']),
	    DIV_item(Join([
		DIV_line(Join([
		    UserTrackingLink(
			String(['RealmOwner.display_name']),
			Or(['CalendarEvent.url'], ['calendar.Website.url']),
			'title',
		    ),
		])),
		Join([
		    SPAN_time(String(['start_end_am_pm'])),
		    ' ',
		    SPAN_excerpt(String(['excerpt'])),
		    DIV_line(Join([
			UserTrackingLink(
			    String(['venue.RealmOwner.display_name']),
			    ['Website.url'],
			    'venue',
			),
			' ',
			UserTrackingLink(
			    String(['address']),
			    ['map_uri'],
			    'address',
			),
			If(['Phone.phone'],
			   Join([
			       ' ',
			       SPAN_phone(['Phone.phone']),
			   ]),
		       ),
		    ])),
		]),
	    ])),
	], {
	    empty_list_widget => DIV_c4_empty_list(
		q{Your search didn't match any results.  Try a different query.},
	    ),
	})),
	IfMobile(
	    Link(
		String(vs_text('next_button')),
		['Model.HomeList', '->format_uri', 'NEXT_LIST'],
		{
		    class => 'c4_next',
		    control => [['Model.HomeList', '->get_query'], 'has_next'],
		},
	    ),
	),
	_no_robots(DIV(
	    [\&_pager, 1,],
	    {class => 'c4_query c4_bottom_pager'},
	)),
	IfMobile(
	    '',
	    XLink('C4_HOME_SUGGEST_SITE', 'c4_suggest_link'),
	),
	_no_robots(MobileToggler()),
	$self->internal_copy,
    ]);
}

sub _no_robots {
    my($widget) = @_;
    return If(['!', 'Type.UserAgent', '->eq_browser_robot'], $widget);
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

sub _pager {
    my($source, $is_bottom) = @_;
    my($mobile) = 0;
    IfMobile(1)->initialize_and_render($source, \$mobile);
    my($now) = $_D->local_today;
    my($when) = ($_D->from_literal($source->ureq(qw(query when))))[0]
	|| $now;
    my($start) = $_D->set_beginning_of_week($when);
    my($weeks) = $mobile ? 2 : 3 + $is_bottom * 2;
    my($prev) = $_D->add_days($start, -3 * 7);
    $prev = $now
	if $_D->is_less_than($prev, $now);
    my($first) = 1;
    return SPAN_c4_pager(
	IfMobile(
	    String(''),
	    Join([
		$_D->is_less_than($start, $now) ? ()
		    : Link(
			'<<',
			_when_uri($prev),
			'c4_prev',
		    ),
		map(
		    {
			my($week) = $_;
			(
			    $first ? () : SPAN_c4_week_spacer(''),
			    map(
				{
				    my($d) = $_D->add_days($start, $week * 7 + $_);
				    my($selected) = $_D->is_equal($d, $when) ? ' selected' : '';
				    my($day) = $_D->get_parts($d, 'day');
				    my($wday) = $_D->english_day_of_week($d);
				    my($weekend) = $_D->english_day_of_week($d) =~ /^s/i
					? ' c4_weekend' : ''; 
				    my($month) = [];
				    if ($first || $day == 1) {
					$month = [
					    $first ? () : SPAN_c4_month_spacer(''),
					    SPAN_c4_month(
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
						    class => "c4_day$selected$weekend",
						    TITLE => $_D->english_day_of_week($d),
						},
					    ),
				    );
				}
				    0 .. 6,
			    ),
			);
		    }
			0 .. ($weeks - 1),
		),
		Link(
		    '>>',
		    _when_uri($_D->add_days($start, 7 * $weeks)),
		    'c4_next',
		),
	    ]),
	),
    );
}

1;
