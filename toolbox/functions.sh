#!/usr/bin/env bash

# http://stackoverflow.com/a/34165860/2908724
function toolbox_position() {
    local n=${1:?For what column do you want position?}

    awk "{ print 1 == index(\$0, \$$n) ? 1 : index(\$0, \" \"\$$n)+1; }"
}
