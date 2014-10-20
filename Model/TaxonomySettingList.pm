# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::TaxonomySettingList;
use strict;
use Bivio::Base 'Model.RealmSettingList';

my($_C) = b_use('FacadeComponent.Constant');
my($_STEMMER) = b_use('Search.Xapian')->get_stemmer;

sub FILE_PATH_BASE {
    return 'Taxonomy';
}

sub taxonomy_map {
    my($proto, $req) = @_;
    return $req->get_if_exists_else_put(
	__PACKAGE__ . '.taxonomy_map',
	sub {_map($proto->new($req))},
    );
}

sub _map {
    my($self) = @_;
    my($x) = $self->unauth_get_all_settings(
	$_C->get_value('site_admin_realm_id', $self->req),
        undef,
	[
	    [qw(supertype Text64K)],
	    [qw(subtype Text64K)],
	],
    );
    my($simple) = {};
    while (my(@x) = each(%$x)) {
	$x[1] = $x[1]->{subtype};
	my($super, $sub) = map(
	    {
		chomp($_);
		$_ =~ s/^[\s\r\n]+|[\s\r\n]+$//sg;
#TODO: This is wrong, but not clear where it would go otherwise...
		[map($_STEMMER->stem_word($_), split(/\s*,\s*/, lc($_)))];
	    }
	    @x,
	);
	foreach my $s (@$sub) {
	    push(@{$simple->{$s} ||= []}, @$super);
	}
    }
    my($res) = {};
    while (my($k, $v) = each(%$simple)) {
	my($seen) = {$k => 1};
	my($expand);
	$expand = sub {
	    return map(
		$seen->{$_}++ ? ()
		    : ($_, $expand->(@{$simple->{$_} || []})),
		@_,
	    );
	};
	$res->{$k} = [sort($expand->(@$v))];
    }
    return $res;
}

1;
