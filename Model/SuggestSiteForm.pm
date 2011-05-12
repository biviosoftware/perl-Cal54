# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::SuggestSiteForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
		name => 'Website.url',
		type => 'String',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

1;
