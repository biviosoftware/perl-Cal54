# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::ICalendar;
use strict;
use Bivio::Base 'Scraper.RegExp';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');
my($_MC) = b_use('MIME.Calendar');
my($_RR) = b_use('MIME.RRule');

sub internal_import {
    my($self) = @_;
    my($url) = $self->get('scraper_list')->get('Website.url');

    unless ($url =~ /ical/) {
	my($html) = $self->c4_scraper_get($url);
	my($ical_url) = $$html =~ m{["'](\w+://[^"']+/ical/[^"']+)["']};

	unless ($ical_url) {
	    ($ical_url) = $$html =~ m{["'](\w+://[^"']+feed=ical[^"']*)["']};
	}
	b_die('no ical ref:') unless $ical_url;
	$url = $ical_url;
    }
    $url =~ s/webcal:/http:/;
    $self->parse_ics($self->c4_scraper_get($url));
    return;
}

sub parse_ics {
    my($self, $ical, $start, $end) = @_;
    $start ||= $_D->get_min;
    $end ||= $_D->get_max;
    my($recurrences) = {};
    $self->pre_parse_html($self->get_scraper_aux, $ical);

    foreach my $vevent (reverse(@{$_MC->from_ics($ical)})) {

	if ($vevent->{'recurrence-id'}) {
	    $recurrences->{_recurrence_id($vevent, 'recurrence-id')} = 1;
	}
	next if $_D->is_date($vevent->{dtstart});
	next if $self->is_canceled($vevent->{status} || '');
	next unless ($vevent->{class} || 'PUBLIC') eq 'PUBLIC';

	foreach my $v (@{_explode_event($self, $vevent, $end)}) {
	    next if $v->{rrule} && $recurrences->{_recurrence_id($v)};
	    next if $_DT->compare($v->{dtstart}, $start) < 0;
	    push(@{$self->get('events')}, {
		map(($_ => $v->{$_}), qw(dtend dtstart uid url location)),
		summary => $v->{summary},
		description => $v->{description},
	    });
	}
    }
    return @{$self->get('events')} ? 1 : 0;
}

sub _explode_event {
    my($self, $vevent, $end) = @_;
    return [$vevent] unless $vevent->{rrule};
    return [
	map(+{
	    %$vevent,
	    %$_,
	}, @{$_RR->process_rrule($vevent, $end)}),
    ];
}

sub _recurrence_id {
    my($vevent, $date_field) = @_;
    return join('-',
        map($vevent->{$_}, qw(uid sequence), $date_field || 'dtstart'));
}

1;
