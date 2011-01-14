# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Type::Scraper;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile([
    UNKNOWN => 0,
    GOOGLE => 1,
    NISSIS => 2,
    ACTIVE_DATA => 3,
    EVANCED => 4,
]);

sub as_class {
    my($self) = @_;
    my($res) = shift->get_short_desc;
    $res =~ s/\s//g;
    return $res;
}

1;
