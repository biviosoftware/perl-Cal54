# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Facade::Cal54Base;
use strict;
use Bivio::Base 'UI.FacadeBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_c4_color {
    return [
	[c4_event_hidden_background => 0xefe98a],
	[[qw(c4_pager c4_pager_selected_border c4_form_background c4_logo_name c4_logo_tag c4_home_title c4_featured c4_button c4_query_submit)] => 0xffffff],
	[[qw(c4_pager_weekend c4_query_submit_border c4_query_submit)] => 0xf8f8f8],
	[[qw(c4_pager_a)]=> 0xe8e8e8],
    ];
}

sub internal_c4_css {
    my($self) = @_;
    return [
	[c4_query_what => ''],
	[c4_form => ''],
	[c4_grid => ''],
	[c4_list => ''],
	[c4_home_bottom_pager => ''],
	[c4_home_other => ''],
    ];
}

sub internal_c4_font {
    my($self) = @_;
    return [
	[c4_home => ['family=Arial, Helvetica, sans-serif', 'medium']],
	[c4_query_submit => ['size=18px']],
	[c4_logo_name => [qw(uppercase bold 48px)]],
	[c4_home_title => [qw(uppercase bold 200%)]],
	[c4_excerpt => ['90%']],
	[c4_query_what => '120%'],
	[c4_pager_weekend => 'bold'],
	[c4_time => [qw(90% bold)]],
	[c4_date => ['bold']],
	[c4_item_a => []],
	[c4_item_a_title => ['110%', 'bold']],
	[c4_item_a_visited => []],
	[c4_item_a_hover => ['underline']],
	[c4_events_item => []],
	[c4_venue => ['90%']],
	[c4_copy => ['90%']],
	[c4_site_tag => ['bold']],
	[c4_tm => ['60%', 'style=vertical-align: top; line-height: 90%']],
	[c4_pager => ['left']],
	[c4_pager_month => ['90%', 'uppercase']],
	[c4_pager_a => ['90%']],
	[c4_featured => ['100%']],
#TODO: needed for mobile only
	[c4_button => ['100%']],
	[c4_site_local => ['bold', 'family="American Typewriter", Courier']],
	[c4_site_tag => ['family="American Typewriter", Courier']],
	[c4_site_name => ['bold', 'family="American Typewriter", Courier']],
	[c4_button => ['100%']],
	[c4_home_list_title => ['130%', 'bold', 'center']],
    ];
}

sub internal_c4_text {
    return [
	[site_name => q{CAL54}],
	[site_copyright => q{bivio Software, Inc.}],
	[c4_home_title => q{Calendar of Events, Concerts, Lectures, Activities for Boulder/Denver}],
	[c4_home_list_title => q{The Searchable Event Calendar for Boulder and Denver}],
    ];
}

1;
