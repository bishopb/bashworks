#!/usr/bin/env bash

function interactive_load() {
    export TERM=xterm-256color
    export PATH=$HOME/bin:$PATH
    module color util
    source "$(module_get_path interactive)"/variables.sh
    source "$(module_get_path interactive)"/functions.sh
    source "$(module_get_path interactive)"/aliases.sh
}

function interactive_post_load() {
    # The One True Editor
    export EDITOR=/usr/bin/vim
    set -o vi

    # interactive shell options
    shopt -s dirspell

    # start SSH agent, if it's not already running
    export SSH_ENV="$HOME"/.ssh/environment
    if [ -f "${SSH_ENV}" ]; then
        . "${SSH_ENV}" > /dev/null
        ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
            interactive_start_agent
        }
    else
        interactive_start_agent
    fi
}
