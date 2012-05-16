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

sub internal_upgrade_db_geo_position {
    my($self) = @_;
    $self->run(<<'EOF');
CREATE TABLE geo_position_t (
  realm_id NUMERIC(18) NOT NULL,
  latitude NUMERIC(11,8) NOT NULL,
  longitude NUMERIC(11,8) NOT NULL,
  CONSTRAINT geo_position_t1 PRIMARY KEY(realm_id)
)
/
EOF
    return;
}

sub internal_upgrade_db_typo_20111118 {
    my($self) = @_;
    $self->req->with_realm(
	'v-denverparamount',
	sub {
	    $self->req(qw(auth_realm owner))->update({
		display_name => 'Paramount Theatre',
	    });
	    return;
	},
    );
    return;
}

1;
