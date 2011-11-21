# Copyright (c) 2010 CAL54, Inc.  All Rights Reserved.
# $Id$
Request();
my($_V) = b_use('Model.Venue');
config({
    'Bivio::IO::Log' => {
	directory => my $tmp = tmp_dir(),
    },
});
sub {
    my($realm, $test_cases, $scraper_aux, $url) = @_;
    req()->initialize_fully;
    req()->set_realm('site-admin');
    DateTime()->set_test_now($test_now);
    my($dir) = IO_File()->absolute_path($realm);
    my($sl) = model('ScraperList')->load_all;
    $sl->find_row_by({'default_venue.RealmOwner.name',
		      $_V->add_realm_prefix($realm)})
	|| $sl->find_row_by({'scraper.RealmOwner.name', $realm})
	|| b_die();
    $sl->test_replace_scraper_aux($scraper_aux, $url)
	if $scraper_aux;
    my($case) = 1;
    return [
	class() => [
	    {
		method => 'do_one',
		compute_return => sub {
		    my(undef, $actual) = @_;
		    my($scraper) = @$actual;
		    return [
			@{$scraper->get('events')}
			. ' events and '
			. $scraper->get('failures')
			. ' failures'];
		},
	    } => [
		map({
		    my($events, $test_now) = @$_;
		    map({
			my($num_events) = $_;
			my($case_dir) = FilePath()->join($dir, $case++);
			sub {
			    IO_File()->rm_rf($tmp);
			    req()->put(scraper_bunit => $case_dir);
			    DateTime()->set_test_now($test_now);
			    return [$sl, DateTime()->now, 1];
			} => sub {
			    assert_equals(
				read_file("$case_dir.in"),
				read_file((glob("$tmp/*/*/*/*.pl"))[0]),
			    );
			    # This keeps the CVS directory clean
			    unlink("$case_dir.out");
			    return qr{\b$num_events events and 0 failures};
			},
		    } @$events),
		} @$test_cases),
	    ],
	],
    ];
};


