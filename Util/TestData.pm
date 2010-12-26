# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Util::TestData;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: bivio TestData [options] command [args..]
commands
  init -- initializes test data
  reset_all - deletes all test venues and events
EOF
}

sub init {
    my($self) = @_;
    $self->assert_test;
    $self->new_other('TestUser')->init;
    _init_venues($self);
    _init_calendar_events($self);
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

sub _init_calendar_events {
    my($self) = @_;
#    wget http://www.google.com/calendar/ical/thelaughinggoat%40gmail.com/public/basic.ics
    foreach my $venue (qw(caffesole thelaughinggoat)) {
	$self->req->with_realm($venue => sub {
	    $self->new_other('CalendarEvent')
		->put(input => "$venue.ics")
		->import_ics;
	    return;
	});
    }
    return;
}

sub _init_venues {
    my($self) = @_;
    $self->model('VenueForm', {
	'RealmOwner.display_name' => 'The Laughing Goat Coffeehouse',
	'Address.street1' => '1709 Pearl Street',
	'Address.city' => 'Boulder',
	'Address.state' => 'CO',
	'Address.zip' => 80302,
	'Address.country' => 'US',
	'calendar.Website.url' => 'http://thelaughinggoat.com/events.php',
	'Website.url' => 'http://thelaughinggoat.com',
	'Email.email' => 'contact@thelaughinggoat.com',
	'Phone.phone' => undef,
    });
    $self->req('Model.RealmOwner')->update({name => 'thelaughinggoat'});
    $self->model('VenueForm', {
	'RealmOwner.display_name' => 'Caffe Sole',
	'Address.street1' => '637R South Broadway',
	'Address.city' => 'Boulder',
	'Address.state' => 'CO',
	'Address.zip' => 80305,
	'Address.country' => 'US',
	'calendar.Website.url' => 'http://www.caffesole.com/events.html',
	'Website.url' => 'http://www.caffesole.com',
	'Email.email' => 'ashkan@caffesole.com',
	'Phone.phone' => '303.499.2985',
    });
    $self->req('Model.RealmOwner')->update({name => 'caffesole'});
    return;
}

1;
