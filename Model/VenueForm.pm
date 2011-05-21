# Copyright (c) 2010 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::VenueForm;
use strict;
use Bivio::Base 'Model.FormModeBaseForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_VL) = b_use('Model.VenueList');
my($_V) = b_use('Model.Venue');

sub LIST_MODEL {
    return 'VenueList';
}

sub PROPERTY_MODEL {
    return 'Venue';
}

sub execute_empty_create {
    shift->internal_put_field('Address.country' => 'US');
    return;
}

sub execute_empty_edit {
    my($self) = @_;
    my($lm) = $self->get('list_model');
    foreach my $field (@{$self->get_visible_field_names}) {
	$self->internal_put_field($field => $lm->get($field))
	    if $lm->has_keys($field);
    }
    $self->internal_put_field(
	'RealmOwner.name' => $_V->strip_realm_prefix($self->get('RealmOwner.name')));
    return;
}

sub execute_ok_create {
    my($self) = @_;
    $self->internal_put_field(
	'Venue.venue_id',
        ($self->new_other('Venue')
	    ->create_realm(
		$self->get_model_properties('Venue'),
		$self->get_model_properties('RealmOwner'),
	    )
	)[0]->get('venue_id'),
    );
    return _models(
	sub {
	    my(undef, $model) = @_;
	    return
		if $model =~ /Venue|RealmOwner/;
	    $self->create_model_properties($model);
	    return;
	},
	$self,
    );
}

sub execute_ok_edit {
    my($self) = @_;
    $self->internal_put_field(
	'RealmOwner.name' => $_V->add_realm_prefix($self->get('RealmOwner.name')));
    return _models(
	sub {
	    my($self, $model) = @_;
	    $self->update_model_properties($model);
	    return;
	},
	@_,
    );
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    $self->field_decl(
		[map(
		    ($_ =~ /street2|phone|SearchWords/ ? [$_, undef, 'NONE']
		        : $_ =~ /state/ ? [$_, 'USState']
			: $_ =~ /zip/ ? [$_, 'USZipCode']
			: $_),
		    $_VL->EDITABLE_FIELD_LIST,
		)],
		{constraint => 'NOT_NULL'},
	    ),
	],
	other => [
	    [$_VL->PRIMARY_KEY_EQUIVALENCE_LIST],
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    foreach my $eq ($_VL->LOCATION_EQUIVALENCE_LIST) {
	$self->internal_put_field($eq->[0], $eq->[1]->[0]);
    }
    return shift->SUPER::internal_pre_execute(@_);
}

sub validate {
    my($self) = @_;
    shift->SUPER::validate(@_);
    return
	if $self->in_error;
#TODO: Duplicate checking Venue.display_name_clean probably necessary (for spaces, specials, etc.) 
#    $self->new_other('Lock')->acquire_unless_exists;
    return;
}

sub _models {
    my($op, $self) = @_;
    foreach my $model (sort(keys(%{$self->get_info('models')}))) {
	$op->($self, $model);
    }
    return;
}

1;
