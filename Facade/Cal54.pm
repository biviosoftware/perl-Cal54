# Copyright (c) 2010-2011 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::Facade::Cal54;
use strict;
use Bivio::Base 'Facade.Cal54Base';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_SELF) = __PACKAGE__->new({
    uri => 'cal54',
    http_host => 'www.cal54.com',
    mail_host => 'cal54.com',
    Color => [
	[[qw(c4_site_name c4_site_tag c4_query_what)]=> 0x0],
	[[qw(c4_item_a c4_item_a_hover b_mobile_toggler_a)] => 0x2200C1],
        [c4_item_a_visited => 0x551A8B],
	[[qw(c4_date c4_time c4_query_submit_background c4_query_background c4_grid_background c4_home_title_background)] => 0x0088ce],
	[[qw(c4_pager c4_pager_selected_border c4_form_background c4_logo_name c4_logo_tag c4_home_title)] => 0xffffff],
	[[qw(c4_pager_weekend c4_query_submit_border c4_query_submit)] => 0xf8f8f8],
	[[qw(c4_pager_a)]=> 0xe8e8e8],
	[b_mobile_toggler_selected => 0x0],
	[c4_featured => 0xffffff],
	[c4_featured_background => 0x0088ce],
#TODO: needed for mobile only
	[c4_button => 0xffffff],
	[c4_button_background => 0x0088ce],
    ],
    Constant => [
	[ActionError_default_view => 'HomeOther->error_default'],
	[ActionError_want_wiki_view => 0],
    ],
    CSS => [
	[c4_query_what => 'width: 25em;'],
        [c4_form => q{IfUserAgent(
            '!is_msie_6_or_before',
            '
                position: fixed;
		top: 0;
		left: 0;
		right: 0;
            ',
        );}],
	[c4_grid => q{
	    width: 50em;
	    margin: auto;
	}],
	[c4_list => q{IfUserAgent(
		'!is_msie_6_or_before',
		'padding-top: 13ex;',
	    );
	    width: 49.5em;
	    padding-left: .5em;
	    margin: auto;
        }],
	[c4_home_bottom_pager => q{
            width: 50em;
            margin: auto;
        }],
	[c4_home_other => q{
	    width: 49.5em;
	    padding-left: .5em;
	    margin: auto;
	    text-align: center;
        }],
    ],
    Font => [
	[body => []],
	[b_mobile_toggler_selected => []],
	[b_mobile_toggler_a => []],
	[c4_home => ['family=Arial, Helvetica, sans-serif', 'medium']],
	[c4_query_submit => ['size=18px']],
	[c4_logo_name => [qw(uppercase bold 48px)]],
	[c4_home_title => [qw(uppercase bold 200%)]],
	[c4_logo_tag => [qw(uppercase bold 80%)]],
	[c4_site_name => ['bold']],
	[c4_excerpt => ['80%']],
	[c4_query_what => '120%'],
	[c4_pager_weekend => 'bold'],
	[c4_time => [qw(80% bold)]],
	[c4_date => ['90%', 'bold']],
	[c4_item_a => []],
	[c4_item_a_title => 'bold'],
	[c4_item_a_visited => []],
	[c4_item_a_hover => ['underline']],
	[c4_events_item => []],
	[c4_venue => ['80%']],
	[c4_copy => ['80%']],
	[c4_site_tag => ['bold']],
	[c4_tm => ['60%', 'style=vertical-align: top; line-height: 90%']],
	[c4_pager => ['left']],
	[c4_pager_month => ['80%', 'uppercase']],
	[c4_pager_a => ['80%']],
	[c4_featured => ['100%']],
#TODO: needed for mobile only
	[c4_button => ['100%']],
    ],
    Task => [
	[C4_HOME_LIST => 'search'],
	[C4_HOME_USER_TRACKING => '/pub/url'],
	[C4_HOME_SUGGEST_SITE => '/pub/suggest-site'],
    ],
    Text => [
	@{__PACKAGE__->internal_c4_text},
	[c4_site_tag => q{SPAN(q{The Web's Calendar});SPAN_c4_tm('&trade;');}],
	[home_page_uri => '/search'],
	[[qw(title xlink)] => [
	    C4_HOME_SUGGEST_SITE => 'Comments or Suggestions?',
	]],
	[SuggestSiteForm => [
	    'prose.prologue' => q{BR(); Know of a local venue we don't cover? Let us know!BR();BR(); Any other comments, questions, or suggestions are appreciated.BR();BR();},
	    'suggestion' => '',
	    'email' => 'Your email (optional)',
	    ok_button => 'Submit',
	]],
    ],
});

sub internal_merge {
    my($proto) = shift;
    my($cfg) = $proto->SUPER::internal_merge(@_);
    my($base_tasks) = $proto->internal_base_tasks;
    $cfg->{Task} = [
    	map(
	    {
		my($t) = $_->[0];
		grep($t eq $_->[0], @{$base_tasks})
		    || $t =~ /^C4_HOME_|MAIL_RECEIVE|XAPIAN/ ? $_ : (),
	    }
    	    @{$cfg->{Task}},
    	),
    ];
    return $cfg;
}

1;
