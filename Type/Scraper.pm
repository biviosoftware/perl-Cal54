# Copyright (c) 2010 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Type::Scraper;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile([
    UNKNOWN => 0,
    GOOGLE => 1,
    ICALENDAR => [2, 'ICalendar'],
    ACTIVE_DATA => 3,
    EVANCED => 4,
    RSS => [5, 'RSS'],
    FULL_CALENDAR => 6,
    BOS_DATES => 7,
    CALENDAR_MANAGER_DATA => 8,
    GIGBOT => 9,
    REG_EXP => 10,
    TICKET_FLY => 11,
]);

sub as_class {
    my($self) = @_;
    my($res) = shift->get_short_desc;
    $res =~ s/\s//g;
    return $res;
}

sub can_preview {
    my($self) = @_;
    return $self->equals_by_name(qw(RSS REG_EXP TICKET_FLY));
}

sub is_continuous {
    return 0;
}

1;
