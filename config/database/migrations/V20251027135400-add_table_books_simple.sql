/*
 * Add a books_simple table in the library database.
 */

BEGIN;

USE library;

CREATE TABLE books_simple (
  ID     INT            PRIMARY KEY AUTO_INCREMENT,
  title  VARCHAR(255)   NOT NULL UNIQUE
);

CREATE INDEX idx_books_simple_title
  ON books_simple(title)
;

COMMIT;
