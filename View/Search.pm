# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::Search;
use strict;
use Bivio::Base 'View';
b_use('UI.ViewLanguageAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub suggest_list_json {
    my($self) = @_;
    view_put(json_body => JSONValueLabelPairList({
	list_class => 'SearchSuggestList',
	value_widget => String(['result_uri']),
	label_widget =>
	    Link(
		DIV_row(
		    DIV(
			Join([
			    SPAN_c4_suggest_time(String(['result_time_info'])),
			    SPAN_bivio_suggest_title(String(['result_title'])),
			    SPAN_bivio_suggest_excerpt(String(['result_excerpt'])),
			], ' '),
			{
			    class => 'col-xs-12 bivio_suggest_headline',
			},
		    ),
		),
		['result_uri'],
	    ),
    }));
}

1;
