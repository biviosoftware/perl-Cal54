# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
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
		summary => $self->internal_clean($event->{Title}),
		description => $self->internal_clean($event->{Description}),
		dtstart => $_DT->from_literal_or_die($event->{From}),
		dtend => $_DT->from_literal_or_die($event->{To}),
	    });
	}
    }
    return;
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
