# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Delegate::RowTagKey;
use strict;
use Bivio::Base 'Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    my($proto) = @_;
    return [
	@{$proto->SUPER::get_delegate_info},
	HIDDEN_CALENDAR_EVENT => [100, 'Boolean'],
	USER_ENTRY_URI => [101, 'Text64K'],
	USER_REFERER_URI => [102, 'Text64K'],
    ];
}

1;
