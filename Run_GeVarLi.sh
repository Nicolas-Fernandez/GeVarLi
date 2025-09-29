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
# Version ________________ v.2025.09
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Bash script wrapper running GeVarLi snakefile
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.09.09
# Use ____________________ './Run_GeVarLi.sh'
###############################################################################

###############################################################################
### ABOUT ###
#############

workdir=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd) # Get working directory
version=$(<${workdir}/VERSION)                         # Get version

###############################################################################
### LIBRARIES ###
#################

source "${workdir}/scripts/lib_colors.sh"  # Define color varibales
source "${workdir}/scripts/lib_spinner.sh" # Run function with a spinner
source "${workdir}/scripts/lib_network.sh" # Check network statut
source "${workdir}/scripts/lib_conda.sh"   # Test if a conda distribution already exist

###############################################################################
### INSTALL / UPDATE WORKFLOW-CORE ###
######################################

conda_workflow_env="workflow-core"

ENV_YAML_PATH="workflow/envs/workflow-core.yaml"
CHECKSUM_DIR=".gevarli_cache"
CHECKSUM_FILE="${CHECKSUM_DIR}/workflow-core.md5"

# Check if the environment already exists and if the YAML file has changed
echo -e "\n${blue}[INFO]${nc} Check Conda environment: '${ylo}${conda_workflow_env}${nc}'..."
mkdir -p ${CHECKSUM_DIR}

if ! conda env list | grep -q "^${conda_workflow_env}\s"; then

  echo -e "\n${ylo}[ACTION]${nc} Environment does not exist. Attempting to create it..."
  if [[ ${network} == "Online" ]]; then # If network is online

    if run_with_spinner conda env create --file "${ENV_YAML_PATH}"; then
    # If succes (0)
    echo -e "\n${green}[SUCCESS]${nc} Environment created. Saving checksum..."
    if [[ "$(uname)" == "Darwin" ]]; then
        md5 -q "${ENV_YAML_PATH}" > "${CHECKSUM_FILE}"
    else
        md5sum "${ENV_YAML_PATH}" | awk '{print $1}' > "${CHECKSUM_FILE}"
    fi
    else
    # If failure (1)
    echo -e "\n${red}[ERROR]${nc} Environment creation failed. Please check the logs."
    exit 1
    fi
  else # If network is offline
    echo -e "\n${red}[ERROR]${nc} Cannot install '${ylo}${conda_workflow_env}${nc}' environment."
    echo -e "${blue}Network status${nc}: ${red}${network}${nc}."
    exit 1
  fi
else
  if [[ "$(uname)" == "Darwin" ]]; then
    CURRENT_CHECKSUM=$(md5 -q "${ENV_YAML_PATH}")
  else
    CURRENT_CHECKSUM=$(md5sum "${ENV_YAML_PATH}" | awk '{print $1}')
  fi
  STORED_CHECKSUM=$(cat "${CHECKSUM_FILE}" 2>/dev/null)

  if [[ "${CURRENT_CHECKSUM}" == "${STORED_CHECKSUM}" ]]; then
    echo -e "\n${blue}[INFO]${nc} '${ylo}${conda_workflow_env}${nc}' is up to date."
  else
    echo -e "\n${ylo}[ACTION]${nc} The YAML file has changed. Attempting to update the environment..."

    if [[ ${network} == "Online" ]]; then # If network is online

    if run_with_spinner conda env update --name "${conda_workflow_env}" --file "${ENV_YAML_PATH}" --prune; then
        echo -e "\n${green}[SUCCESS]${nc} Environment updated. Saving new checksum..."
        echo "${CURRENT_CHECKSUM}" > "${CHECKSUM_FILE}"
    else
        echo -e "\n${red}[ERROR]${nc} Environment update failed. Please check the logs."
        exit 1
    fi

    else # If network is offline
    echo -e "\n${red}[ERROR]${nc} Cannot update '${ylo}${conda_workflow_env}${nc}' environment."
    echo -e "${blue}Network status${nc}: ${red}${network}${nc}."
     exit 1
    fi
  fi
fi


###############################################################################
### ACTIVATE CONDA WORKFLOW ENVIRONMENT ###
###########################################


if conda env list | grep -q "^${conda_workflow_env}\s"; then
  echo -e "\n ${green}[SUCCESS]${nc} Activate ${ylo}${conda_workflow_env}${nc} conda environment."
  conda activate ${conda_workflow_env}
else
  echo -e "\n ${red}[ERROR]${nc} Cannot activate ${ylo}${conda_workflow_env}${nc} conda environment."
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
  --rerun-incomplete \
  --list-conda-envs

echo -e "\n ${green} > Snakemake: create conda environments${nc} \n"
snakemake \
  --directory ${workdir}/ \
  --snakefile ${workdir}/workflow/Snakefile \
  --rerun-incomplete \
  --conda-create-envs-only \
  --use-conda

echo -e "\n ${green} > Snakemake: dry run${nc} \n"
snakemake \
  --directory ${workdir}/ \
  --snakefile ${workdir}/workflow/Snakefile \
  --rerun-incomplete \
  --use-conda \
  --dry-run \
  --quiet host rules

echo -e "\n ${green} > Snakemake: run${nc} \n"
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

echo -e "\n Deactivate ${ylo}${conda_workflow_env}${nc} conda environment. \n"
conda deactivate

###############################################################################
###############################################################################
