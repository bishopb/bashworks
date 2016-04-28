#!/usr/bin/env bash

# process_ppid -- Show parent PID
# $1 - The process whose parent you want to show, default to $$
# see http://stackoverflow.com/a/36922050/2908724
function process_ppid() {
    local stat=($(</proc/${1:-$$}/stat))
    echo ${stat[3]}
}

# process_apid -- Show all ancestor PID
# $1 - The process whose ancestors you want to show, default to $$
# $2 - Stop when you reach this ancestor PID, default to 1
# see http://stackoverflow.com/a/36922050/2908724
function process_apid() {
    local ppid=$(process_ppid ${1:$$})
    while [ 0 -lt $ppid -a ${2:-1} -ne $ppid ]; do
        echo $ppid
        ppid=$(process_ppid $ppid)
    done
}
