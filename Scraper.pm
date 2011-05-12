# Copyright (c) 2010-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper;
use strict;
use Bivio::Base 'HTML.Scraper';
use XML::Simple ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_A) = b_use('IO.Alert');
my($_C) = b_use('IO.Config');
my($_CE) = b_use('Model.CalendarEvent');
my($_CEFL) = b_use('Model.CalendarEventFilterList');
my($_DT) = b_use('Type.DateTime');
my($_F) = b_use('IO.File');
my($_FP) = b_use('Type.FilePath');
my($_HC) = b_use('Bivio.HTMLCleaner');
my($_L) = b_use('IO.Log');
my($_R) = b_use('IO.Ref');
my($_RO) = b_use('Model.RealmOwner');
my($_RT) = b_use('Auth.RealmType');
my($_T) = b_use('Agent.Task');
#TODO: Make a RowTag
my($_TT) = b_use('Type.Text');
my($_TZ) = b_use('Type.TimeZone')->get_default;
my($_V) = b_use('Model.Venue');
my($_VE) = b_use('Model.VenueEvent');

sub c4_scraper_get {
    my($self, $uri) = @_;
    my($log) = _log($self);
    my($d);
    unless ($d = _bunit_dir($self)) {
	sleep(1);
	# ignore utf warnings
	local($SIG{__WARN__}) = sub {};
	return $self->extract_content($self->http_get($uri, $log));
    }
    $self->put(last_uri => $self->abs_uri($uri));
    return $self->read_file($_FP->join($d, $_FP->get_tail($log)));
}

sub do_all {
    my($proto, $scraper_list) = @_;
    my($date_time) = $_DT->now;
    $scraper_list->do_rows(
	sub {
	    my($it) = @_;
	    $_A->reset_warn_counter;
	    $_T->commit($proto->do_one($it, $date_time)->req);
	    return 1;
	},
    );
    return;
}

sub do_one {
    my($proto, $scraper_list, $date_time) = @_;
    my($self) = $scraper_list->get_scraper_class->new({
	req => $scraper_list->req,
#TODO: Do not hardwire
	time_zone => $_TZ,
	scraper_list => $scraper_list,
	log_stamp => $_DT->to_file_name($date_time),
	date_time => $date_time,
	log_index => 1,
	events => [],
	failures => 0,
	tz => $_TZ,
    });
    $self->req->with_realm(
	$scraper_list->get('Scraper.scraper_id'),
	sub {
	    return $self->internal_catch(
		sub {
		    $self->internal_import;
		    b_die('no events')
			unless @{$self->get('events')};
		    _filter_events($self);
		    _log($self, $_R->to_string($self->get('events')), '.pl');
		    $self->internal_update;
		    return;
		},
	    );
	},
    );
    b_info($scraper_list->get('Website.url'),
	   ', ', scalar(@{$self->get('events')}), ' events',
	   $self->unsafe_get('add_count')
	       ? (', ', $self->get('add_count'), ' new')
	       : (),
	   $self->unsafe_get('delete_count')
	       ? (', ', $self->get('delete_count'), ' deleted')
	       : ());
    return $self;
}

sub eval_scraper_aux {
    my($self) = @_;
    my($aux) = $self->get('scraper_list')->get('Scraper.scraper_aux');
    return {} unless $aux;
    my($res) = eval($aux);
    b_die('eval failed: ', $@)
	if $@;
    $self->put(scraper_aux => $res);
    return $res;
}

sub get_request {
    return shift->get('req');
}

sub get_scraper_aux {
    my($self) = @_;
    return $self->get('scraper_aux')
	if $self->unsafe_get('scraper_aux');
    my($res) = $self->eval_scraper_aux;
    $self->put(scraper_aux => $res);
    return $res
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
    $self->put(die => $die);
    return;
}

sub internal_clean {
    my($self, $value) = @_;
    $value = ${$_HC->clean_text(\$value)};
    $value =~ s{<.*?>}{ }sg;
    return $value;
}

sub internal_compute_year {
    my($self, $month) = @_;
    my($current_month, $current_year) =
	$_DT->get_parts($self->get('date_time'), qw(month year));
    return $current_year
	if abs($month - $current_month) < 6;
    return $current_year + ($month > $current_month ? -1 : 1);
}

sub internal_date_time {
    my($self, $str) = @_;
    # mm/dd/yyyy hh:mm (a|p)m
    # mm/dd/yyyy hh(a|p)m
    # yyyy/mm/dd hh:mm (a|p)m
    $str =~ s/(a|p)\.?(m)\.?/$1$2/i;
    my($d, $t) = $str =~ m,^([\d/]+)\s+(.*?)\s*$,;
    b_die('unparsable date/time: ', $str)
	unless $t;
    my($mon, $mday, $year) = split('/', $d);
    ($mon, $mday, $year) = ($mday, $year, $mon)
	if length($mon) eq 4;
    my($hour, $min, $ap) = $t =~ m,^(\d+)\:(\d+)\s*(a|p)m$,i;

    unless ($year && $ap) {
	($hour, $ap) = $t =~ m,^(\d+)\s*(a|p)m$,i;
	b_die('unparsable date/time: ', $str)
	    unless $ap;
	$min = 0;
    }
    $hour += 12 if lc($ap) eq 'p' && $hour < 12;
    return $self->get('time_zone')->date_time_to_utc(
	$_DT->from_parts_or_die(0, $min, $hour, $mday, $mon, $year));
}

sub internal_parse_xml {
    my($self, $url) = @_;
    my($xml, $err) = XML::Simple::xml_in(${$self->c4_scraper_get($url)},
        NoAttr => 1,
	SuppressEmpty => undef,
	KeyAttr => [],
    );
    b_die('xml parse error: ', $err) if $err;
    b_die('no xml data for url: ', $url) unless keys(%$xml);
    return $xml;
}

sub internal_update {
    my($self) = @_;
    my($ce) = $_CE->new($self->req);
    my($date_time) = $self->get('date_time');
    my($curr) = {@{$_CEFL->new($self->req)
	->map_iterate(
	    sub {
		my($copy) = shift->get_shallow_copy;
		return (
		    "$copy->{'CalendarEvent.dtstart'} $copy->{'RealmOwner.display_name'}" => $copy,
		);
	    },
	    {begin_date => $date_time},
	),
    }};
    my($added, $updated, $visited) = ({}, {}, {});
    
    foreach my $event (@{$self->get('events')}) {
	my($key) = $event->{dtstart} . ' '
	    . $_TT->from_literal_or_die($event->{summary});

	if ($visited->{$key}) {
	    b_warn('duplicate event: ', $key);
	    next;
	}
	$visited->{$key} = $event;

	if (my $e = delete($curr->{$key})) {
	    $ce->load_from_properties($e)->update_from_vevent($event);
	    $updated->{$key} = $event;
	}
	else {
	    $ce->create_from_vevent($event);
	    $added->{$key} = $event;
	}
	_link_event_to_venue($self, $ce, $event);
    }
    $self->put(
	add_count => scalar(keys(%$added)),
	delete_count => _delete_events($self, $added, $updated, $curr),
    );
    return;
}

sub is_canceled {
    my($self, $text) = @_;
    return $text =~ /\bcancel(l?)ed\b/i ? 1 : 0;
}

sub _bunit_dir {
    my($self) = @_;
    return $_C->is_test && $self->ureq('scraper_bunit');
}

sub _delete_events {
    my($self, $added, $updated, $deleted) = @_;
    # use unique event names to determine deletion percentage,
    # avoids problems with deleted reccurring events
    my($deleted_count) =
	_unique_count($self, $deleted, 'RealmOwner.display_name')
	    - _unique_count($self, $added, 'summary');
    my($total) = _unique_count($self, $updated, 'summary') + $deleted_count;
    my($to_delete) = $deleted_count / ($total || 1);
    my($ce) = $_CE->new($self->req);

    if ($deleted_count <= 3 || $to_delete <= .10) {
	foreach my $v (values(%$deleted)) {
	    $ce->load_from_properties($v)->cascade_delete;
	}
	return scalar(keys(%$deleted));
    }
    b_warn($to_delete,
        ': attempting to delete more than 10% events, not deleting');
    return 0;
}

sub _filter_event {
    my($self, $type, $event, $aux) = @_;
    my($rule) = $aux->{$type . '_event'};

    unless ($rule) {
	return $type eq 'accept' ? 1 : 0;
    }

    foreach my $f (keys(%$rule)) {
	return 1 if ($event->{$f} || '') =~ $rule->{$f};
    }
    return 0;
}

sub _filter_events {
    my($self) = @_;
    my($date_time) = $self->get('date_time');
    my($aux) = $self->get_scraper_aux;
    my($events) = [];

    foreach my $event (@{$self->get('events')}) {
	next if $self->is_canceled($event->{summary});
	$event->{dtend} ||= $event->{dtstart};
	$event->{time_zone} ||= $self->get('time_zone');
	next unless $_DT->is_greater_than($event->{dtend}, $date_time);
	next unless _filter_event($self, 'accept', $event, $aux);
	next if _filter_event($self, 'reject', $event, $aux);
	$event->{venue} = _venue_name_for_event($self, $event);
	next unless $event->{venue};
	push(@$events, $event);
    }
    $self->put(events => $events);
    return;
}

sub _link_event_to_venue {
    my($self, $ce, $event) = @_;
    $_VE->new($self->req)->unauth_create_or_update({
	calendar_event_id => $ce->get('calendar_event_id'),
	venue_id => _venue_id_from_name($self, $event->{venue}),
    });
    return;
}

sub _log {
    my($self, $content, $suffix) = @_;
    my($file) = $_L->file_name(
	$_FP->join(
	    $self->simple_package_name,
	    $self->get('log_stamp'),
	    $self->get('scraper_list')->get('Scraper.scraper_id'),
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

sub _unique_count {
    my($self, $values, $field) = @_;
    return scalar(keys(%{
	{map(($_->{$field} => 1), values(%$values))},
    }));
}

sub _venue_id_from_name {
    my($self, $name) = @_;
    $name = $_V->add_realm_prefix($name);
    my($names) = $self->get_if_defined_else_put('venue_ids', {});
    return $names->{$name}
	||= $_RO->new($self->req)->unauth_load_or_die({
	    name => $name,
	    realm_type => $_RT->VENUE,
	})->get('realm_id');
}

sub _venue_name_for_event {
    my($self, $event) = @_;
    my($aux) = $self->get_scraper_aux;
    my($venue_name);

    if ($aux->{location_to_venue} && $event->{location}) {

	foreach my $regexp (keys(%{$aux->{location_to_venue}})) {
	    next unless ($event->{location} || '') =~ $regexp;
	    $venue_name = $aux->{location_to_venue}->{$regexp};
	    last;
	}
    }
    return $venue_name
	|| $_V->strip_realm_prefix(
	    $self->get('scraper_list')->get('default_venue.RealmOwner.name'));
}

1;
