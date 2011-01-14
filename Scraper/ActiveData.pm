# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::ActiveData;
use strict;
use Bivio::Base 'Bivio.Scraper';
use XML::Simple ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');
my($_HTML) = b_use('Bivio::HTML');

sub internal_import {
    my($self) = @_;
    my($addr1) = $self->get('venue_list')->get('Address.street1');
    b_die('venue missing Address.street1')
	unless $addr1;
    my($start) = $_D->add_days($_D->local_today, -1);
    my($end) = $_D->add_months($start, 6);
    # first parse calendar for "/eventlistsyndicator.aspx", use that host
    # otherwise look for "EventList.aspx" and use current host
    my($webhost) = _parse_webhost($self);
    # query the Eventlist.aspx xml download
    # http://events.colorado.edu/Eventlist.aspx?fromdate=1/1/2011&todate=1/31/2011&type=public&download=download&dlType=XML
    my($xml) = $self->c4_scraper_get('http://' . $webhost . '/Eventlist.aspx?'
        . join('&', 				       
	       'fromdate=' . $_D->to_string($start),
	       'todate=' . $_D->to_string($end),
	       'type=public',
	       'download=download',
	       'dlType=XML'
	));
    my($res, $err) = XML::Simple::xml_in($$xml);
    b_die('xml parse error: ', $err) if $err;
    b_die('no events: ', $res) unless keys(%$res);
    
    # download and parse events, see ~/tmp/e.xml
    # iterate events, taking Address1 which match the current venue
    foreach my $event (@{$res->{Event}}) {
	next unless lc($addr1) eq lc($event->{Address1}->{content} || '');
	next if lc($event->{Status}->{content} || '') eq 'cancelled';
	next unless $event->{StartDate}->{content}
	    && $event->{StartTime}->{content}
	    && $event->{EndDate}->{content}
	    && $event->{EndTime}->{content};
	push(@{$self->get('events')}, {
	    summary => _clean($self, $event->{EventName}->{content}),
	    time_zone => $self->get('time_zone'),
	    description => _clean($self, $event->{EventDescription}->{content}),
	    dtstart => _date_time($self, $event, 'Start'),
	    dtend => _date_time($self, $event, 'End'),
	});


	# description combines EventDescription, Location, Building, Room,
	# ContactName, ContactPhone, ContactEmail,
	# ExternalField1, ExternalField2

	# EventName: Performance Certificate Recital: Margaret Higginson...
	# EventDescription: &lt;div&gt;PROGRAM:&lt;/div&gt;...
	# ContactName: CU Presents Box Office
	# ContactPhone: 303-492-8008
	# ContactEmail: musictix@colorado.edu
	# Location: Main Campus
	# Building: Imig Music
	# Room: Grusin Music Hall
	# ExternalField1: &lt;li&gt;Everyone&lt;/li&gt;
	# ExternalField2: Free and open to the public. No tickets required.
	# StartDate: 1/12/2011
	# StartTime: 07:30 PM
	# EndDate: 1/12/2011
	# EndTime: 09:30 PM
        # OneTimeSeries: One Time
	# Status: Cancelled
	# Address1: 1020 18th Street
	# Address2:
	# City: Boulder
	# State: CO
	# Zipcode:
	# Phone:
    }

    # download rss and get detail links for each event
    # http://events.colorado.edu/RSSSyndicator.aspx?category=&location=5-312-0&type=N&starting=1/1/2011&ending=1/31/2011&binary=Y
    return;
}

sub _clean {
    my($self, $value) = @_;
    $value = $_HTML->unescape($value);
    $value =~ s,<.*?>, ,g;
    return $value;
}

sub _date_time {
    my($self, $event, $type) = @_;
    my($mon, $mday, $year) = split('/', $event->{$type . 'Date'}->{content});
    my($hour, $min, $ap) =
	$event->{$type . 'Time'}->{content} =~ m,^(\d+)\:(\d+) (a|p)m$,i;
    b_die('unparsable date/time: ', $event)
	unless $year && $ap;
    $hour += 12 if lc($ap) eq 'p' && $hour < 12;
    return $self->get('time_zone')->date_time_to_utc(
	$_DT->from_parts_or_die(0, $min, $hour, $mday, $mon, $year));
}

sub _parse_webhost {
    my($self) = @_;
    my($html) = $self->c4_scraper_get(
	$self->get('venue_list')->get('calendar.Website.url'));
    my($host) = $$html =~ m,http://(.*?)/EventListSyndicator.aspx,;
    return $host if $host;
    b_die('unparsed host value')
	unless $$html =~ /("|')EventList.aspx\?/;
    $host = $$html =~ m,http://(.*?)/,;
    b_die('host not found in calendar website')
	unless $host;
    return $host;
}

1;
