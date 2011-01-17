# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Util::TestData;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
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
    _init_venues($self);
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
	    $_S->GOOGLE,
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
	    $_S->GOOGLE,
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
	    $_S->NISSIS,
	    'nissis',
	],
	[
	    'CU Macky Auditorium',
	    '1595 Pleasant St',
	    'Boulder',
	    'CO',
	    80302,
	    'US',
	    'http://macky.colorado.edu/events/',
	    'http://macky.colorado.edu',
	    'ignore-cu_macky@bivio.biz',
	    '',
	    $_S->ACTIVE_DATA,
	    'cu_macky',
	],
	[
	    'CU Imig Music Building',
	    '1020 18th Street',
	    'Boulder',
	    'CO',
	    80302,
	    'US',
	    'http://music.colorado.edu/events/',
	    'http://music.colorado.edu',
	    'ignore-cu_imig@bivio.biz',
	    '',
	    $_S->ACTIVE_DATA,
	    'cu_imig',
	],
	[
	    'Fiske Planetarium and Science Center',
	    '408 UCB',
	    'Boulder',
	    'CO',
	    80309,
	    'US',
	    'http://fiske.colorado.edu/events/index.php',
	    'http://fiske.colorado.edu',
	    'fiske@colorado.edu',
	    '303.492.5002',
	    $_S->ACTIVE_DATA,
	    'cu_fiske',
	],
	[
	    'University Memorial Center',
	    '1669 Euclid Av',
	    'Boulder',
	    'CO',
	    80302,
	    'US',
	    'http://umc.colorado.edu/eventlist.html',
	    'http://umc.colorado.edu/',
	    'ignore-cu_umc@bivio.biz',
	    '',
	    $_S->ACTIVE_DATA,
	    'cu_umc',
	],
	[
	    'CU Art Museum',
	    '1085 18th Street',
	    'Boulder',
	    'CO',
	    80309,
	    'US',
	    'http://events.colorado.edu/EventList.aspx?view=Summary',
	    'http://cuartmuseum.colorado.edu/',
	    'ignore-cu_art@bivio.biz',
	    '',
	    $_S->ACTIVE_DATA,
	    'cu_art',
	],
	[
	    'Boulder Public Library - Main Branch',
	    '1001 Arapahoe Avenue',
	    'Boulder',
	    'CO',
	    80302,
	    'US',
	    'http://events.boulderlibrary.org?lib=0',
	    'http://www.boulderlibrary.org',
	    'ignore-bpl_main@bivio.biz',
	    '303.441.3100',
	    $_S->EVANCED,
	    'bpl_main',
	],
	[
	    'Boulder Public Library - George Reynolds Branch',
	    '3595 Table Mesa Drive',
	    'Boulder',
	    'CO',
	    80305,
	    'US',
	    'http://events.boulderlibrary.org?lib=2',
	    'http://www.boulderlibrary.org/locations/grb.html',
	    'ignore-bpl_reynolds@bivio.biz',
	    '303.441.3120',
	    $_S->EVANCED,
	    'bpl_reynolds',
	],
	[
	    'Boulder Public Library - Meadows Branch',
	    '4800 Baseline Road',
	    'Boulder',
	    'CO',
	    80303,
	    'US',
	    'http://events.boulderlibrary.org?lib=3',
	    'http://www.boulderlibrary.org/locations/meadows.html',
	    'ignore-bpl_meadows@bivio.biz',
	    '303.441.4390',
	    $_S->EVANCED,
	    'bpl_meadows',
	],
	[
	    'The West End Tavern',
	    '926 Pearl Street',
	    'Boulder',
	    'CO',
	    80302,
	    'US',
	    'http://www.thewestendtavern.com/Events/LiveMusic/tabid/318/Default.aspx',
	    'http://www.thewestendtavern.com',
	    'westend@bigredf.com',
	    '303.444.3535',
	    $_S->WEST_END_TAVERN,
	    'westend',
	],
	[
	    'Hotel Boulderado',
	    '2115 Thirteenth St.',
	    'Boulder',
	    'CO',
	    80302,
	    'US',
	    'http://www.boulderado.com/musiconthemezz.html',
	    'http://www.boulderado.com',
	    'ignore-boulderaro@bivio.biz',
	    '303.442.4344',
	    $_S->BOULDERADO,
	    'boulderado',
	],
	[
	    'Colorado Chautauqua Association',
	    '900 Baseline Road',
	    'Boulder',
	    'CO',
	    80302,
	    'US',
	    'http://www.chautauqua.com/upcoming_events.php',
	    'http://www.chautauqua.com',
	    'ignore-chautauqua@bivio.biz',
	    '303.442.3282',
	    $_S->CHAUTAUQUA,
	    'chautauqua',
	],
	[
	    'CU Cristol Chemistry & Biochemistry',
	    '1606 Central Campus Mall',
	    'Boulder',
	    'CO',
	    80302,
	    'US',
	    'http://events.colorado.edu/EventList.aspx?view=Summary',
	    'http://events.colorado.edu',
	    'ignore-cu_cristol@colorado.edu',
	    '',
	    $_S->ACTIVE_DATA,
	    'cu_cristol',
	],
	[
	    'CU Duane Physics',
	    '2000 Colorado Av',
	    'Boulder',
	    'CO',
	    80302,
	    'US',
	    'http://events.colorado.edu/EventList.aspx?view=Summary',
	    'http://events.colorado.edu',
	    'ignore-cu_duane@colorado.edu',
	    '',
	    $_S->ACTIVE_DATA,
	    'cu_duane',
	],
	[
	    'Fox Theatre',
	    '1135 13th Street',
	    'Boulder',
	    'CO',
	    80304,
	    'US',
	    'http://foxtheatre.com/Store/ChooseTicket.aspx',
	    'http://foxtheatre.com',
	    'ignore-foxtheatre@colorado.edu',
	    '',
	    $_S->FOX_THEATRE,
	    'foxtheatre',
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
