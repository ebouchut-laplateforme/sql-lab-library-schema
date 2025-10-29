#!/bin/bash

#set -x  # Uncomment to enable "debug" mode

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# This shell script reads data from a CSV file,
# and generates a SQL script that inserts the CSV data in the `authors_simple table`.
#
# Each row of this CSV contains at most 2 columns (first the last name, then the first name).
# The `authors_simple` table contains a `full_name` column.
# We will build the full name by concatenating the first and the last name fields of a CSV row,
#   separated with a space and store this into the `authors_simple.full_name`.
# The generated SQL script contains a **single** SQL INSERT statement.
#
# The CSV file requires processing data before they can be inserted:
# - We do not insert the first line because it is a header (not data).
# - Each row contains (at most ;-) 2 columns that we need to be concatenate before insertion.
#
# See: https://github.com/ebouchut-laplateforme/sql-lab-library-schema/issues/8
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CSV_FILE=${1:-20251028095800-authors_simple.import.csv}


# `awk -F,` tells awk that the field separator is a comma.
# Note: \047 is an escape sequence that denotes the simple quote (`'`).
# `<<-'END_AWK'` is a bash here-doc notation for a multiline string where variables are not interpolated.
# The purpose of using `previous_full_name` trick is to end each row/value with a comma except the last one.
# `sort | uniq -u`: Removes duplicates. Side effect: lines are ordered.
#
awk -F, -f - "$CSV_FILE"  <<-'END_AWK1' |
  NR == 1 {
    # Ignore the first line (header)
    next
  }
  NR >= 2 {
    if (length(previous_full_name) > 0) {
      print previous_full_name;
    }
  }
  {
    # Create a variable with the full name  enclosed in single quotes, ready to be printed when processing the next line.

    # Escape single quotes: Replace all occurrences of a single quote with 2 consecutive single quotes in the the line (all fields)
    gsub(/'/, "''", $0);

    # Remove leading and trailing spaces from the last name ($1)
    sub(/^ +/, "", $1);
    sub(/ +$/, "", $1);

    # Build the full name by concatenating the first name ($2) and last name ($1) separated with a space.
    previous_full_name = "";

    if (NF >= 2 && length($2) > 0) {
      # The last name (second field: $2) is present.

      # Remove leading and trailing spaces from the first name ($2)
      sub(/^ +/, "", $2);
      sub(/ +$/, "", $2);

      previous_full_name = $2;
    }
    if (length($1) > 0) {
      # The fist name ($1) is present
      if (NR >= 2) {
        # Only add a space between the last and full name when both are present.
        previous_full_name = previous_full_name " "
      }

      # Add the first name if present
      previous_full_name = previous_full_name $1
    }
  }
  END {
    if (length(previous_full_name) > 0) {
      print previous_full_name;
    }
  }
END_AWK1
sort | uniq | awk -f <(cat <<-'END_AWK2'
  BEGIN {
    print "BEGIN;\n";
    print "USE library;\n\n";
    print "INSERT INTO authors_simple (full_name) VALUES";
  }
  NR == 1 {
    previous_full_name = $0;
  }
  NR >= 2 {
      # Note there is a comma after the value
    print "\t('" previous_full_name "'),";
  }
  {
    previous_full_name = $0;
  }
  END {
    # Note: No comma after the **last** value (last line)
    print "\t('" previous_full_name "')";

    print ";\n";
    print "COMMIT;\n";
  }
END_AWK2
)
