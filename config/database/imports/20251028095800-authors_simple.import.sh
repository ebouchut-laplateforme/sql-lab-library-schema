#!/bin/bash

#set -x  # Uncomment to enable "debug" mode

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# This shell script reads data from a CSV file,
# and generates a SQL script that inserts this data .
#
# When run this SQL script will populate the authors_simple table w.
# that populate the books table on the standard output.
# The CSV contains the value of the title split into 2 columns that we first  need to concatenate before insertion.
# The generated SQL script contains a SQL INSERT statement.
#
# SQL script  populates the `full_name` column of the `authors_simple` table
# with the concatenation of the first 2 columns (last and first name) found in each row of the  CSV file.
#
# The CSV file requires processing data before they can be inserted:
# - We do not insert the first line because it is a header (not data).
# - Each row contains 2 columns that we need to be concatenate before insertion.
#
# See: https://github.com/ebouchut-laplateforme/sql-lab-library-schema/issues/8
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CSV_FILE=${1:-20251028095800-authors_simple.import.csv}


# `tail -n +2 ` prints all lines except the first one (header), (starts printing at line 2)
# `awk -F,` tells awk that the field separator is a comma.
# Note: \047 is an escape sequence that denotes the simple quote (`'`).
awk -F, -f - "$CSV_FILE"  <<-'END_AWK'
  BEGIN {
    print "BEGIN;\n";
    print "USE library;\n\n";
    print "INSERT INTO authors_simple (title) VALUES";
  }
  NR == 1 {
    next
  }
  NR > 2 {
    print "\t" previous_line ",";
  }
  {
    # Escape single quotes: Replace all occurrences of a single quote with 2 consecutive single quotes in the first 2 fields
    gsub(/\047/, "\047\047", $1);
    gsub(/\047/, "\047\047", $2);

    # Left-trim the leading space from the first name (second field: $2)
    gsub(/^ /, "", $2);

    previous_line = "\t(\047" $2 " " $1 "\047)";
  }
  END {
      print "\t" previous_line;

      print ");\n";
      print "COMMIT;\n";
  }
END_AWK
