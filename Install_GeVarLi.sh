#!/bin/bash

###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __| ___| \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__|_)\_|____|____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ Install_GeVarLi.sh
# Version ________________ v.2023.10
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Bash script running gevarli.smk snakefile
# Date ___________________ 2023.10.13
# Latest modifications ___ 2023.10.13
# Use ____________________ bash Install_GeVarLi.sh

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
gevarli_version="2023.09"                              # GeVarLi version
workflow_base_version="2023.06"                        # Workflow base version

echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}ABOUT${nc} ${green}#####${nc}
${green}-----------------${nc}

${blue}Name${nc} ___________________ Start_GeVarLi.sh
${blue}Version${nc} ________________ ${ylo}${gevarli_version}${nc}
${blue}Author${nc} _________________ Nicolas Fernandez
${blue}Affiliation${nc} ____________ IRD_U233_TransVIHMI
${blue}Aim${nc} ____________________ Bash script for ${red}Ge${nc}nome assembling, ${red}Var${nc}iant calling and ${red}Li${nc}neage assignation
${blue}Date${nc} ___________________ 2021.10.12
${blue}Latest modifications${nc} ___ 2023.09.19
${blue}Run${nc} ____________________ bash Start_GeVarLi.sh
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
  linux*)   os="linux" ;;
  bsd*)     os="bsd" ;;
  darwin*)  os="osx" ;;
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
    ram_gb=$(expr ${mem_size} \/ $((1024**3)) )      # mem_size / 1024**3 = Gb
elif [[ ${os} == "linux" ]]
then
    model_name=$(lscpu | grep -o -E "Model name: +.+" | sed -E "s/Model name: +//")                           # Get chip model name
    physical_cpu=$(lscpu | grep -o -E "^CPU\(s\): +[0-9]+" | sed -E "s/CPU\(s\): +//")                        # Get physical cpu
    threads_cpu=$(lscpu | grep -o -E "^Thread\(s\) per core: +[0-9]+" | sed -E "s/Thread\(s\) per core: +//") # Get thread(s) per core
    logical_cpu=$(expr ${physical_cpu} \* ${threads_cpu})                                                     # Calcul logical cpu
    mem_size=$(grep -o -E "MemTotal: +[0-9]+" /proc/meminfo | sed -E "s/MemTotal: +//")                       # Get memory size (Kb)
    ram_gb=$(expr ${mem_size} \/ $((1024**2)) )                                                               # mem_size / 1024**2 = Gb
else
    echo -e "Please, use '${red}osx${nc}' or '${red}linux${nc}' operating systems"
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
else
    echo -e "
Conda environment ${red}workflow-base_v.${workflow_base_version}${nc} will be now created, with:

    # ${red}Snakemake${nc}: Run GeVarLi workflow (ver. 7.28.3)
    # ${red}Mamba${nc}:     Install snakemake conda's environments, faster than conda (ver. 1.4.4)
    # ${red}Yq${nc}:        Parse config.yaml file (ver. 3.2.2)
    # ${red}Rename${nc}:    Rename fastq files (ver. 1.601)
    # ${red}Graphviz${nc}:  Dot snakemake DAG (ver. 8.0.5)
"
    conda env create -f ${workdir}/workflow/environments/${os}/workflow-base_v.${workflow_base_version}.yaml
fi

# Remove depreciated 'gevarli' or 'snakemake' old environments
old_envs="gevarli-base_v.2022.11 \
          gevarli-base_v.2022.12 \
          gevarli-base_v.2023.01 \
          gevarli-base_v.2023.02 \
          gevarli-base_v.2023.03 \
          gevarli-base_v.2023.04 \
          snakemake-base_v.2023.01 \
          snakemake-base_v.2023.02 \
          snakemake-base_v.2023.03 \
          snakemake-base_v.2023.04"

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

# intern shell source conda
source ~/miniconda3/etc/profile.d/conda.sh 2> /dev/null          # local user
source /usr/local/miniconda3/etc/profile.d/conda.sh 2> /dev/null # HPC server
conda activate workflow-base_v.${workflow_base_version}          # conda activate workflow-base

###############################################################################
### SETTINGS ###
################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}SETTINGS${nc} ${green}#####${nc}
${green}--------------------${nc}
"

conda_version=$(conda --version | sed 's/conda //')                   # Conda version (ver. >= 23.3.1)
snakemake_version=$(snakemake --version)                              # Snakemake version (ver. 7.25.0)
mamba_version=$(mamba --version | sed 's/mamba //' | head -n 1)       # Mamba version (ver. 1.4.2)
yq_version=$(yq --version | sed 's/yq //')                            # Yq version (ver. 3.2.1)
rename_version="1.601"                                                # Rename version (ver. 1.601)
graphviz_version="7.1.0"                                              # GraphViz version (ver. 7.1.0)
#graphviz_version=$(dot --version | sed 's/dot - graphviz version //') # GraphViz version

fastq=$(expr $(ls -l ${workdir}/resources/reads/*.fastq.gz 2> /dev/null | wc -l)) # Get fastq.gz files count
if [[ "${fastq}" == "0" ]]                                                        # If no sample,
then                                                                               # start GeVarLi with at least 1 sample
    echo -e "${red}¡${nc} No fastq file detected in ${ylo}resources/reads/${nc} ${red}!${nc}
${red}SARS-CoV-2${nc} ${ylo}resources/data_test/${nc} fastq will be used as sample example"
    cp ${workdir}/resources/data_test/*.fastq.gz ${workdir}/resources/reads/       # using data_test/*.fastq.gz
fi
samples=$(expr ${fastq} \/ 2) # {fastq.gz count} / 2 = samples count (paired-end)

config_file="${workdir}/configuration/config.yaml"       # Get configuration file
conda_frontend=$(yq -c '.conda.frontend' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//') # Get user config: conda frontend
max_threads=$(yq -r '.resources.cpus' ${config_file})    # Get user config: max threads
max_memory=$(yq -r '.resources.ram' ${config_file})      # Get user config: max memory
memory_per_job=$(expr ${max_memory} \/ ${max_threads})   # Calcul maximum memory usage per job
reference=$(yq -c '.consensus.reference' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//' | sed 's/\"\,\"/_\&_/') # Get user config:  genome reference
aligner=$(yq -c '.consensus.aligner' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//' | sed 's/\"\,\"/_\&_/')     # Get user config: aligner 
min_cov=$(yq  -c '.consensus.min_cov' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//' | sed 's/\"\,\"/_\&_/')    # Get user config: minimum coverage
min_af=$(yq -r '.consensus.min_af' ${config_file})       # Get user config: minimum allele frequency
clipping=$(yq -r '.cutadapt.clipping' ${config_file})    # Get user config: hard clipping option
nextclade=$(yq -c '.nextclade.run' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//')    # Get user config: run nextclade
dataset=$(yq -c '.nextclade.dataset' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//')  # Get user config: dataset for nextclade
pangolin=$(yq -c '.pangolin.run' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//')      # Get user config: run pangolin
subset=$(yq -r '.fastq_screen.subset' ${config_file})    # Get user config: fastq_screen subsetption
time_stamp_start=$(date +"%Y-%m-%d %H:%M")               # Get system: analyzes starting time
time_stamp_archive=$(date +"%Y-%m-%d_%Hh%M")             # Convert time for archive (wo space)
SECONDS=0                                                # Initialize SECONDS counter

# Print some analyzes settings
echo -e "
${blue}Working directory${nc} _______ ${workdir}/

${blue}Conda version${nc} ___________ ${ylo}${conda_version}${nc} (>= 23.3.1)
${blue}Snakemake version${nc} _______ ${ylo}${snakemake_version}${nc}
${blue}Conda frontend${nc} __________ ${ylo}${conda_frontend}${nc}
${blue}Mamba version${nc} ___________ ${ylo}${mamba_version}${nc}  

${blue}Starting time${nc} ___________ ${time_stamp_start}
"

###############################################################################
### SNAKEMAKE PIPELINES ###
###########################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}SNAKEMAKE PIPELINES${nc} ${green}#####${nc}
${green}-------------------------------${nc}
"

snakefiles_list="indexing_genomes quality_control gevarli"

echo -e "
${blue}## Unlocking Working Directory ##${nc}
${blue}---------------------------------${nc}
"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Set or overwrite values in the workflow config object.
# Re-run all jobs the output of which is recognized as incomplete.
# Remove a lock on the working directory.

for snakefile in ${snakefiles_list} ; do
    echo -e "${blue}-- ${snakefile} --${nc}" ;
    snakemake \
	--directory ${workdir}/ \
        --snakefile ${workdir}/workflow/snakefiles/${snakefile}.smk \
        --config os=${os} \
        --rerun-incomplete \
        --unlock ;
done

echo -e "
${blue}## Conda Environments List ##${nc}
${blue}-----------------------------${nc}
"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# Set or overwrite values in the workflow config object.
# Re-run all jobs the output of which is recognized as incomplete.
# List all conda environments and their location on disk.

for snakefile in ${snakefiles_list} ; do
    echo -e "${blue}-- ${snakefile} --${nc}" ;
    snakemake \
        --directory ${workdir}/ \
        --snakefile ${workdir}/workflow/snakefiles/${snakefile}.smk \
        --cores ${max_threads} \
        --config os=${os} \
        --rerun-incomplete \
        --list-conda-envs ;
done

#echo -e "
#${blue}## Conda Environments Cleanup ##${nc}
#${blue}-----------------------------${nc}
#"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# Set or overwrite values in the workflow config object.
# Re-run all jobs the output of which is recognized as incomplete.
# Cleanup unused conda environments.
#
#for snakefile in ${snakefiles_list} ; do
#    echo -e "${blue}-- ${snakefile} --${nc}" ;
#    snakemake \
#        --directory ${workdir}/ \
#        --snakefile ${workdir}/workflow/snakefiles/${snakefile}.smk \
#        --cores ${max_threads} \
#        --config os=${os} \
#        --rerun-incomplete \
#        --conda-cleanup-envs ;
#done

echo -e "
${blue}## Conda Environments Setup ##${nc}
${blue}------------------------------${nc}
"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# Set or overwrite values in the workflow config object.
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
        --cores ${max_threads} \
        --config os=${os} \
        --rerun-incomplete \
        --use-conda \
        --conda-frontend ${conda_frontend} \
        --conda-create-envs-only ;
done



###############################################################################
### CLEAN and SAVE ###
######################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}CLEAN & SAVE${nc} ${green}#####${nc}
${green}------------------------${nc}
"

# Deactive environments
conda deactivate

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

# Log analyzes settings
echo "
Name ___________________ Installation_GeVarLi.sh
Version ________________ ${gevarli_version}
Author _________________ Nicolas Fernandez
Affiliation ____________ IRD_U233_TransVIHMI
Aim ____________________ Bash script for GeVarLi
Date ___________________ 2023.10.13
Latest modifications ___ 2023.10.13
Run ____________________ bash Installation_GeVarLi.sh

Operating System _______ ${os}
Shell __________________ ${shell}

                   Brand(R) | Type(R) | Model | @ Speed GHz
Chip Model Name ________ ${model_name}
Physical CPUs __________ ${physical_cpu} cores
Logical CPUs ___________ ${logical_cpu} threads
System Memory __________ ${ram_size} Gb of RAM

Working directory ______ ${workdir}/
Samples processed ______ ${samples} samples (${fastq} fastq files)

Conda version __________ ${conda_version}
Snakemake version ______ ${snakemake_version}
Conda frontend _________ ${conda_frontend}
Mamba version __________ ${mamba_version}

Max threads ____________ ${max_threads} of ${logical_cpu} threads available
Max memory _____________ ${max_memory} of ${ram_size} Gb available
Jobs memory ____________ ${memory_per_job} Gb per job maximum

Start time _____________ ${time_stamp_start}
End time _______________ ${time_stamp_end}
Processing time ________ ${minutes} minutes and ${seconds} seconds elapsed
" > ${workdir}/installation.log

echo -e "
${green}------------------------------------------------------------------------${nc}
"
###############################################################################
