# Copyright (c) 2010-2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Util::CalendarEvent;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

my($_DT) = b_use('Type.DateTime');
my($_F) = b_use('IO.File');
my($_S) = b_use('Bivio.Scraper');
my($_ST) = b_use('Type.Scraper');

sub USAGE {
    return <<'EOF';
usage: bivio CalendarEvent [options] command [args..]
commands
  clear_events -- clear all events for a venue
  clean_page -- input html file, output HTMLCleaner text
  delete_scraper -- delete a scraper and all events associated with it
  delete_dead_scrapers -- deletes scrapers not in the scrapers.csv
  export_venues -- export venues.csv
  export_scrapers -- export scrapers.csv
  import_events -- scrape and import events for a venue
  import_events_for_all_venues -- scrape all venues
  init_scrapers -- create/update scrapers from scrapers.csv
  init_venues -- create/update venues from venues.csv
EOF
}

sub clean_page {
    my($self) = @_;
    return b_use('Cal54::HTMLCleaner')->new->clean_html(
	$self->read_input,
	'http://ignore/',
    );
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

sub delete_dead_scrapers {
    my($self) = @_;
    my($list) = $self->model('ScraperList')->load_all;
    my($visited_urls) = {
	@{$list->map_rows(sub {
	    return shift->get(qw(Website.url Scraper.scraper_id));
	})}
    };
    my($count) = scalar(keys(%$visited_urls));
    _iterate_csv($self, undef, sub {
        my($v) = @_;
	delete($visited_urls->{$v->{'Website.url'}});
	return 1;
    });
    b_die('no records matched')
	if $count == scalar(keys(%$visited_urls));

    foreach my $id (values(%$visited_urls)) {
	$self->req->with_realm($id, sub {
            $self->clear_events;
	    $self->new_other('RealmAdmin')->delete_auth_realm;
	});
    }
    return;
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
        'Website.url,default_venue.RealmOwner.name,Scraper.scraper_type,scraper.RealmOwner.name,Scraper.scraper_aux', 'o=3a');
}

sub export_venues {
    my($self) = @_;
    $self->initialize_fully;
    $self->new_other('Geocode')->process_all_venues;
    return _csv($self, 'VenueList',
        'RealmOwner.display_name,RealmOwner.name,Website.url,calendar.Website.url,Email.email,Phone.phone,Address.street1,Address.street2,Address.city,Address.state,Address.zip,Address.country,GeoPosition.latitude,GeoPosition.longitude,SearchWords.value');
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
    $self->commit_or_rollback;
    $self->req->set_realm(undef);
    $self->req->set_user(undef);
    $self->new_other('Search')->put(
	force => 1,
    )->rebuild_db;
    return;
}

sub init_scrapers {
    my($self, $filename) = @_;
    my($list) = $self->model('ScraperList')->load_all;
    my($visited_urls) = {
	@{$list->map_rows(sub {
	    return shift->get(qw(Website.url Scraper.scraper_id));
	})}
    };
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
	delete($visited_urls->{$v->{'Website.url'}});
	$self->req->put(query =>
	    $list->find_row_by('Website.url', $v->{'Website.url'})
		? $list->format_query('THIS_DETAIL')
		: undef);
	my($is_new_scraper) = $self->req('query') ? 0 : 1;
	$self->model('ScraperForm', $v);
	$self->print('added scraper: ',
	    $self->req(qw(Model.Scraper scraper_id)),
	    ' ', $v->{'Website.url'}, "\n")
	    if $is_new_scraper;
	$self->unauth_model('RealmOwner', {
	    realm_id => $self->req(qw(Model.Scraper scraper_id)),
	})->update({
	    name => $v->{'scraper.RealmOwner.name'},
	}) if $v->{'scraper.RealmOwner.name'} =~ /\_/;
	$self->req->clear_nondurable_state;
    });
    b_info('orphaned urls: ', $visited_urls)
	if %$visited_urls;
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
	$ro->unauth_load({
	    name => $v->{'RealmOwner.name'},
	}) unless $ro->is_loaded;
	$self->model('GeoPosition')->unauth_create_or_update({
	    realm_id => $ro->get('realm_id'),
	    latitude => $v->{'GeoPosition.latitude'},
	    longitude => $v->{'GeoPosition.longitude'},
	}) if $v->{'GeoPosition.latitude'} && $v->{'GeoPosition.longitude'};
	$self->req->clear_nondurable_state;
    });
    return;
}

sub _csv {
    my($self, $list, $cols, $query) = @_;
    $self->req->set_realm('site-admin');
    my($csv) = $self->new_other('ListModel')->csv($list, $query || '', $cols);
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
