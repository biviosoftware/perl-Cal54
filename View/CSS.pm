# Copyright (c) 2010-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::CSS;
use strict;
use Bivio::Base 'View';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
b_use('Widget.ABTest')->global_init('x5');

sub internal_site_css {
    return shift->SUPER::internal_site_css(@_) . <<'EOF';
span.b_abtest {
  display: block;
  float: right;
}
span.b_abtest a {
  display: block;
}
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
table.c4_grid div.c4_list {
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
.c4_list div.date {
  Font('c4_date');
  margin-bottom: 1ex;
  border-bottom: 1pt solid;
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
div.c4_sidebar_spacer {
   margin-bottom: 2ex;
}
.c4_cal_input {
   margin-top: .5ex;
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
#c4_cal_popup {
  display: none;
  visibility: hidden;
}
.c4_cal_cpDayColumnHeader,
.c4_cal_cpCurrentMonthDate,
.c4_cal_cpOtherMonthDate,
.c4_cal_cpCurrentDate,
.c4_cal_cpTodayText,
.c4_cal_cpText {
  Font('c4_cal');
}
.c4_cal_cpYearNavigation,
.c4_cal_cpMonthNavigation,
.c4_cal_cpYearNavigation:hover,
.c4_cal_cpMonthNavigation:hover {
  text-align: center;
  vertical-align: middle;
  Font('c4_cal_month');
}
td.c4_cal_cpDayColumnHeader {
  text-align: right;
}
.c4_cal_cpCurrentMonthDate,
.c4_cal_cpOtherMonthDate,
.c4_cal_cpCurrentDate {
  text-align: right;
  text-decoration: none;
  Font('c4_cal_disabled');
}
.c4_cal_cpCurrentMonthDate,
.c4_cal_cpCurrentMonthDate:visited {
  Font('c4_cal_day');
}
.c4_cal_cpCurrentMonthDate:hover,
.c4_cal_cpOtherMonthDate:hover,
.c4_cal_cpCurrentDate:hover,
.c4_cal_cpCurrentMonthDate:hover {
  Font('c4_cal_day_hover');
}
.c4_cal_cpCurrentMonthDateDisabled,
.c4_cal_cpOtherMonthDateDisabled,
.c4_cal_cpCurrentDateDisabled,
.c4_cal_cpCurrentMonthDateDisabled:hover,
.c4_cal_cpOtherMonthDateDisabled:hover,
.c4_cal_cpCurrentDateDisabled:hover {
  Font('c4_cal_disabled');
  text-align: right;
  text-decoration: line-through;
}
.c4_cal_cpCurrentDate,
.c4_cal_cpCurrentDate:visited {
  Font('c4_cal_today');
  text-decoration: underline;
}
.c4_cal_cpCurrentDate:hover {
  Font('c4_cal_today_hover');
}
td.c4_cal_cpCurrentDateDisabled
{
  border-width: 1px;
  border: solid thin;
  Color('c4_cal_disabled-border');
}
td.c4_cal_cpTodayText,
td.c4_cal_cpTodayTextDisabled
{
  border: solid 1pt;
  Color('c4_cal-border');
  border-width: 1px 0 0 0;
}
a.c4_cal_cpTodayText,
span.c4_cal_cpTodayTextDisabled {
  height: 1ex;
}
td.c4_cal_cpTodayText {
  text-align: center;
}
a.c4_cal_cpTodayText {
  Font('c4_cal');
}
SPAN.c4_cal_cpTodayTextDisabled {
  Font('c4_cal_disabled');
}
.c4_cal_cpBorder {
  border: solid thin;
  Color('c4_cal-border');
}
td.c4_cal_cpTodayText {
  display: none;
  visibility: hidden;
}
div.c4_logo_text {
  vertical-align: top;
  margin-top: -.5ex;
}
div.c4_nav,
table.c4_grid td {
  vertical-align: top;
}
span.c4_logo_name {
  display: block;
  font-size: 250%;
  font-family: Times;
  font-weight: bold;
  text-transform: uppercase;
  margin-bottom: 0;
}
span.c4_logo_tag {
  margin-top: -1.5ex;
  display: block;
  text-align: right;
  font-size: 60%;
  font-family: Times;
  font-weight: bold;
  text-transform: uppercase;
}
table.c4_grid .c4_right {
  text-align: right;
}
.c4_query .c4_what {
  width: 25em;
}
table.c4_grid div.c4_list {
  text-align: left;
}
ABTest(
    x1 => q{
	div.c4_list {
	    width: 40em;
	}
    },
    x2 => q{
	table.c4_grid,
	div.c4_list {
	    width: 50em;
	}
	span.c4_logo_name,
	span.c4_logo_tag {
            color: #0088ce;
        }
	div.c4_list .item .venue,
	div.c4_list .item .address,
	div.c4_list .item .venue:hover,
	div.c4_list .item .address:hover,
	div.c4_list .item a.title,
	div.c4_list .item a:hover,
	div.c4_list .item a:visited {
             color: #0377aa;
        }
        div.c4_query input.submit {
            background-position: center bottom;
            border: solid thin #cccccc;
            color: #0;
            font: 26px Times;
            padding: 0;
            height: 36px;
            width: 4em;
            margin: 0;
            vertical-align: top;
            border-style: solid;
            color: #0088ce;
            text-transform: lowercase;
            background-color: #eeeeee;
        }
        div.c4_query .c4_what {
            height: 26px;
            padding: 2px 0;
            padding-right: 10px;
            margin: 0;
            color: #0;
            font: 18px;
            vertical-align: top;
        }
        div.c4_list div.date,
        div.c4_list .item span.time {
            color: #303030;
        }
    },
    q{
	body.c4_home {
	    margin: 0;
	}
        form.c4_form {
            margin: auto;
            width: 50em;
        }
	.c4_query {
	    padding-bottom: 0;
	}
        table.c4_grid {
	     width: 100%;
	     background-color: #0088ce;
	     margin-bottom: 2ex;
	}
	table.c4_grid td.c4_right {
	     padding-right: 1.5em;
	     padding-top: 20px;
	} 
	table.c4_grid td.c4_left {
	     padding-left: 1.5em;
	     padding-top: 16px;
	     padding-bottom: 1ex;
	}
	span.c4_logo_name,
	span.c4_logo_tag {
             font-family: arial;
             color: #ffffff;
        }
        span.c4_logo_name {
             margin-bottom: .2ex;
             font-size: 48px;
             margin-right: -.2ex;
        }
        span.c4_logo_tag {
             font-size: 80%;
        }
	div.c4_pager a,
	div.c4_pager a:hover,
	div.c4_pager a:visited,
	div.c4_list .item .venue,
	div.c4_list .item .address,
	div.c4_list .item .venue:hover,
	div.c4_list .item .address:hover,
	div.c4_list .item a.title,
	div.c4_list .item a:hover,
	div.c4_list .item a:visited {
            color: #2200C1;
        }
        div.c4_query input.submit {
            background-position: center bottom;
            border: solid thin #cccccc;
            color: #0;
            font: 18px arial;
            padding: 0;
            height: 36px;
            width: 4em;
            margin: 0;
            vertical-align: top;
            border-style: solid;
            background-color: #0088ce;
            border-left: none;
            color: #ffffff;
        }
        div.c4_query .c4_what {
            height: 26px;
            padding: 2px 0;
            margin: 0;
            color: #0;
            font: 18px;
            vertical-align: top;
        }
        div.c4_list div.date,
        div.c4_list .item span.time {
            color: #303030;
        }
        div.c4_list .item span.time {
            font-weight: normal;
        }
	.c4_list .item a.title {
	    text-decoration: none;
	}
	.c4_list .item .venue,
	.c4_list .item .address {
	    font-size: 80%;
	}
	div.c4_pager {
	    text-align: center;
	    padding-top: 2ex;
	    margin-bottom: 4ex;
	}
	div.c4_pager a.next {
	    margin-left: 1.5em;
	}
	div.c4_pager span.c4_month {
	    margin-right: .5em;
	    margin-left: 2em;
	}
	div.c4_pager a.c4_day {
	    margin-right: .5em;
	}
	span.c4_site_name {
	    font-family: arial;
	}
	div.c4_copy {
	    margin-bottom: 4ex;
        }
        .c4_pager table.c4_month {
            display: inline;
            margin: 0 3em;
        }
        .c4_pager .c4_month_name {
            text-align: center;
            padding: .5ex 0;
            color: #ffffff;
            background-color: #0088ce;
        }
        .c4_pager td.c4_day {
            width: 1.5em;
            text-align: right;
        }
        .c4_pager td.c4_day_link a,
        .c4_pager td.c4_day_link a:hover {
            color: #2200C1;
            text-decoration: none;
            display: block;
            text-align: right;
            width: 100%;
        }
        .c4_pager td.c4_day_link a:hover {
            background-color: #0088ce;
            color: white;
        }
        .c4_pager td.c4_day_name {
            padding-top: .3ex;
        }
        .c4_pager td.c4_day_disabled {
            color: #888888;
        }
        span.c4_x5_pager {
            padding-top: .6ex;
            padding-left: .8em;
            display: block;
            color: white;
            width: 100%;
            text-align: left;
        }
        .c4_x5_pager .c4_x5_month,
        .c4_x5_pager .c4_x5_prev,
        .c4_x5_pager .c4_x5_next {
            font-size: 80%;
        }
        .c4_x5_pager .c4_x5_month {
            padding-right: .2em;
            text-transform: uppercase;
        }
        .c4_x5_pager .c4_x5_prev {
            padding-right: 1em;
        }
        .c4_x5_pager .c4_x5_spacer,
        .c4_x5_pager .c4_x5_next {
            padding-left: 1em;
        }
        .c4_x5_pager a {
            font-size: 80%;
            padding-left: .3em;
            color: white;
        }
        .c4_x5_pager a.selected {
            border: 1px solid white;
            padding-right: .2em;
            margin-left: .5em;
        }
        div.x5_list {
            padding-top: 13ex;
            width: 50em;
            margin: auto;
        }
        a.c4_x5_weekend {
            color: #CCCCCC;
            font-weight: bold;
        }
    },
);
ABTest(
    x4 => q{
	.c4_list .item a.title {
	    text-decoration: underline;
	}
    },
    x5 => q{
        form.c4_form {
            background-color: white;
            position: fixed;
            top: 0;
            width: 100%;
            padding-bottom: 3ex;
        }
        table.c4_grid {
            width: 50em;
            height: 10ex;
            margin: auto;
        }
	span.b_abtest {
	    padding-top: 13ex;
	    float: right;
	}
    },
);
EOF
}

1;

# Now  Mar [grey]Apr 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 ... 30 May Jun

# Clicking moves to that month with a query (not javascript)

# Keep CAL 54 bar sticky.
