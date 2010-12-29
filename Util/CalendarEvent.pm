# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Util::CalendarEvent;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_MC) = b_use('MIME.Calendar');
my($_D) = b_use('Type.Date');
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
    $self->model('CalendarEvent')->do_iterate(sub {
        shift->cascade_delete;
	return 1;
    });
    my($start) = $_D->add_days($_D->local_today, -2);
    my($end) = $_D->add_months($start, 3);

    foreach my $vevent (@{$_MC->from_ics($self->read_input)}) {
	foreach my $v (@{_explode_event($self, $vevent, $start, $end)}) {
#TODO: skip old events
	    $self->model('CalendarEvent')->create_from_vevent($v);
	}
    }
    return;
}

sub _explode_event {
    my($self, $vevent, $start, $end) = @_;
    return [$vevent] unless $vevent->{rrule};
    return [
	map(+{
	    %$vevent,
	    %$_,
	}, @{$_RR->process_rrule($vevent, $start, $end)}),
    ];
}

1;
