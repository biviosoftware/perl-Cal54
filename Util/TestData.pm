# Copyright (c) 2010-2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Util::TestData;
use strict;
use Bivio::Base 'Bivio.ShellUtil';


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
    my($ce) = $self->new_other('CalendarEvent');
    $ce->init_venues('venues.csv');
    $ce->init_scrapers('scrapers.csv');
    $self->req->with_realm(
	'v-bouldertheatre',
	sub {
	    $ce->import_events;
	    return;
	},
    );
    return;
}

sub reset_all {
    my($self) = @_;
    $self->assert_test;
    foreach my $type (
	[qw(CALENDAR_EVENT CalendarEvent)],
	[qw(VENUE Venue)]
    ) {
	$self->model('RealmOwner')->do_iterate(
	    sub {
		my($it) = @_;
		$self->model($type->[1])->unauth_delete_realm($it)
		    if $it->get('display_name') =~ /\btest\b/i;
		return 1;
	    },
	    'unauth_iterate_start',
	    'realm_id',
	    {realm_type => [$type->[0]]},
	);
    }
    return;
}

1;
