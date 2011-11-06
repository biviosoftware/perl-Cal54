# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Action::UserTracking;
use strict;
use Bivio::Base 'Action.EmptyReply';
b_use('IO.Trace');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_ENTRY_URI) = 'c4e';
my($_REF_URI) = 'c4r';
my($_UCF) = b_use('Model.UserCreateForm');
my($_R) = b_use('Biz.Random');
my($_UA) = b_use('Type.UserAgent');
my($_ULF) = b_use('Model.UserLoginForm');
# TaskLog must register as a handler first
my($_TL) = b_use('Model.TaskLog');
b_use('Agent.Task')->register(__PACKAGE__);

sub handle_pre_execute_task {
    my($proto, undef, $req) = @_;
    return
	if !(my $cookie = $req->ureq('cookie'));
    return
	if $cookie->unsafe_get($_ULF->USER_FIELD)
	|| !$_UA->is_actual_browser($req);
    my($self) = $proto->new($req);
    if ($cookie->unsafe_get($_ENTRY_URI)) {
	_trace('clearing cookie, creating user') if $_TRACE;
	_create_user($self, $cookie);
	return;
    }
    return
	unless my $r = $self->ureq('r');
    _trace('adding cookie: ', $r->header_in('Referer'), ' ', $r->unparsed_uri)
	if $_TRACE;
    $cookie->put(
	$_REF_URI => $r->header_in('Referer') || '',
	$_ENTRY_URI => $r->unparsed_uri,
    );
    return;
}

sub _create_user {
    my($self, $cookie) = @_;
    my($req) = $self->req;
    $_UCF->execute($req, {
	'RealmOwner.display_name' => 'x',
	'RealmOwner.password' => $_R->string(8),
	without_login => 1,
    });
    my($user) = $req->get('Model.User');
    $user->update({
	last_name => 'u' . $user->get('user_id'),
    });
    $req->set_realm($user->get('user_id'));
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
    $_ULF->handle_cookie_in($cookie, $req);
    $_TL->set_user_id($req, $user->get('user_id'));
    return;
}

1;
