#!/usr/bin/env bash

function toolbox_load() {
    PATH=$HOME/bin:$PATH
    source "$(module_get_path toolbox)"/functions.sh
}
