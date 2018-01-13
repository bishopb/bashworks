#!/usr/bin/env bash

# interactive_newscreen -- Create a new, named screen
function interactive_newscreen {
    local name=${1:-}
    screen -t "$name" -S "$name"
}

# interactive_changescreen -- Select from a list of screens
function interactive_changescreen {
    if [ -n "$STY" ]; then
        echo "Currently in screen $STY. Disconnect before changing."
        return 1
    fi

    local stys=$(ls /var/run/screen/S-$(whoami) 2>/dev/null | sort -t. -k2)
    local quit="Exit without changing screens"
    local new="Create new, named screen"
    local PS3="Screen? "

    select sty in "$quit" "$new" $stys; do
    case "$sty" in
    "$quit")
        echo "No screen change."
        return 0
        ;;
    "$new")
        echo "Creating new screen."
        read -p 'Screen name? ' name
        if [ -z "$name" ]; then
            echo 'No screen name, no screen created'
            return 1
        else
            interactive_newscreen "$name"
            return $?
        fi
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

# interactive_stylize_jobs
# stylize jobs output
function interactive_stylize_jobs() {
    if [ -t 1 ]; then
        local CO=$(color_force_off)
        local CB=$(color_force_on 1)
        local CF=$(color_force_on 2)
    fi
    unexpand -at35, | awk -v CO="${CO:-}" -v CB="${CB:-}" -v CF="${CF:-}" '{
        # get the jobnum and fg/bg marker
        split(substr($1, 2), p, "]");

        if (p[2] == "+") { printf "%s", CF; }
        if (p[2] == "-") { printf "%s", CB; }
        if (p[2] == "")  { p[2]="."; }

        if ($2 ~ /[0-9]+/) {
            printf "%2.2s%s %6s %-9s", p[1], p[2], $2 ,$3;
            $3="";
        } else {
            printf "%2.2s%s %-9s", p[1], p[2], $2;
        }
        $1=$2="";
        print $0 CO
    }'
}

# interactive_hr
# draw a line across the terminal
# see http://wiki.bash-hackers.org/snipplets/print_horizontal_line
function interactive_hr() {
  local line='━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
  local line='┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄'
  local cols=${1:-${COLUMNS:-$(tput cols)}}
  while ((${#line} < cols)); do line+="$line"; done
  printf "${line:0:cols}"
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

# set the terminal title, if possible
# https://stackoverflow.com/a/1687708/2908724
function interactive_title() {
  local title=${1:?What would you like in the title?}
  echo -e "\033]2;$title\007"
}

# draw a line-surrounded header, with a message offset in the middle, like:
# ---[message goes here]--------------------------------------------------
function interactive_header() {
  local message=${1:?What message would you like in the banner?}
  local stripped=$(color_strip <<< "${message}")
  local columns=${COLUMNS:-$(tput cols)}
  local padding=$((columns - ${#stripped}))
  color_on ${2:-250}
  interactive_hr 2
  color_off
  printf '[%b]' "${message}"
  color_on ${2:-250}
  interactive_hr $((padding - 4)) # the leading 2 '-', plus the 2 '[]' characters
  color_off
  echo
}

function interactive_prompt_command() {
  rc=$?
  local fg bg
  [ 0 -eq ${rc} ] && { fg=0; bg=2; } || { fg=7; bg=1; }

  # last result
  prompt="[\[<fg=${fg}>\]\[<bg=${bg}>\] ${rc} \[</>\]] "

  # time and place
  prompt+='\[<fg=126>\]$(date +%T)\[</>\]  '
  prompt+='\[<fg=75>\]${USER:-?}\[</>\]@\[<fg=70>\]$(hostname)\[</>\]:\[<fg=178>\]${PWD:-?}\[</>\]'

  # git-ish
  local branch
  branch=$(git branch -a 2>/dev/null| grep '^*' | cut -c3-) || true;
  [ -n "${branch}" ] && prompt+="\[<fg=204>\]<${branch}>\[</>\]"

  # screen
  local screen
  screen=$(pstree --show-parents -p $$ | head -n 1 | sed 's/\(.*\)+.*/\1/' | grep screen | wc -l) || true
  [ "1" = "${screen}" ] && prompt+="  \[<fg=93>\]screen\[</>\]"

  # drop to the bottom, break a line width, draw the header
  tput cup 9999 0
  PS1='\n'
  PS1+="$(printf '%b' "$(color_markup <<< "${prompt}")")"
  PS1+='\n\!\$ '

  return $rc
}
