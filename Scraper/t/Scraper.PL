# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
Request();
config({
    'Bivio::IO::Log' => {
	directory => my $tmp = tmp_dir(),
    },
});
sub {
    my($realm, $max_case) = @_;
    req()->initialize_fully;
    req()->set_realm('site-admin');
    DateTime()->set_test_now('1/8/2010 12:00:00');
    my($dir) = IO_File()->absolute_path($realm);
    my($vl) = model('VenueList')->load_all;
    $vl->find_row_by({'Venue.venue_id', realm_id($realm)}) || b_die();
    return [
	class() => [
	    do_one => [
		map(
		    {
			my($case) = $_;
			my($case_dir) = FilePath()->join($dir, $case);
			sub {
			    req()->put(scraper_bunit => $case_dir);
			    return [$vl, DateTime()->now];
			} => sub {
			    assert_equals(
				read_file("$case_dir.in"),
				read_file("$case_dir.out"),
			    );
			    # This keeps the CVS directory clean
			    unlink("$case_dir.out");
			    return qr{[1-9]\d+ events and 0 failures};
			},
		    }
		    1 .. $max_case,
		),
	    ],
	],
    ];
};
