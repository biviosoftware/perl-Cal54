# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::SuggestSiteForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub execute_ok {
    my($self) = @_;
    b_use('UI.View')->execute('Venue->suggest_venue_mail', $self->req);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [
	    {
		name => 'suggestion',
		type => 'Text',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'email',
		type => 'Email.email',
		constraint => 'NONE',
	    },
	],
    });
}

1;
