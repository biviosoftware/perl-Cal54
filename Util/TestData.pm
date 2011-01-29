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
    return;
}

sub init_venues {
    my($self) = @_;
    $self->initialize_ui;
    $self->req->with_realm(
	b_use('FacadeComponent.Constant')
	    ->get_value('site_admin_realm_name', $self->req),
	sub {

	    foreach my $v (@{$self->new_other('CSV')
	        ->parse_records($_F->read('venues.csv'))}) {
		delete($v->{'Venue.venue_id'});
		my($ro) = $self->model('RealmOwner');

		if ($ro->unauth_load({
		    name => $v->{'RealmOwner.name'},
		})) {
		    $self->req->put(query => $ro->format_query_for_this);
		}
		my($scraper) = $v->{'Venue.scraper_type'};
		next unless $scraper;
		$v->{'Venue.scraper_type'} = $_S->from_any($scraper);
		$self->model('VenueForm', $v);
		$self->req('Model.RealmOwner')->update({
		    name => $v->{'RealmOwner.name'},
		});
		$self->req('Model.Venue')->update({
		    scraper_aux => $v->{'Venue.scraper_aux'},
		});
	    }
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

1;
