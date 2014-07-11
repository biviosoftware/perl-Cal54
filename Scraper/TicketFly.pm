# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::TicketFly;
use strict;
use Bivio::Base 'Scraper.RSS';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub clean_description {
    my($self, $item) = @_;
    $item->{title} =~ s/( at .*?) on .*//;
    $item->{location} = $1;
    return shift->SUPER::clean_description(@_);
}

sub internal_parse_item {
    my($self, $item, $current) = @_;
    $current->{location} = $item->{location};
    $self->extract_once_fields($self->eval_scraper_aux('{
        once => [
            [qr/.*?$date $time_ap/s => {
                fields => [qw(date start_time)],
            }],
            [qr/\bfree\b.*?\n+(.*?)\nVenue Information/is => {
                fields => [qw(description)],
            }],
            [qr/buy tickets.*?\n+(.*?)\nVenue Information/is => {
                fields => [qw(description)],
            }],
            [qr/buy tickets.*?\n+?(?:Supporting Acts.*?\n)(.*?)\nVenue Information/is => {
                fields => [qw(description)],
            }],
        ],
    }'), \($item->{description}), $current);

    if ($current->{summary} && $current->{description}) {
	my($summary) = quotemeta($current->{summary});
	$current->{description} =~ s/^\s*$summary\s*//s;
    }
    return shift->SUPER::internal_parse_item(@_);
}

1;
