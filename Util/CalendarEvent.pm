# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Util::CalendarEvent;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');

sub USAGE {
    return <<'EOF';
usage: bivio CalendarEvent [options] command [args..]
commands
  clear_events -- clear all events for a venue
  import_events -- scrape and import events for a venue
EOF
}

sub clear_events {
    my($self) = @_;
    $self->are_you_sure('Clear events for '
        . $self->req(qw(auth_realm owner name)) . '?');
    my($ro) = $self->model('RealmOwner');
    $self->model('CalendarEvent')->do_iterate(sub {
        my($ce) = @_;
	$ro->unauth_delete({
	    realm_id => $ce->get('calendar_event_id'),
	});
	$ce->unauth_delete({
	    calendar_event_id => $ce->get('calendar_event_id'),
	});
 	return 1;
    });
    return;
}

sub import_events {
    my($self) = @_;
    $self->initialize_ui;
    my($list) = $self->model('VenueList')->unauth_load_all;
    $list->find_row_by('RealmOwner.display_name',
        $self->req(qw(auth_realm owner display_name)))
	|| $self->usage_error('venue not found: ',
            $self->req(qw(auth_realm owner display_name)));
    b_use('Bivio.Scraper')->do_one($list, $_DT->now);
    return;
}

1;
