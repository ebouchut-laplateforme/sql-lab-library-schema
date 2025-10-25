/*
 * This SQL script creates the structure for a library management application, that is:
 * - the library database 
 * - a user named librarian with all premissions only on this database
 * - the databse tables
 */

/*
 * Start a transaction to group the SQL statements (between `BEGIN;` and `COMMIT;`)
 * to create the database, a user, its structure (tables, integrity constraints)
 * This ensures the creation is either made **as a single unit** or cancelled on error.
 */
BEGIN;

/*
 * Create the library database
 */
CREATE DATABASE IF NOT EXISTS library
    CHARACTER SET utf8mb4
;

/* 
 * Set library as the default database 
 * for this session (i.e. until the end of this script)
 */
USE library;

/*
 * Create a dedicated database user named librarian 
 * (used to connect to the library database)
 */
CREATE USER 'librarian'@'127.0.0.1' 
     IDENTIFIED BY 'bookworm'
;

/*
 * Give the librarian all permissions 
 * on the library database
 */
GRANT ALL
    ON library.*
    TO 'librarian'@'127.0.0.1'
;
FLUSH PRIVILEGES; -- Thx Aleij.

/*
 * Many-to-one relationship between books and authors 
 * Many books (N) --> (1) one author
 */
CREATE TABLE authors (
  id            INT           PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(255)  NOT NULL
);

CREATE TABLE books (
  id            INT           PRIMARY KEY AUTO_INCREMENT,
  title         VARCHAR(255)  NOT NULL,
  isbn          VARCHAR(255)  UNIQUE NOT NULL,
  first_edition DATE,
  author_id     INT           NOT NULL,
  
  CONSTRAINT    fk_books_author_id_authors
    FOREIGN KEY (author_id) REFERENCES authors (id)
        ON UPDATE CASCADE
);

CREATE TABLE genres (
  id            INT           PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(255)  NOT NULL
);

/*
 * Many-to-many association table
 * Yes I know, the naming convention of this junction table (`books_genres`) has a Rails slant.
 * But rest assured, I am working on joining the Spring Boot side, 
 * so `book_genres` is about to enter the stratosphere in the coming month ;-).
 */
CREATE TABLE books_genres (
  id            INT           PRIMARY KEY AUTO_INCREMENT,
  book_id       INT           NOT NULL,
  genre_id      INT           NOT NULL,

  /*
   * Integrity constraint to enforce referential integrity between the `books_genres` and `books tables`:
   * - Ensures every `book_id` in `books_genres` must exist in the `books` table's `id` column.
   * - When a book's `id` is updated in the `books` table, the corresponding `book_id` values 
   *   in `books_genres` are automatically updated (`ON UPDATE CASCADE`).
   */
  CONSTRAINT    fk_books_genres_book_id_books
    FOREIGN KEY (book_id) REFERENCES books (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
  
 /*
  * Integrity constraint to enforce referential integrity between the `books_genres` and `genres` tables:
  * - Ensures every `genre_id` in `books_genres` must exist in the `genres` table's `id` column.
  * - When a genre's `id` is updated in the `genres` table, the corresponding `genre_id` values 
  *   in `books_genres` are automatically updated (`ON UPDATE CASCADE`)
  */
  CONSTRAINT    fk_books_genres_genre_id_genres
    FOREIGN KEY (genre_id) REFERENCES genres (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

/* 
 * Commit the above SQL statements to the database
 * if no errors have occurred since the beginning of the transaction
 * (marked with `BEGIN;`).
 */
COMMIT;