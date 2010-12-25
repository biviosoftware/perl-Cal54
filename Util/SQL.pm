# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Util::SQL;
use strict;
use Bivio::Base 'ShellUtil';

# export BCONF=~/bconf/c4.bconf
# cd files/ddl
# perl -w ../../Util/c4-sql init_dbms
# perl -w ../../Util/c4-sql create_test_db

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub clear_calendar_events {
    my($self) = @_;
    $self->usage_error('Can not be run with a production database.')
	if $self->req->is_production;
    $self->model('CalendarEvent')->do_iterate(sub {
        my($ce) = @_;
	$ce->cascade_delete;
	return 1;
    }, 'unauth_iterate_start');
    return;
}

sub ddl_files {
    return shift->SUPER::ddl_files(['bOP', 'c4']);
}

sub import_ics {
    my($self) = @_;
    $self->assert_not_general;
    $self->initialize_ui;
    $self->model('CalendarEvent')->update_from_ics($self->read_input);
    return;
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

1;
