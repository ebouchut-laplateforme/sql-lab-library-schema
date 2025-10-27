-- Rename a table field
-- Rename books.first_edition to books.first_edition_date

BEGIN;

USE library;

ALTER TABLE books
  RENAME COLUMN first_edition TO first_edition_date
;

COMMIT;
