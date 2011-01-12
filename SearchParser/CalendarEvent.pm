# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::SearchParser::CalendarEvent;
use strict;
use Bivio::Base 'Search.Parser';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_M) = b_use('Biz.Model');
my($_DT) = b_use('Type.DateTime');

sub do_iterate_realm_models {
    my($self, $op, $req) = @_;
    my($now) = $_DT->now;
    $_M->new($req, 'CalendarEvent')
	->do_iterate(
	    sub {
		my($it) = @_;
		return 1
		    unless $it->is_searchable;
		return $op->($it);
	    },
	    'calendar_event_id asc',
	);
    return;
}

sub get_or_default {
    my($self, $key) = @_;
    return shift->SUPER::get_or_default(@_);
}

sub handle_new_text {
    my($self) = shift->SUPER::handle_new_text(@_);
    my($parseable) = @_;
    my($m) = $parseable->get('model');
    $self->put(
	title => $m->new_other('RealmOwner')
	    ->unauth_load_or_die({realm_id => $m->get('calendar_event_id')})
	    ->get('display_name'),
	content_type => 'text/calendar',
	is_public => 1,
    );
    return $self;
}

sub realms_for_rebuild_db {
    my($self, $req) = @_;
    return $_M->new($req, 'Venue')
	->map_iterate(
	    sub {shift->get('venue_id')},
	    'unauth_iterate_start',
	    'venue_id',
	); 
}

1;
