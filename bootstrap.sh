# Load the framework
source "${HOME}"/bashworks/module/source.sh
module_repo "${HOME}"/bashworks

# Load common tools
module toolbox

# When interactive, load the stuff I use
[[ $- = *i* ]] && { 
    module interactive
    module vt
}
