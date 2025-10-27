/*
 * This script changes the datatype of a field in a database table.
 *
 * Update the field books.isbn:
 *
 * - Change its datatype from VARCHAR(255) to VARCHAR(17)
 * - Add unique and not null constraints
 */

BEGIN;

ALTER TABLE books
  CHANGE COLUMN isbn isbn  VARCHAR(17) UNIQUE NOT NULL
;

COMMIT;
