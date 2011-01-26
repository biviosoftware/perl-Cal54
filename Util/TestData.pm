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
	    'Bunit Test',
	    '111 main',
	    'Boulder',
	    'CO',
	    80304,
	    'US',
	    'http://test.bunit/cal',
	    'http://test.bunit',
	    'ignore-bunit@bivio.biz',
	    '',
	    $_S->GOOGLE,
	    'bunit_venue',
	],
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
	    'coffee food',
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
	    'coffee food',
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
	    $_S->REGEXP,
	    'nissis',
	    'music',
	    <<'EOF',
{
    repeat => [
	[qr/($month\s*>.*)/, {
	    fields => ['link'],
	    follow_link => {
		global => [
		    [qr/$month\s+$year/, {
			fields => ['month', 'year'],
		    }],
		],
		repeat => [
		    [qr/\n$day\s+$time\s*\-\s*$time\s(.*?)(\n$day\n|\nGathering Place)/s, {
			fields => ['day', 'start_time_pm', 'end_time_pm',
			    'description', 'save'],
			summary_from_description =>
			    qr/(?:^|\n)([^\n]+\{\d+\})\n/s,
		    }],
		],
	    },
	}],
    ],
}
EOF
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
	    'cu',
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
	    'cu',
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
	    'cu',
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
	    'cu umc',
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
	    $_S->REGEXP,
	    'westend',
	    undef,
	    <<'EOF',
{
    repeat => [
        [qr/(?:$month\s+)?$day\s+(.*?)\s*,\s*$time_ap\s+(.*?)\n\n/s, {
	    fields => ['month', 'day', 'summary', 'start_time', 'description'],
	}],
    ],
}
EOF
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
	    $_S->REGEXP,
	    'boulderado',
	    undef,
	    <<'EOF',
{
    global => [
        [qr/Live Music ${time_ap}\s*\-\s*$time_ap/, {
            fields => ['start_time', 'end_time'],
	}],
    ],
    repeat => [
        [qr/\b$day_name,\s*$month\s+$day\s*~\s*$line(?:\((.*?)\))?/, {
	    fields => ['day_name', 'month', 'day', 'summary', 'description'],
	}],
    ],
}
EOF
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
	    $_S->REGEXP,
	    'chautauqua',
	    undef,
	    <<'EOF',
{
    repeat => [
	[qr{([^\n]+?\n(?:[^\n]+?\n)?)\w+,\s*$month\s+$day,\s+$year,\s+$time_ap.*?\n\n([^\n]+)\n\n}s, {
	    fields => [qw(summary month day year start_time description)],
	}],
    ],
}
EOF
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
	    $_S->REGEXP,
	    'foxtheatre',
	    undef,
	    <<'EOF',
{
    repeat => [
	[qr{^$month_day\s+(.*?)\s*$}m, {
	    fields => [qw(month_day summary)],
	    follow_link => {
		global => [
		    [qr{\bshow\:\s*$time_ap}i, {
			fields => ['start_time'],
		    }],
		    [qr{about this show.*?\n+(.*?)\n}is, {
			fields => ['description'],
		    }],
		],
	    }
	}],
    ],
}
EOF
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
		RowTag.value
		Venue.scraper_aux
	    ),
	)};
	$self->req->with_realm(
	    b_use('FacadeComponent.Constant')
		->get_value('site_admin_realm_name', $self->req),
	    sub {
		$self->model('VenueForm', $v);
		$self->req('Model.RealmOwner')->update({name => $v->{name}});
		$self->req('Model.Venue')->update({
		    scraper_aux => $v->{'Venue.scraper_aux'},
		});
		return;
	    },
	);
    }
    return;
}

1;
