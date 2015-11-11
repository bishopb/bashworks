#!/usr/bin/env bash

function interactive_load() {
    PATH=$HOME/bin:$PATH
    source "$(module_get_path interactive)"/functions.sh
    source "$(module_get_path interactive)"/aliases.sh
}

function interactive_post_load() {
    # The One True Editor
    export EDITOR=/usr/bin/vim
    set -o vi

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