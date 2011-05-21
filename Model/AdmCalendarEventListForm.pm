# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::AdmCalendarEventListForm;
use strict;
use Bivio::Base 'Biz.ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_VL) = b_use('Model.VenueList');
my($_SW) = __PACKAGE__->get_instance('SearchWords')->get_field_type('value');

sub execute_empty_row {
    my($self) = @_;
    $self->load_from_list_model_properties;
    return;
}

sub execute_ok_row {
    my($self) = @_;
    my($lm) = $self->get_list_model;
    my($v) = $self->get('SearchWords.value');
    return
	if $_SW->is_equal($lm->get('SearchWords.value'), $v);
    $lm->get_model('SearchWords')
	->update({value => $v});
    # Force a search db update
    $lm->get_model('CalendarEvent')->update({});
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
