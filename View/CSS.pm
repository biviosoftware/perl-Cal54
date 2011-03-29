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
  CSS('c4_form');
  width: 100%;
  padding-bottom: 2.5ex;
}
table.c4_grid {
  background-color: #0088ce;
  height: 10ex;
  CSS('c4_grid');
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
a.c4_logo_text {
  display: block;
  vertical-align: top;
  margin-top: -.5ex;
}
span.c4_logo_name,
span.c4_logo_tag {
  color: #ffffff;
}
span.c4_logo_name {
  Font('c4_logo_name');
}
td.c4_left span.c4_logo_name {
  display: block;
  margin-bottom: .2ex;
  margin-right: -.2ex;
}
span.c4_logo_tag {
  Font('c4_logo_tag');
}
td.c4_left span.c4_logo_tag {
  margin-top: -1.5ex;
  display: block;
  text-align: right;
}
table.c4_grid td.c4_right {
  padding-right: 1.5em;
  padding-top: 20px;
} 
div.c4_query {
  padding: 0;
  Color('c4_query-background');
}
.c4_query .c4_what {
  Font('c4_query_what');
  CSS('c4_query_what');
  vertical-align: top;
  height: 26px;
  padding: 2px 0;
  margin: 0;
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
.c4_pager .c4_week_spacer {
  padding-left: .7em;
}
.c4_pager .c4_month_spacer,
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
  CSS('c4_list');
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
}
body.c4_home div.c4_bottom_pager {
  CSS('c4_home_bottom_pager');
  padding: 0;
}
div.c4_mobile_toggler,
div.c4_empty_list,
div.c4_bottom_pager .c4_pager,
div.c4_copy {
  text-align: center;
}
span.c4_site_name {
  Font('c4_site_name');
}
div.c4_copy {
  Font('c4_copy');
}
div.c4_copy {
  margin-top: 2ex;
  margin-bottom: 4ex;
}
body.c4_mobile a.c4_logo_text {
  margin-top: 0;
  margin-bottom: .5ex;
}
div.c4_mobile_header a.c4_logo_text,
div.c4_mobile_header div.c4_query {
  margin-left: .5em;
}
div.c4_mobile_header {
  padding: 0;
  width: 100%;
  padding-top: .5ex;
!  padding-left: .5em;
}
div.c4_mobile_header span.c4_logo_tag {
  margin-left: .5em;
}
body.c4_mobile div.c4_list {
  text-align: left;
  padding: 0;
  padding-left: .5em;
  padding-right: .5em;
}
div.b_mobile_toggler {
   text-align: center;
   margin-top: 2ex;
}
body.c4_mobile .c4_query input.submit {
  vertical-align: middle;
  background: none;
  border: none;
  Font('c4_query_submit');
  Color('c4_query_submit-background');
  padding: 0;
  margin: 0;
  margin-left: 2ex;
  height: 5ex;
  width: 5em;
  font-size: 80%;
}
body.c4_mobile .c4_pager a.c4_prev {
  padding-left: 0;
}
body.c4_mobile .c4_pager .c4_prev {
  padding-right: .5em;
}
body.c4_mobile .c4_pager .c4_week_spacer,
body.c4_mobile .c4_pager .c4_month_spacer,
body.c4_mobile .c4_pager .c4_next {
  padding-left: .5em;
}
body.c4_mobile div.c4_bottom_pager .c4_pager,
div.c4_mobile_header {
  Color('c4_query-background');
  width: 100%;
}
body.c4_mobile .c4_list .item span.time {
  display: block;
}
EOF
}

1;
