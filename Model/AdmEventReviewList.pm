# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::AdmEventReviewList;
use strict;
use Bivio::Base 'Model.HomeList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub EXCLUDE_HIDDEN_ROWS {
    return 0;
}

sub internal_initialize {
    my($self) = @_;
    my($ii) = $self->merge_initialize_info($self->SUPER::internal_initialize, {
	other => [
	    {
		name => 'is_hidden',
		type => 'Boolean',
		in_select => 1,
		select_value => '(
                    SELECT COUNT(*)
                    FROM row_tag_t rt
                    WHERE rt.primary_id = calendar_event_t.calendar_event_id
                ) AS is_hidden',
	    },
	],
	other_query_keys => ['scraper'],
    });
    unshift(@{$ii->{order_by}}, qw(
        CalendarEvent.modified_date_time
	CalendarEvent.dtstart
	venue.RealmOwner.display_name
    ));
    return $ii;
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    if (my $scraper = $query->unsafe_get('scraper')) {
	my($list) = $self->req('Model.ScraperList');
	$list = $list->find_row_by(
	    'default_venue.RealmOwner.display_name', $scraper)
	    || $list->find_row_by('Website.url', $scraper);
	$stmt->where($stmt->EQ('CalendarEvent.realm_id',
	    [$list
		 ? $list->get('Scraper.scraper_id')
	         : 0
	    ]));
    }
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
