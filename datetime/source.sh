#!/usr/bin/env bash

function datetime_load() {
    PATH=$HOME/bin:$PATH
    source "$(module_get_path datetime)"/functions.sh
    source "$(module_get_path datetime)"/aliases.sh
}
