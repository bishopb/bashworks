#!/usr/bin/env bash

# color_test -- Show all standard ANSI color combinations
# $1 - The text to show in the test grid, default to gYw
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html
# see http://unix.stackexchange.com/a/41639/50240
function color_test() {
    local T=${1:-'gYw'}
    printf "          "
    for b in 0 1 2 3 4 5 6 7; do printf "  4${b}m "; done
    echo
    for f in "" 30 31 32 33 34 35 36 37; do
        for s in "" "1;"; do
            printf "%4sm" "${s}${f}"
            printf " \033[%sm%s\033[0m" "$s$f" "gYw "
            for b in 0 1 2 3 4 5 6 7; do
                printf " \033[4%s;%sm%s\033[0m" "$b" "$s$f" " $T "
            done
            echo
         done
    done
}

# color_test_256 -- Show all 256 colors, provided your TERM supports it
# http://www.commandlinefu.com/commands/view/11759/
function color_test_256() {
    for i in {0..255}; do
        color_on $i
        printf '%0.3d\n' $i
    done | column -c 132 | expand -t1
    color_off
}

function color_on() {
    echo -en "\e[38;05;${1:-3}m";
}

function color_off() {
    echo -en "\e[m"
}
