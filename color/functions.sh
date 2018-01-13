#!/usr/bin/env bash

# color_on_code -- Emit the ANSI escape sequence for the given color(s).
# This does not activate the color, only shows the appropriate ANSI
# escape code (which you may then emit with echo -e or printf %b).
# $1 - The foreground color you want
# $2 - The optional background color
color_on_code() {
    printf '\\033[%s' ${2:+"48;5;$2;"}
    printf '38;5;%sm' ${1:?Missing foreground color}
}

# color_off_code -- Emit the ANSI escape sequence to disable colors.
color_off_code() {
    printf '\\033[0m'
}

# color_test -- Show all standard ANSI color combinations
# $1 - The text to show in the test grid, default to gYw
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html
# see http://unix.stackexchange.com/a/41639/50240
color_test() {
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
# http://bitmote.com/index.php?post/2012/11/19/Using-ANSI-Color-Codes-to-Colorize-Your-Bash-Prompt-on-Linux
color_test_256() {
	echo -en "\n   +  "
	for i in {0..35}; do
	  printf "%2b " $i
	done

	printf "\n\n %3b  " 0
	for i in {0..15}; do
	  echo -en "\033[48;5;${i}m  \033[m "
	done

	for i in {0..6}; do
	  let "i = i*36 +16"
	  printf "\n\n %3b  " $i
	  for j in {0..35}; do
		let "val = i+j"
		echo -en "\033[48;5;${val}m  \033[m "
	  done
	done

	echo -e "\n"
}

# turn on the numbered color(s) if not in a pipe
color_on() {
    [ -t 1 ] && color_force_on $1 $2
}

# turn off colors, if not in a pipe
color_off() {
    [ -t 1 ] && color_force_off
}

# turn on the numbered colors
color_force_on() {
    printf '%b' "$(color_on_code $1 $2)"
}

# turn off colors
color_force_off() {
    printf '%b' "$(color_off_code)"
}

# strip ANSI color codes
color_strip() {
	sed -e 's,\[[0-9;]*[m|K],,g' -e 's,\\033,,g' -e 's,\\\[,,g' -e 's,\\],,g'
}

# replace color mark-up with corresponding ANSI codes
# <fg=N></> and <bg=N></>
# printf '%b' "$(color_markup <<< 'Hi <fg=20><bg=200>Bishop</>, how are you?')"
color_markup() {
    sed -e 's,< *fg *= *\([0-9][0-9]*\) *>,\\033[38;5;\1m,g' \
        -e 's,< *bg *= *\([0-9][0-9]*\) *>,\\033[48;5;\1m,g' \
        -e 's,< */ *>,\\033[0m,g'
}

# remove color mark-up
color_markup_strip() {
    sed -e 's,< *fg *= *\([0-9][0-9]*\) *>,,g' \
        -e 's,< *bg *= *\([0-9][0-9]*\) *>,,g' \
        -e 's,< */ *>,,g'
}
