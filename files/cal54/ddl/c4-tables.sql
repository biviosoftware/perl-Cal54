-- Copyright (c) 2010 bivio Software, Inc.  All rights reserved.
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

CREATE TABLE search_words_t (
  realm_id NUMERIC(18) NOT NULL,
  value VARCHAR(4000),
  CONSTRAINT search_words_t1 PRIMARY KEY(realm_id)
)
/
CREATE TABLE venue_t (
  venue_id NUMERIC(18) NOT NULL,
  scraper_type NUMERIC(3) NOT NULL,
  CONSTRAINT venue_t1 PRIMARY KEY(venue_id)
)
/
