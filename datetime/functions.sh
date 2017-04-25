#!/usr/bin/env bash

# Highlight the current day and show week numbers in traditional cal format
# Usage: datetime_calendar [YYYY-MM-DD]
# See also: http://unix.stackexchange.com/a/29446/50240
function datetime_calendar() {
    local today Y m d ref dNbA dNbM dNbW nxtm xntY nxtA refZ days h1 h2 cdate
    today=($(date '+%Y %m %d')); Y=0; m=1; d=2
    [[ -z $1 ]] && ref=(${today[@]}) || ref=(${1//-/ })
    dNbA=$(date --date="$(date +%Y-%m-01)" +'%u')
    today[m]=$((10#${today[m]})); ref[m]=$((10#${ref[m]}))
    today[d]=$((10#${today[d]})); ref[d]=$((10#${ref[d]}))
    nxtm=$(( ref[m]==12 ?1       :ref[m]+1 ))
    nxtY=$(( ref[m]==12 ?ref[Y]+1:ref[Y]   ))
    nxtA="$nxtY-$nxtm-1"
    refZ=$(date --date "$(date +$nxtA) yesterday" +%Y-%m-%d)
    days=$(date --date="$refZ" '+%d')

    h1="$(date --date="${ref[Y]}-${ref[m]}-${ref[d]}" '+%B %Y')"
    h2="Mo Tu We Th Fr Sa Su"
    printf "    %$(((${#h2}-${#h1}-1)/2))s%s\n" " " "$h1"
    printf "    %s\n" "$h2"

    printf "%2d  " "$((10#$(date -d "$(date +${ref[Y]}-${ref[m]}-01)" +'%V')))"
    printf "%$(((dNbA-1)*3))s"
    dNbW=$dNbA
    dNbM=1
    while :; do
        if (( today[Y]==ref[Y] &&  
              today[m]==ref[m] && 
              today[d]==dNbM )) ;then
            printf "\x1b[7m%2d\x1b[0m " "$dNbM"
        else
            printf "%2d " "$dNbM"
        fi
        if (( dNbM < days )); then
          ((dNbM++))
        elif (( dNbM = days )); then
          break
        fi
        if ((dNbW >=7)) ;then
            cdate=$((10#$(date -d "$(date +${ref[Y]}-${ref[m]}-$dNbM)" +'%V')))
            printf "\n%2d  " "$cdate"
            dNbW=0
        fi
        ((dNbW++))
    done
    printf "%$(((8-dNbW)*3))s\n"
}
