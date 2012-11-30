# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::CalendarManagerData;
use strict;
use Bivio::Base 'Bivio.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');

sub internal_import {
    my($self) = @_;
    my($xml) = $self->internal_parse_xml(
	$self->get('scraper_list')->get('Website.url'));

    foreach my $cal (@{_items($self, $xml, qw(Calendars Calendar))}) {
	foreach my $event (@{_items($self, $cal, qw(Events Event))}) {
	    next if $event->{AllDay} eq 'true';
	    push(@{$self->get('events')}, {
		summary => $event->{Title},
		description => $event->{Description},
		dtstart => _date_time($self, $event->{From}),
		dtend => _date_time($self, $event->{To}),
	    });
	}
    }
    return;
}

sub _date_time {
    my($self, $v) = @_;
    $v =~ s/T/ /;
    return $self->get('time_zone')->date_time_to_utc(
	$_DT->from_literal_or_die($v));
}

sub _items {
    my($self, $xml, @path) = @_;
    my($res) = $xml;

    foreach my $p (@path) {
	$res = $res->{$p};
    }
    b_die() unless $res;
    return ref($res) eq 'ARRAY' ? $res : [$res];
}

1;
