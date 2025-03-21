#!/bin/bash

###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ Run_GeVarLi.sh
# Version ________________ v.2025.03
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Bash script running GeVarLi snakefile
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.03.12
# Use ____________________ '. Run_GeVarLi.sh'
###############################################################################

###############################################################################
### ABOUT ###
#############

workdir=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd) # Get working directory
version=$(<${workdir}/VERSION_temp.txt)                # Get version

blue="\033[1;34m"  # blue
green="\033[1;32m" # green
red="\033[1;31m"   # red
ylo="\033[1;33m"   # yellow
nc="\033[0m"       # no color

###############################################################################
### NETWORK ###
###############

# Test if network is online
if ping -c 1 -W 5 google.com > /dev/null 2>&1 || \
   ping -c 1 -W 5 cloudflare.com > /dev/null 2>&1
then
    network="Online"
else
    network="Offline"
fi

###############################################################################
### CONDA ###
#############

# Test if a conda distribution already exist
if [[ ! $(command -v conda) ]]
then # If no, invitation message to install it
    echo -e "
    ${red}No Conda distribution found.${nc}
    ${blue}GeVarLi${nc} use the free and open-source package manager ${ylo}Conda${nc}.
    Read documentation at: ${green}https://transvihmi.pages.ird.fr/nfernandez/GeVarLi/en/pages/installations/${nc}"
    return 0
else # If yes, intern shell source conda
    echo -e "\n ${green}Conda${nc} distribution found and sourced."
    source ~/miniforge3/etc/profile.d/conda.sh 2> /dev/null                            # local user with miniforge3
    source ~/mambaforge/etc/profile.d/conda.sh 2> /dev/null                            # local user with mambaforge ¡ Deprecated !
    source ~/miniconda3/etc/profile.d/conda.sh 2> /dev/null                            # local user with miniconda3 ¡ Deprecated !
    source /usr/local/bioinfo/miniconda3-23.10.0-1/etc/profile.d/conda.sh 2> /dev/null # iTROP HPC server (conda 23.11.0)

###############################################################################
### SPINNER ###
###############

# Function to run a command with a spinner
run_with_spinner() {
    ("$@" > /dev/null 2>&1) &
    local pid=$!
    disown $pid 2>/dev/null

    local spinner=( "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏" )
    local i=0
    while kill -0 $pid 2>/dev/null; do
        # Clear the line
        printf "\r\033[K%s Please wait" "${spinner[$i]}"
        i=$(( (i+1) % ${#spinner[@]} ))
        sleep 0.1
    done
    wait $pid
    local exit_code=$?
    # Clear the spinner line
    printf "\r\033[K"
    if [ $exit_code -eq 0 ]; then
        echo "✔ Job done!"
    else
        echo "✖ Job failed with exit code $exit_code."
    fi
}

###############################################################################
### WORKFLOW-CORE ###
#####################

# Test if 'workflow-core' environment exist.
if conda env list | grep -q "^workflow-core"
then # If 'exist'
    echo -e "\n ${ylo}Workflow-Core${nc} conda environment already created."
    #  Test if 'workflow-core' environment is up-to-date.
    ENV_YAML="${workdir}/workflow/envs/workflow-core.yaml"
    CURRENT_ENV=$(conda env export --no-builds --name workflow-core | grep -v '^prefix:')
    EXPECTED_ENV=$(grep -v '^prefix:' "$ENV_YAML")
    if false #diff <(echo "$CURRENT_ENV") <(echo "$EXPECTED_ENV") > /dev/null
    then # If 'up-to-date'
        echo -e "\n ${ylo}Workflow-Core${nc} environment is already up-to-date."
    else # If 'not' up-to-date
        if [[ $network == "Offline" ]]
        then # If 'offline'
            echo -e "\n Cannot update ${ylo}Workflow-Core${nc} environment.
                     ${green}Network${nc}: ${red}${network}${nc}."
        else # If 'online'
            echo -e "\n Updating ${ylo}Workflow-Core${nc} environment. \n"
            run_with_spinner \
                conda env update \
                    --prune \
                    --name workflow-core \
                    --file $ENV_YAML
        fi
    fi
else # If 'not' exist
    echo -e "\n ${ylo}Workflow-Core${nc} conda environment not found."
    if [[ $network == "Online" ]]
    then # If 'online'
        echo -e "\n ${ylo}Workflow-Core${nc} conda environment will be create, with:
    > ${red}Snakemake${nc}
    > ${red}Snakedeploy${nc}   
    > ${red}Snakemake Slurm plugin${nc} \n"
    run_with_spinner \
	    conda env create \
	        --file ${workdir}/workflow/envs/workflow-core.yaml \
	        --quiet
        else # If 'offline'
            echo -e "\n Cannot install ${ylo}Workflow-Core${nc} environment.
                     ${green}Network${nc}: ${red}${network}${nc}".
    fi
fi

###############################################################################
### ACTIVATE WORKFLOW-CORE ###
###############################

# Active workflow-core conda environment.
if conda env list | grep -q "^workflow-core"
then
    echo -e "\n Activate ${ylo}Workflow-Core${nc} conda environment."
    conda activate workflow-core
else
    echo -e "\n Cannot activate ${ylo}Workflow-Core${nc} conda environment."
    return 0
fi

###############################################################################
### RUN SNAKEMAKE ###
#####################

echo -e "
${blue}------------------------------------------------------------------------${nc}
${blue}#####${nc} ${red}Run Snakemake${nc} ${blue}#####${nc}
${blue}-------------------------${nc}
"

echo -e "\n ${green} > Snakemake: unlock working directory${nc} \n"
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --rerun-incomplete \
    --unlock

echo -e "\n ${green} > Snakemake: list conda environments${nc} \n"
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --list-conda-envs

echo -e "\n ${green} > Snakemake: create conda environments${nc} \n"
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --conda-create-envs-only \
    --use-conda

echo -e "\n ${green} > Snakemake: dry run${nc} \n"
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --use-conda \
    --dry-run \
    --quiet host rules

echo -e "\n ${green} > Snakemake: run${nc} \n"
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile\
    --cores ${max_threads} \
    --resources mem_gb=${max_memory} \
    --rerun-incomplete \
    --keep-going \
    --use-conda \
    --quiet host progress

###############################################################################
### DEACTIVATE WORKFLOW-CORE ###
#################################

# Deactive workflow-core conda environment.
echo -e "\n Deactivate ${ylo}Workflow-Core${nc} conda environment."
conda deactivate

###############################################################################