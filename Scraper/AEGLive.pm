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
    link => qr/(Next >>.*\})/i,
    page_count => 3,
  },
  repeat => [
    [qr/\n(.*?\}\n(?:.*\n)?)$month $day, $year, $time_ap/ => {
      fields => [qw(summary month day year start_time)],
      follow_link => {
        once => [
          [qr/Ticket Prices.*?\n(?:[^\n]{0,50}\n)+(.*?)Service and handling fees/is => {
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
