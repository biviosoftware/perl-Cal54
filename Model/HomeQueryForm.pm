# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::HomeQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_L) = b_use('Type.Line');
my($_EMPTY_WHAT) = ' ';
my($_ULF) = b_use('Model.UserLoginForm');
my($_AC) = b_use('Ext.ApacheConstants');
my($_UA) = b_use('Type.UserAgent');

sub execute_empty {
    my($self) = @_;
    if (my $query = $self->ureq('query')) {
	my($res) = _query(
	    $self,
	    $self->new_other('HomeList')->parse_query_from_request,
        );
	return $res
	    if $res;
    }
    else {
	_no_query($self);
    }
    return shift->SUPER::execute_empty(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	other => [
	    $self->field_decl([
		[qw(is_default_what Boolean)],
		[qw(is_robot Boolean)],
		[qw(is_search_click Boolean)],
	    ]),
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    $self->internal_put_field(
	is_robot => $_UA->is_robot($self->req),
	is_default_what => 0,
	is_search_click => 0,
    );
    return @res;
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
	unless defined($what) && length($what);
    $self->new_other('RowTag')->row_tag_replace(
	$uid,
	'C4_MOST_RECENT_SEARCH',
	$what,
    );
    return;
}

sub _no_query {
    my($self) = @_;
    return
	if $self->get('is_robot');
    return
	if _query_search_click($self);
    my($what);
    if (my $uid = _uid($self)) {
	if (defined(
	    $what = $self->new_other('RowTag')
		->row_tag_get($uid, 'C4_MOST_RECENT_SEARCH')
	)) {
	    $what = ($_L->from_literal($what))[0];
	    $what = ''
		unless defined($what);
	}
    }
    unless (defined($what)) {
	$self->internal_put_field(is_default_what => 1);
	$what = 'music';
    }
    $self->req->put(query => {what => $what});
    return;
}

sub _query {
    my($self, $query) = @_;
    return _query_robot($self, $query)
	if $self->get('is_robot');
    _query_search_click($self);
    return;
}

sub _query_robot {
    my($self, $lq) = @_;
    return
	unless grep(
	    defined($_),
	    $lq->unsafe_get(qw(what when)),
        );
    my($this) = $lq->unsafe_get('this');
    return {
	task_id => 'C4_HOME_LIST',
#TODO: This should be encapsulated, but no routine right now
	query => $this && {'ListQuery.this' => $this->[0]},
	http_status_code => $_AC->HTTP_MOVED_PERMANENTLY,
    };
}

sub _query_search_click {
    my($self, $query) = @_;
    return
	unless my $r = $self->ureq('r');
    return
	unless my $ref = $r->header_in('Referer');
    my($ref) = URI->new($ref);
    return
	unless $ref->can('host')
	&& $ref->host =~ /^(?:www\.(?:google|bing|search-results)|search\.(?:yahoo|aol|mywebsearch|comcast)|int.ask)\.(?:com|net)$/
	&& $ref->can('query');
    my($q) = {$ref->query_form};
    return
	unless my $search = $q->{q} || $q->{p} || $q->{searchfor};
    $search =~ s/\bcal\s*54(?:[\.\s]*com)?\b//;
    $search =~ s/\s+/ /g;
    $search =~ s/^\s+|\s+$//g;
    return
	unless $search;
    $self->req->put(query => {what => $search});
    $self->internal_put_field(is_search_click => 1);
    return;
}

sub _uid {
    my($self) = @_;
    return $self->get('is_robot')
	? undef
	: $_ULF->unsafe_get_cookie_user_id($self->req);
}
	
1;
