#!/usr/bin/env bash

# fun_check_spinid -- Ask Wheel of Fortune if a given login's Spin ID won!
# $1 username
# $2 password
function fun_check_spinid() {
    local user=${1:?Missing username}
    local pass=${2:?Missing password}
    local cookiejar
    cookiejar=$(mktemp)
    curl -sSk 'https://www.wheeloffortune.com/account/Login' \
        -H 'origin: http://www.wheeloffortune.com' \
        -H 'accept-encoding: gzip, deflate, br' \
        -H 'accept-language: en-US,en;q=0.8' \
        -H 'pragma: no-cache' \
        -H 'upgrade-insecure-requests: 1' \
        -H 'user-agent: Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 Chrome/56.0.2924.87 Safari/537.36' \
        -H 'content-type: application/x-www-form-urlencoded' \
        -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
        -H 'cache-control: no-cache' \
        -H 'authority: www.wheeloffortune.com' \
        -H 'referer: http://www.wheeloffortune.com/' \
        -d "LoginEmail=$user&LoginPassword=$pass&ReturnUrl=%2F" \
        -c "$cookiejar" \
        --compressed -o /dev/null

    curl -sSk 'https://www.wheeloffortune.com/Widget/SpinTestModal' \
        -H 'pragma: no-cache' \
        -H 'accept-encoding: gzip, deflate, sdch, br' \
        -H 'x-requested-with: XMLHttpRequest' \
        -H 'user-agent: Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 Chrome/56.0.2924.87 Safari/537.36' \
        -H 'accept-language: en-US,en;q=0.8' \
        -H 'accept: text/html, */*; q=0.01' \
        -H 'cache-control: no-cache' \
        -H 'authority: www.wheeloffortune.com' \
        -H 'referer: https://www.wheeloffortune.com/home' \
        -b "$cookiejar" \
        --compressed | grep -q 'Sorry'
    rc=$?
    rm -f "$cookiejar"

    if [ 0 -eq $rc ]; then
        echo "$1 did not win"
    else
        echo "$1 may have won"
    fi
}
