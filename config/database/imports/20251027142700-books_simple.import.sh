#!/bin/bash

#set -x  # Uncomment to enable "debug" mode

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# This shell script reads data from a CSV file,
#   in order to generate a SQL script that populate the books table on the standard output.
# The CSV contains the value of the title split into 2 columns that we first  need to concatenate before insertion.
# The generated SQL script contains a SQL INSERT statement for each row.
#
# SQL script  populates the `title` column of the `books_simple` table
# with the concatenation of the first 2 columns found in each row of the  CSV file.
#
# The CSV file requires processing data before they can be inserted:
# - We do not insert the first line because it is a header (not data).
# - Each row contains 2 columns that we need to concatenate before insertion.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# TODO: Ensure that we have at least one file passed-in as argument or else display the command usage
CSV_FILE=${1:-20251027142700-books_simple.import.csv}


# `tail -n +2` Skips the header line (first line) and prints the content of the CSV file starting from line 2.
# `awk -F` tells awk that the field separator is a comma.
# Note: \047 is an escape sequence that denotes the simple quote (`'`).
#       This trick made me bang my head against the wall ;-)!.
#
tail -n +2 "$CSV_FILE" |\
  awk -F, '\
    BEGIN {\
      print "BEGIN;\n";\
      print "USE library;\n";\
      }\
    { print "INSERT INTO books_simple (title) VALUES (\047" $0 "\047);"; }
    END {\
      print "\nCOMMIT;";\
    }\
  '
