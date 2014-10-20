# Copyright (c) 2011 CAL54, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::ScraperList;
use strict;
use Bivio::Base 'Biz.ListModel';


sub get_scraper_class {
    my($self) = @_;
    return b_use('Scraper.' . $self->get('Scraper.scraper_type')->as_class);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [
	    [qw(Scraper.scraper_id Website.realm_id
		scraper.RealmOwner.realm_id)],
	],
	other => [qw(
	    Scraper.scraper_aux
	    Scraper.default_venue_id
	    scraper.RealmOwner.name
	)],
	order_by => [
	    qw(
	        default_venue.RealmOwner.display_name
		default_venue.RealmOwner.name
		Website.url
		Scraper.scraper_type
	    ),
	    {
		name => 'event_count',
		type => 'Integer',
		in_select => 1,
		select_value => '(
                    SELECT COUNT(*)
                    FROM calendar_event_t ce
                    WHERE ce.realm_id = scraper_t.scraper_id
                    AND ce.dtstart > current_timestamp
                ) AS event_count',
	    },
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);

    unless ($row->{'scraper.RealmOwner.name'} =~ /\_/) {
	$row->{'scraper.RealmOwner.name'} = undef;
    }
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->from(
	$stmt->LEFT_JOIN_ON(qw(Scraper default_venue.RealmOwner), [
	    [qw(Scraper.default_venue_id default_venue.RealmOwner.realm_id)],
	]),
    );
    return;
}

sub test_replace_scraper_aux {
    my($self, $aux, $url) = @_;
    $self->internal_get->{'Scraper.scraper_aux'} = $aux;
    $self->internal_get->{'Website.url'} = $url
	if $url;
    return;
}

1;
