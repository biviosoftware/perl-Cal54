# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::XHTMLWidget::UserTrackingHandler;
use strict;
use Bivio::Base 'HTMLWidget.JavaScript';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_VAR) = __PACKAGE__->var_name('c4_uth');

sub get_html_field_attributes {
    return qq{ onclick="return $_VAR(this)"};
}

sub render {
    my($self, $source, $buffer) = @_;
    my($url) = $source->req->format_stateless_uri({
	task_id => 'C4_HOME_USER_TRACKING',
	query => {
	    x => '',
	},
    });
#TODO: centralize the xhtmlrequest javascript code    
    return shift->SUPER::render($source, $buffer, __PACKAGE__,
        $self->strip(<<"EOF"));
$_VAR = function(v) {
    var req = (function () {
      try {return new XMLHttpRequest();} catch (e) {}
      try {return new ActiveXObject("Msxml2.XMLHTTP.6.0");} catch (e) {}
      try {return new ActiveXObject("Msxml2.XMLHTTP.3.0");} catch (e) {}
      try {return new ActiveXObject("Msxml2.XMLHTTP");} catch (e) {}
      return;
    })();

    if (req) {
        req.open("GET", "$url" + escape(v.href), false);
        req.send(null);
    }
    return;
}
EOF
}

1;
