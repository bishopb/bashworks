#!/usr/bin/env bash

function vt_load() {
    PATH=/opt/site:$HOME/bin:$PATH
    source "$(module_get_path vt)"/functions.sh
    source "$(module_get_path vt)"/aliases.sh
}

function vt_post_load() {
    [ -d "${HOME}"/.aws ] || {
        echo "Creating AWS configuration directory" >&2
        mkdir "${HOME}"/.aws;
    }
    [ -r "${HOME}"/.aws/config ] || {
        echo "Creating AWS configuration file" >&2
        touch "${HOME}"/.aws/config;
        chmod 600 "${HOME}"/.aws/config;
        echo "[profile bishop]"   >> "${HOME}"/.aws/config;
        echo "region = us-east-1" >> "${HOME}"/.aws/config;
    }
    [ -r "${HOME}"/.aws/credentials ] || {
        echo "Creating empty AWS credentials container" >&2
        touch "${HOME}"/.aws/credentials;
        chmod 600 "${HOME}"/.aws/credentials;
        echo "[bishop]"                 >> "${HOME}"/.aws/credentials;
        echo "aws_access_key_id = "     >> "${HOME}"/.aws/credentials;
        echo "aws_secret_access_key = " >> "${HOME}"/.aws/credentials;
    }
    export AWS_PROFILE=bishop
}
