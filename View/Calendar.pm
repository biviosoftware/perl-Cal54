# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::Calendar;
use strict;
use Bivio::Base 'View';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub adm_list {
    vs_put_pager('AdmCalendarEventListForm');
    return shift->internal_body(
	Form({
	    form_class => 'AdmCalendarEventListForm',
	    class => 'c4_events paged_list',
	    value => Join([
		StandardSubmit(),
		List(
		    'AdmCalendarEventListForm',
		    [
			Link(
			    Join([
				DateTime([['->get_list_model'], 'CalendarEvent.dtstart']),
				Simple(' '),
				String([['->get_list_model'], 'RealmOwner.display_name']),
			    ]),
			    URI({
				uri => [['->get_list_model'], 'CalendarEvent.url'],
			    }),
			    'item',
			),
			Text(
			    'SearchWords.value',
			    {size => 1, class => 'c4_search_words'},
			),
		    ],
		),
		StandardSubmit(),
	    ]),
	}),
    );
}

1;
