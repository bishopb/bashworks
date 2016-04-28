#!/usr/bin/env bash

# interactive_newscreen -- Create a new, named screen
function interactive_newscreen {
    local name=${1:-}
    screen -t "$name" -S "$name"
}

# interactive_changescreen -- Select from a list of screens
function interactive_changescreen {
    if [ -n "$STY" ]; then
        echo "Currently in screen $STY."
    else
        echo "Not in a screen."
    fi
    echo
    local quit="Do not change screens"
    local stys=$(ls /var/run/screen/S-$(whoami) | sort -t. -k2)
    local PS3="Screen? "

    select sty in "$quit" $stys; do
    case "$sty" in
    "$quit")
        echo "No screen change."
        return 0
        ;;
    *)
        screen -DRR "$sty"
        return $?
        ;;
    esac
    done
}

# interactive_start_agent -- Start a new SSH agent
function interactive_start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add $(find "$HOME"/.ssh/ -perm 0600 -name id\*)
}

# interactive_diceware -- Throw some dice and get some words
function interactive_diceware {
    numWords=${1:-5}
    srclist="http://world.std.com/~reinhold/beale.wordlist.asc"
    wordlist="${TMPDIR:-/tmp}/diceware.wordlist.asc"


    if [ ! -e "$wordlist" ]; then
        curl -sS "$srclist" > "$wordlist"
    fi

    for w in $(seq 1 $numWords); do
       digits=
       for d in 1 2 3 4 5; do
         digit=$(shuf --random-source=/dev/random -i 1-6 -n 1)
         digits="$digits$digit"
       done
       grep "^$digits\s" "$wordlist"
    done
}

# interactive_compile_ssh_config - Builds a single SSH config from source files
# see http://serverfault.com/a/452617/204816
function interactive_compile_ssh_config() {
    local compiled="$HOME"/.ssh/config
    echo "
##############################################################################
# 
# Auto-generated on $(date).
# DO NOT EDIT
#
##############################################################################

" > "$compiled"

    for config in "$HOME"/.ssh/*.config; do
        echo "# Begin file: $config" >> "$compiled"
        cat "$config" >> "$compiled"
        echo "# End file: $config" >> "$compiled"
    done
    chmod 600 "$compiled"
}

# interactive_format_jobs
# improve jobs output
function interactive_format_jobs() {
    local filter='{
        if ($2 ~ /[0-9]+/) {
            printf "%4s %5s %-9s",$1,$2,$3; $1=$2=$3=""; print $0;
        } else {
            printf "%4s %-9s",$1,$2; $1=$2=""; print $0;
        }
    }'
    awk "$filter"
}

# interactive_hr
# draw a line across the terminal
# see http://wiki.bash-hackers.org/snipplets/print_horizontal_line
function interactive_hr() {
  local start=$'\e(0' end=$'\e(B' line='qqqqqqqqqqqqqqqq'
  local cols=${COLUMNS:-$(tput cols)}
  while ((${#line} < cols)); do line+="$line"; done
  printf '%s%s%s\n' "$start" "${line:0:cols}" "$end"
}

# interactive_banner
# places a message at the top-most line of the terminal
function interactive_banner() {
  local message=${1:?What message would you like in the banner?}
  local columns=${COLUMNS:-$(tput cols)}
  local padding=$((columns - ${#message}))
  echo -n $'\e7\e[0;0H\e[7m'
  echo -n $message
  while ((padding--)); do echo -n " "; done
  echo -n $'\e[K\e8'
}
