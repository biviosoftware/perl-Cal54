# Copyright (c) 2011 CAL54, Inc.  All rights reserved.
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
    my($url) = $self->get('scraper_list')->get('Website.url');
    my($lib) = $url =~ m,lib=(\d+),;
    b_die('unparsable evanced url: ', $url)
	unless defined($lib);
    my($html) = $self->c4_scraper_get($url);
    my($host) = $$html =~ m,"(http://[^"]+?)/eventsxml\.asp[^"]+",;
    b_die('unparsable eventsxml host')
	unless $host;
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
	    summary => $event->{title},
	    description => $event->{description},
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
