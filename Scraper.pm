# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper;
use strict;
use Bivio::Base 'HTML.Scraper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_A) = b_use('IO.Alert');
my($_C) = b_use('IO.Config');
my($_CE) = b_use('Model.CalendarEvent');
my($_DT) = b_use('Type.DateTime');
my($_F) = b_use('IO.File');
my($_FP) = b_use('Type.FilePath');
my($_L) = b_use('IO.Log');
my($_T) = b_use('Agent.Task');
#TODO: Make a RowTag
my($_TZ) = b_use('Type.TimeZone')->AMERICA_DENVER;

sub c4_scraper_get {
    my($self, $uri) = @_;
    my($log) = _log($self);
    return $self->extract_content($self->http_get($uri, $log))
	unless my $d = _bunit_dir($self);
    $self->put(last_uri => $self->abs_uri($uri));
    return $self->read_file($_FP->join($d, $_FP->get_tail($log)));
}

sub do_all {
    my($self, $venue_list) = @_;
    my($date_time) = $_DT->now;
    $venue_list->do_rows(
	sub {
	    my($it) = @_;
	    return 1
		unless $it->get('scraper_type')->eq_nissis;
	    $_A->reset_warn_counter;
	    b_info($self->do_one($it, $date_time));
	    return 1;
	},
    );
    return;
}

sub do_one {
    my($proto, $venue_list, $date_time) = @_;
    my($self) = $proto->new({
	req => $venue_list->req,
#TODO: Do not hardwire
	time_zone => $_TZ,
	venue_list => $venue_list,
        log_stamp => $_DT->to_file_name($date_time),
	date_time => $date_time,
	log_index => 1,
	events => [],
	failures => 0,
	tz => $_TZ,
    });
    $self->req->with_realm(
	$venue_list->get('Venue.venue_id'),
	sub {
	    return $self->internal_catch(
		sub {
		    $self->internal_import;
		    _update($self);
		    return;
		},
	    );
	},
    );
    return b_debug $venue_list->get_model('RealmOwner')->as_string
	. ': '
	. @{$self->get('events')}
	. ' events and '
	. $self->get('failures')
	. ' failures';
}

sub get_request {
    return shift->get('req');
}

sub internal_catch {
    my($self, $op) = @_;
    return
	unless my $die = b_catch($op);
    _log(
	$self,
	\(join(
	    "\n",
	    $die->as_string,
	    $self->get_or_default('last_text', ''),
	    $self->get_or_default('last_uri', ''),
	    $self->get_or_default('last_log', ''),
	    $die->get_or_default('stack', ''),
	)),
	'.err',
    );
    $self->put(failures => $self->get('failures') + 1);
    return;
}

sub _bunit_dir {
    my($self) = @_;
    return $_C->is_test && $self->ureq('scraper_bunit');
}

sub _log {
    my($self, $content, $suffix) = @_;
    my($file) = $_L->file_name(
	$_FP->join(
	    $self->simple_package_name,
	    $self->get('log_stamp'),
	    $self->get('venue_list')->get('Venue.venue_id'),
	    _log_base($self, $suffix),
	),
	$self->req,
    );
    $_F->mkdir_parent_only($file);
    $self->put(last_log => $file);
    return $file
	unless defined($content);
    $_F->write($file, $content);
    return;
}

sub _log_base {
    my($self, $suffix) = @_;
    $self->put(log_index => 1 + (my $li = $self->get('log_index')));
    return sprintf('%04d', $li) . ($suffix || '.html');
}

sub _update {
    my($self) = @_;
    my($bunit_dir) = _bunit_dir($self);
    $_F->write("$bunit_dir.out", b_use('IO.Ref')->to_string($self->get('events')))
	if $bunit_dir;
    my($ce) = $_CE->new($self->req);
    my($date_time) = $self->get('date_time');
    foreach my $event (@{$self->get('events')}) {
#TODO: only newer events
#TODO: delete newer events which are no longer valid
#TODO: deal with repeated events
	unless ($ce->unsafe_load({dtstart => $event->[0]->{dtstart}})) {
	    $ce->create_realm(@$event);
	    next;
	}
	if ($_DT->is_equal($ce->get('modified_date_time'), $date_time)) {
	    b_warn($event, ': duplicate dtstart just inserted: ', $ce->get_shallow_copy);
	    next;
	}
	$ce->update($event->[0]);
	$ce->new_other('RealmOwner')
	    ->unauth_load_or_die({realm_id => $ce->get('calendar_event_id')})
	    ->update($event->[1]);
    }
    $_T->commit($self->req)
	unless $bunit_dir;
    return;
}

1;
