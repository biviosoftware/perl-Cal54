# Copyright (c) 2010-2011 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::Facade::Cal54;
use strict;
use Bivio::Base 'Facade.Cal54Base';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');

my($_SELF) = __PACKAGE__->new({
    uri => 'cal54',
    http_host => 'www.cal54.com',
    mail_host => 'cal54.com',
    Color => [
	@{__PACKAGE__->internal_c4_color},
	[[qw(c4_site_name c4_site_tag c4_query_what b_mobile_toggler_selected)]=> 0x0],
	[[qw(c4_item_a c4_item_a_hover b_mobile_toggler_a)] => 0x0077b3],
        [c4_item_a_visited => 0x591899],
	[[qw(c4_date c4_time c4_query_submit_background c4_query_background c4_grid_background c4_home_title_background c4_featured_background c4_button_background c4_home_list_title)] => 0xc82127],
    ],
    Constant => [
	[ActionError_default_view => 'Home->error_default'],
	[ActionError_want_wiki_view => 0],
	[xlink_c4_about => {
	    task_id => 'C4_HOME_WIKI_VIEW',
	    path_info => 'About',
	}],
    ],
    CSS => [
	@{__PACKAGE__->internal_c4_css},
	[html_body => 'padding-top: 0;'],
    ],
    Font => [
	@{__PACKAGE__->internal_c4_font},
	[body => []],
	[b_mobile_toggler_selected => ['normal_weight']],
	[b_mobile_toggler_a => ['normal_weight']],
    ],
    Task => [
	[C4_HOME_LIST => 'search'],
	[C4_HOME_USER_TRACKING => '/pub/url'],
	[C4_HOME_SUGGEST_SITE => '/pub/suggest-site'],
	[SITE_WIKI_VIEW => undef],
	[C4_HOME_WIKI_VIEW => '/bp/*'],
	[LOGIN => undef],
    ],
    Text => [
	@{__PACKAGE__->internal_c4_text},
	[Image_alt => [
	    c4_local => 'This establishment supports local events by local artists.',
	]],
	[c4_site_tag => q{SPAN(q{The Web's Calendar});SPAN_c4_tm('&trade;');}],
	[home_page_uri => '/search'],
	[[qw(title xlink)] => [
	    C4_HOME_SUGGEST_SITE => 'Comments or Suggestions?',
	    c4_about => 'About',
	    C4_HOME_LIST => 'Home',
	    C4_HOME_WIKI_VIEW => 'Wiki',
	]],
	[SuggestSiteForm => [
	    'prose.prologue' => q{BR(); Know of a local venue we don't cover? Let us know!BR();BR(); Any other comments, questions, or suggestions are appreciated.BR();BR();},
	    'suggestion' => 'Message',
	    'email' => 'Your email (optional)',
	    ok_button => 'Submit',
	]],
	[previous_button => 'Previous'],
	[next_button => 'Next'],
	[prose => [
	    xhtml_copyright => <<"EOF",
&copy; @{[$_DT->now_as_year]} vs_text('site_copyright'); BR(); SPAN_c4_site_tag('Make a ');SPAN_c4_site_local('local');SPAN_c4_site_tag(' scene.&trade;');
EOF
	]],
    ],
});

1;
