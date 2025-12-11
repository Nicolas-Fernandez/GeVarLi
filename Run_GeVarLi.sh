#!/bin/bash
set -euo pipefail

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
# Version ________________ v.2025.12
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Bash script wrapper running GeVarLi snakefile
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.12.11
# Use ____________________ 'bash Run_GeVarLi.sh'
###############################################################################

###############################################################################
### ABOUT ###
#############

workdir=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd) # Get working directory
version=$(<${workdir}/VERSION)                         # Get version
conda_workflow_env="workflow-core"

###############################################################################
### LIBRARIES ###
#################

source "${workdir}/scripts/lib_colors.sh"   # Define color varibales
source "${workdir}/scripts/lib_spinner.sh"  # Run a function with a spinner
source "${workdir}/scripts/lib_network.sh"  # Check network statut
source "${workdir}/scripts/lib_conda.sh"    # Setup conda
source "${workdir}/scripts/lib_workflow.sh" # Setup workflow


###############################################################################
### SETUP CONDA ###
###################

if ! setup_conda; then
    exit 1
fi

###############################################################################
### MANAGE WORKFLOW-CORE ENVIRONMENT ###
########################################

if ! setup_workflow; then
    exit 1
fi

###############################################################################
### ACTIVATE CONDA WORKFLOW ENVIRONMENT ###
###########################################

if conda env list | grep -q "^${conda_workflow_env}\s"; then
    printf "
    [${GREEN}SUCCES${NC}]: Activate ${YLO}${conda_workflow_env}${NC} conda environment.
    "
    conda activate ${conda_workflow_env}
else
    printf "
    [${RED}ERROR${NC}]: Cannot activate ${YLO}${conda_workflow_env}${NC} conda environment.
    "
    return 0
fi

###############################################################################
### RUN SNAKEMAKE ###
#####################

printf "
${BLUE}------------------------------------------------------------------------${NC}
${BLUE}#####${NC} ${RED}Run Snakemake${NC} ${BLUE}#####${NC}
${BLUE}-------------------------${NC}
"

printf "
${GREEN} > Snakemake: unlock working directory${NC}
"
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --rerun-incomplete \
    --unlock

printf "
${GREEN} > Snakemake: list conda environments${NC}
"
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --rerun-incomplete \
    --list-conda-envs

printf "
${GREEN} > Snakemake: create conda environments${NC}
"
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --rerun-incomplete \
    --conda-create-envs-only \
    --use-conda

printf "
${GREEN} > Snakemake: dry run${NC}
"
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --rerun-incomplete \
    --use-conda \
    --dry-run \
    --quiet host rules

printf "
${GREEN} > Snakemake: run${NC}
"
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --rerun-incomplete \
    --keep-going \
    --use-conda \
    --jobs unlimited \
    --quiet host progress

###############################################################################
### DEACTIVATE CONDA WORKFLOW ENVIRONMENT ###
#############################################

printf "
Deactivate ${YLO}${conda_workflow_env}${NC} conda environment.
"
conda deactivate

###############################################################################
###############################################################################
