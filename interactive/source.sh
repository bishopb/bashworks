#!/usr/bin/env bash

function interactive_load() {
    export TERM=${TERM:-xterm-256color}
    export PATH="${HOME}"/bin:"${PATH}"
    module color util datetime
    source "$(module_get_path interactive)"/variables.sh
    source "$(module_get_path interactive)"/functions.sh
    source "$(module_get_path interactive)"/aliases.sh
}

function interactive_post_load() {
    # Ensure The One True Editor
    export EDITOR=$(which vim)
    set -o vi

    # interactive shell options
    shopt -s dirspell

    # start SSH agent, if it's not already running
    export SSH_ENV="${HOME}"/.ssh/environment
    if [ -f "${SSH_ENV}" ]; then
        . "${SSH_ENV}" > /dev/null
        ps -ef | grep "${SSH_AGENT_PID}" | grep ssh-agent$ > /dev/null || {
            interactive_start_agent
        }
    else
        interactive_start_agent
    fi

    # run NVM, if present
    [ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh"
}
