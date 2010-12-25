# Copyright (c) 2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Cal54::BConf;
use strict;
use base 'Bivio::BConf';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub dev_overrides {
    my($proto, $pwd, $host, $user, $http_port) = @_;
    return {
    };
}

sub merge_overrides {
    my($proto, $host) = @_;
    return Bivio::IO::Config->merge_list({
	$proto->merge_class_loader({
	    delegates => {
		'Bivio::Agent::HTTP::Cookie' => 'Bivio::Delegate::Cookie',
		'Bivio::Agent::TaskId' => 'Cal54::Delegate::TaskId',
		'Bivio::Auth::Support' => 'Bivio::Delegate::SimpleAuthSupport',
		'Bivio::TypeError' => 'Cal54::Delegate::TypeError',
	    },
	    maps => {
#		Action => ['Cal54::Action'],
		Delegate => ['Cal54::Delegate'],
		Facade => ['Cal54::Facade'],
		Model => ['Cal54::Model'],
		ShellUtil => ['Cal54::Util'],
		TestLanguage => ['Cal54::Test'],
		Type => ['Cal54::Type'],
		View => ['Cal54::View'],
	    },
	}),
	'Bivio::UI::Facade' => {
	    default => 'Cal54',
	    http_suffix => 'www.cal54.com',
	    mail_host => 'cal54.com',
	},
	'Bivio::UI::View::ThreePartPage' => {
	    center_replaces_middle => 1,
	},
	$proto->merge_http_log({
	    ignore_list => [
	    ],
	    error_list => [
	    ],
	    critical_list => [
	    ],
	}),
    },
    $proto->default_merge_overrides({
	version => 10,
	root => 'Cal54',
	prefix => 'c4',
	owner => 'bivio Software, Inc.',
    }));
}

1;
