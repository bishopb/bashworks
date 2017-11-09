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
        OFS="";
        print "sum=",sum;
        print "count=",c;
        print "average=",ave;
        print "median=",median;
        print "q1=",a[0];
        print "q4=",a[c-1];
      }
    '
}

# util_body -- keep the first line of output at top
# Output is the first line followed by the command
# @see http://unix.stackexchange.com/a/11859/50240
function util_body() {
    IFS= read -r header
    printf '%s\n' "$header"
    "$@"
}

# util_cdup -- go up N number of directories
# @see http://stackoverflow.com/q/41636778/2908724
function util_cdup() {
    # $1=number of times, defaults to 1
    printf -v path '%*s' "${1:-1}"
    cd "${path// /../}"
}

# util_sponge -- Soak up stdin until EOF, then dump it
# @see http://unix.stackexchange.com/a/337061/50240
function util_sponge() {
    awk '{a[NR] = $0} END {for (i = 1; i <= NR; i++) print a[i]}'
}

# = -- General purpose calculator
# @see http://stackoverflow.com/a/19251899/2908724
# @see http://stackoverflow.com/a/29581452/2908724
# $ = 1+sin[3.14159] + log[1.5] - atan2[1,2] - 1e5 + 3e-10
# > 0.94182
function =() {
    local in="$(echo "$@" | sed -e 's/\[/(/g' -e 's/\]/)/g')";
    awk 'BEGIN {print '"$in"'}' < /dev/null
}

# util_backoff -- Retry a command a command until it succeeds, limiting the
# maximum number of times it can run and backing off after each failed
# attempt.
# ATTEMPTS=99 TIMEOUT=2 util_backoff curl 'http://example.co'
# @see http://stackoverflow.com/a/8351489/2908724
function util_backoff() {
    local -i max_attempts=${ATTEMPTS-5}
    local -i timeout=${TIMEOUT-1}
    local -i attempt=0
    local -i exitCode=0

    if [ $timeout -lt 0 ]; then
        timeout=1
    elif [ $max_attempts -lt 1 ]; then
        max_attempts=1
    fi

    while (( $attempt < $max_attempts )); do
        attempt=$(( attempt + 1 ))

		"$@"
		exitCode=$?

		if [ $exitCode -eq 0 ]; then
			return 0
        elif [ $attempt -eq $max_attempts ]; then
            echo "Exited with $exitCode. Giving up." >&2
            return $exitCode
        else
            echo "Exited with $exitCode. Retrying after $timeout seconds." >&2
            sleep $timeout
            timeout=$(( timeout * 2 ))
		fi
    done
}
