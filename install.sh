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
mkdir -p "${HOME}"/{bin,etc/{,dictionaries}}

# install add-ons
curl -sS -o "${HOME}"/etc/dictionaries/enable1.txt \
    https://raw.githubusercontent.com/dolph/dictionary/master/enable1.txt
