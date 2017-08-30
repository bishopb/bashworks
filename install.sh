# file: install.sh
# Installs the bashworks framework, linking up the on-board dotfiles and
# arranging the environment
set -e
set +x

# setup GitHub access
function setup_github_access() {
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
    chown "${USER}" "${HOME}"/.ssh/config
    chmod 644 "${HOME}"/.ssh/config
}
setup_github_access

# install the framework, if we just downloaded the installer
function install_framework() {
    if [ ! -d "${HOME}"/bashworks ]; then
        command git clone https://github.com/bishopb/bashworks.git "${HOME}"/bashworks
    fi
}
install_framework

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
link_dotfiles

# create top-level organization
function create_directories() {
    command mkdir -p "${HOME}"/{bin,etc/{,dictionaries},tmp}
}
create_directories

# install add-ons
function install_enable_dictionary() {
    local target="${HOME}"/etc/dictionaries/enable1.txt
    local source="https://raw.githubusercontent.com/dolph/dictionary/master/enable1.txt"
    [ -e "$target" ] && return 0
    command curl -sS -o "$target" "$source"
}
function install_the_silver_searcher() {
    $(which ag >/dev/null 2>&1) && return 0
	command sudo yum install -y pcre-devel xz-devel
	command cd /usr/local/src
	command sudo git clone https://github.com/ggreer/the_silver_searcher.git
	command cd the_silver_searcher
	command sudo ./build.sh
	command sudo make install
}
function install_ripgrep() {
    $(which rg >/dev/null 2>&1) && return 0
	command sudo yum-config-manager --add-repo=https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-7/carlwgeorge-ripgrep-epel-7.repo
    command sudo yum install -y ripgrep
}
install_enable_dictionary
install_ripgrep

source "${HOME}"/.bashrc
