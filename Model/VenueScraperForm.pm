# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::VenueScraperForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');

sub execute_empty {
    my($self) = @_;
    $self->load_from_model_properties($self->req('Model.Venue'));
    return;
}

sub execute_ok {
    my($self) = @_;
    $self->update_model_properties($self->req('Model.Venue'));
    return;
}

sub execute_other {
    my($self) = @_;
    $self->validate_and_execute_ok;
    return if $self->in_error;
    my($list) = $self->new_other('VenueList')->unauth_load_all;
    $list->find_row_by('Venue.venue_id', $self->req(qw(Model.Venue venue_id)))
	|| b_die('venue not in VenueList');
    my($die) = Bivio::Die->catch(sub {
        my($scraper) = b_use('Bivio.Scraper')
	    ->do_one($list, b_use('Type.DateTime')->now);
	$self->internal_put_field(events => $scraper->get('events'));
	$self->internal_put_field(error => $scraper->get('die')->as_string)
	    if $scraper->unsafe_get('die');
    });
    $self->internal_put_field(error => $die->as_string)
	if $die;

    foreach my $event (@{$self->get('events')}) {
	my($tz) = $event->{time_zone};
	$event->{time_zone} = $tz->get_short_desc;

	foreach my $f (qw(dtstart dtend)) {
	    next unless $event->{$f};
	    $event->{$f} = $_DT->to_string(
		$tz->date_time_from_utc($event->{$f}));
	    $event->{$f} =~ s/\s+GMT$//;
	}
    }
    $self->internal_stay_on_page;
    return;
}

sub has_events {
    my($self) = @_;
    return @{$self->get('events')} ? 1 : 0;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'Venue.scraper_type',
	    'Venue.scraper_aux',
	    {
		name => 'test_scraper_button',
		type => 'FormButton',
		constraint => 'NONE',
	    },
	],
	other => [
	    'calendar.Website.url',
	    {
		name => 'events',
		type => 'Array',
		constraint => 'NONE',
	    },
	    {
		name => 'error',
		type => 'String',
		constraint => 'NONE',
	    },
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->internal_put_field(events => []);
    $self->internal_put_field(error => '');
    $self->internal_put_field('calendar.Website.url' =>
        $self->new_other('Website')->unauth_load_or_die({
	    realm_id => $self->req(qw(Model.Venue venue_id)),
	    location => b_use('Type.Location')->CALENDAR,
	})->get('url'));;
    return;
}

1;
