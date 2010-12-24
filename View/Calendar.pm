# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::Calendar;
use strict;
use Bivio::Base 'View';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub home_page {
    return shift->internal_body(
	# DIV_c4_main_list(Join([
	#     DIV_date('Dec 13'),
	#     DIV_item(Join([
	# 	Link(String(qq{9pm, Jeff Jenkins' Piano Conversations\nDazzle Jazz, 930 Lincoln St, Denver, CO 80203, 303.839.5100}), '/', 'c4_go'),
	# 	DIV_excerpt(String(q{Think Marian McPartland's piano jazz, only live!  Jeff Jenkins, one of the country's premier pianists, will be bringing in different guests every week to play and converse with.})),
	#     ])),
	# ])),
	_list(),
    );
}

sub _list() {
    my($self) = @_;
    return vs_list(CalendarEventMonthList => [
	['RealmOwner.name', {
	    column_widget => Join([
		Link(
		    Join([
			SPAN_title(String(['CalendarEvent.title'])),
			SPAN_description(String(['CalendarEvent.description'])),
		    ]),
		    ['CalendarEvent.url'],
		),
	    ]),
	}],
    ]);
    return;
}

1;
