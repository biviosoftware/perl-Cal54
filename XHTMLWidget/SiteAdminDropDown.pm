# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::XHTMLWidget::SiteAdminDropDown;
use strict;
use Bivio::Base 'XHTMLWidget';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub TASK_MENU_LIST {
    return (
	shift->SUPER::TASK_MENU_LIST(@_),
	'adm_venue_list',
	'adm_calendar_event_list_form',
	'adm_scraper_list',
    );
}

1;
