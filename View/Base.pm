# Copyright (c) 2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Cal54::View::Base;
use strict;
use Bivio::Base 'View.ThreePartPage';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub VIEW_SHORTCUTS {
    return 'Cal54::ViewShortcuts';
}

sub internal_xhtml_adorned {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_xhtml_adorned(@_);
    view_unsafe_put(
	xhtml_body_first => FORM_c4_query({
	    value => Join([
		DIV_item(Join([
		    SPAN('Where:'),
		    INPUT({
			VALUE => 'Denver',
		    }),
		])),
		DIV_item(Join([
		    SPAN('What:'),
		    INPUT({
			VALUE => 'music',
		    }),
		])),
		DIV_item(Join([
		    SPAN('When:'),
		    INPUT({
			VALUE => 'now',
		    }),
		])),
		DIV_item(Join([
		    INPUT({
			TYPE => 'submit',
		    }),
		])),
	    ]),
	}),
	xhtml_dock_left => And(
	    ['auth_user_id'],
	    view_get('xhtml_dock_left'),
	),
	xhtml_header_left => undef,
	xhtml_main_left => String(' '),
	xhtml_header_right => undef,
	xhtml_dock_right => And(
	    ['auth_user_id'],
	    view_get('xhtml_dock_right'),
	),
	xhtml_footer_left => String(' '),
	xhtml_footer_center => Prose(
	    "&copy; @{[__PACKAGE__->use('Type.DateTime')->now_as_year]} SPAN_cal54('CAL54');",
	),
	xhtml_footer_right => String(' '),
    );
    return @res;
}

1;
