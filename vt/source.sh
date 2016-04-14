#!/usr/bin/env bash

function vt_load() {
    PATH=/opt/site:$HOME/bin:$PATH
    source "$(module_get_path vt)"/functions.sh
    source "$(module_get_path vt)"/aliases.sh
}
