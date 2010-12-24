# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::CSS;
use strict;
use Bivio::Base 'View';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_site_css {
    return shift->SUPER::internal_site_css(@_) . <<'EOF';
form.c4_query {
  position: fixed;
  margin-top: 1ex;
}
td.footer_center,
div.main_body {
  width: 40em;
}
td.footer_left,
td.main_left {
  width: 12em;
}
form.c4_query input {
  width: 10em;
  display: block;
}
form.c4_query div.item {
  margin-bottom: 2ex;
!  width: 5em;
}
.c4_main_list .item {
  margin-bottom: 1ex;
  margin-top: 0;
}
.c4_main_list .item a {
  text-decoration: underline;
}
div.item div.excerpt {
  margin-top: .5ex;
  font-size: 90%;
}
span.cal54 {
  font-size: 80%;
}
.c4_main_list div.date {
  font-weight: bold;
}
EOF
}

1;
