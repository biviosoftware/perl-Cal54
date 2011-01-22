# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
Request();
config({
    'Bivio::IO::Log' => {
	directory => my $tmp = tmp_dir(),
    },
});
sub {
    my($realm, $test_cases) = @_;
    req()->initialize_fully;
    req()->set_realm('site-admin');
    DateTime()->set_test_now($test_now);
    my($dir) = IO_File()->absolute_path($realm);
    my($vl) = model('VenueList')->load_all;
    $vl->find_row_by({'Venue.venue_id', realm_id($realm)}) || b_die();
    my($case) = 1;
    return [
	class() => [
	    do_one => [
		map({
		    my($events, $test_now) = @$_;
		    map({
			my($num_events) = $_;
			my($case_dir) = FilePath()->join($dir, $case++);
			sub {
			    IO_File()->rm_rf($tmp);
			    req()->put(scraper_bunit => $case_dir);
			    DateTime()->set_test_now($test_now);
			    return [$vl, DateTime()->now];
			} => sub {
			    assert_equals(
				read_file("$case_dir.in"),
				read_file((glob("$tmp/*/*/*/*/*.pl"))[0]),
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


