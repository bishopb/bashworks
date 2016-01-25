#!/usr/bin/env bash

function vt_load() {
    PATH=$HOME/bin:$PATH
    source "$(module_get_path vt)"/functions.sh
}
