# file: install.sh
# Installs the bashworks framework, linking up the on-board dotfiles and
# arranging the environment

set -e
set +x

[ -d "${HOME}"/tmp ] || command mkdir -p "${HOME}"/tmp

# nice little helper
function run() {
    local tmpfile rc
    tmpfile=$(mktemp)
    "${@}" &>>"${tmpfile}" && rc=$? || rc=$?
    { echo "[$(date)] ${rc} ${@}"; cat "${tmpfile}"; } >> "${HOME}"/tmp/bashworks.install.log
    rm -f "${tmpfile}"
}

# setup GitHub access
function setup_github_access() {
    [ -d "${HOME}/.ssh" ] || mkdir "${HOME}/.ssh"
    [ -e "${HOME}/.ssh/config" ] || touch "${HOME}/.ssh/config"

    local keyfile="${HOME}/.ssh/id_rsa.bishopb.github"
    if [ ! -f "${keyfile}" ]; then
        echo 'Personal GitHub key missing: using a stub.' >&2
        command touch "${keyfile}"
    fi
    if ! $(command grep -q 'Host bishopb.github.com' "${HOME}/.ssh/config"); then
        cat >> "${HOME}/.ssh/config" <<EOCONFIG
Host bishopb.github.com
    HostName github.com
    User git
    IdentitiesOnly yes
    IdentityFile ${keyfile}
EOCONFIG
    fi
    command chown "${USER}" "${HOME}"/.ssh/config
    command chmod 644 "${HOME}"/.ssh/config
}
run setup_github_access

# install the framework, if we just downloaded the installer
function install_framework() {
    if [ ! -d "${HOME}"/bashworks ]; then
        command git clone https://github.com/bishopb/bashworks.git "${HOME}"/bashworks
    fi
}
run install_framework

# link the dotfiles
function link_dotfiles() {
    for src in "${HOME}"/bashworks/dotfiles/*; do
        tgt="${HOME}/.${src##*/}"
        if [ -e "${tgt}" ]; then
            command mv "${tgt}" "${tgt}.backup"
        fi
        if [ ! -e "${tgt}" ]; then
            command ln -s "${src}" "${tgt}"
        fi
    done
}
run link_dotfiles

# create top-level organization
function create_directories() {
    command mkdir -p "${HOME}"/{bin,etc/{,dictionaries},tmp}
}
run create_directories || true

# install add-ons
function install_enable_dictionary() {
    local target="${HOME}"/etc/dictionaries/enable1.txt
    local source="https://raw.githubusercontent.com/dolph/dictionary/master/enable1.txt"
    [ -e "$target" ] && return 0
    command curl -sS -o "$target" "$source"
}
function install_ripgrep() {
    $(which rg >/dev/null 2>&1) && return 0
    command sudo yum-config-manager --add-repo=https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-7/carlwgeorge-ripgrep-epel-7.repo
    command sudo yum install -y ripgrep
}
{ run install_enable_dictionary; run install_ripgrep; } &

# re-run the bash rc to catch up this particular session
[ -d "${HOME}/.bashrc" ] && source "${HOME}/.bashrc"
