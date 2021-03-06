# Copyright (c) 2010 CAL54, Inc.  All rights reserved.
# $Id$
package Cal54::BConf;
use strict;
use base 'Bivio::BConf';


sub IS_2014STYLE {
    return 1;
}

sub merge_overrides {
    my($proto, $host) = @_;
    return Bivio::IO::Config->merge_list({
	$proto->merge_class_loader({
	    delegates => [
		'Bivio::Agent::TaskId',
		'Bivio::Auth::RealmType',
                'Bivio::Type::Location',
		'Bivio::Type::RowTagKey',
	    ],
	    maps => {
		Action => ['Cal54::Action'],
		Bivio => ['Cal54'],
		Delegate => ['Cal54::Delegate'],
		Facade => ['Cal54::Facade'],
		Model => ['Cal54::Model'],
		Scraper => ['Cal54::Scraper'],
		SearchParser => ['Cal54::SearchParser'],
		ShellUtil => ['Cal54::Util'],
		TestLanguage => ['Cal54::Test'],
		Type => ['Cal54::Type'],
		View => ['Cal54::View'],
		XHTMLWidget => ['Cal54::XHTMLWidget'],
	    },
	}),
	'Bivio::Type::TimeZone' => {
	    default => 'AMERICA_DENVER',
	},
	'Bivio::UI::Facade' => {
	    default => 'Cal54',
	    http_host => 'www.cal54.com',
	    mail_host => 'cal54.com',
	},
	'Bivio::UI::View::ThreePartPage' => {
	    center_replaces_middle => 1,
	},
	$proto->merge_http_log({
	    ignore_list => [
                'NOT_FOUND.* referer=<undef>',
	    ],
	    error_list => [
	    ],
	    critical_list => [
	    ],
	}),
    },
    $proto->default_merge_overrides({
	version => $proto->CURRENT_VERSION,
	root => 'Cal54',
	prefix => 'c4',
	owner => 'CAL54, Inc.',
    }));
}

1;
