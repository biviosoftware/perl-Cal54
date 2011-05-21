# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Delegate::RowTagKey;
use strict;
use Bivio::Base 'Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    my($proto) = @_;
    return [
	@{$proto->SUPER::get_delegate_info},
	C4_HIDDEN_CALENDAR_EVENT => [100, 'Boolean'],
	C4_USER_ENTRY_URI => [101, 'Text64K'],
	C4_USER_REFERER_URI => [102, 'Text64K'],
	C4_MOST_RECENT_SEARCH => [103, 'Line'],
    ];
}

1;
