# Copyright (c) 2010-2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Util::CalendarEvent;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_F) = b_use('IO.File');
my($_S) = b_use('Bivio.Scraper');
my($_ST) = b_use('Type.Scraper');

sub USAGE {
    return <<'EOF';
usage: bivio CalendarEvent [options] command [args..]
commands
  clear_events -- clear all events for a venue
  delete_scraper -- delete a scraper and all events associated with it
  export_venues -- export venues.csv
  export_scrapers -- export scrapers.csv
  import_events -- scrape and import events for a venue
  import_events_for_all_venues -- scrape all venues
  init_scrapers -- create/update scrapers from scrapers.csv
  init_venues -- create/update venues from venues.csv
EOF
}

sub clear_events {
    my($self) = @_;
    $self->are_you_sure('Clear events for '
        . $self->req(qw(auth_realm owner name)) . '?');
    my($ro) = $self->model('RealmOwner');
    my($sw) = $self->model('SearchWords');
    my($ve) = $self->model('VenueEvent');
    my($count) = 0;
    $self->model('CalendarEvent')->do_iterate(sub {
        my($ce) = @_;
	$sw->unauth_delete({
	    realm_id => $ce->get('calendar_event_id'),
	});
	$ro->unauth_delete({
	    realm_id => $ce->get('calendar_event_id'),
	});
	$ve->unauth_delete({
	    calendar_event_id => $ce->get('calendar_event_id'),
	});
	$ce->unauth_delete({
	    calendar_event_id => $ce->get('calendar_event_id'),
	});
	$count++;
 	return 1;
    });
    return 'deleted ' . $count . ' events';
}

sub delete_scraper {
    my($self) = @_;
    my($scraper) = $self->model('Scraper')->load;
    my($count) = 0;
    $self->model('CalendarEvent')->do_iterate(sub {
       my($ce) = @_;
       $self->unauth_model('VenueEvent', {
	   calendar_event_id => $ce->get('calendar_event_id'),
       })->delete;
       $ce->cascade_delete;
       $count++;
       return 1;
   });
    $self->print($count, " events\n");
    $scraper->cascade_delete;
    return;
}

sub export_scrapers {
    my($self) = @_;
    return _csv($self, 'ScraperList',
        'default_venue.RealmOwner.name,Scraper.scraper_type,scraper.RealmOwner.name,Website.url,Scraper.scraper_aux');
}

sub export_venues {
    my($self) = @_;
    return _csv($self, 'VenueList',
        'RealmOwner.name,RealmOwner.display_name,Website.url,calendar.Website.url,Email.email,Phone.phone,Address.street1,Address.street2,Address.city,Address.state,Address.zip,Address.country,SearchWords.value');
}

sub import_events {
    my($self) = @_;
    $self->initialize_ui;
    my($list) = $self->model('ScraperList')->unauth_load_all;

    # find scraper by scraper_id or venue name
    unless ($list->find_row_by('Scraper.scraper_id', $self->req('auth_id'))) {
	$list->find_row_by('default_venue.RealmOwner.display_name',
            $self->req(qw(auth_realm owner display_name)))
	        || $self->usage_error('venue not found: ',
		    $self->req(qw(auth_realm owner display_name)));
    }
    $_S->do_one($list, $_DT->now, $self->unsafe_get('force'));
    return;
}

sub import_events_for_all_venues {
    my($self) = @_;
    $self->initialize_ui;
    $_S->do_all($self->model('ScraperList')->unauth_load_all);
    return;
}

sub init_scrapers {
    my($self, $filename) = @_;
    my($list) = $self->model('ScraperList')->load_all;
    _iterate_csv($self, $filename, sub {
        my($v) = @_;
	$v->{'Scraper.scraper_type'} =
	    $_ST->from_any($v->{'Scraper.scraper_type'});
	$v->{'Scraper.default_venue_id'} =
	    $v->{'default_venue.RealmOwner.name'}
	    ? $self->unauth_model('RealmOwner', {
		name => $v->{'default_venue.RealmOwner.name'},
	    })->get('realm_id')
	    : undef;
	$self->req->put(query =>
	    $list->find_row_by('Website.url', $v->{'Website.url'})
		? $list->format_query('THIS_DETAIL')
		: undef);
	$self->print('added scraper: ',
	    $self->req(qw(Model.Scraper scraper_id)),
	    ' ', $v->{'Website.url'}, "\n")
	    unless $self->req('query');
	$self->model('ScraperForm', $v);
	$self->unauth_model('RealmOwner', {
	    realm_id => $self->req(qw(Model.Scraper scraper_id)),
	})->update({
	    name => $v->{'scraper.RealmOwner.name'},
	}) if $v->{'scraper.RealmOwner.name'} =~ /\_/;
	$self->req->clear_nondurable_state;
    });
    return;
}

sub init_venues {
    my($self, $filename) = @_;
    _iterate_csv($self, $filename, sub {
	my($v) = @_;	     
	my($ro) = $self->model('RealmOwner');
	$self->req->put(query =>
	    $ro->unauth_load({
		name => $v->{'RealmOwner.name'},
	    })
		? $ro->format_query_for_this
		: undef);
	$self->print('added venue: ', $v->{'RealmOwner.display_name'},
	    ', ', $v->{'Address.city'}, "\n")
	    unless $self->req('query');
	$self->model('VenueForm', $v);
	$self->req->clear_nondurable_state;
    });
    return;
}

sub _csv {
    my($self, $list, $cols) = @_;
    $self->req->set_realm('site-admin');
    my($csv) = $self->new_other('ListModel')->csv($list, '', $cols);
    $$csv =~ s/\n+Notes:.*$/\n/s || b_die();
    return $csv;
}

sub _iterate_csv {
    my($self, $filename, $op) = @_;
    $self->initialize_ui;
    $self->req->with_realm(
	b_use('FacadeComponent.Constant')
	    ->get_value('site_admin_realm_name', $self->req),
	sub {
	    foreach my $v (@{$self->new_other('CSV')
	        ->parse_records($filename
		    ? $_F->read($filename)
		    : $self->read_input)}) {
		$op->($v);
	    }
	});
    return;
}

1;
