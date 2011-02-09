# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::AdmCalendarEventListForm;
use strict;
use Bivio::Base 'Biz.ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_VL) = b_use('Model.VenueList');

sub execute_empty_row {
    my($self) = @_;
    $self->load_from_list_model_properties;
    return;
}

sub execute_ok_row {
    my($self) = @_;
#TODO: use update_model_properties
    $self->get_list_model->get_model('SearchWords')
	->update({value => $self->get('SearchWords.value')});
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	list_class => 'AdmCalendarEventList',
        visible => [
	    {
		name => 'SearchWords.value',
		in_list => 1,
	    },
	],
	other => [
	    {
		name => 'SearchWords.realm_id',
		in_list => 1,
	    },
	],
    });
}

sub internal_initialize_list {
    my($self) = @_;
    my($lm) = $self->new_other($self->get_list_class);
    return $lm->load_page($lm->parse_query_from_request);
}

1;
