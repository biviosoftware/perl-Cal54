# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::VenueScraperForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty {
    my($self) = @_;
    $self->load_from_model_properties($self->req('Model.Venue'));
    return;
}

sub execute_ok {
    my($self) = @_;
    $self->update_model_properties($self->req('Model.Venue'));
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'Venue.scraper_type',
	    'Venue.scraper_aux',
	],
    });
}

1;
