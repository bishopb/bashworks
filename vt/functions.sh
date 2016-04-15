#!/usr/bin/env bash

function vt_site() {
    local src=$1
    local dst=/opt/site
    local alt=$(find /opt -maxdepth 1 -type d -name site.* | sort)

    # if no source is given, show the current linkages
    if [ -z "$src" ]; then
        if [ -L "$dst" ]; then
            echo "$dst links to $(readlink $dst)"
        elif [ -e "$src" ]; then
            echo "$dst exists, but isn't a link."
            echo "Therefore, $FUNCNAME cannot select site implementations."
            return 0
        fi

        if [ -z "$alt" ]; then
            echo "There are no site implementation alternatives."
            echo "Clone into $dst/site.* to select from alternatives."
            return 0
        else
            local noop="Leave as is"
            local undo="Unlink"
            local PS3="Alternative? "
            echo ""
            select dir in "$noop" "$undo" $alt; do
            case "$dir" in
                $noop) echo "No changes made."
                    return 0
                    ;;
                 $undo) rm -f "$dst"
                     echo "Unlinked"
                     return 0
                     ;;
                 *) echo ""
                    $FUNCNAME "$dir"
                    return $?
                    ;;
            esac
            done
        fi
        # NOTREACHED
    fi

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

    echo "Link $src to $dst"

    # link them up
    command ln -s "$src" "$dst" || {
        echo "Failed to link $src -> $dst" >&2
        return 3
    }

    # restart dependents
    sudo service httpd restart
    sudo service php-fpm restart
}

function vt_add() {
    local branch=${1:?What branch would you like to create locally (can be new)?}
    local target="/opt/site.$1"
    git clone git@github.com:VoiceThread/site.git "$target"
    cd "$target"
    git checkout -b "$1"
}

function vt_remove() {
    local branch=${1:?What branch would you like to locally remove?}
    sudo rm -rf /opt/site."$1"
}

function vt_test_job_in_edit() {
    local jobn=${1:?What edit job would you like to test?}
    local file=$(jobs $jobn | awk '{print $4}')
    if [ -e "$file" ]; then
        ( set -x; vt_clean_logs; vt test:reset; vt test:run "$file" )
    fi
}

function vt_clean_logs() {
    sudo truncate -cs 0 \
        /debug/{errors,foreman,propel}.log* \
        /debug/metrics.{json,log} \
        /debug/rollback_warnings /debug/trace.out
    sudo rm -f /debug/apache_coredumps/* /debug/failed/* /debug/notification/*
}
