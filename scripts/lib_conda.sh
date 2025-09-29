#!/bin/bash

###############################################################################
### CONDA ###
#############

# Test if a conda distribution already exist
if [[ ! $(command -v conda) ]]
then
    # If no, invitation message to install it
    echo -e "
    ${red}No Conda distribution found.${nc}

    ${blue}GeVarLi${nc} use the free and open-source package manager ${ylo}Conda${nc}.
    
    ${blue}Read documentation${nc} at: ${green}https://transvihmi.pages.ird.fr/nfernandez/GeVarLi/en/pages/installations/${nc}
    "
    return 0
else
    # If yes, intern shell source conda
    echo -e "\n ${green}Conda${nc} distribution found and sourced."
    source ~/miniforge3/etc/profile.d/conda.sh 2> /dev/null                            # local user with miniforge3
    source ~/mambaforge/etc/profile.d/conda.sh 2> /dev/null                            # local user with mambaforge ¡ Deprecated !
    source ~/miniconda3/etc/profile.d/conda.sh 2> /dev/null                            # local user with miniconda3 ¡ Deprecated !
    source /usr/local/bioinfo/miniconda3-23.10.0-1/etc/profile.d/conda.sh 2> /dev/null # iTROP HPC server (conda 23.11.0)
fi
