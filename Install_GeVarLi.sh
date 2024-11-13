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
# Name ___________________ Install_GeVarLi.sh
# Version ________________ v.2024.11
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Install Snakemake and conda envirorments
# Date ___________________ 2024.10.01
# Latest modifications ___ 2024.11.13 (Fix: issues with zash shell)
# Use ____________________ ./Install_GeVarLi.sh

###############################################################################
### COLORS ###
##############
red="\033[1;31m"   # red
green="\033[1;32m" # green
ylo="\033[1;33m"   # yellow
blue="\033[1;34m"  # blue
nc="\033[0m"       # no color


###############################################################################
### ABOUT ###
#############
workdir=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd) # Get working directory
sample_test="SARS-CoV-2_Omicron-BA1_Covid-Seq-Lib-on-MiSeq_250000-reads"
gevarli_version="2024.11"                              # GeVarLi version
workflow_base_version="2024.11"                        # Workflow base version
snakemake_version="8.25.3"                             # Snakemake version

echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}ABOUT${nc} ${green}#####${nc}
${green}-----------------${nc}

${blue}Name${nc} ___________________ Install_GeVarLi.sh
${blue}Version${nc} ________________ ${ylo}${gevarli_version}${nc}
${blue}Author${nc} _________________ Nicolas Fernandez
${blue}Affiliation${nc} ____________ IRD_U233_TransVIHMI
${blue}Aim${nc} ____________________ Install Snakemake and conda environments
${blue}Date${nc} ___________________ 2024.10.01
${blue}Latest modifications${nc} ___ 2024.11.13 (Fix: issues with zash shell)
${blue}Run${nc} ____________________ ./Install_GeVarLi.sh
"


###############################################################################
### OPERATING SYSTEM ###
########################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}OPERATING SYSTEM${nc} ${green}#####${nc}
${green}----------------------------${nc}
"

# Get and print operating system 
case "$OSTYPE" in
  darwin*)  os="osx" ;;
  linux*)   os="linux" ;;
  bsd*)     os="bsd" ;;                       
  solaris*) os="solaris" ;;
  msys*)    os="windows" ;;
  cygwin*)  os="windows" ;;
  *)        os="unknown (${OSTYPE})" ;;
esac
echo -e "${blue}Operating system${nc} _______ ${red}${os}${nc}"

# Get and print shell
shell=$SHELL
echo -e "${blue}Shell${nc} __________________ ${ylo}${shell}${nc}"


###############################################################################
### HARDWARE ###
################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}HARDWARE${nc} ${green}#####${nc}
${green}--------------------${nc}
"

if [[ ${os} == "osx" ]]
then
    model_name=$(sysctl -n machdep.cpu.brand_string) # Get chip model name
    physical_cpu=$(sysctl -n hw.physicalcpu)         # Get physical cpu
    logical_cpu=$(sysctl -n hw.logicalcpu)           # Get logical cpu
    mem_size=$(sysctl -n hw.memsize)                 # Get memory size (bit)
    ram_gb=$(expr ${mem_size} \/ $((1024**3)))       # mem_size / 1024**3 = Gb
elif [[ ${os} == "linux" || ${os} == "bsd" || ${os} == "solaris" ]]
then
    model_name=$(lscpu | grep -o -E "Model name: +.+" | sed -E "s/Model name: +//")                           # Get chip model name
    physical_cpu=$(lscpu | grep -o -E "^CPU\(s\): +[0-9]+" | sed -E "s/CPU\(s\): +//")                        # Get physical cpu
    threads_cpu=$(lscpu | grep -o -E "^Thread\(s\) per core: +[0-9]+" | sed -E "s/Thread\(s\) per core: +//") # Get thread(s) per core
    logical_cpu=$(expr ${physical_cpu} \* ${threads_cpu})                                                     # Calcul logical cpu
    mem_size=$(grep -o -E "MemTotal: +[0-9]+" /proc/meminfo | sed -E "s/MemTotal: +//")                       # Get memory size (Kb)
    ram_gb=$(expr ${mem_size} \/ $((1024**2)))                                                                # mem_size / 1024**2 = Gb
else
    echo -e "Please, use UNIX operating systems like '${red}osx${nc}', '${red}linux${nc}' or '${red}WSL${nc}'"
    exit 1
fi

# Print some hardware specifications (maybe wrong with WSL...)
echo -e "                         ${ylo}Brand(R)${nc} | ${ylo}Type(R)${nc} | ${ylo}Model${nc} | ${ylo}@ Speed GHz${nc}
${blue}Chip Model Name${nc} ________ ${model_name}
${blue}Physical CPUs${nc} __________ ${red}${physical_cpu}${nc}
${blue}Logical CPUs${nc} ___________ ${red}${logical_cpu}${nc} threads
${blue}System Memory${nc} __________ ${red}${ram_gb}${nc} Gb of RAM
"


###############################################################################
### NETWORK ###
###############
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}NETWORK${nc} ${green}#####${nc}
${green}-------------------${nc}
"

# Test to ping Google or Cloudflare
if ping -c 1 -W 5 google.com > /dev/null 2>&1 || \
   ping -c 1 -W 5 cloudflare.com > /dev/null 2>&1
then
    network="Online"
    echo -e "
${blue}Network${nc} ________________ ${red}${network}${nc}
"

else
    network="Offline"
    echo -e "
${blue}Network${nc} ________________ ${red}${network}${nc}

Please, check your network conection before installation
"
    exit 1
fi


###############################################################################
### CONDA ###
#############
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}CONDA${nc} ${green}#####${nc}
${green}-----------------${nc}
"

# Test if a conda distribution already exist
if [[ ! $(command -v conda) ]]
then # If no, invit to install it and EXIT
    echo -e "
${red}No Conda installation found...${nc}

${green}GeVarLi${nc} use the free and open-source package manager ${blue}Conda${nc}.
You can install it with ${blue}Miniforge3${nc} using: '${ylo}source ./Install_Miniforge3_Conda-Mamba.sh${nc}'
"
    exit 1
else # If yes, print informations
    which conda                  # which Conda
    mamba --version              # versions Conda / Mamba
    conda config --show channels # channels
fi


###############################################################################
### WORKFLOW-BASE INSTALLATION ###
##################################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}WORKFLOW-BASE INSTALLATION${nc} ${green}#####${nc}
${green}---------------------------------------${nc}
"

# Test if latest 'workflow-base' environment exist
if [[ $(conda info --envs | grep -o -E "^workflow-base_v.${workflow_base_version}") ]]
then # If yes, do nothing
    echo -e "
Conda environment ${ylo}workflow-base_v.${workflow_base_version}${nc} it's already created!
"
else # If no, install it
    echo -e "
Conda environment ${red}workflow-base_v.${workflow_base_version}${nc} not found...
Conda environment ${ylo}workflow-base_v.${workflow_base_version}${nc} will be now created, with:

    # ${red}Snakemake${nc} (ver. 8.25.3) ${blue} ___ Workflow manager (rules)${nc}
    # ${red}Yq${nc}        (ver. 3.4.3)  ${blue} ___ YAML parser (config)${nc}
    # ${red}Rename${nc}    (ver. 1.601)  ${blue} ___ File renamer (FASTQ)${nc}
    # ${red}Graphviz${nc}  (ver. 12.0.0) ${blue} ___ Graph visualization (DAG)${nc}
"
    conda env create --file ${workdir}/workflow/environments/workflow-base_v.${workflow_base_version}.yaml > /dev/null 2>&1
fi

# Remove depreciated 'gevarli', 'snakemake' or 'workflow' old environments
old_envs="gevarli-base_v.2022.11 \
          gevarli-base_v.2022.12 \
          gevarli-base_v.2023.01 \
          gevarli-base_v.2023.02 \
          gevarli-base_v.2023.03 \
          gevarli-base_v.2023.04 \
          snakemake-base_v.2023.01 \
          snakemake-base_v.2023.02 \
          snakemake-base_v.2023.03 \
          snakemake-base_v.2023.04 \
          workflow-base_v.2023.06 \
          workflow-base_v.2024.01 \
          workflow-base_v.2024.02 \
          workflow-base_v.2024.07 \
          workflow-base_v.2024.08"

for env in ${old_envs} ; do
    conda remove --name ${env} --all --yes --quiet > /dev/null 2>&1 ;
done



###############################################################################
### SETTINGS ###
################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}SETTINGS${nc} ${green}#####${nc}
${green}--------------------${nc}
"

config_file="${workdir}/configuration/config.yaml" # Get configuration file

time_stamp_start=$(date +"%Y-%m-%d %H:%M")   # Get system: analyzes starting time
time_stamp_archive=$(date +"%Y-%m-%d_%Hh%M") # Convert time for archive (wo space)
SECONDS=0                                    # Initialize SECONDS counter

# Print some analyzes settings
echo -e "
${blue}Starting time${nc} __________ ${time_stamp_start}
${blue}Working directory${nc} ______ ${workdir}/
"

###############################################################################
### SNAKEMAKE INSTALL ###
#########################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}SNAKEMAKE PIPELINES${nc} ${green}#####${nc}
${green}-------------------------------${nc}
"

cp ${workdir}/resources/data_test/${sample_test}_R*.fastq.gz ${workdir}/resources/reads/ # use data_test fastq

# MODULES
snakefiles_list=("indexing_genomes" "gevarli")

echo -e "
${blue}## Conda Environments List ##${nc}
${blue}-----------------------------${nc}
"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# List all conda environments and their location on disk.

for snakefile in "${snakefiles_list[@]}" ; do
    echo -e "${blue}-- ${snakefile} --${nc}" ;
    conda run --name workflow-base_v.${workflow_base_version} snakemake \
        --directory ${workdir}/ \
        --snakefile ${workdir}/workflow/snakefiles/${snakefile}.smk \
        --list-conda-envs ;
done

echo -e "
${blue}## Conda Environments Setup ##${nc}
${blue}------------------------------${nc}
"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# If specified, only creates the job-specific conda environments then exits.
## The --use-conda flag must also be set.
# If defined in the rule, run job in a conda environment.

for snakefile in "${snakefiles_list[@]}" ; do
    echo -e "${blue}-- ${snakefile} --${nc}" ;
    conda run --name workflow-base_v.${workflow_base_version} snakemake \
        --directory ${workdir}/ \
        --snakefile ${workdir}/workflow/snakefiles/${snakefile}.smk \
        --conda-create-envs-only \
	--use-conda ;
done

echo -e "
${blue}## Dry Run ##${nc}
${blue}-------------${nc}
"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# If defined in the rule, run job in a conda environment.
# Do not execute anything, and display what would be done.
## If very large workflow, use --dry-run --quiet to just print a summary of the DAG of jobs.
# Do not output any progress or rule information.

for snakefile in "${snakefiles_list[@]}" ; do
    echo -e "${blue}-- ${snakefile} --${nc}" ;
    conda run --name workflow-base_v.${workflow_base_version} snakemake \
        --directory ${workdir}/ \
        --snakefile ${workdir}/workflow/snakefiles/${snakefile}.smk \
        --use-conda \
        --dry-run \
	--quiet rules \
	--quiet host ;
done


###############################################################################
### CLEAN and SAVE ###
######################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}CLEAN & SAVE${nc} ${green}#####${nc}
${green}------------------------${nc}
"

# Cleanup
rm -f ${workdir}/resources/reads/${sample_test}_R*.fastq.gz > /dev/null 2>&1

# Timer
time_stamp_end=$(date +"%Y-%m-%d %H:%M") # Get date / hour ending analyzes
elapsed_time=${SECONDS}                  # Get SECONDS counter 
minutes=$((${elapsed_time}/60))          # / 60 = minutes
seconds=$((${elapsed_time}%60))          # % 60 = seconds

# Print timer
echo -e "
${blue}Start time${nc} _____________ ${time_stamp_start}
${blue}End time${nc} _______________ ${time_stamp_end}
${blue}Processing time${nc} ________ ${ylo}${minutes}${nc} minutes and ${ylo}${seconds}${nc} seconds elapsed

${green}------------------------------------------------------------------------${nc}
"


###############################################################################
