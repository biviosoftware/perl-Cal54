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
        my($req) = shift->req;
#	return
#	    unless $_F->get_from_source($req)->get('want_local_file_cache');
#TODO: Share with LocalFilePlain, probably set_cache_max_age on Agent.Reply
	# Facebook only checks once a day so setting to an hour for "this"
	# pages is reasonable.  Setting the search page to one minute allows
	# us to avoid multiple hits from facebook on /search.
	my($max_age) = $req->get('Model.HomeList')->c4_has_this
	    ? 60 * 60 : 60;
        $req->get('reply')
	    ->set_header('Cache-Control', "max-age=$max_age")
	    ->set_header(Expires => $_DT->rfc822($_DT->add_seconds($_DT->now, $max_age)));
	return;
    });
    view_put(
	home_base_html_tag_attrs => ' xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://www.facebook.com/2008/fbml" xmlns:og="http://ogp.me/ns#" xml:lang="en_US" lang="en_US"',
	home_base_head => Join([
	    Title(['CAL54', ['Model.HomeList', '->c4_title']]),
	    map(_meta(@$_),
		[title => ['Model.HomeList', '->c4_title']],
		[site_name => vs_site_name()],
		[image => _abs_uri(['UI.Facade', 'Icon', '->get_uri', 'logo'])],
		[type => 'activity'],
		[url => _abs_uri(['Model.HomeList', '->c4_format_uri'])],
		[app_id => '237465832943306'],
		[locale => 'en_US'],
	    ),
	    If(
		['Model.HomeList', '->c4_has_this'],
		Join([
		    map(_meta(@$_),
			[description => ['Model.HomeList', '->c4_description']],
			['street-address' => ['Model.HomeList', 'Address.street1']],
			['locality' => ['Model.HomeList', 'Address.city']],
			['region' => ['Model.HomeList', 'Address.state']],
			['postal-code' => ['Model.HomeList', 'Address.zip']],
			['country-name' => ['Model.HomeList', 'Address.country']],
			['phone_number' => ['Model.HomeList', 'Phone.phone']],
			['email' => ['Model.HomeList', 'Email.email']],
		    ),
		]),
	    ),
	]),
    );
    return $self->internal_body(Join([
	q[<div id="fb-root"></div><script type="text/javascript">window.fbAsyncInit=function(){FB.init({appId:'237465832943306',status:false,cookie:false,xfbml:true,oauth:false,channelUrl:'],
	_abs_uri('/f/channel.html'),
	q['})};(function(){var e=document.createElement('script');e.src=document.location.protocol+'//connect.facebook.net/en_US/all.js';e.async=true;document.getElementById('fb-root').appendChild(e);}());</script>],
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
	uri => ,
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
			class => 'c4_prev',
			control => [['Model.HomeList', '->get_query'], 'has_prev']
		    },
		),
	    ),
	),
	DIV_c4_list(
	    Grid([[
		List(HomeList => [
		    DIV_date(['month_day']),
		    DIV_item(Join([
			DIV_line(Join([
			    vs_unless_robot(
				UserTrackingLink(
				    String(['RealmOwner.display_name']),
				    Or(['CalendarEvent.url'], ['calendar.Website.url']),
				    'title',
				),
				Link(
				    String(['RealmOwner.display_name']),
				    ['->c4_format_uri'],
				    'title',
				),
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
			    vs_unless_robot(
				DIV_c4_fb_like(
				    Tag({
					tag_if_empty => 1,
					value => '',
					tag => 'fb:like',
					SHOW_FACES => 'false',
					SEND => 'false',
					WIDTH => 90,
					LAYOUT => 'button_count',
					COLORSCHEME => 'light',
					FONT => 'arial',
					HREF => _abs_uri(['->c4_format_uri']),
				    }),
				),
			    ),

			]),
		    ])),
		], {
		    empty_list_widget => DIV_c4_empty_list(
			q{Your search didn't match any results.  Try a different query.},
		    ),
		    cell_expand => 1,
		    cell_align => 'top',
		}),
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

sub _meta {
    my($n, $v) = @$_;
    return META({
	PROPERTY => ($n eq 'app_id' ? 'fb' : 'og') . ":$n",
	CONTENT => $v,
    });
}

1;
