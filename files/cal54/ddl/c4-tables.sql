-- Copyright (c) 2010 CAL54, Inc.  All rights reserved.
-- $Id$
--
-- Data Definition Language for Cal54 Models
--
-- * Tables are named after their models, but have underscores where
--   the case changes.  
-- * Make sure the type sizes match the Model field types--yes, this file 
--   should be generated from the Models...
-- * Don't put any constraints or indices here.  Put them in *-constraints.sql.
--   It makes it much easier to manage the constraints and indices this way.
--

CREATE TABLE scraper_t (
  scraper_id NUMERIC(18) NOT NULL,
  scraper_type NUMERIC(3) NOT NULL,
  scraper_aux TEXT64K,
  default_venue_id NUMERIC(18),
  CONSTRAINT scraper_t1 PRIMARY KEY(scraper_id)
)
/
CREATE TABLE search_words_t (
  realm_id NUMERIC(18) NOT NULL,
  value VARCHAR(4000),
  CONSTRAINT search_words_t1 PRIMARY KEY(realm_id)
)
/
CREATE TABLE venue_t (
  venue_id NUMERIC(18) NOT NULL,
  CONSTRAINT venue_t1 PRIMARY KEY(venue_id)
)
/
CREATE TABLE venue_event_t (
  calendar_event_id NUMERIC(18) NOT NULL,
  venue_id NUMERIC(18) NOT NULL,
  CONSTRAINT venue_event_t1 PRIMARY KEY(calendar_event_id)
)
/
CREATE TABLE geo_position_t (
  realm_id NUMERIC(18) NOT NULL,
  latitude NUMERIC(11,8) NOT NULL,
  longitude NUMERIC(11,8) NOT NULL,
  CONSTRAINT geo_position_t1 PRIMARY KEY(realm_id)
)
/
