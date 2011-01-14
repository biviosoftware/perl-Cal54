# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::Evanced;
use strict;
use Bivio::Base 'Bivio.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');

# http://wiki.evancedsolutions.com/index.php/Creating_XML-RSS_Feeds

sub internal_import {
    my($self) = @_;
    my($start) = $_D->add_days($self->get('date_time'), -1);
    my($end) = $_D->add_months($start, 6);
    my($host, $lib) = $self->get('venue_list')->get('calendar.Website.url')
	=~ m,^(http\://.*?)\?lib=(\d+),;
    b_die('unparsable evanced url: ',
	$self->get('venue_list')->get('calendar.Website.url'))
	unless defined($lib);
    my($xml) = $self->internal_parse_xml($host . '/eventsxml.asp?'
        . join('&',
	    'lib=' . $lib,
	    'ag=',
	    'et=',
	    'dm=exml',
	    'LangType=0',
	    'startdate=' . $_D->to_string($start),
	    'enddate=' . $_D->to_string($end),
        ));
	    
    foreach my $event (@{$xml->{item}}) {
	next if lc($event->{time} || '') eq 'all day';
	next if $event->{enddate} && ($event->{enddate} ne $event->{date});
	push(@{$self->get('events')}, {
	    summary => $self->internal_clean($event->{title}),
	    description => $self->internal_clean($event->{description}),
	    time_zone => $self->get('time_zone'),
	    dtstart => $self->internal_date_time(
		$event->{date1} . ' ' . $event->{time}),
	    dtend => $self->internal_date_time(
		$event->{date1} . ' ' . $event->{endtime}),
	    url => $event->{link},
	});
    }
    return;
}

1;
