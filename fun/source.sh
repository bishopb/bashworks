#!/usr/bin/env bash

function fun_load() {
    source "$(module_get_path fun)"/functions.sh
    source "$(module_get_path fun)"/aliases.sh
}
