#!/usr/bin/env bash

# interactive_newscreen -- Create a new, named screen
function interactive_newscreen {
    local name=${1:-}
    screen -t "$name" -S "$name"
}

# interactive_changescreen -- Select from a list of screens
function interactive_changescreen {
    if [ -n "$STY" ]; then
        echo "Currently in screen $STY"
    else
        echo "Not in a screen"
    fi
    quit="Do not switch"
    stys=$(ls /var/run/screen/S-$(whoami) | sort -t. -k2)
    select sty in "$quit" $stys; do
    case "$sty" in
    "$quit")
        echo "Not changes screens"
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
