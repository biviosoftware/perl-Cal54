# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::SearchList;
use strict;
use Bivio::Base 'Model';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_DTWTZ) = b_use('Type.DateTimeWithTimeZone');
my($_HL) = b_use('Model.HomeList');
my($_SEARCH_TYPE) = b_use('Type.FileName')->simple_package_name;

sub internal_load_rows {
    my($self) = @_;
    $self->get_query->put(count => 100);
    my($rows) = shift->SUPER::internal_load_rows(@_);
    my($earliest_date) = {};
    my($now) = $_DT->now;

    foreach my $row (@$rows) {
	my($unique) = _key($row);
	my($dt) = $earliest_date->{$unique};
	if (! $dt || $_DT->compare(
	    $dt,
	    $row->{modified_date_time}
	) > 0) {
	    next if $_DT->compare(
		$row->{modified_date_time},
		$now,
	    ) < 0;
	    $earliest_date->{$unique} = $row->{modified_date_time};
	}
    }
    my($res) = [];
    foreach my $row (@$rows) {
	my($unique) = _key($row);
	my($dt) = $earliest_date->{$unique};
	next
	    unless $dt && $row->{modified_date_time} eq $dt;
	push(@$res, $row);
    }
    $res = [sort({
	$_DT->compare($a->{modified_date_time}, $b->{modified_date_time})
    } @$res)];
    return @$res > 10
	? [splice(@$res, 0, 10)]
	: $res;
}

sub load_row_with_model {
    my($self, $row, $model) = @_;
    if ($model && $model->isa('Bivio::Biz::Model::CalendarEvent')) {
	$row->{result_uri} = $self->req->format_uri(
	    'C4_HOME_LIST',
	    $model->format_query_for_this,
	);
	$row->{result_type} = $_SEARCH_TYPE;
	$row->{result_title} = $row->{title};
	$row->{result_excerpt} = $row->{excerpt}
	    || $row->{model}->get_venue_realm->get('display_name');
	my($dt_tz) = $_DTWTZ->new(
	    $row->{modified_date_time},
	    $row->{model}->get('time_zone'),
	)->as_date_time;
	$row->{result_time_info} = $_DT->english_month3(
	    $_DT->get_parts($dt_tz, 'month'))
	    . ' ' . $_DT->get_parts($dt_tz, 'day')
	    . ', ' . $_HL->format_date_time($dt_tz);
	return 1;
    }
#TODO: allow results in admin facades
    return 0;
}

sub _key {
    my($row) = @_;
    return join('-', $row->{result_title} || ' ', $row->{excerpt} || ' ');
}

1;
