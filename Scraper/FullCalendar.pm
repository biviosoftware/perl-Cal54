# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::FullCalendar;
use strict;
use Bivio::Base 'Bivio.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');
my($_JSON) = b_use('MIME.JSON');

sub internal_import {
    my($self) = @_;
    my($start) = $_D->add_days($self->get('date_time'), -1);
    my($end) = $_D->add_months($start, 3);
    my($url) = $self->get('scraper_list')->get('Website.url');
    $url =~ s{(//.*?)/.*$}{$1};
    $url .= '/';

    my($json) = $_JSON->from_text($self->c4_scraper_get($url
	. '/api/events/getall'
	. '?'
	. join('&',
	    'startMs=' . $_DT->to_unix($start) . '000',
	    'endMs=' . $_DT->to_unix($end) . '000',
	    'calendarName=' . 'Events+and+Entertainment',
	 ),
    ));

    foreach my $record (@$json) {
	next if $record->{allDay} eq 'true';
	next unless $record->{content};
	next if $record->{content} =~ /\$/;	
	next if length($record->{content}) > 30;
	push(@{$self->get('events')}, {
	    summary => $record->{title},
	    description => $record->{content},
	    dtstart => $_DT->from_literal_or_die($record->{start}),
	    dtend => $_DT->from_literal_or_die($record->{end}),
	});
    }
    return;
}

1;
