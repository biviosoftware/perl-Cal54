# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::XHTMLWidget::C4HomePager;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');

sub NEW_ARGS {
    return ['is_bottom'];
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('is_bottom');
    $self->initialize_attr(class => 'c4_pager');
    $self->initialize_attr(tag => 'span');
    return shift->SUPER::initialize(@_);
}

sub render_tag_value {
    my($self, $source, $buffer) = @_;
    my($is_bottom) = $self->render_simple_attr(is_bottom => $source);
    my($now) = $_D->local_today;
    my($when) = $source->req('Model.HomeList')->c4_first_date;
    my($start) = $_D->set_beginning_of_week($when);
    my($weeks) = 3 + $is_bottom * 2;
    my($prev) = $_D->add_days($start, -3 * 7);
    $prev = $now
	if $_D->is_less_than($prev, $now);
    my($first) = 1;
    Link(
	'<<',
	_when_uri($prev),
	'c4_prev',
    )->initialize_and_render($source, $buffer)
	if $_D->is_greater_than_or_equals($start, $now);
    foreach my $week (0 .. ($weeks - 1)) {
	SPAN_c4_week_spacer('')->initialize_and_render($source, $buffer)
	    unless $first;
	foreach my $dow (0 .. 6) {
	    my($d) = $_D->add_days($start, $week * 7 + $dow);
	    my($selected) = $_D->is_equal($d, $when) ? ' selected' : '';
	    my($day) = $_D->get_parts($d, 'day');
	    my($wday) = $_D->english_day_of_week($d);
	    my($weekend) = $_D->english_day_of_week($d) =~ /^s/i
		? ' c4_weekend' : ''; 
	    if ($first || $day == 1) {
		SPAN_c4_month_spacer('')->initialize_and_render($source, $buffer)
		    unless $first;
		SPAN_c4_month(
		    $_D->english_month3($_D->get_parts($d, 'month')),
		)->initialize_and_render($source, $buffer);
		$first = 0;
	    }
	    Link(
		$day,
		_when_uri($d),
		{
		    class => "c4_day$selected$weekend",
		    TITLE => $_D->english_day_of_week($d),
		},
	    )->initialize_and_render($source, $buffer)
		if $_D->is_greater_than_or_equals($d, $now);
	}
    }
    Link(
	'>>',
	_when_uri($_D->add_days($start, 7 * $weeks)),
	'c4_next',
    )->initialize_and_render($source, $buffer);
    return;
}

sub _when_uri {
    my($date) = @_;
    $date = $_D->to_string($date);
    return URI({
	query => {
	    when => $date,
	    what => Join([
		[
		    sub {
			my(undef, $what) = @_;
			$what = ''
			    unless defined($what);
			$what =~ s{(\d+/\d+(?:/\d+)?)\s+}{};
			return $what;
		    },
		    [qw(->ureq query what)],
		],
	    ]),
	},
    });
}

1;
