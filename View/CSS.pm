# Copyright (c) 2010-2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::CSS;
use strict;
use Bivio::Base 'View';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_site_css {
    return shift->SUPER::internal_site_css(@_) . <<'EOF';
a.c4_logo:hover {
  text-decoration: none;
}
div.c4_logo_holder {
  padding-top: 1ex;
  text-align: right;
}
div.c4_logo_subform {
  text-align: center;
  padding-top: 1ex;
  padding-bottom: 1ex;
}
! show logo centered in phone mode
@media (max-width: 767px) {
  div.c4_logo_holder {
    text-align: center;
  }
}
 
! bootstrap overrides
nav .navbar-form {
  box-shadow: none;
}

! bOP overrides
html, body {
!  padding-top: 0;
  CSS('html_body');
}
nav.navbar div.input-group {
  width: auto;
}

span.c4_pager a.c4_weekend {
  Font('c4_pager_weekend');
}
span.c4_pager {
  padding-top: 4px;
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

body .c4_prev_button,
body .c4_next_button {
  text-align: center;
  display: block;
  margin: auto;
  width: 6em;
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
.c4_list .item a:hover {
  Font('c4_item_a_hover');
}
.c4_list .item a:visited {
  Font('c4_item_a_visited');
}
.c4_list .item div.line {
  margin-bottom: .2ex;
}
.c4_list .item span.time, .c4_suggest_time {
  Font('c4_time');
  margin-right: .2em;
}
.c4_list .item .venue {
  margin-right: .5em;
}
.c4_list .item .venue,
.c4_list .item .phone,
.c4_list .item .address {
  Font('c4_venue');
}
.c4_list .item .excerpt {
}
div.c4_empty_list {
  height: 12em;
  vertical-align: top;
  padding-top: 5em;
}
span.c4_site_name {
  Font('c4_site_name');
}
span.c4_site_tag {
  Font('c4_site_tag');
}
span.c4_site_local {
  Font('c4_site_local');
}
div.c4_copy {
  Font('c4_copy');
}
div.c4_copy {
  margin-top: 2ex;
  margin-bottom: 4ex;
}

! admin css
div.c4_scraper {
   width: 50em;
}
tr.c4_event_hidden {
  Color('c4_event_hidden-background');
}

EOF
}

1;
