#!/usr/bin/env bash

# util_pluck -- Extract the selected columns
# $1 the first column to extract
# $2 the second column to extract
# ...
# $N
# Recognizings environment variables corresponding to the AWK field and
# recording splitting and outputing variables: FS, RS, OFS, and ORS
#
# A naive way to parse a CSV: FS=, util_column 2 3 < data.csv
function util_pluck() {
    awk -v FS="${FS:- }" \
        -v RS="${RS:-$'\n'}" \
        -v OFS="${OFS:- }" \
        -v ORS="${ORS:-$'\n'}" \
        -v input="$(echo "$@")" \
        '
        BEGIN { split(input, columns, " ") }
        {
            for (column in columns)
                printf "%s%s", $(columns[column]), OFS;
            printf "%s", ORS;
        }
    '
}

# util_stats -- Calculate statistics on a stream of numbers.
# Output is sum, count, average, median, minimum, and maximum
function util_stats() {
    # http://unix.stackexchange.com/a/13779/50240
    sort -n | awk '
      BEGIN {
        c = 0;
        sum = 0;
      }
      $1 ~ /^[0-9]*(\.[0-9]*)?$/ {
        a[c++] = $1;
        sum += $1;
      }
      END {
        ave = sum / c;
        if( (c % 2) == 1 ) {
          median = a[ int(c/2) ];
        } else {
          median = ( a[c/2] + a[c/2-1] ) / 2;
        }
        OFS="\t";
        print sum, c, ave, median, a[0], a[c-1];
      }
    '
}
