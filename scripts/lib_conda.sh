#!/bin/bash

###############################################################################
### CONDA ###
#############
# Name ___________________ lib_conda.sh
# Version ________________ v.2025.12
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Setup conda
# Date ___________________ 2025.09.30
# Latest modifications ___ 2025.11.13
# Use ____________________ source lib_conda.sh
###############################################################################

setup_conda() {
    if command -v conda &> /dev/null # Test if a conda distribution exist
    then # If yes, source it
        local conda_base=$(conda info --base)
        if [ -f "${conda_base}/etc/profile.d/conda.sh" ]
        then
            source "${conda_base}/etc/profile.d/conda.sh"
            printf "
    [${GREEN}SUCCES${NC}]: ${BLUE}Conda${NC} distribution found and sourced.
            "
        else
            printf "
    [${RED}ERROR${NC}]: Found ${BLUE}Conda${NC}, but could not source the ${YLO}'conda.sh'${NC} script.

        Looked for it at: ${YLO}'${conda_base}/etc/profile.d/conda.sh'${NC}
            "
            return 1
        fi
    else # If no, invitation to install it
        printf "
    [${RED}ERROR${NC}]: No ${BLUE}Conda${NC} distribution found.

    [${YLO}INFO${NC}]: ${BLUE}GeVarLi${NC} use the free and open-source package manager: ${BLUE}Conda${NC}.
        Please make sure ${BLUE}conda${NC} is installed and that you have initialized your shell with ${YLO}'conda init'${NC}.

    [${YLO}INFO${NC}]: Read documentation at: ${BLUE}https://transvihmi.pages.ird.fr/nfernandez/GeVarLi/en/pages/installations/${NC}
        "
        return 1
    fi
    return 0
}