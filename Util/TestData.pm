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
    $self->initialize_fully;
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
    foreach my $values (
	[
	    'The Laughing Goat Coffeehouse',
	    '1709 Pearl Street',
	    'Boulder',
	    'CO',
	    80302,
	    'US',
	    'http://thelaughinggoat.com/events.php',
	    'http://thelaughinggoat.com',
	    'contact@thelaughinggoat.com',
	    undef,
	    b_use('Type.Scraper')->GOOGLE,
	    'thelaughinggoat',
	],	
	[
	    'Caffe Sole',
	    '637R South Broadway',
	    'Boulder',
	    'CO',
	    80305,
	    'US',
	    'http://www.caffesole.com/events.html',
	    'http://www.caffesole.com',
	    'ashkan@caffesole.com',
	    '303.499.2985',
	    b_use('Type.Scraper')->GOOGLE,
	    'caffesole',
	],
	[
	    q{Nissi's},
	    '2675 North Park Drive',
	    'Lafayette',
	    'CO',
	    80326,
	    'US',
	    'http://www.nissis.com/lmcalendar.html',
	    'http://www.nissis.com',
	    'marc@nissis.com',
	    '303.665.2757',
	    b_use('Type.Scraper')->NISSIS,
	    'nissis',
	],
    ) {
        my($v) = {map(
	    ($_ => shift(@$values)),
	    qw(
		RealmOwner.display_name
		Address.street1
		Address.city
		Address.state
		Address.zip
		Address.country
		calendar.Website.url
		Website.url
		Email.email
		Phone.phone
		Venue.scraper_type
		name
	    ),
	)};
	$self->req->with_realm(
	    b_use('FacadeComponent.Constant')
		->get_value('site_admin_realm_name', $self->req),
	    sub {
		$self->model('VenueForm', $v);
		$self->req('Model.RealmOwner')->update({name => $v->{name}});
		return;
	    },
	);
    }
    return;
}

1;
