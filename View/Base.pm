# Copyright (c) 2010 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::View::Base;
use strict;
use Bivio::Base 'View.ThreePartPage';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub VIEW_SHORTCUTS {
    return 'Cal54::ViewShortcuts';
}

sub internal_xhtml_adorned {
    my($self) = @_;
    my($res) = shift->SUPER::internal_xhtml_adorned(@_);
    view_unsafe_put(
	xhtml_dock_left => NavContainer(
	    Link(vs_text('site_name'), 'SITE_ROOT'),
	    Join([
		FeatureTaskMenu({
		    class => 'nav navbar-nav',
		    want_more_label => String('More'),
		    selected_class => 'active',
		}),
		TaskMenu([
		    ForumDropDown()->put(task_menu_no_wrap => 1),
		    UserSettingsForm(),
		    UserState(),
		], {
		    class => 'nav navbar-nav navbar-right',
		}),
	    ]),
	),
    );
    return $res;
}

1;
