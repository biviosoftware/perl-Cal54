# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Util::Geocode;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

my($_S) = b_use('HTML.Scraper');
my($_API_URI) = 'http://maps.googleapis.com/maps/api/geocode/json';
my($_HTML) = b_use('Bivio.HTML');
my($_JSON) = b_use('MIME.JSON');
my($_CSV) = b_use('Util.CSV');
my($_F) = b_use('IO.File');
my($_A) = b_use('Model.Address');
# Google doesn't like repeated requests in a short period
my($_DELAY) = 1;

sub USAGE {
    return <<'EOF';
usage: bivio Geocode [options] command [args..]
commands
  address_to_geoposition -- get the formatted address and geoposition for an address
  process_all_venues -- create/update the GeoPosition model for all existing venues
EOF
}

sub address_to_geoposition {
    my($self, $address) = @_;
    my($scraper) = $_S->new;
    $address =~ s/\s+/+/g;
    my($uri) = $_API_URI . '?sensor=false' . "&address=$address";
    my($res) = $_JSON->from_text($scraper->extract_content($scraper->http_get($uri)));
    my(@info) = (
	$res->{results}->[0]->{formatted_address},
	$res->{results}->[0]->{geometry}->{location}->{lat},
	$res->{results}->[0]->{geometry}->{location}->{lng},
    );
    if ($res->{status} =~ /ok/i) {
	$self->print($info[0], ': (', $info[1], ', ', $info[2], ")\n");
	return @info;
    }
    b_warn($address, ': address not found : ', $res->{status});
    return;
}

sub process_all_venues {
    my($self) = @_;
    $self->print("Geocode: processing all venues\n");
    my($address_fields) = [qw(
	Address.street1
	Address.street2
	Address.city
	Address.state
	Address.country
    )];
    my($venues) = b_use('Biz.ListModel')->new_anonymous({
	primary_key => [
	    [qw(RealmOwner.realm_id Venue.venue_id Address.realm_id)],
	],
	other => [
	    'RealmOwner.display_name',
	    @$address_fields,
	],
    })->map_iterate();
    my($found) = 0;
    my($total) = 0;
    for my $v (@$venues) {
	$total++;
	$self->print($v->{'RealmOwner.display_name'}, ": ");
	my($address, $lat, $lng) = $self->address_to_geoposition(
	    join(' ', map({$v->{$_} || ''} @$address_fields)),
	);
	sleep($_DELAY)
	    if $_DELAY;
	next
	    unless defined($lat) && defined($lng);
	$found++;
	$self->model('GeoPosition')->unauth_create_or_update({
	    realm_id => $v->{'RealmOwner.realm_id'},
	    latitude => $lat,
	    longitude => $lng,
	});
    }
    $self->print("$total venues processed, $found geographic positions found\n");
    return;
}

1;
