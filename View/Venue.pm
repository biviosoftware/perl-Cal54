# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::Venue;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub form {
    return shift->internal_body(
	vs_simple_form(VenueForm => [
	    map(
		$_ eq 'Venue.scraper_type'
		    ? ["VenueForm.$_", {
			wf_want_select => 1,
		    }]
		    : "VenueForm.$_",
		b_use('Model.VenueList')->EDITABLE_FIELD_LIST),
	]),
    );
}

sub list {
    return shift->internal_put_base_attr(
	tools => TaskMenu([
	    'ADM_VENUE_FORM',
	]),
	body => vs_paged_list(VenueList => [
	    ['RealmOwner.display_name', {
		wf_list_link => {
		    task => 'ADM_VENUE_FORM',
		    query => 'THIS_DETAIL',
		},
	    }],
	    'Address.street1',
	    ['calendar.Website.url', {
		uri => ['calendar.Website.url'],
	    }],
	]),
    );
}

sub scraper {
    return shift->internal_put_base_attr(
	tools => TaskMenu([
	    Link('Venue Calendar',
		 ['Model.VenueScraperForm', 'calendar.Website.url']),
	    Link('Scraper Calendar', URI({
		task_id => 'ADM_SCRAPER_PREVIEW',
		query => {
		    x => ['Model.VenueScraperForm', 'calendar.Website.url'],
		},
	    })),
	    'ADM_VENUE_LIST',
	]),
	body => Join([
	    vs_simple_form(VenueScraperForm => [
		H1(String([['Model.Venue', '->get_model', 'RealmOwner'],
		    'display_name'])),
		'VenueScraperForm.Venue.scraper_type',
		['VenueScraperForm.Venue.scraper_aux', {
		    cols => 80,
		    rows => 25,
		}],
		'*ok_button test_scraper_button cancel_button',
	    ]),
	    DIV_c4_scraper(If(['Model.VenueScraperForm', '->has_events'],
	       String([sub {
                   my($source) = @_;
		   return ${b_use('IO.Ref')->to_string(
		       $source->req(qw(Model.VenueScraperForm events)))};
	       }])->put(hard_newlines => 1),
	    )),
	    String(['Model.VenueScraperForm', 'error']),
	]),
    );
}

sub scraper_preview {
    return shift->internal_body(
	Simple([sub {
	    my($source) = @_;
	    my($values) = [];
	    my($cleaner) = $source->req(qw(Action.ScraperPreview cleaner));

	    foreach my $line (split("\n",
	        $source->req(qw(Action.ScraperPreview text)))) {
		my($uri) = $cleaner->unsafe_get_link_for_text($line);
		push(@$values,
		     defined($uri)
			 ? Link($line, URI({
			     query => {
				 x => $uri,
			     },
			 }))
			 : String($line),
		     BR());
	    }
	    return Join($values);
        }]),
    );
}

1;
