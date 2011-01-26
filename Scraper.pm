# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
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
my($_HTML) = b_use('Bivio.HTML');
my($_L) = b_use('IO.Log');
my($_R) = b_use('IO.Ref');
my($_T) = b_use('Agent.Task');
#TODO: Make a RowTag
my($_TZ) = b_use('Type.TimeZone')->get_default;
my($_TT) = b_use('Type.Text');

sub c4_scraper_get {
    my($self, $uri) = @_;
    my($log) = _log($self);
    return $self->extract_content($self->http_get($uri, $log))
	unless my $d = _bunit_dir($self);
    $self->put(last_uri => $self->abs_uri($uri));
    return $self->read_file($_FP->join($d, $_FP->get_tail($log)));
}

sub do_all {
    my($proto, $venue_list) = @_;
    my($date_time) = $_DT->now;
    $venue_list->do_rows(
	sub {
	    my($it) = @_;
	    $_A->reset_warn_counter;
	    b_info($it->get('RealmOwner.display_name'));
	    $proto->do_one($it, $date_time);
	    return 1;
	},
    );
    return;
}

sub do_one {
    my($proto, $venue_list, $date_time) = @_;
    my($self) = b_use('Scraper.' . $venue_list->get('Venue.scraper_type')->as_class)
	->new({
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
		    b_die('no events')
			unless @{$self->get('events')};
		    _log($self, $_R->to_string($self->get('events')), '.pl');
		    $self->internal_update;
		    return;
		},
	    );
	},
    );
    return $venue_list->get_model('RealmOwner')->as_string
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

sub internal_clean {
    my($self, $value) = @_;
    $value = $_HTML->unescape($value);
    $value =~ s{<.*?>}{ }g;
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
    my($refresh) = {};
    my($e);
    foreach my $event (@{$self->get('events')}) {
	unless ($_DT->is_greater_than($event->{dtend}, $date_time)) {
	    next;
	}
	my($key) = "$event->{dtstart} " . $_TT->from_literal_or_die($event->{summary});
	if ($e = $refresh->{$key}) {
	    b_warn($event, ': duplicate event: ', $e);
	    next;
	}
	$refresh->{$key} = $event;
	unless ($e = delete($curr->{$key})) {
	    $ce->create_from_vevent($event);
	    next;
	}
	$ce->load_from_properties($e)
	    ->update_from_vevent($event);
    }
    my($curr_count) = scalar(keys(%$curr));
    my($new_count) = scalar(@{$self->get('events')});
    my($to_delete) = $curr_count / ($new_count + $curr_count || 1);
    if ($curr_count <= 3 || $to_delete <= .05) {
	foreach my $v (values(%$curr)) {
#TODO: Check recurring events.  If they had already occured in the past, simply update
#      the dtend to be before $date_time.
	    $ce->load_from_properties($v)
		->cascade_delete;
	}
    }
    else {
	b_warn($curr_count, ': attempting to delete more than 5% events, not deleting');
    }
    $_T->commit($self->req)
	unless _bunit_dir($self);
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

1;
