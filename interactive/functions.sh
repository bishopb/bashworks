#!/usr/bin/env bash

# interactive_newscreen -- Create a new, named screen
function interactive_newscreen {
    local name=${1:-}
    screen -t "$name" -S "$name"
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
