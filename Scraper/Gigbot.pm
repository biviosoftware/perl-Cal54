# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::Gigbot;
use strict;
use Bivio::Base 'Scraper.ICalendar';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_import {
    my($self) = @_;
    shift->SUPER::internal_import(@_);
    my($cleaner) = b_use('Bivio.HTMLCleaner')->new;
    my($events) = [];

    foreach my $event (@{$self->get('events')}) {
	my($desc) = $event->{description};
	my($url) = $desc =~ /Show Info:\n(http.*?)\n/;
	next unless $url;
	$event->{description} = undef;
	$event->{url} = $url;
	my($html) = $self->c4_scraper_get($url);
	# fixup bad unicode
	# c3 a2 e2 82  ac e2 84 a2
	$$html =~ s/\xc3\xa2\xe2\x82\xac\xe2\x84\xa2/'/g;
	my($text) = $cleaner->clean_html($html, $url);
	$self->extract_once_fields($self->eval_scraper_aux('{
            once => [
                [qr/\n([^\n]+?)\n*\(Read More/is => {
                    fields => [qw(description)],
                }],
                [qr/at\n(.*?)\n/i => {
                    fields => [qw(location)],
                }],
            ],
        }'), $text, $event);
	$self->extract_once_fields($self->get_scraper_aux, $text, $event);
	$event->{description} =~ s/\{\d+\}//g
	    if $event->{description};
	push(@$events, $event)
	    unless $event->{summary} =~ /private (party|event)/i;
    }
    $self->put(events => $events);
    return;
}

sub parse_ics {
    my($self, $ics_text) = @_;
    # fixup bad ics
    $$ics_text =~ s/\r\n.*?(\n\w+\:)/$1/sg;
#TODO: ics missing tz, assumes denver
    unless ($$ics_text =~ /\nTZID\:/) {
	$$ics_text =~ s/(DTEND:.*?\n)/$1TZID:America\/Denver\n/g;
    }
    return shift->SUPER::parse_ics(@_);
}

1;
