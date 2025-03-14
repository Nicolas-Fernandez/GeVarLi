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
# Aim ____________________ Bash script running gevarli.smk snakefile
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.03.12
# Use ____________________ '. Run_GeVarLi.sh'
###############################################################################

###############################################################################
### ABOUT ###
#############

workdir=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd) # Get working directory
version=$(<${workdir}/version.txt)                     # Get version
test_dir=$(<${workdir}/.test/)                         # Get test directory

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
    echo -e "Please, use an '${ylo}UNIX${nc}' operating system, like: '${red}linux${nc}', '${red}osx${nc}' or '${red}WSL${nc}'."
    return 0
fi


###############################################################################
### Network ###
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

# Test if a conda distribution already exist
if [[ ! $(command -v conda) ]]
then # If no, invitation message to install it
    message_conda="
    ${red}No Conda distribution found.${nc}
    ${blue}GeVarLi${nc} use the free and open-source package manager ${ylo}Conda${nc}.
    Read documentation at: ${green}https://transvihmi.pages.ird.fr/nfernandez/GeVarLi/en/pages/installations/${nc}"
else # If yes, informations message about it
    message_conda="
$(conda --version)
$(which conda)
$(conda config --show channels)"
fi

# Intern shell source conda
source ~/miniforge3/etc/profile.d/conda.sh 2> /dev/null                            # local user with miniforge3
source ~/mambaforge/etc/profile.d/conda.sh 2> /dev/null                            # local user with mambaforge ¡ Deprecated !
source ~/miniconda3/etc/profile.d/conda.sh 2> /dev/null                            # local user with miniconda3 ¡ Deprecated !
source /usr/local/bioinfo/miniconda3-23.10.0-1/etc/profile.d/conda.sh 2> /dev/null # iTROP HPC server (conda 23.11.0)


###############################################################################
### SPINNER ###
###############

bash ${workdir}/workflow/scripts/spinner2.sh > /dev/null 2>&1

###############################################################################
### WORKFLOW-CORE ###
#####################

# Test if 'workflow-core' environment exist.
if conda env list | grep -q "^workflow-core"
then # If 'exist'
    echo -e "
${ylo}Workflow-Core${nc} conda environment already created.
"
    if [[ $network == "Online" ]]
    then # If 'online'
	echo -e "\r
Updating ${ylo}Workflow-Core${nc} environment.
"
        #run_with_spinner \
	conda env update \
	    --prune \
	    --name workflow-core \
	    --file ${workdir}/workflow/envs/workflow-core.yaml
	    #> /dev/null 2>&1
    fi
else # If 'not' exist
    echo -e "
${ylo}Workflow-Core${nc} conda environment not found.
"
    if [[ $network == "Online" ]]
    then # If 'online'
        echo -e "
${ylo}Workflow-Core${nc} conda environment will be create, with:

    > ${red}Snakemake${nc}
    > ${red}Snakedeploy${nc}   
    > ${red}Snakemake Slurm plugin${nc}
"
        #run_with_spinner \
	conda env create \
	    --file ${workdir}/workflow/envs/workflow-core.yaml \
	    --quiet \
	    > /dev/null 2>&1
    fi
fi

# Active workflow-core conda environment.
if conda env list | grep -q "^workflow-core"
then
    conda activate workflow-core
else
    echo -e "
${ylo}Workflow-Core${nc} conda environment not installed.
"
    return 0
fi

###############################################################################
### CHECK CONFIGURATION ###
###########################

conda_version=$(conda --version | sed 's/conda //')             # Conda version
mamba_version=$(mamba --version | head -n 1 | sed 's/mamba //') # Mamba version
snakemake_version=$(snakemake --version)                        # Snakemake version

config_file="${workdir}/config/config.yaml"     # Get configuration file

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


###############################################################################
### MESSAGE ###
###############

# Timer
time_stamp_start=$(date +"%Y-%m-%d %H:%M")   # Get system: analyzes starting time
time_stamp_archive=$(date +"%Y-%m-%d_%Hh%M") # Convert time for archive (wo space)
SECONDS=0                                    # Initialize SECONDS counter

# Colors
blue="\033[1;34m"  # blue
green="\033[1;32m" # green
red="\033[1;31m"   # red
ylo="\033[1;33m"   # yellow
nc="\033[0m"       # no color

# Message
message="
${blue}------------------------------------------------------------------------${nc}
${blue}#####${nc} ${red}ABOUT${nc} ${blue}#####${nc}
${blue}-----------------${nc}

${green}Name${nc} ___________________ Run_GeVarLi.sh
${green}Version${nc} ________________ ${ylo}${version}${nc}
${green}Author${nc} _________________ Nicolas Fernandez
${green}Affiliation${nc} ____________ IRD_U233_TransVIHMI
${green}Aim${nc} ____________________ Bash script running GeVarLi Snakefile
${green}Date${nc} ___________________ 2021.10.12
${green}Latest modifications${nc} ___ 2025.03.12
${green}Use${nc} ____________________ '${ylo}. Run_GeVarLi.sh${nc}'

${blue}------------------------------------------------------------------------${nc}
${blue}#####${nc} ${red}Operating System${nc} ${blue}#####${nc}
${blue}----------------------------${nc}

${green}Shell${nc} __________________ ${ylo}${shell}${nc}
${green}Operating system${nc} _______ ${red}${os}${nc}

${blue}------------------------------------------------------------------------${nc}
${blue}#####${nc} ${red}Hardware${nc} ${blue}#####${nc}
${blue}--------------------${nc}

${ylo}Brand(R)${nc} | ${ylo}Type(R)${nc} | ${ylo}Model${nc} | ${ylo}@ Speed GHz${nc}
${green}Chip Model Name${nc} ________ ${model_name}
${green}Physical CPUs${nc} __________ ${red}${physical_cpu}${nc}
${green}Logical CPUs${nc} ___________ ${red}${logical_cpu}${nc} threads
${green}System Memory${nc} __________ ${red}${ram_gb}${nc} Gb of RAM

${blue}------------------------------------------------------------------------${nc}
${blue}#####${nc} ${red}Network${nc} ${blue}#####${nc}
${blue}-------------------${nc}

${green}Network${nc} ________________ ${red}${network}${nc}

${blue}------------------------------------------------------------------------${nc}
${blue}#####${nc} ${red}Conda${nc} ${blue}#####${nc}
${blue}-----------------${nc}

${message_conda}

${blue}------------------------------------------------------------------------${nc}
${blue}#####${nc} ${red}Workflow-Core${nc} ${blue}#####${nc}
${blue}-------------------------${nc}

${green}GeVarLi${nc} use ${green}Snakemake${nc}, a workflow manager.
${green}Snakemake${nc} is provided into ${red}Workflow-Core${nc}, a ${green}Conda${nc} environment.

You can remove old depreciated environements such as: 'gevarli-base', 'snakemake-base' or 'workflow-base'.
To list all your conda environments, you can run: '${ylo}conda env list${nc}'.
To remove old conda environments, you can run: '${ylo}conda remove --all --yes --name${nc} ${red}<ENV_NAME>${nc}'.

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
"

# Print settings message
echo -e "${message}"

# Log settings message
mkdir -p ${workdir}/results/10_Reports/ 2> /dev/null

echo -e "${message}" \
    | sed "s/\x1B\[[0-9;]*[mK]//g" \
    > ${workdir}/results/10_Reports/settings.log

mkdir -p ${workdir}/results/10_Reports/envs/ 2> /dev/null
cp ${workdir}/workflow/envs/*.yaml ${workdir}/results/10_Reports/envs/
cp ${config_file} ${workdir}/results/10_Reports/config.log 2> /dev/null


# If errors:
if [[ ! $(command -v conda) ]] # If no conda
then
    return 0
elif [[ "${fastq}" == "0" ]] # If no FASTQ
then
    return 0
fi


###############################################################################
### RUN SNAKEMAKE ###
#####################

# Print settings message
echo -e "
${blue}------------------------------------------------------------------------${nc}
${blue}#####${nc} ${red}Run Snakemake${nc} ${blue}#####${nc}
${blue}-------------------------${nc}
"

echo -e "
${green} > Snakemake: unlock working directory${nc}
"
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --rerun-incomplete \
    --unlock

echo -e "
${green} > Snakemake: list conda environments${nc}
"
 snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --list-conda-envs

 echo -e "
${green} > Snakemake: create conda environments${nc}
"
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --conda-create-envs-only \
    --use-conda

echo -e "
${green} > Snakemake: dry run${nc}
"
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --use-conda \
    --dry-run \
    --quiet host rules

echo -e "
${green} > Snakemake: run${nc}
"
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile\
    --cores ${max_threads} \
    --resources mem_gb=${max_memory} \
    --rerun-incomplete \
    --keep-going \
    --use-conda \
    --quiet host progress

# Deactive workflow-core conda environment.
echo -e "
Deactivate ${ylo}Workflow-Core${nc} conda environment."
conda deactivate

###############################################################################
### Gzip ###
############

# Gzip reports directory
#cd ${workdir}/results/
#tar -zcf 10_Reports_archive.tar.gz 10_Reports/
#cd ${workdir}

# Gzip results directory
#mkdir -p ${workdir}/archives/ 2> /dev/null
#tar -zcf archives/Results_${time_stamp_archive}_${reference}_${aligner}-${min_cov}X_${samples}sp_archive.tar.gz results/

###############################################################################
### Timer ###
#############

# Timer
time_stamp_end=$(date +"%Y-%m-%d %H:%M") # Get date / hour ending analyzes
elapsed_time=${SECONDS}                  # Get SECONDS counter 
hours=$((${elapsed_time}/3600))          # /3600 = hours
minutes=$(((${elapsed_time}%3600)/60))   # %3600 /60 = minutes
seconds=$((${elapsed_time}%60))          # %60 = seconds
formatted_time=$(printf "%02d:%02d:%02d" ${hours} ${minutes} ${seconds}) # Format

# Time message
message_time="
${green}Start time${nc} _____________ ${time_stamp_start}
${green}End time${nc} _______________ ${time_stamp_end}
${green}Processing time${nc} ________ ${ylo}${formatted_time}${nc}
"

# Print time message
echo -e "${message_time}"

# Log time message
echo -e "${message_time}" \
    | sed "s/\x1B\[[0-9;]*[mK]//g" \
    >> ${workdir}/results/10_Reports/settings.log

###############################################################################
