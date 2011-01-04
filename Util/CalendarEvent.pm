# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Util::CalendarEvent;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_MC) = b_use('MIME.Calendar');
my($_RR) = b_use('Biz.RRule');

sub USAGE {
    return <<'EOF';
usage: bivio CalendarEvent [options] command [args..]
commands
  import_ics -- reads ICS from input and imports into auth_realm
EOF
}

sub import_ics {
    my($self) = @_;
    $self->assert_not_general;
    $self->initialize_ui;
    # clear the venue's existing events
#TODO: reuse calendar_event_id    
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
    my($start) = $_D->add_days($_D->local_today, -1);
    my($end) = $_D->add_months($_D->local_today, 3);
    my($recurrences) = {};
    
    foreach my $vevent (reverse(@{$_MC->from_ics($self->read_input)})) {
	next if $_D->is_date($vevent->{dtstart});
	next if ($vevent->{status} || '') eq 'CANCELLED';

	foreach my $v (@{_explode_event($self, $vevent, $end)}) {
	    next if $_D->compare($v->{dtstart}, $start) < 0;

	    if ($v->{'recurrence-id'}) {
		$recurrences->{_recurrence_id($v, 'recurrence-id')} = 1;
	    }
	    elsif ($v->{rrule} && $recurrences->{_recurrence_id($v)}) {
		next;
	    }
	    $self->model('CalendarEvent')->create_from_vevent($v);
	}
    }
    return;
}

sub _explode_event {
    my($self, $vevent, $end) = @_;
    return [$vevent] unless $vevent->{rrule};
    return [
	map(+{
	    %$vevent,
	    %$_,
	}, @{$_RR->process_rrule($vevent, $end)}),
    ];
}

sub _recurrence_id {
    my($vevent, $date_field) = @_;
    return join('-',
        map($vevent->{$_}, qw(uid sequence), $date_field || 'dtstart'));
}

1;
