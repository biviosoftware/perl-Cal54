# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::FandangoVenues;
use strict;
use Bivio::Base 'HTML.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = b_use('IO.File');
my($_R) = b_use('IO.Ref');
my($_G) = b_use('ShellUtil.Geocode');
my($_CSV) = b_use('ShellUtil.CSV');
my($_DIRECTORY) = 'FandangoVenues';

sub new {
    return shift->SUPER::new({directory => $_DIRECTORY});
}

sub scrape_co_theaters {
    my($self) = @_;
    my($all) = do(my $cache = "$_DIRECTORY/cache.pl") || {};
    foreach my $uri (
	${$self->extract_content($self->http_get('http://www.fandango.com/site-index/theaters/co.html', 'theaters_co.html'))}
	=~ m{"(http://www.fandango.com/\w+/theaterpage)"}g,
    ) {
        print(STDERR "$uri\n");
	die($uri)
	    unless $uri =~ m{\.com/(\w+)_([a-z]+)};
	next
	    if $all->{$1};
	$all->{$1} = my $info = {
	    uri => $uri,
	    code => $2,
	    name => $1,
	};
	foreach my $line (split(/\n/, ${$self->extract_content($self->http_get($uri, "$info->{name}.html"))})) {
	    unless ($info->{display_name}) {
		$info->{display_name} = $1
		    if $line =~ m{<h3><a href=".+?">(.+?)<}s;
		next;
	    }
	    if ($line =~ /(\w[\w\s]+)\s*,\s*([A-Z][A-Z])\s*\&nbsp\;\s*(\d+)\s*</) {
		@$info{qw(city state zip)} = ($1, $2, $3);
	    }
	    elsif ($line =~ /\((\d+)\)\s*(\d+)-(\d+)/) {
		$info->{phone} = "$1.$2.$3";
		last;
	    }
	    elsif ($line =~ /(\w+)\s*[-\s]+\s*(\w+)\s*-\s*(\w+)/) {
		$info->{phone} = "$1.$2.$3";
		last;
	    }
	    elsif ($line =~ m{^\s*</p>}s) {
		$info->{phone} = '';
		last;
	    }
	    else {
		die('too many street: ', $line)
		    if $info->{street1};
		die('street: ', $line)
		    unless $line =~ m{<p>(.+)<};
		$info->{street1} = $1;
	    }
	}
	$_F->write($cache, $_R->to_string($all));
	sleep(1);
    }
    my($res) = '';
    foreach my $name (sort(keys(%$all))) {
	my($info) = $all->{$name};
	unless ($info->{latitude}) {
	    my(undef, $lat, $long) = $_G->address_to_geoposition(
		"$info->{street1}, $info->{city}, $info->{state} $info->{zip}");
	    $info->{latitude} = $lat;
	    $info->{longitude} = $long;
	    $_F->write($cache, $_R->to_string($all));
	    sleep(1);
	}
	$res .= ${$_CSV->from_one_row([
	    $info->{display_name},
	    "v-fandango_$info->{code}",
	    $info->{uri},
	    $info->{uri},
	    '',
	    $info->{phone},
	    $info->{street1},
	    '',
	    $info->{city},
	    $info->{state},
	    $info->{zip},
	    'US',
	    $info->{latitude},
	    $info->{longitude},
	])};
    }
    $_F->write("$_DIRECTORY/venues.csv", $res);
    return $res;
}

1;
