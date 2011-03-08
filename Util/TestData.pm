# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Util::TestData;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = b_use('IO.File');
my($_S) = b_use('Type.Scraper');

sub USAGE {
    return <<'EOF';
usage: bivio TestData [options] command [args..]
commands
  enable_calendar_for_adm -- enable feature_calendar for a venue
  init -- initializes test data
  init_venues -- create/update venues from venues.csv
  reset_all -- deletes all test venues and events
EOF
}

sub enable_calendar_for_adm {
    my($self) = @_;
    $self->assert_not_general;
    $self->req->set_user('adm');
    $self->new_other('RealmRole')
	->edit(qw(ADMINISTRATOR +DATA_READ +DATA_WRITE +FEATURE_CALENDAR));
    $self->new_other('RealmAdmin')->join_user('ADMINISTRATOR');
    return;
}

sub init {
    my($self) = @_;
    $self->assert_test;
    $self->initialize_fully;
    $self->new_other('TestUser')->init;
    $self->init_venues;
    $self->init_scrapers;
    return;
}

sub init_scrapers {
    my($self) = @_;
    my($list) = $self->model('ScraperList')->load_all;
    _iterate_csv($self, 'scrapers.csv', sub {
        my($v) = @_;
	delete($v->{'Scraper.scraper_id'});
	delete($v->{'Website.location'});
	$v->{'Scraper.scraper_type'} =
	    $_S->from_any($v->{'Scraper.scraper_type'});
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
    my($self) = @_;
    _iterate_csv($self, 'venues.csv', sub {
	my($v) = @_;	     
        delete($v->{'Venue.venue_id'});
	my($ro) = $self->model('RealmOwner');
	$self->req->put(query =>
	    $ro->unauth_load({
		name => $v->{'RealmOwner.name'},
	    })
		? $ro->format_query_for_this
		: undef);
	$self->model('VenueForm', $v);
	$self->req->clear_nondurable_state;
    });
    return;
}

sub reset_all {
    my($self) = @_;
    $self->assert_test;
    foreach my $type (qw(CALENDAR_EVENT VENUE)) {
	$self->model('RealmOwner')
	    ->do_iterate(
		sub {
		    my($it) = @_;
		    $self->model('Venue')->unauth_delete_realm($it)
			if $it->get('display_name') =~ /\btest\b/i;
		    return 1;
		},
		'unauth_iterate_start',
		'realm_id',
		{realm_type => [$type]},
	    );
    }
    return;
}

sub _iterate_csv {
    my($self, $csv_file, $op) = @_;
    $self->initialize_ui;
    $self->req->with_realm(
	b_use('FacadeComponent.Constant')
	    ->get_value('site_admin_realm_name', $self->req),
	sub {
	    foreach my $v (@{$self->new_other('CSV')
	        ->parse_records($_F->read($csv_file))}) {
		$op->($v);
	    }
	});
    return;
}

1;
