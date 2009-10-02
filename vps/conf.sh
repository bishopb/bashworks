#--------------------------
## Prompts the admin for the host ip to use
#--------------------------
function vps_conf_interactive_network() {
    if [[ -z $VPS_INTERNET_MAP ]] || [[ -z $VPS_INTRANET_MAP ]]; then
        print_warning "VPS_INTERNET_MAP and VPS_INTRANET_MAP are not set, \
                       cannot configure network"
    fi

    local choice=""
    local line=""
    
    print_info "Please select the network for this VPS"

    for index in ${!VPS_INTERNET_MAP[@]}; do
        line="${index}) "
        
        if [[ -n $VPS_LABEL_MAP ]]; then
            line+="${VPS_LABEL_MAP[$index]} "
        fi

        line+="${VPS_INTERNET_MAP[$index]} "
        line+="vps_ip: ${VPS_INTRANET_MAP[$index]}${vps_id}"

        echo $line
    done

    read -p "Choice number> " choice

    vps_intranet=${VPS_INTRANET_MAP[$choice]}
    vps_ip=${vps_intranet}${vps_id}
    vps_host_ip=${VPS_INTERNET_MAP[$choice]}
}

function vps_conf_interactive() {
    unset vps_ip
    unset vps_intranet
    unset vps_host_ip

    conf_interactive vps
    vps_conf_interactive_network
}