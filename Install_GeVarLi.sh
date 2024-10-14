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
# Version ________________ v.2024.10
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ GeVarLi Conda environments pre-installion
# Date ___________________ 2024.10.01
# Latest modifications ___ 2024.10.01 (Init)
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
gevarli_version="2024.10"                              # GeVarLi version
workflow_base_version="2024.08"                        # Workflow base version
snakemake_version="8.16.0"                             # Snakemake version
nextclade_version="3.8.2"                              # Nextclade version

echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}ABOUT${nc} ${green}#####${nc}
${green}-----------------${nc}

${blue}Name${nc} ___________________ Install_GeVarLi.sh
${blue}Version${nc} ________________ ${ylo}${gevarli_version}${nc}
${blue}Author${nc} _________________ Nicolas Fernandez
${blue}Affiliation${nc} ____________ IRD_U233_TransVIHMI
${blue}Aim${nc} ____________________ GeVarLi Conda environments pre-installation
${blue}Date${nc} ___________________ 2024.10.01
${blue}Latest modifications${nc} ___ 2024.10.01 (Init)
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

if curl -s --head --request GET http://www.google.com --max-time 5 > /dev/null || \
   curl -s --head --request GET http://www.cloudflare.com --max-time 5 > /dev/null;
then
    network="Online"
else
    network="Offline"
fi

echo -e "
${blue}Network${nc} ________________ ${red}${network}${nc}
"


###############################################################################
### CONDA INIT ###
##################

# Intern shell source conda
source ~/miniforge3/etc/profile.d/conda.sh 2> /dev/null                            # local user with miniforge3
source ~/mambaforge/etc/profile.d/conda.sh 2> /dev/null                            # local user with mambaforge ¡ Deprecated !
source ~/miniconda3/etc/profile.d/conda.sh 2> /dev/null                            # local user with miniconda3 ¡ Deprecated !
source /usr/local/bioinfo/miniconda3-23.10.0-1/etc/profile.d/conda.sh 2> /dev/null # iTROP HPC server (conda 23.11.0)


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
then
    echo -e "
Conda environment ${ylo}workflow-base_v.${workflow_base_version}${nc} it's already created!
"
else # Test network conection
    if [[ ${network} = "Online" ]]
    then
        echo -e "
Conda environment ${red}workflow-base_v.${workflow_base_version}${nc} not found...
Conda environment ${ylo}workflow-base_v.${workflow_base_version}${nc} will be now created, with:

    # ${red}Snakemake${nc} (ver. 8.16.0) ${blue} ___ Workflow manager (rules)${nc}
    # ${red}Mamba${nc}     (ver. 1.5.8)  ${blue} ___ Packages manager (conda environments)${nc}
    # ${red}Yq${nc}        (ver. 3.4.3)  ${blue} ___ YAML parser (config)${nc}
    # ${red}Rename${nc}    (ver. 1.601)  ${blue} ___ File renamer (FASTQ)${nc}
    # ${red}Graphviz${nc}  (ver. 12.0.0) ${blue} ___ Graph visualization (DAG)${nc}
"
        conda env create -f ${workdir}/workflow/environments/workflow-base_v.${workflow_base_version}.yaml &> /dev/null
    else
	echo -e "
Conda environment ${red}workflow-base_v.${workflow_base_version}${nc} not found...
${blue}GeVarLi${nc} is running in ${red}${network}${nc} mode.
Please, check your network conection!
"
    fi
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
          workflow-base_v.2024.07"

for env in ${old_envs} ; do
    conda remove --name ${env} --all --yes --quiet 2> /dev/null ;
done


###############################################################################
### CONDA ACTIVATION ###
########################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}CONDA ACTIVATION${nc} ${green}#####${nc}
${green}----------------------------${nc}
"

echo -e "conda activate ${ylo}workflow-base_v.${workflow_base_version}${nc}"

conda activate workflow-base_v.${workflow_base_version}


###############################################################################
### SETTINGS ###
################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}SETTINGS${nc} ${green}#####${nc}
${green}--------------------${nc}
"

snakemake_version=$(snakemake --version)                        # Snakemake version (ver. 8.14.0)
conda_version=$(conda --version | sed 's/conda //')             # Conda version     (ver. 24.5.07)
mamba_version=$(mamba --version | head -n 1 | sed 's/mamba //') # Mamba version     (ver. 1.5.8)
yq_version=$(yq --version | sed 's/yq //')                      # Yq version        (ver. 3.4.3)
rename_version="1.601"                                          # Rename version    (ver. 1.601)
graphviz_version="11.0.0"                                       # GraphViz version  (ver. 11.0.0)
#graphviz_version=$#(dot -V | sed 's/dot - graphviz version //') # GraphViz version  (ver. 11.0.0)

fastq=$(expr $(ls -l ${workdir}/resources/reads/*.fastq.gz 2> /dev/null | wc -l)) # Get fastq.gz files count
if [[ "${fastq}" == "0" ]]                                                        # If no sample,
then                                                                              # Need at least 1 sample
    cp ${workdir}/resources/data_test/${sample_test}_R*.fastq.gz ${workdir}/resources/reads/ # use data_test fastq
fi

config_file="${workdir}/configuration/config.yaml" # Get configuration file

conda_frontend=$(yq -Mc '.conda.frontend' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//') # Get user config: conda frontend
max_threads=$(yq -Mr '.resources.cpus' ${config_file}) # Get user config: max threads
max_memory=$(yq -Mr '.resources.ram' ${config_file})   # Get user config: max memory (Gb)
memory_per_job=$(expr ${max_memory} \/ ${max_threads}) # Calcul maximum memory usage per job

time_stamp_start=$(date +"%Y-%m-%d %H:%M")   # Get system: analyzes starting time
time_stamp_archive=$(date +"%Y-%m-%d_%Hh%M") # Convert time for archive (wo space)
SECONDS=0                                    # Initialize SECONDS counter

# Print some analyzes settings
echo -e "
${blue}Max threads${nc} ____________ ${red}${max_threads}${nc} of ${ylo}${logical_cpu}${nc} threads available
${blue}Max memory${nc} _____________ ${red}${max_memory}${nc} of ${ylo}${ram_gb}${nc} Gb available
${blue}Jobs memory${nc} ____________ ${red}${memory_per_job}${nc} Gb per job

${blue}Starting time${nc} __________ ${time_stamp_start}
${blue}Working directory${nc} ______ ${workdir}/

${blue}Snakemake version${nc} ______ ${ylo}${snakemake_version}${nc}
${blue}Conda version${nc} __________ ${ylo}${conda_version}${nc}
${blue}Conda frontend${nc} _________ ${ylo}${conda_frontend}${nc}
${blue}Mamba version${nc} __________ ${ylo}${mamba_version}${nc}  
"


###############################################################################
### SNAKEMAKE INSTALL ###
#########################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}SNAKEMAKE PIPELINES${nc} ${green}#####${nc}
${green}-------------------------------${nc}
"

# MODULES
snakefiles_list="indexing_genomes gevarli"

echo -e "
${blue}## Conda Environments List ##${nc}
${blue}-----------------------------${nc}
"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# List all conda environments and their location on disk.

for snakefile in ${snakefiles_list} ; do
    echo -e "${blue}-- ${snakefile} --${nc}" ;
    snakemake \
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
# Re-run all jobs the output of which is recognized as incomplete.
# If defined in the rule, run job in a conda environment.
# If mamba package manager is not available, or if you still prefer to use conda, you can enforce that with this setting.
## Default "mamba", recommended because much faster !
# If specified, only creates the job-specific conda environments then exits. The –use-conda flag must also be set.

for snakefile in ${snakefiles_list} ; do
    echo -e "${blue}-- ${snakefile} --${nc}" ;
    snakemake \
        --directory ${workdir}/ \
        --snakefile ${workdir}/workflow/snakefiles/${snakefile}.smk \
        --rerun-incomplete \
        --use-conda \
        --conda-frontend ${conda_frontend} \
        --conda-create-envs-only ;
done

echo -e "
${blue}## Dry Run ##${nc}
${blue}-------------${nc}
"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# Set or overwrite values in the workflow config object.
# Re-run all jobs the output of which is recognized as incomplete.
# If defined in the rule, run job in a conda environment.
# If mamba package manager is not available, or if you still prefer to use conda, you can enforce that with this setting.
## Default "mamba", recommended because much faster !
# Tell the scheduler to assign creation of given targets (and all their dependencies) highest priority.
# Do not execute anything, and display what would be done. If very large workflow, use –dry-run –quiet to just print a summary of the DAG of jobs.
# Do not output any progress or rule information.

for snakefile in ${snakefiles_list} ; do
    echo -e "${blue}-- ${snakefile} --${nc}" ;
    snakemake \
        --directory ${workdir}/ \
        --snakefile ${workdir}/workflow/snakefiles/${snakefile}.smk \
	--resources mem_gb=${max_memory} \
        --cores ${max_threads}\
        --rerun-incomplete \
        --use-conda \
        --conda-frontend ${conda_frontend} \
        --dry-run ;
done


###############################################################################
### CLEAN and SAVE ###
######################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}CLEAN & SAVE${nc} ${green}#####${nc}
${green}------------------------${nc}
"

# Save and deactive environments
conda deactivate

# Cleanup
rm -f ${workdir}/resources/reads/${sample_test}_R*.fastq.gz 2> /dev/null

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
"

rm -f ${workdir}/resources/reads/${sample_test}_R*.fastq.gz 2> /dev/null


echo -e "
${green}------------------------------------------------------------------------${nc}
"


###############################################################################
