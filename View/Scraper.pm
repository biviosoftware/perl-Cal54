# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::View::Scraper;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub form {
    return shift->internal_put_base_attr(
	tools => TaskMenu([
	    Link('HTML Calendar',
		 ['Model.ScraperForm', 'Website.url']),
	    Link('Scraper Calendar', URI({
		task_id => 'ADM_SCRAPER_PREVIEW',
		query => {
		    x => ['Model.ScraperForm', 'Website.url'],
		},
	    })),
	    'ADM_SCRAPER_LIST',
	]),
	body => Join([
	    vs_simple_form(ScraperForm => [
		'ScraperForm.Website.url',
		'ScraperForm.Scraper.scraper_type',
		['ScraperForm.Scraper.default_venue_id', {
		    choices => ['Model.VenueList'],
		    list_display_field => 'RealmOwner.display_name',
		    unknown_label => ' ',
		}],
		['ScraperForm.Scraper.scraper_aux', {
		    cols => 80,
		    rows => 25,
		}],
		If(['Type.FormMode', '->eq_edit'],
		   StandardSubmit({
		       buttons => 'ok_button test_scraper_button cancel_button',
		   }),
		   StandardSubmit({
		       buttons => 'ok_button cancel_button',
		   }),
	        ),
	    ], 1),
	    DIV_c4_scraper(If(['Model.ScraperForm', '->has_events'],
	       String([sub {
                   my($source) = @_;
		   return ${b_use('IO.Ref')->to_string(
		       $source->req(qw(Model.ScraperForm events)))};
	       }])->put(hard_newlines => 1),
	    )),
	    String(['Model.ScraperForm', 'error']),
	]),
    );
}

sub list {
    return shift->internal_put_base_attr(
	tools => TaskMenu([
	    'ADM_SCRAPER_FORM',
	]),
	body => vs_paged_list(ScraperList => [
	    map([$_, {
		wf_list_link => {
		    task => 'ADM_SCRAPER_FORM',
		    query => 'THIS_DETAIL',
		},
	    }], qw(RealmOwner.display_name Scraper.scraper_type)),
	    'Website.url',
	]),
    );
}

sub preview {
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
