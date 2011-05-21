# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::BosDates;
use strict;
use Bivio::Base 'Scraper.RegExp';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_import {
    my($self) = @_;
    my($url) = $self->get('scraper_list')->get('Website.url');
    my($event_url) = $url;
    $event_url =~ s{/calendar.php$}{/event.php?event=}
	|| b_die('failed to parse url: ', $url);
    my($html) = $self->c4_scraper_get($url);

    for my $i (1 .. 3) {
	my($next) = $$html =~ m{href="([^"]+)">&gt;&gt;<};
	b_die('parse next failed') unless $next;

	while ($$html =~ /\?event=(\d+)/g) {
	    _add_event($self, $event_url . $1);
	}
	$html = $self->c4_scraper_get($next);
    }
    return;
}

sub _add_event {
    my($self, $url) = @_;
    my($text) = b_use('Bivio.HTMLCleaner')->new
	->clean_html($self->c4_scraper_get($url), $url);
    my($current) = {
	url => $url,
    };
    $self->extract_once_fields($self->eval_scraper_aux('{
	once => [
	    [qr/Date.*?\:\s*$month $day $year/i => {
		fields => [qw(month day year)],
	    }],
	    [qr/Link\:.*?\}\s*(.*?)\n\n/is => {
		fields => [qw(description)],
	    }],
	    [qr/Time\:\s*$time_ap/i => {
		fields => [qw(start_time)],
	    }],
	],
    }'), $text, $current);
    $self->extract_once_fields($self->get_scraper_aux, $text, $current);
    push(@{$self->get('events')}, {
	%{$self->internal_collect_data($current)},
    }) if $current->{summary};
    return;
}

1;
