# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::HomeQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_L) = b_use('Type.Line');
my($_EMPTY_WHAT) = ' ';
my($_ULF) = b_use('Model.UserLoginForm');

sub execute_empty {
    my($self) = @_;
    unless ($self->ureq('query')) {
	my($what);
	if (my $uid = _uid($self)) {
	    $what = $_L->from_literal_or_die($what)
		if defined(
		    $what = $self->new_other('RowTag')
			->row_tag_get($uid, 'C4_MOST_RECENT_SEARCH')
		);
	}
	unless (defined($what)) {
	    $self->internal_put_field(is_default_what => 1);
	    $what = 'music';
	}
	$self->req->put(query => {what => $what});
    }
    return shift->SUPER::execute_empty(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	other => [
	    $self->field_decl([[qw(is_default_what Boolean)]]),
	],
    });
}

sub internal_query_fields {
    return [
	[qw(what Line)],
	[qw(when Line)],
    ];
}

sub row_tag_replace_what {
    my($self) = @_;
    return
	unless my $uid = _uid($self);
    return
	if $self->unsafe_get('is_default_what');
    my($what) = $self->unsafe_get('what');
    $what = $_EMPTY_WHAT
	unless defined($what);
    $self->new_other('RowTag')->row_tag_replace(
	$uid,
	'C4_MOST_RECENT_SEARCH',
	$what,
    );
    return;
}

sub _uid {
    return $_ULF->unsafe_get_cookie_user_id(shift->req);
}

1;
