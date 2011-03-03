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
div.c4_empty_list {
  height: 12em;
  vertical-align: top;
  padding-top: 5em;
  text-align: center;
}
table.c4_grid td {
  vertical-align: bottom;
}
table.c4_grid td.c4_list {
  padding-top: 1ex;
  vertical-align: top;
}
td.c4_left {
  padding-right: 1em;
}
.c4_query {
  padding-bottom: 22px;
}
.c4_query span.label {
  Font('c4_query_label');
}
.c4_query input {
  margin-right: 1em;
}
.c4_query .c4_what {
  vertical-align: top;
  width: 20em;
  Font('c4_query_what');
}
.c4_query .c4_when {
  width: 5em;
}
.c4_query input.submit {
  width: 6em;
  vertical-align: top;
  Font('c4_query_submit');
  padding: 0;
  margin: 0;
}
td.c4_right {
  width: 40em;
}
.c4_right div.date {
  Font('c4_date');
  margin-bottom: 1ex;
  border-bottom: 1px solid;
}
.c4_right .item {
  margin-bottom: 2ex;
}
.c4_right .item a {
  Font('c4_item_a');
}
.c4_right .item a.title {
  Font('c4_item_a_title');
}
.c4_right .item a:hover {
  Font('c4_item_a_hover');
}
.c4_right .item a:visited {
  Font('c4_item_a_visited');
}
.c4_right .item div.line {
  margin-bottom: .2ex;
}
.c4_right .item span.time {
  Font('c4_time');
  margin-right: .2em;
}
.c4_right .item .venue {
  margin-right: .5em;
}
.c4_right .item .venue,
.c4_right .item .address {
  Font('c4_venue');
}
.c4_right .item .excerpt {
  Font('c4_excerpt');
}
span.c4_site_name {
  Font('c4_site_name');
}
div.c4_copy {
  Font('c4_copy');
}
div.c4_scraper {
  width: 50em;
}
div.c4_sidebar_title {
  Font('c4_sidebar_title');
  margin-bottom: .3ex;
}
div.c4_sidebar_list {
  margin-bottom: 2ex;
}
div.c4_sidebar_list a {
  display: block;
  Font('c4_sidebar_list');
}
img.c4_logo {
  padding-bottom: 1ex;
}
div.c4_tag {
  Font('c4_right_title');
  font-size: 140%;
}
body.c4_home_mobile {
  Font('c4_home');
  margin: 2ex 1em;
  min-width: 0;
}
form.mobile {
  display: block;
  position: relative;
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
EOF
}

1;
