# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Scraper::AEGLive;
use strict;
use Bivio::Base 'Scraper.RegExp';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub eval_scraper_aux {
    my($self) = @_;
    return shift->SUPER::eval_scraper_aux(<<'EOF');
{
  crawl_delay => 5,
  pager => {
    link => qr/\n(>.*\})\n/i,
    page_count => 3,
  },
  repeat => [
    [qr/\n(http.*?)\n+$day_name, $month $day, $year $time_ap/ => {
      fields => [qw(link day_name month day year start_time)],
      follow_link => {
        once => [
          [qr/\nEvent Details\n+(.*?)\n\n/is => {
            fields => [qw(summary)],
          }],
          [qr/Ticket Prices.*?\n(?:[^\n]{0,50}\n)+(.*?)Service and handling fees/is => {
            fields => [qw(description)],
          }],
          [qr/\nWebsites\n(?:[^\n]{0,50}\n)+(.*?)Service and handling fees/is => {
            fields => [qw(description)],
          }],
        ],
      },
    }],
  ],
}
EOF
}

1;
