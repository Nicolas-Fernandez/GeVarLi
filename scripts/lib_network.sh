#!/bin/bash

###############################################################################
### NETWORK ###
###############
# Name ___________________ lib_network.sh
# Version ________________ v.2025.12
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Check network statut
# Date ___________________ 2025.09.30
# Latest modifications ___ 2025.11.13
# Use ____________________ source lib_network.sh
###############################################################################

check_network_status() {
    local wait_time=5 # at least 5 seconds for our South partners
    # Ping Google and Cloudflare
    if ping -c 1 -W ${wait_time} google.com > /dev/null 2>&1 || \
    ping -c 1 -W ${wait_time} cloudflare.com > /dev/null 2>&1
    then
        return 0 # Online
    else
        return 1 # Offline
    fi
}
