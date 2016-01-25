#!/usr/bin/env bash

function vt_site() {
    local src=${1:?What is the path to site code?}
    local dst=/opt/site

    # ensure src is a reasonable directory
    if [ -d "$src" ]; then
        if [ ! -e "$src/rewrite.conf" ]; then
            echo "Did not find expected $src/rewrite.conf" >&2
            return 2
        fi
    else
        echo "$src is not a directory" >&2
        return 1
    fi

    # remove extant link to /opt/site
    if [ -e "$dst" ]; then
        if [ -L "$dst" ]; then
            rm "$dst"
        else
            echo "$dst is not a link, halting without action." >&2
            return 1
        fi
    fi

    # link them up
    command ln -s "$src" "$dst" || {
        echo "Failed to link $src -> $dst" >&2
        return 3
    }

    # restart dependents
    sudo service httpd restart
}
