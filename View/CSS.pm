# Copyright (c) 2010-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::CSS;
use strict;
use Bivio::Base 'View';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_site_css {
    return shift->SUPER::internal_site_css(@_) . <<'EOF';
div.c4_scraper {
  width: 50em;
}
body.c4_home {
  Font('c4_home');
  margin: 0;
}
form.c4_form {
  margin: auto;
  background-color: white;
  If(
      ['!', [qw(->req Type.UserAgent)], '->is_msie_6_or_before'],
      'position: fixed;
      top: 0;
      left: 0;
      right: 0;',
  );
  width: 100%;
  padding-bottom: 2.5ex;
}
table.c4_grid {
  background-color: #0088ce;
  width: 50em;
  height: 10ex;
  margin: auto;
}
table.c4_grid td {
  vertical-align: top;
}
td.c4_left {
  padding: 16px 1em 1ex 1.5em;
}
img.c4_logo {
  padding-bottom: 1ex;
}
span.c4_logo_text {
  display: block;
  vertical-align: top;
  margin-top: -.5ex;
}
span.c4_logo_name,
span.c4_logo_tag {
  color: #ffffff;
  font-weight: bold;
}
span.c4_logo_name {
  display: block;
  text-transform: uppercase;
  margin-bottom: .2ex;
  margin-right: -.2ex;
  font-size: 48px;
}
span.c4_logo_tag {
  margin-top: -1.5ex;
  display: block;
  text-align: right;
  font-size: 80%;
  text-transform: uppercase;
}
table.c4_grid td.c4_right {
  padding-right: 1.5em;
  padding-top: 20px;
} 
div.c4_query {
  padding: 0 0 0 .8em;
}
.c4_query .c4_what {
  Font('c4_query_what');
  vertical-align: top;
  width: 25em;
  height: 26px;
  padding: 2px 0;
  margin: 0;
}
.c4_query .c4_when {
  width: 5em;
}
.c4_query input.submit {
  vertical-align: top;
  background-position: center bottom;
  border: solid thin;
  Color('c4_query_submit-border');
  border-left: none;
  Font('c4_query_submit');
  Color('c4_query_submit-background');
  padding: 0;
  margin: 0;
  height: 36px;
  width: 4em;
  vertical-align: top;
}
span.c4_pager a.c4_weekend {
  Font('c4_pager_weekend');
}
span.c4_pager {
  padding-top: .6ex;
  padding-bottom: .5ex;
  display: block;
  width: 100%;
  Font('c4_pager');
}
.c4_pager .c4_month,
.c4_pager .c4_prev,
.c4_pager .c4_next {
  Font('c4_pager_month');
}
.c4_pager .c4_month {
  padding-right: .2em;
}
.c4_pager .c4_prev {
  padding-right: 1em;
}
.c4_pager .c4_spacer,
.c4_pager .c4_next {
  padding-left: 1em;
}
.c4_pager a {
  Font('c4_pager_a');
  padding-left: .3em;
}
.c4_pager a.selected {
  border: solid thin;
  Color('c4_pager_selected-border');
  padding-right: .2em;
  margin-left: .5em;
}
div.c4_list {
  If(
    ['!', [qw(->req Type.UserAgent)], '->is_msie_6_or_before'],
    'padding-top: 13ex;',
  );
  width: 50em;
  margin: auto;
}
.c4_list div.date {
  Font('c4_date');
  margin-bottom: 1ex;
  border-bottom: thin solid;
}
.c4_list .item {
  margin-bottom: 2ex;
}
.c4_list .item a {
  Font('c4_item_a');
}
.c4_list .item a.title {
  Font('c4_item_a_title');
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
div.c4_empty_list {
  height: 12em;
  vertical-align: top;
  padding-top: 5em;
  text-align: center;
}
span.c4_site_name {
  Font('c4_site_name');
}
div.c4_copy {
  Font('c4_copy');
}
div.c4_copy {
  margin-bottom: 4ex;
}
EOF
}

1;
