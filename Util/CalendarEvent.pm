# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Util::CalendarEvent;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
    $self->model('CalendarEvent')->update_from_ics($self->read_input);
    return;
}

1;
