# Load the framework
source ~/bashworks/module/source.sh
module_repo ~/bashworks

# Load common tools
module toolbox

# When interactive, load the stuff I use and set a compact prompt
[[ $- = *i* ]] && { 
    module interactive vt
}
