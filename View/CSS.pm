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
body.c4_home_mobile {
  Font('c4_home');
  margin: 2ex 1em;
  min-width: 0;
}
form.c4_query {
  If(
    ['!', 'Type.UserAgent', '->is_msie_6_or_before'],
    q{position: fixed;},
  );
}
form.mobile {
  display: block;
  position: relative;
}
div.c4_empty_list {
  height: 12em;
  vertical-align: top;
  padding-top: 5em;
  text-align: center;
}
div.c4_list {
  padding-left: 12em;
  If(
    ['Type.UserAgent', '->is_msie_6_or_before'],
    q{position: absolute; top: 2ex; left: 1em;},
  );
}
div.mobile {
  padding-left: 0;
}
div.mobile_head {
  text-align: center;
  vertical-align: top;
}
div.mobile_head .item {
  margin-top: 1ex;
  margin-bottom: 0;
}
div.mobile_head input {
  width: 100%;
}
#c4_inputs {
  If(
    [qw(->req query)],
    q{display: none;},
    q{display: block;},
  );
}
div.arrow {
  color: #FF3333;
  font-size: 250%;
}
div.logo_group {
  display: inline;
  If(
    [qw(->req query)],
    q{cursor: pointer;}
  );
}
.toggle {
  If(
    [qw(->req query)],
    q{cursor: pointer;}
  );
}
.decrease_font_size {
  float: left;
}
.increase_font_size {
  float: right;
}
.c4_query img.c4_logo {
  margin-bottom: .5ex;
}
.c4_query input {
  width: 10em;
  display: block;
}
.c4_query .item {
  padding-left: 2px;
  margin-bottom: 2ex;
}
.c4_list div.date {
  Font('c4_date');
  margin-bottom: 1ex;
  border-bottom: 1px solid;
}
.c4_list .item {
  margin-bottom: 2ex;
}
.c4_list .item a {
  Font('c4_item_a');
}
.c4_list .item a:hover {
  Font('c4_item_a_hover');
}
.c4_list .item a:visited {
  Font('c4_item_a_visited');
}
.c4_list .item div.line {
  margin-bottom: .2ex;
}
.c4_list .item span.time {
  Font('c4_time');
  margin-right: .2em;
}
.c4_list .item .venue {
  margin-right: .5em;
}
.c4_list .item .venue,
.c4_list .item .address {
  Font('c4_venue');
}
.c4_list .item .excerpt {
  Font('c4_excerpt');
}
span.c4_site_name {
  Font('c4_site_name');
}
div.c4_site_tag {
  Font('c4_site_tag');
  margin-top: .2ex;
  margin-bottom: 1ex;
}
span.c4_tm {
  Font('c4_tm');
}
div.c4_copy {
  Font('c4_copy');
}
form.c4_events a.item {
  display: block;
  Font('c4_events_item');
}
form.c4_events input.c4_search_words {
  margin-bottom: .5ex;
  width: 50em;
}
div.c4_scraper {
  width: 50em;
}
EOF
}

1;
