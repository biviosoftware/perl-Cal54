# Copyright (c) 2010 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Util::SQL;
use strict;
use Bivio::Base 'ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ddl_files {
    return shift->SUPER::ddl_files(['bOP', 'c4']);
}

sub initialize_db {
    my($self) = shift;
    my(@res) = $self->SUPER::initialize_db(@_);
    $self->new_other('SiteForum')->init;
    return @res;
}

sub initialize_test_data {
    my($self) = @_;
    my(@res) = shift->SUPER::initialize_test_data(@_);
    $self->new_other('TestData')->init;
    return @res;
}

sub internal_upgrade_db_venue_names {
    my($self) = @_;
    $self->model('Venue')->do_iterate(sub {
        my($v) = @_;
	my($ro) = $v->get_model('RealmOwner');
	b_die() if $ro->get('name') =~ /^v\-/;
	$ro->update({
	    name => 'v-' . $ro->get('name'),
	});
	return 1;
    }, 'unauth_iterate_start');					  
    return;
}

1;
