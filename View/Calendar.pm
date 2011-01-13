# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::Calendar;
use strict;
use Bivio::Base 'View';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub adm_list {
    vs_put_pager('AdmCalendarEventList');
    return shift->internal_body(
	vs_list_form(
	    'AdmCalendarEventListForm',
	    [
		'CalendarEvent.dtstart',
		['RealmOwner.display_name', {
		    wf_list_link => {
			href => URI({
			    uri => [['->get_list_model'], 'CalendarEvent.url'],
			}),
		    },
		}],
		'AdmCalendarEventListForm.CalendarEvent.location',
	    ],
	    {
		class => 'paged_list',
	    },
	),
    );
}

1;
