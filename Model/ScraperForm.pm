# Copyright (c) 2011 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::Model::ScraperForm;
use strict;
use Bivio::Base 'Model.FormModeBaseForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_TZ) = b_use('Type.TimeZone')->get_default;

sub LIST_MODEL {
    return 'ScraperList';
}

sub PROPERTY_MODEL {
    return 'Scraper';
}

sub execute_empty_create {
    my($self) = @_;
    return;
}

sub execute_empty_edit {
    my($self) = @_;
    $self->load_from_model_properties($self->req('Model.Scraper'));
    $self->load_from_model_properties(_website($self));
    return;
}

sub execute_ok_create {
    my($self) = @_;
    my($scraper) = $self->new_other('Scraper')->create_realm(
	$self->get_model_properties('Scraper'),
	{});
    $self->new_other('Website')->create({
	realm_id => $scraper->get('scraper_id'),
	%{$self->get_model_properties('Website')},
    });
    return {
	task_id => $self->req('task_id'),
	query => {
	    'ListQuery.this' => $scraper->get('scraper_id'),
	},
    };
}

sub execute_ok_edit {
    my($self) = @_;
    $self->update_model_properties($self->req('Model.Scraper'));
    $self->update_model_properties(_website($self));
    return;
}

sub execute_other {
    my($self) = @_;
    $self->validate_and_execute_ok;
    return if $self->in_error;
    my($list) = $self->new_other('ScraperList')->unauth_load_all;
    $list->find_row_by('Scraper.scraper_id', $self->req(qw(Model.Scraper scraper_id)))
	|| b_die('scraper not in ScraperList');
    my($die) = Bivio::Die->catch(sub {
        my($scraper) = $list->get_scraper_class->do_one(
	    $list,
	    $_TZ->date_time_from_utc($_DT->now),
	);
	$self->internal_put_field(events => $scraper->get('events'));
	$self->internal_put_field(error => $scraper->get('die')->as_string)
	    if $scraper->unsafe_get('die');
    });
    $self->internal_put_field(error => $die->as_string)
	if $die;

    foreach my $event (@{$self->get('events')}) {
	my($tz) = $event->{time_zone};
	next unless $tz;
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
	    'Scraper.scraper_type',
	    'Scraper.scraper_aux',
	    'Scraper.default_venue_id',
	    'Website.url',
	    {
		name => 'test_scraper_button',
		type => 'FormButton',
		constraint => 'NONE',
	    },
	],
	other => [
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
    return shift->SUPER::internal_pre_execute(@_);
}

sub _website {
    my($self) = @_;
    return $self->new_other('Website')->unauth_load_or_die({
	realm_id => $self->req(qw(Model.Scraper scraper_id)),
    });
}

1;
