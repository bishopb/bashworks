# file: install.sh
# Installs the bashworks framework, linking up the on-board dotfiles and
# arranging the environment
set -e
set +x

# install the framework if not present
if [ ! -d "${HOME}"/bashworks ]; then
    command git clone https://github.com/bishopb/bashworks.git "${HOME}"/bashworks
fi

# link the dotfiles
for src in "${HOME}"/bashworks/dotfiles/*; do
    tgt="${HOME}/.${src##*/}"
    if [ -e "${tgt}" ]; then
        command rm --interactive "${tgt}"
    fi
    if [ ! -e "${tgt}" ]; then
        command ln -s "${src}" "${tgt}"
    fi
done

# create top-level organization
mkdir -p "${HOME}"/{bin,etc/{,dictionaries},tmp}

# install add-ons
function install_enable_dictionary() {
    local target="${HOME}"/etc/dictionaries/enable1.txt
    local source="https://raw.githubusercontent.com/dolph/dictionary/master/enable1.txt"
    [ -e "$target" ] && return 0
    curl -sS -o "$target" "$source"
}
function install_the_silver_searcher() {
    $(which ag >/dev/null 2>&1) && return 0
	sudo yum install -y pcre-devel xz-devel
	cd /usr/local/src
	sudo git clone https://github.com/ggreer/the_silver_searcher.git
	cd the_silver_searcher
	sudo ./build.sh
	sudo make install
}
install_enable_dictionary
install_the_silver_searcher
