-- Copyright (c) 2010 CAL54, Inc.  All rights reserved.
-- $Id$
--
-- Constraints & Indexes for Cal54 Models
--
-- * This file is sorted alphabetically by table
-- * The only "NOT NULL" values are for things which are optional.
--   There should be very few optional things.  For example, there
--   is no such thing as an optional enum value.  0 should be used
--   for the UNKNOWN enum value.
-- * Booleans are: <name> NUMBER(1) CHECK (<name> BETWEEN 0 AND 1) NOT NULL,
-- * How to number all constraints sequentially:
--   perl -pi -e 's/(\w+_t)\d+/$1.++$n{$1}/e' bOP-constraints.sql
--   Make sure there is a table_tN ON each constraint--random N.
--
----------------------------------------------------------------

----------------------------------------------------------------
-- Non-PRIMARY KEY Constraints
----------------------------------------------------------------

--
-- scraper_t
--
ALTER TABLE scraper_t
  ADD CONSTRAINT scraper_t2
  FOREIGN KEY (default_venue_id)
  REFERENCES venue_t(venue_id)
/
CREATE INDEX scraper_t3 ON scraper_t (
  default_venue_id
)
/

--
-- search_words_t
--
ALTER TABLE search_words_t
  ADD CONSTRAINT search_words_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX search_words_t3 ON search_words_t (
  realm_id
)
/

--
-- venue_event_t
--
ALTER TABLE venue_event_t
  ADD CONSTRAINT venue_event_t2
  FOREIGN KEY (venue_id)
  REFERENCES venue_t(venue_id)
/
CREATE INDEX venue_event_t3 ON venue_event_t (
  venue_id
)
/
ALTER TABLE venue_event_t
  ADD CONSTRAINT venue_event_t4
  FOREIGN KEY (calendar_event_id)
  REFERENCES calendar_event_t(calendar_event_id)
/
CREATE INDEX venue_event_t5 ON venue_event_t (
  calendar_event_id
)
/
