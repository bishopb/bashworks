#!/usr/bin/env bash
# Adjusts terminal-related variables.
# https://unix.stackexchange.com/a/108482/50240

function terminal_load() {
    # correct for deviant terminals
	# http://www.tldp.org/HOWTO/BackspaceDelete/system.html
	if [ "gnome-terminal" = "${COLORTERM}" ]; then
		TERM=gnome
	fi

    # upgrade to 256 colors if available
    case "${TERM}" in
    xterm|putty|rxvt|Eterm|konsole|gnome|screen)
        infocmp "${TERM}-256color" >/dev/null
        if [ $? -eq 0 ]; then
            TERM="${TERM}-256color"
        fi
        ;;
    esac
}
