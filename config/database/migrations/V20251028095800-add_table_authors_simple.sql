/*
 * Add a authors_simple table in the library database.
 */

BEGIN;

USE library;

CREATE TABLE authors_simple (
  ID        INT            PRIMARY KEY AUTO_INCREMENT,
  full_name VARCHAR(255)   NOT NULL UNIQUE
);

CREATE INDEX idx_authors_simple_full_name
  ON authors_simple(full_name)
;

COMMIT;
