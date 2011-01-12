# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::CalendarEvent;
use strict;
use Bivio::Base 'Model';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_S) = b_use('Bivio.Search');
my($_TS) = b_use('Type.String');

sub create {
    my($self) = @_;
    my($res) = shift->SUPER::create(@_);
    $_S->update_model($self->req, $self);
    return $res;
}

sub delete {
    my($self, $query) = @_;
    $_S->delete_model($self->req, $query ? $query->{calendar_event_id} : $self);
    return shift->SUPER::delete(@_);
}

sub delete_all {
    b_die('not supported');
    # DOES NOT RETURN
}

sub get_auth_user_id {
    return undef;
}

sub get_content {
    my($self) = @_;
#TODO: Consider adding email address
    return \(
	($self->get('location') || '')
	. ' '
	. $self->new_other('RealmOwner')
	->unauth_load_or_die({realm_id => $self->get('realm_id')})
	->get('display_name'),
    );
}

sub get_search_excerpt {
    return ${$_TS->canonicalize_and_excerpt(shift->get('description') || '')};
}

sub is_searchable {
    return $_DT->is_greater_than(shift->get('dtend'), $_DT->now);
}

sub update {
    my($self) = @_;
    $_S->update_model($self->req, $self);
    return shift->SUPER::update(@_);
}

1;
