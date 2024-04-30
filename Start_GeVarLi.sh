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
# Name ___________________ Start_GeVarLi.sh
# Version ________________ v.2024.03
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Bash script running gevarli.smk snakefile
# Date ___________________ 2021.10.12
# Latest modifications ___ 2024.03.22 (update version)
# Use ____________________ bash Start_GeVarLi.sh

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
gevarli_version="2024.03"                              # GeVarLi version
workflow_base_version="2024.02"                        # Workflow base version
nextclade_version="3.1.0"                              # Nextclade version

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
${blue}Latest modifications${nc} ___ 2024.03.22 (update version)
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
    ram_gb=$( expr ${mem_size} \/ $((1024**2)) )                                                              # mem_size / 1024**2 = Gb
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
### NETWORK ###
###############
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}NETWORK${nc} ${green}#####${nc}
${green}-------------------${nc}
"

if : >/dev/tcp/8.8.8.8/53
then
    network="Online"
else
    network="Offline"
fi

echo -e "
${blue}Network${nc} ________________ ${red}${network}${nc}
"


###############################################################################
### WORKFLOW-BASE INSTALLATION ###
##################################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}WORKFLOW-BASE INSTALLATION${nc} ${green}#####${nc}
${green}---------------------------------------${nc}
"

# Intern shell source conda
source ~/miniconda3/etc/profile.d/conda.sh 2> /dev/null                            # local user
source /usr/local/bioinfo/miniconda3-4.10.3/etc/profile.d/conda.sh 2> /dev/null    # HPC server (new iTROP)
#source /usr/local/bioinfo/miniconda3-23.10.0-1/etc/profile.d/conda.sh 2> /dev/null # HPC server (new iTROP)
#source /usr/local/miniconda3/etc/profile.d/conda.sh 2> /dev/null                   # HPC server (old iTROP)

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

    # ${red}Snakemake${nc}: Run GeVarLi workflow (ver. 8.4.6)
    # ${red}Mamba${nc}:     Install snakemake conda's environments, faster than conda (ver. 1.5.6)
    # ${red}Yq${nc}:        Parse config.yaml file (ver. 3.2.3)
    # ${red}Rename${nc}:    Rename fastq files (ver. 1.601)
    # ${red}Graphviz${nc}:  Dot snakemake DAG (ver. 9.0.0)
"
        conda env create -f ${workdir}/workflow/environments/${os}/workflow-base_v.${workflow_base_version}.yaml &> /dev/null
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
          workflow-base_v.2024.01"

for env in ${old_envs} ; do
    conda remove --name ${env} --all --yes --quiet 2> /dev/null ;
done


###############################################################################
### NEXTCLADE DATASETS UPDATES ###
##################################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}NEXTCLADE DATASETS UPDATES${nc} ${green}#####${nc}
${green}--------------------------------------${nc}
"

## Nextclade installation
# Test if a 'nextclade' environment exist
if [[ $(conda info --envs | grep -o -E "^nextclade_v.${nextclade_version}") ]]
then
    echo -e "
Conda environment ${ylo}nextclade_v.${nextclade_version}${nc} it's already created!
"
else
    # Test network conection
    if [[ ${network} = "Online" ]]
    then
	echo -e "
Conda environment ${red}nextclade_v.${nextclade_version}${nc} not found...                                                                                                
Conda environment ${ylo}nextclade_v.${nextclade_version}${nc} will be now created, with:

    #  ${red}Nextclade${nc}: Update Nextclade databases (ver. ${nextclade_version})
"
        conda env create -f ${workdir}/workflow/environments/${os}/nextclade_v.${nextclade_version}.yaml &> /dev/null
    else
	echo -e "
Conda environment ${red}nextclade_v.${nextclade_version}${nc} not found...
${blue}GeVarLi${nc} is running in ${red}${network}${nc} mode.
Please, check your network conection!
"
    fi
fi

## Databases update
# Test network conection
if [[ ${network} = "Online" ]]
then
    echo -e "conda activate ${ylo}nextclade_v.${nextclade_version}${nc}"
    conda activate nextclade_v.${nextclade_version}
    for dataset in resources/nextclade/* ; do
	name=$(basename ${dataset})
	echo "Updating: ${name}"
	nextclade dataset get --name ${name} --output-dir ${dataset}/
    done
    conda deactivate
else
    echo -e "
${blue}GeVarLi${nc} is running in ${red}${network}${nc} mode.
${blue}Nextclade${nc} datasets updatde ${red}not available${nc}!
"
fi


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

snakemake_version=$(snakemake --version)                        # Snakemake version (ver. 8.2.0)
conda_version=$(conda --version | sed 's/conda //')             # Conda version (ver. 23.11.0)
mamba_version=$(mamba --version | sed 's/mamba //' | head -n 1) # Mamba version (ver. 1.5.6)
yq_version=$(yq --version | sed 's/yq //')                      # Yq version (ver. 3.2.3)
rename_version="1.601"                                          # Rename version (ver. 1.601)
graphviz_version="9.0.0"                                        # GraphViz version (ver. 9.0.0)

fastq=$(expr $(ls -l ${workdir}/resources/reads/*.fastq.gz 2> /dev/null | wc -l)) # Get fastq.gz files count
if [[ "${fastq}" == "0" ]]                                                         # If no sample,
then                                                                                # start GeVarLi with at least 1 sample
    echo -e "${red}¡${nc} No fastq file detected in ${ylo}resources/reads/${nc} ${red}!${nc}
${red}SARS-CoV-2${nc} ${ylo}resources/data_test/${nc} fastq will be used as sample example"
    cp ${workdir}/resources/data_test/SARS-CoV-2_Omicron-BA1*.fastq.gz ${workdir}/resources/reads/ # use data_test fastq
    fastq="2"
fi
samples=$(expr ${fastq} \/ 2) # {fastq.gz count} / 2 = samples count (paired-end)

config_file="${workdir}/configuration/config.yaml" # Get configuration file

conda_frontend=$(yq -c '.conda.frontend' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//') # Get user config: conda frontend
max_threads=$(yq -r '.resources.cpus' ${config_file})  # Get user config: max threads
max_memory=$(yq -r '.resources.ram' ${config_file})    # Get user config: max memory (Gb)
memory_per_job=$(expr ${max_memory} \/ ${max_threads}) # Calcul maximum memory usage per job

consensus=$(yq -c '.consensus.run' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//') # Get user config: run consensus
reference=$(yq -c '.consensus.reference' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//' | sed 's/\"\,\"/ ; /g') # Get user config: genome reference
aligner=$(yq -c '.consensus.aligner' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//' | sed 's/\"\,\"/ ; /g')     # Get user config: aligner 
min_cov=$(yq  -c '.consensus.min_cov' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//' | sed 's/\"\,\"/ ; /g')    # Get user config: minimum coverage
min_freq=$(yq -r '.consensus.min_freq' ${config_file}) # Get user config: minimum allele frequency
clipping=$(yq -r '.cutadapt.clipping' ${config_file})  # Get user config: hard clipping option

nextclade=$(yq -c '.nextclade.run' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//')   # Get user config: run nextclade
dataset=$(yq -c '.nextclade.dataset' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//') # Get user config: dataset for nextclade
pangolin=$(yq -c '.pangolin.run' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//')     # Get user config: run pangolin

multiqc=$(yq -c '.multiqc.run' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//') # Get user config: run multiqc
subset=$(yq -r '.fastq_screen.subset' ${config_file})                            # Get user config: fastq_screen subsetption

time_stamp_start=$(date +"%Y-%m-%d %H:%M")   # Get system: analyzes starting time
time_stamp_archive=$(date +"%Y-%m-%d_%Hh%M") # Convert time for archive (wo space)
SECONDS=0                                    # Initialize SECONDS counter

# Print some analyzes settings
echo -e "
${blue}Working directory${nc} _______ ${workdir}/
${blue}Samples processed${nc} _______ ${red}${samples}${nc} samples (${ylo}${fastq}${nc} fastq files)

${blue}Snakemake version${nc} _______ ${ylo}${snakemake_version}${nc}
${blue}Conda version${nc} ___________ ${ylo}${conda_version}${nc}
${blue}Conda frontend${nc} __________ ${ylo}${conda_frontend}${nc}
${blue}Mamba version${nc} ___________ ${ylo}${mamba_version}${nc}  

${blue}Max threads${nc} _____________ ${red}${max_threads}${nc} of ${ylo}${logical_cpu}${nc} threads available
${blue}Max memory${nc} ______________ ${red}${max_memory}${nc} of ${ylo}${ram_gb}${nc} Gb available
${blue}Jobs memory${nc} _____________ ${red}${memory_per_job}${nc} Gb per job

${blue}Consensus run${nc} ___________ ${red}${consensus}${nc}  
${blue}Reference genome${nc} ________ ${ylo}${reference}${nc}
${blue}Aligner${nc} _________________ ${ylo}${aligner}${nc}

${blue}Min coverage${nc} ____________ ${red}${min_cov}${nc} X
${blue}Min allele frequency${nc} ____ ${red}${min_freq}${nc}

${blue}Hard-clipping primers${nc} ___ ${red}${clipping}${nc}

${blue}Nextclade run${nc} ___________ ${red}${nextclade}${nc}
${blue}Nextclade dataset${nc} _______ ${red}${dataset}${nc}
${blue}Nextclade version${nc} _______ ${red}v.${nextclade_version}${nc}

${blue}Pangolin run${nc} ____________ ${red}${pangolin}${nc}

${blue}MultiQC run${nc} _____________ ${red}${multiqc}${nc}
${blue}Fastq-Screen subset${nc} _____ ${red}${subset}${nc} reads per sample

${blue}Starting time${nc} ___________ ${time_stamp_start}
"


###############################################################################
### RENAME SAMPLES ###
######################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}RENAME FASTQ FILES${nc} ${green}#####${nc}
${green}------------------------------${nc}
"

# Rename fastq files to remove "_001" Illumina pattern (mandatory)
## De/comment line (#) if you want keep Illumina barcode-ID and/or Illumina line-ID
echo -e "Removing ${red}'_S'${nc} index tag ID"
rename "s/_S\d+_/_/" ${workdir}/resources/reads/*.fastq.gz 2> /dev/null                # Remove barcode-ID like {_S001_}
echo -e "Removing ${red}'_L'${nc} line tag ID"
rename "s/_L\d+_/_/" ${workdir}/resources/reads/*.fastq.gz 2> /dev/null                # Remove line-ID ID like {_L001_}
echo -e "Removing ${red}'_001'${nc} illumina tag ID"
rename "s/_001.fastq.gz/.fastq.gz/" ${workdir}/resources/reads/*.fastq.gz 2> /dev/null # Remove end-name ID like {_001}.fastq.gz

echo -e "
If you want to keep Illumina ${blue}barcode-ID${nc} and/or Illumina ${blue}line-ID${nc}, please edit ${ylo}Start_GeVarLi.sh${nc} script (l.235).
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
if [[ "${multiqc}" == "no" ]]                         # Run only CONSENSUS, no quality output
then
    snakefiles_list="indexing_genomes gevarli"
elif [[ "${consensus}" == "no" ]]                     # Run only QUALITY, no consensus output
then
    snakefiles_list="indexing_genomes quality_control"
fi

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
	--resources mem_gb=${max_memory} \
        --cores ${max_threads} \
        --config os=${os} \
        --rerun-incomplete \
        --list-conda-envs \
        2> /dev/null ;
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
#	 --resources mem_gb=${max_memory} \
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
	--resources mem_gb=${max_memory} \
        --cores ${max_threads} \
        --config os=${os} \
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
        --config os=${os} \
        --rerun-incomplete \
        --use-conda \
        --conda-frontend ${conda_frontend} \
        --dry-run \
        --quiet all ;
done

echo -e "
${blue}## Let's Run! ##${nc}
${blue}----------------${nc}
"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# Define a global maximum number of threads available to any rule. Snakefiles requesting more threads will have their values reduced to the maximum. 
# Set or overwrite values in the workflow config object.
# Re-run all jobs the output of which is recognized as incomplete.
# Go on with independent jobs if a job fails.
# If defined in the rule, run job in a conda environment.
# If mamba package manager is not available, or if you still prefer to use conda, you can enforce that with this setting.
## Default "mamba", recommended because much faster !
# Tell the scheduler to assign creation of given targets (and all their dependencies) highest priority.
# Print out the shell commands that will be executed.

for snakefile in ${snakefiles_list} ; do
    echo -e "${blue}-- ${snakefile} --${nc}" ;
    snakemake \
        --directory ${workdir}/ \
        --snakefile ${workdir}/workflow/snakefiles/${snakefile}.smk \
        --cores ${max_threads} \
        --max-threads ${max_threads} \
	--resources mem_gb=${max_memory} \
        --config os=${os} \
        --rerun-incomplete \
        --keep-going \
        --use-conda \
        --conda-frontend ${conda_frontend} \
        --printshellcmds ;
done


###############################################################################
### CONCATENATE RESULTS ###
###########################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}CONCATENATE RESULTS${nc} ${green}#####${nc}
${green}-------------------------------${nc}
"

cp ${workdir}/results/00_Quality_Control/multiqc/multiqc_report.html \
   2> /dev/null \
   ${workdir}/results/All_readsQC_reports.html

# for each references used
for directory in ${workdir}/results/02_Mapping/*/ ; do
    reference=$(basename ${directory}) ;
    # Concatenate CONSENSUS
    cat ${workdir}/results/05_Consensus/${reference}/*_consensus.fasta \
        2> /dev/null \
        1> ${workdir}/results/All_${reference}_consensus_sequences.fasta ;
    # Concatenate COVERAGE
    cat ${workdir}/results/03_Coverage/${reference}/*coverage-stats.tsv \
        2> /dev/null \
        1> ${workdir}/results/All_${reference}_genome_coverages.tsv ;
    awk "NR==1 || NR%2==0" ${workdir}/results/All_${reference}_genome_coverages.tsv \
        2> /dev/null \
        1> ${workdir}/results/GENCOV.tmp \
        && mv ${workdir}/results/GENCOV.tmp ${workdir}/results/All_${reference}_genome_coverages.tsv \
              2> /dev/null ;
    # Concatenate PANGOLIN
    cat ${workdir}/results/06_Lineages/${reference}/*_pangolin-report.csv \
        2> /dev/null \
        1> ${workdir}/results/All_${reference}_pangolin_lineages.csv ;
    awk "NR==1 || NR%2==0" ${workdir}/results/All_${reference}_pangolin_lineages.csv \
        2> /dev/null \
        1> ${workdir}/results/PANGO.tmp \
        && mv ${workdir}/results/PANGO.tmp ${workdir}/results/All_${reference}_pangolin_lineages.csv \
        2> /dev/null ;
    sed "s/,/\t/g" ${workdir}/results/All_${reference}_pangolin_lineages.csv \
        2> /dev/null \
        1> ${workdir}/results/All_${reference}_pangolin_lineages.tsv ;
    rm -f ${workdir}/results/All_${reference}_pangolin_lineages.csv 2> /dev/null ;
    # Concatenate NEXTCLADE
    cat ${workdir}/results/06_Lineages/${reference}/*_nextclade-report.tsv \
        2> /dev/null \
        1> ${workdir}/results/All_${reference}_nextclade_lineages.tsv ;
    awk "NR==1 || NR%2==0" ${workdir}/results/All_${reference}_nextclade_lineages.tsv \
        2> /dev/null \
        1> ${workdir}/results/NEXT.tmp \
        && mv ${workdir}/results/NEXT.tmp ${workdir}/results/All_${reference}_nextclade_lineages.tsv \
        2> /dev/null ;
done


###############################################################################
### GRAPHS, SUMMARY and LOGS ###
#############################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}GRAPHS, SUMMARY and LOGS${nc} ${green}#####${nc}
${green}------------------------------------${nc}
"

# Make directories
mkdir -p ${workdir}/results/10_Reports/graphs/ 2> /dev/null
mkdir -p ${workdir}/results/10_Reports/files-summaries/ 2> /dev/null

graph_list="dag rulegraph filegraph"
extention_list="pdf png"

for snakefile in ${snakefiles_list} ; do
    for graph in ${graph_list} ; do
	for extention in ${extention_list} ; do
	    snakemake \
		--directory ${workdir}/ \
                --snakefile ${workdir}/workflow/snakefiles/${snakefile}.smk \
                --${graph} \
	    | dot -T${extention} \
            2> /dev/null \
	    1> ${workdir}/results/10_Reports/graphs/${snakefile}_${graph}.${extention} ;
	done ;
    done ;
done

for snakefile in ${snakefiles_list} ; do
    snakemake \
        --directory ${workdir} \
        --snakefile ${workdir}/workflow/snakefiles/${snakefile}.smk \
        --summary > ${workdir}/results/10_Reports/files-summaries/${snakefile}_files-summary.txt \
    2> /dev/null ;
done

cp ${config_file} ${workdir}/results/10_Reports/config.log 2> /dev/null


###############################################################################
### CLEAN and SAVE ###
######################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}CLEAN & SAVE${nc} ${green}#####${nc}
${green}------------------------${nc}
"

# Save and deactive environments
mkdir -p ${workdir}/results/10_Reports/conda_env/ 2> /dev/null
cp ${workdir}/workflow/environments/${os}/*.yaml ${workdir}/results/10_Reports/conda_env/
conda deactivate

# Cleanup
find ${workdir}/results/ -type f -empty -delete # Remove empty file (like empty log)
find ${workdir}/results/ -type d -empty -delete # Remove empty directory
rm -f ${workdir}/resources/reads/SARS-CoV-2_Omicron-BA1_Covid-Seq-Lib-on-MiSeq_250000-reads_R*.fastq.gz 2> /dev/null

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
Name ___________________ Start_GeVarLi.sh
Version ________________ ${gevarli_version}
Author _________________ Nicolas Fernandez
Affiliation ____________ IRD_U233_TransVIHMI
Aim ____________________ Bash script for GeVarLi
Date ___________________ 2021.10.12
Latest modifications ___ 2024.03.22 (update version)
Run ____________________ bash Start_GeVarLi.sh

Operating System _______ ${os}
Shell __________________ ${shell}

                   Brand(R) | Type(R) | Model | @ Speed GHz
Chip Model Name ________ ${model_name}
Physical CPUs __________ ${physical_cpu} cores
Logical CPUs ___________ ${logical_cpu} threads
System Memory __________ ${ram_size} Gb of RAM

Working directory ______ ${workdir}/
Samples processed ______ ${samples} samples (${fastq} fastq files)

Snakemake version ______ ${snakemake_version}
Conda version __________ ${conda_version}
Conda frontend _________ ${conda_frontend}
Mamba version __________ ${mamba_version}

Max threads ____________ ${max_threads} of ${logical_cpu} threads available
Max memory _____________ ${max_memory} of ${ram_size} Gb available
Jobs memory ____________ ${memory_per_job} Gb per job maximum

Consensus run __________ ${consensus}
Reference genome _______ ${reference}
Aligner ________________ ${aligner}

Min coverage ___________ ${min_cov}
Min allele frequency ___ ${min_af}

Hard-clipping primers __ ${clipping}

Nextclade run __________ ${nextclade}
Nextclade dataset ______ ${dataset}
Nextclade version ______ v.${nextclade_version}

Pangolin run ___________ ${pangolin}

MultiQC run ____________ ${multiqc}
Fastq-Screen subset ____ ${subset} reads per sample

Start time _____________ ${time_stamp_start}
End time _______________ ${time_stamp_end}
Processing time ________ ${minutes} minutes and ${seconds} seconds elapsed
" > ${workdir}/results/10_Reports/settings.log

# Gzip reports directory
cd ${workdir}/results/
tar -zcf 10_Reports_archive.tar.gz 10_Reports

# Gzip results directory
#mkdir -p ${workdir}/archives/ 2> /dev/null
#cd ${workdir}/
#tar -zcf archives/Results_${time_stamp_archive}_${reference}_${aligner}-${min_cov}X_${samples}sp_archive.tar.gz results/

echo -e "
${green}------------------------------------------------------------------------${nc}
"


###############################################################################
