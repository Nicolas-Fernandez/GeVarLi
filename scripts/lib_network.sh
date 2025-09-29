#!/bin/bash

###############################################################################
### NETWORK ###
###############

# Check network statut
if ping -c 1 -W 5 google.com > /dev/null 2>&1 || \
   ping -c 1 -W 5 cloudflare.com > /dev/null 2>&1
then
    network="Online"
else
    network="Offline"
fi