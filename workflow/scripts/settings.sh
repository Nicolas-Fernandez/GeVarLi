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

workdir=$(cd "$(dirname "${BASH_SOURCE[0]}" )"/../../ && pwd) # Get working directory
version=$(<${workdir}/VERSION.txt)                # Get version

blue="\033[1;34m"  # blue
green="\033[1;32m" # green
red="\033[1;31m"   # red
ylo="\033[1;33m"   # yellow
nc="\033[0m"       # no color

###############################################################################
### OPERATING SYSTEM ###
########################

shell=$SHELL # Get shell

# Get operating system 
case "$OSTYPE" in
  darwin*)  os="osx" ;;
  linux*)   os="linux" ;;
  bsd*)     os="bsd" ;;                       
  solaris*) os="solaris" ;;
  msys*)    os="windows" ;;
  cygwin*)  os="windows" ;;
  *)        os="unknown (${OSTYPE})" ;;
esac

###############################################################################
### HARDWARE ###
################

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
    echo -e "\n Please, use an '${ylo}UNIX${nc}' operating system, like:
        > '${green}linux${nc}'
        > '${green}osx${nc}'
        > '${green}WSL${nc}' \n"
    return 0
fi

###############################################################################
### NETWORK ###
###############

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

message_conda="
$(conda --version)
Path: $(which conda)
$(conda config --show channels)
"

###############################################################################
### CONFIGURATION ###
#####################

conda_version=$(conda --version | sed 's/conda //')             # Conda version
mamba_version=$(mamba --version | head -n 1 | sed 's/mamba //') # Mamba version
snakemake_version=$(snakemake --version)                        # Snakemake version

fastq_dir=$(yq -Mr '.fastq_dir' ${config_file}) # Get path to fastq files directory
fastq_files=$(/bin/ls -l ${fastq_dir}/*.fastq.gz 2> /dev/null | wc -l | sed 's/       //') # Get fastq.gz files count
fastq_R1=$(/bin/ls -l ${fastq_dir}/*R1*.fastq.gz 2> /dev/null | wc -l | sed 's/       //') # Get R1 fastq files count
fastq_R2=$(/bin/ls -l ${fastq_dir}/*R2*.fastq.gz 2> /dev/null | wc -l | sed 's/       //') # Get R2 fastq files count

max_threads=$(yq -Mr '.resources.cpus' ${config_file}) # Get user config: max threads
max_memory=$(yq -Mr '.resources.ram' ${config_file})   # Get user config: max memory (Gb)

qualities=$(yq -Mr '.modules.qualities' ${config_file}) # Reads QC
keeptrim=$(yq -Mr '.modules.keeptrim' ${config_file})   # Keep trimmed reads
cleapping=$(yq -Mr '.modules.cleapping' ${config_file}) # Reads cleapping
covstats=$(yq -Mr '.modules.covstats' ${config_file})   # Mapping coverage stats
consensus=$(yq -Mr '.modules.consensus' ${config_file}) # Consensus
lineages=$(yq -Mr '.modules.lineages' ${config_file})   # Lineages assignation
gisaid=$(yq -Mr '.modules.gisaid' ${config_file})       # Gisaid submission file

# Get user config: genome reference
reference=$(yq -Mc '.consensus.reference' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//' | sed 's/\"\,\"/ ; /g')
# Get user config: mapper
mapper=$(yq -Mc '.consensus.mapper' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//' | sed 's/\"\,\"/ ; /g')
# Get user config: minimum coverage
min_cov=$(yq  -Mc '.consensus.min_cov' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//' | sed 's/\"\,\"/ ; /g')
# Get user config: minimum allele frequency
min_freq=$(yq -Mr '.consensus.min_freq' ${config_file})
# Get user config: assigner tool 
assigner=$(yq  -Mc '.consensus.assigner' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//' | sed 's/\"\,\"/ ; /g')
# Get user config: hard clipping option
hard_clipping=$(yq -Mr '.cutadapt.clipping' ${config_file})
# Get user config: dataset for nextclade
nextclade_dataset=$(yq -Mc '.nextclade.dataset' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//')
# Get user config: fastq_screen subsetption
fastqscreen_subset=$(yq -Mr '.fastq_screen.subset' ${config_file})
# Get user config: cutadapt clipping
cutadapt_clipping=$(yq -Mr '.cutadapt.clipping' ${config_file})


message_settings="""
${blue}------------------------------------------------------------------------${nc}
${blue}#####${nc} ${red}Configuration${nc} ${blue}#####${nc}
${blue}-------------------------${nc}

${green}Starting time${nc} ______________ ${time_stamp_start}

${green}Conda version${nc} ______________ ${ylo}${conda_version}${nc}
${green}Mamba version${nc} ______________ ${ylo}${mamba_version}${nc}  
${green}Snakemake version${nc} __________ ${ylo}${snakemake_version}${nc}

${green}Max threads${nc} ________________ ${red}${max_threads}${nc} of ${ylo}${logical_cpu}${nc} threads available
${green}Max memory${nc} _________________ ${red}${max_memory}${nc} of ${ylo}${ram_gb}${nc} Gb available
${green}Jobs memory${nc} ________________ ${red}${memory_per_job}${nc} Gb per job

${green}Network${nc} ____________________ ${red}${network}${nc}

${green}Working directory${nc} _________ '${ylo}${workdir}/${nc}'

${green}Fastq directory${nc} ___________ '${ylo}${fastq_dir}${nc}'
${green}  > Fastq processed${nc} ________ ${red}${fastq_files}${nc} fastq files
${green}  > Forward reads${nc} __________ ${red}${fastq_R1}${nc} R1
${green}  > Reverse reads${nc} __________ ${red}${fastq_R2}${nc} R2

${blue}Modules:${nc}
${green}  > Quality Control${nc} ________ ${red}${qualities}${nc}
${green}  > Keep Trim${nc} ______________ ${red}${keeptrim}${nc}
${green}  > Soft Clipping${nc} __________ ${red}${cleapping}${nc}
${green}  > Cov Stats${nc} ______________ ${red}${covstats}${nc}
${green}  > Consensus${nc} ______________ ${red}${consensus}${nc}
${green}  > Lineages${nc} _______________ ${red}${lineages}${nc}
${green}  > Gisaid${nc} _________________ ${red}${gisaid}${nc}

${blue}Params:${nc}
${green}  > Reference genome${nc} _______ ${ylo}${reference}${nc}
${green}  > Mapper${nc} ________________ ${ylo}${mapper}${nc}
${green}  > Min coverage${nc} ___________ ${red}${min_cov}${nc} X
${green}  > Min allele frequency${nc} ___ ${red}${min_freq}${nc}
${green}  > Assigner${nc} _ ${red}${assigner}${nc} 
${green}   - Nextclade dataset${nc} _____ ${red}${nextclade_dataset}${nc}
${green}  > Fastq-Screen subset${nc} ____ ${red}${fastqscreen_subset}${nc}
${green}  > Cutadapt clipping${nc} ______ ${red}${cutadapt_clipping} nt${nc}
"""

# Print settings message 
echo -e "${message}"

# Log settings message
mkdir -p ${workdir}/results/10_Reports/ 2> /dev/null
echo -e "${message}" \
    | sed "s/\x1B\[[0-9;]*[mK]//g" \
    > ${workdir}/results/10_Reports/settings.log