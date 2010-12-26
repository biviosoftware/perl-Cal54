# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::CSS;
use strict;
use Bivio::Base 'View';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_site_css {
    return shift->SUPER::internal_site_css(@_) . <<'EOF';
body.c4_home {
  Font('c4_home');
  margin: 2ex 1em;
}
form.c4_query {
  If(
    ['!', 'Type.UserAgent', '->is_msie_6_or_before'],
    q{position: fixed;},
  );
}
div.c4_list {
  padding-left: 12em;
  width: 40em;
  If(
    ['Type.UserAgent', '->is_msie_6_or_before'],
    q{position: absolute; top: 2ex; left: 1em;},
  );
}
.c4_query img.c4_logo {
  margin-bottom: .5ex;
}
.c4_query input {
  width: 10em;
  display: block;
}
.c4_query div.item {
  padding-left: 2px;
  margin-bottom: 2ex;
}
.c4_list .item {
  margin-bottom: 2ex;
}
.c4_list .item a {
  Font('c4_item_a');
}
.c4_list .item div.line {
  margin-bottom: .2ex;
}
.c4_list .item a:hover {
  Font('c4_item_a_hover');
}
.c4_list .item a:visited {
  Font('c4_item_a_visited');
}
.c4_list .item .excerpt {
  Font('c4_excerpt');
}
.c4_list div.date {
  Font('c4_date');
  margin-bottom: .7ex;
  color: #FF3333;
}
span.c4_site_name {
  Font('c4_site_name');
}
div.c4_copy {
  Font('c4_copy');
}
EOF
}

1;
