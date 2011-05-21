# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Action::UserTracking;
use strict;
use Bivio::Base 'Biz.Action';
b_use('IO.Trace');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_ENTRY_URI) = 'c4e';
my($_REF_URI) = 'c4r';
my($_ULF) = b_use('Model.UserLoginForm');
b_use('Agent.Task')->register(__PACKAGE__);

sub execute {
    my($proto, $req) = @_;
    $req->get('reply')->set_output(\('ok'));
    return 1;
}

sub handle_pre_execute_task {
    my($proto, undef, $req) = @_;
    my($cookie) = $req->ureq('cookie');
    return unless $cookie;
    return if $cookie->unsafe_get($_ULF->USER_FIELD);
    return
	unless $req->unsafe_get('Type.UserAgent')
	    && $req->get('Type.UserAgent')->is_browser;
    my($self) = $proto->new($req);

    if ($cookie->unsafe_get($_ENTRY_URI)) {
	_trace('clearing cookie, creating user') if $_TRACE;
	_create_user($self, $cookie);
    }
    else {
	my($r) = $self->ureq('r');
	return unless $r;
	_trace('adding cookie: ', $r->header_in('Referer'), ' ', $r->uri)
	    if $_TRACE;
	$cookie->put($_REF_URI => $r->header_in('Referer') || '');
	$cookie->put($_ENTRY_URI => $r->uri);
    }
    return;
}

sub _create_user {
    my($self, $cookie) = @_;
    b_use('Model.UserCreateForm')->execute($self->req, {
	'RealmOwner.display_name' => 'x',
	'RealmOwner.password' => b_use('Biz.Random')->string(8),
	without_login => 1,
    });
    my($user) = $self->req('Model.User');
    $user->update({
	last_name => 'u' . $user->get('user_id'),
    });
    $self->req->set_realm($user->get('user_id'));

    foreach my $info (
	[C4_USER_ENTRY_URI => $_ENTRY_URI],
	[C4_USER_REFERER_URI => $_REF_URI],
    ) {
	my($key, $field) = @$info;
	$user->new_other('RowTag')
	    ->create_value($key => $cookie->unsafe_get($field));
	$cookie->delete($field);
    }
    $cookie->put($_ULF->USER_FIELD => $user->get('user_id'));
    $_ULF->handle_cookie_in($cookie, $self->req);
    b_use('Model.TaskLog')->set_user_id($self->req, $user->get('user_id'));
    return;
}

1;
