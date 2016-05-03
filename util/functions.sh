#!/usr/bin/env bash

# util_column -- Extract the selected columns
# $1 the first column to extract
# $2 the second column to extract
# ...
# $N
# Recognizings environment variables corresponding to the AWK field and
# recording splitting and outputing variables: FS, RS, OFS, and ORS
#
# A naive way to parse a CSV: FS=, util_column 2 3 < data.csv
function util_column() {
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
