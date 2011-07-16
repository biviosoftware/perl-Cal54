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

sub _featured_item {
    return DIV_featured(Join([
	SPAN_title('Featured Event'),
	DIV_date(q{Sunday June 26, 2011}),
	DIV_item(Join([
	    DIV_line(
		UserTrackingLink(
		    'Riff Raff - RDS Foundation Fundraiser',
		    'http://rdsfoundation.org/index.php?option=com_content&task=view&id=32',
		    'title',
		),
	    ),
	    Join([
		SPAN_time(q{6pm - 9}),
		' ',
		SPAN_excerpt(
		    q{Boulder's Riff Raff will be playing for the fundraising dinner of the RDS Foundation (www.rdsfoundation.org - we raise money for people with bipolar disorder to get the treatment they need and can't afford).  Tickets for this outdoor event are $50 which include the concert and a catered full dinner and wine from Laudisio's.}
		),
		DIV_line(Join([
		    UserTrackingLink(
			q{BC Interiors},
			'http://www.bcinteriors.com/',
			'venue',
		    ),
		    ' ',
		    UserTrackingLink(
			'3390 Valmont Rd, Boulder',
			'http://maps.google.com/maps?q=BC+Interiors+3390+Valmont+Rd,+Boulder+CO,+80301',
			'address',
		    ),
		    ' ',
		    SPAN_phone('303.555.5555'),
		])),
	    ]),
	])),
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
	    vs_unless_robot(IfMobile('', C4HomePager(0))),
	]),
    );
}

sub _list {
    my($self) = @_;
    return Join([
	vs_unless_robot(IfMobile(
	    Link(
		String(vs_text('previous_button')),
		['Model.HomeList', '->format_uri', 'PREV_LIST'],
		{
		    class => 'c4_prev',
		    control => [['Model.HomeList', '->get_query'], 'has_prev']
		},
	    ),
	)),
	DIV_c4_list(
	    Grid([[
		List(HomeList => [
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
				If (['Phone.phone'],
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
		    cell_expand => 1,
		    cell_align => 'top',
		}),
		# IfMobile(
		#     Simple(''),
		#     _featured_item(),
		# )->put(cell_align => 'top'),
	    ]]),
	),
	vs_unless_robot(
	    Join([
		DIV(
		    IfMobile(
			Link(
			    String(vs_text('next_button')),
			    ['Model.HomeList', '->format_uri', 'NEXT_LIST'],
			    {
				class => 'c4_next',
				control => [['Model.HomeList', '->get_query'], 'has_next'],
			    },
			),
			DIV(
			    C4HomePager(1),
			    {class => 'c4_query c4_bottom_pager'},
			),
		    ),
		),
	    ]),
	),
	$self->internal_footer,
    ]);
}

1;
