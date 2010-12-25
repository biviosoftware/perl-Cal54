# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Util::TestData;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: bivio TestData [options] command [args..]
commands
  init -- initializes test data
EOF
}

sub init {
    my($self) = @_;
    $self->new_other('TestUser')->init;
    return;
}

1;
