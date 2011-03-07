# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::ScraperList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_scraper_class {
    my($self) = @_;
    return b_use('Scraper.' . $self->get('Scraper.scraper_type')->as_class);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [
	    [qw(Scraper.scraper_id Website.realm_id)],
	],
	other => [qw(
	    Scraper.scraper_aux
	    Scraper.default_venue_id
	)],
	order_by => [qw(
	    RealmOwner.display_name
	    RealmOwner.name
	    Website.url
	    Scraper.scraper_type
	)],
    });
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->from(
	$stmt->LEFT_JOIN_ON(qw(Scraper RealmOwner), [
	    [qw(Scraper.default_venue_id RealmOwner.realm_id)],
	]),
    );
    return;
}

1;
