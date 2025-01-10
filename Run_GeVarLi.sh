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
# Version ________________ v.2025.01
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Bash script running gevarli.smk snakefile
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.01.08 (Prepare for Snakedeploy)
# Use ____________________ 'bash Run_GeVarLi.sh'

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
version="2025.01"                                      # Version
workdir=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd) # Get working directory
sample_test="SARS-CoV-2_Omicron-BA1_Covid-Seq-Lib-on-MiSeq_250000-reads"

echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}ABOUT${nc} ${green}#####${nc}
${green}-----------------${nc}

${blue}Name${nc} ___________________ Run_GeVarLi.sh
${blue}Version${nc} ________________ ${ylo}${version}${nc}
${blue}Author${nc} _________________ Nicolas Fernandez
${blue}Affiliation${nc} ____________ IRD_U233_TransVIHMI
${blue}Aim${nc} ____________________ Bash script for ${red}Ge${nc}nome assembling, ${red}Var${nc}iant calling and ${red}Li${nc}neage assignation
${blue}Date${nc} ___________________ 2021.10.12
${blue}Latest modifications${nc} ___ 2025.01.08 (Prepare for Snakedeploy)
${blue}Use${nc} ____________________ '${ylo}bash Run_GeVarLi.sh${nc}'
"

###############################################################################
### CHECK OPERATING SYSTEM ###
##############################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}Operating System${nc} ${green}#####${nc}
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
### CHECK HARDWARE ###
######################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}Hardware${nc} ${green}#####${nc}
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
### CHECK INTERNET ###
######################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}Internet${nc} ${green}#####${nc}
${green}-------------------${nc}
"

if ping -c 1 -W 5 google.com > /dev/null 2>&1 || \
   ping -c 1 -W 5 cloudflare.com > /dev/null 2>&1
then
    network="Online"
else
    network="Offline"
fi

echo -e "
${blue}Network${nc} ________________ ${red}${network}${nc}
"

###############################################################################
### CHECK CONDA ###
###################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}Conda${nc} ${green}#####${nc}
${green}-----------------${nc}
"

# Test if a conda distribution already exist
if [[ ! $(command -v conda) ]]
then # If no, invit to install it and EXIT
    echo -e "
${red}No Conda distribution found.${nc}
${green}GeVarLi${nc} use the free and open-source package manager ${ylo}Conda${nc}.
Read documentation at: ${blue}https://transvihmi.pages.ird.fr/nfernandez/GeVarLi/en/pages/installations/${nc}
"
    exit 1
else # If yes, print informations
    echo -e "Your Conda configuration:"
    which conda                  # which Conda
    conda --version              # version
    conda config --show channels # channels
fi

###############################################################################
### CONDA INIT ###
##################

# Intern shell source conda
source ~/miniforge3/etc/profile.d/conda.sh 2> /dev/null                            # local user with miniforge3
source ~/mambaforge/etc/profile.d/conda.sh 2> /dev/null                            # local user with mambaforge ¡ Deprecated !
source ~/miniconda3/etc/profile.d/conda.sh 2> /dev/null                            # local user with miniconda3 ¡ Deprecated !
source /usr/local/bioinfo/miniconda3-23.10.0-1/etc/profile.d/conda.sh 2> /dev/null # iTROP HPC server (conda 23.11.0)

###############################################################################
### WORKFLOW-CORE ###
#####################

echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}Workflow-Core${nc} ${green}#####${nc}
${green}-------------------------${nc}
"

# Test if 'workflow-core' environment exist.
if [[ $(conda env list | grep -q "^workflow-core}") ]]
then # If yes, update it.
    echo -e "${ylo}Workflow-Core${nc} conda environment already created. Updating."
    conda env update --prune --name workflow-core --file ${workdir}/workflow/envs/workflow-core.yaml
else # If not, create it.
    echo -e "
${ylo}Workflow-Core${nc} conda environment will be create, with:

    > ${red}Snakemake${nc}${blue} ___ workflow manager${nc}
    > ${red}Yq${nc}${blue} __________ yaml parser${nc}
    > ${red}GraphViz${nc}${blue} ____ drawing graph${nc}
"
    conda env create --file ${workdir}/workflow/envs/workflow-core.yaml > /dev/null 2>&1

echo -e "
You can remove old depreciated environements such as: 'gevarli-base', 'snakemake-base' or 'workflow-base'.
To list all your conda environments, you can run: '${ylo}conda env list${nc}'.
To remove old conda environments, you can run: '${ylo}conda remove --all --yes --name <ENV_NAME>${nc}'.
"

# Active workflow-core conda environment
echo -e "Activate ${ylo}Workflow-Core${nc} conda environment."
conda activate workflow-core

###############################################################################
### CHECK CONFIGURATION ###
###########################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}Configuration${nc} ${green}#####${nc}
${green}-------------------------${nc}
"

conda_version=$(conda --version | sed 's/conda //')             # Conda version
mamba_version=$(mamba --version | head -n 1 | sed 's/mamba //') # Mamba version
snakemake_version=$(snakemake --version)                        # Snakemake version

fastq=$(expr $(ls -l ${workdir}/resources/reads/*.fastq.gz 2> /dev/null | wc -l)) # Get fastq.gz files count
if [[ "${fastq}" == "0" ]]                                                         # If no sample,
then                                                                                # start GeVarLi with at least 1 sample
    echo -e "${red}¡${nc} No FASTQ files detected in ${ylo}resources/reads/${nc} ${red}!${nc}
${red}${sample_test}${nc} in ${ylo}resources/data_test/${nc} FASTQ files were be used as sample example"
    cp ${workdir}/resources/data_test/${sample_test}_R*.fastq.gz ${workdir}/resources/reads/ # use data_test fastq
    fastq="2"
fi
samples=$(expr ${fastq} \/ 2) # {fastq.gz count} / 2 = samples count (paired-end)

config_file="${workdir}/configuration/config.yaml" # Get configuration file

max_threads=$(yq -Mr '.resources.cpus' ${config_file}) # Get user config: max threads
max_memory=$(yq -Mr '.resources.ram' ${config_file})   # Get user config: max memory (Gb)
memory_per_job=$(expr ${max_memory} \/ ${max_threads}) # Calcul maximum memory usage per job

module_list=$(yq -Mc '.modules' ${config_file} | sed 's/"//g') # Get user config: modules list (default: OFF)
quality="   / off"   # Reads QC
trimming="   / off"  # Reads trimmed
cleapping="   / off" # Reads cleapping
covstats="   / off"  # Mapping coverage stats
consensus="   / off" # Consensus
nextclade="   / off" # Nextclade
pangolin="   / off"  # Pangolin
gisaid="   / off"    # Gisaid
if [[ ${module_list} =~ "quality" ]] ; then quality="ON /    " ; fi
if [[ ${module_list} =~ "trimming" ]] ; then trimming="ON /    " ; fi
if [[ ${module_list} =~ "cleapping" ]] ; then cleapping="ON /    " ; fi
if [[ ${module_list} =~ "covstats" ]] ; then covstats="ON /    " ; fi
if [[ ${module_list} =~ "consensus" ]] ; then consensus="ON /    " ; fi
if [[ ${module_list} =~ "nextclade" ]] ; then nextclade="ON /    " ; fi
if [[ ${module_list} =~ "pangolin" ]] ; then pangolin="ON /    " ; fi
if [[ ${module_list} =~ "gisaid" ]] ; then gisaid="ON /    " ; fi

# Get user config: genome reference
reference=$(yq -Mc '.consensus.reference' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//' | sed 's/\"\,\"/ ; /g')
# Get user config: aligner
aligner=$(yq -Mc '.consensus.aligner' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//' | sed 's/\"\,\"/ ; /g')
# Get user config: minimum coverage
min_cov=$(yq  -Mc '.consensus.min_cov' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//' | sed 's/\"\,\"/ ; /g')
# Get user config: minimum allele frequency
min_freq=$(yq -Mr '.consensus.min_freq' ${config_file})
# Get user config: hard clipping option
hard_clipping=$(yq -Mr '.cutadapt.clipping' ${config_file})
# Get user config: dataset for nextclade
nextclade_dataset=$(yq -Mc '.nextclade.dataset' ${config_file} | sed 's/\[\"//' | sed 's/\"\]//')
# Get user config: fastq_screen subsetption
fastqscreen_subset=$(yq -Mr '.fastq_screen.subset' ${config_file})
# Get user config: cutadapt clipping
cutadapt_clipping=$(yq -Mr '.cutadapt.clipping' ${config_file})

time_stamp_start=$(date +"%Y-%m-%d %H:%M")   # Get system: analyzes starting time
time_stamp_archive=$(date +"%Y-%m-%d_%Hh%M") # Convert time for archive (wo space)
SECONDS=0                                    # Initialize SECONDS counter

# Print some analyzes settings
echo -e "
${blue}Conda version${nc} __________ ${ylo}${conda_version}${nc}
${blue}Mamba version${nc} __________ ${ylo}${mamba_version}${nc}  
${blue}Snakemake version${nc} ______ ${ylo}${snakemake_version}${nc}

${blue}Max threads${nc} ____________ ${red}${max_threads}${nc} of ${ylo}${logical_cpu}${nc} threads available
${blue}Max memory${nc} _____________ ${red}${max_memory}${nc} of ${ylo}${ram_gb}${nc} Gb available
${blue}Jobs memory${nc} ____________ ${red}${memory_per_job}${nc} Gb per job

${blue}Starting time${nc} __________ ${time_stamp_start}
${blue}Working directory${nc} ______ ${workdir}/
${blue}Samples processed${nc} ______ ${red}${samples}${nc} samples (${ylo}${fastq}${nc} fastq files)

${blue}Quality Ccontrol${nc} _______ [ ${red}${quality}${nc} ]
${blue}Trimming${nc} _______________ [ ${red}${trimming}${nc} ]
${blue}Cleapping${nc} ______________ [ ${red}${cleapping}${nc} ]
${blue}Consensus${nc} ______________ [ ${red}${consensus}${nc} ]
${blue}Covstats${nc} _______________ [ ${red}${covstats}${nc} ]
${blue}Nextclade${nc} ______________ [ ${red}${nextclade}${nc} ]
${blue}Pangolin${nc} _______________ [ ${red}${pangolin}${nc} ]
${blue}Gisaid${nc} _________________ [ ${red}${gisaid}${nc} ]

${blue}Reference genome${nc} _______ ${ylo}${reference}${nc}
${blue}Aligner${nc} ________________ ${ylo}${aligner}${nc}
${blue}Min coverage${nc} ___________ ${red}${min_cov}${nc} X
${blue}Min allele frequency${nc} ___ ${red}${min_freq}${nc}

${blue}Nextclade dataset${nc} ______ ${red}${nextclade_dataset}${nc}
${blue}Fastq-Screen subset${nc} ____ ${red}${fastqscreen_subset}${nc}
${blue}Cutadapt clipping${nc} ______ ${red}${cutadapt_clipping}${nc}
"


###############################################################################
### UPDATE NEXTCLADE DATASETS ###
#################################
if [[ ${nextclade} = "ON" ]]
then
 
    echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}Update Nextclade Dataset Updates${nc} ${green}#####${nc}
${green}-------------------------------------${nc}
"

    ## Nextclade installation
    # Check if a 'nextclade' environment exist
    if [[ ! $(conda env list | grep -q "^nextclade_v.") ]]
    then
	# Check network conection
        if [[ ${network} = "Online" ]]
        then
            conda env create -f ${workdir}/workflow/envs/${}.yaml &> /dev/null
        else
	    echo -e "
Network: ${red}${network}${nc}.
Nextclade conda environment: ${red}not found${nc}.
Nextclade dataset updates: ${red}not available${nc}.
"
        fi
    fi

    ## Databases update
    # Check network conection
    if [[ ${network} = "Online" ]]
    then
        nextclade_version=$(conda env list | grep "nextclade_v" | sed -E 's/.*nextclade_v\.([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
	conda activate nextclade_v.${nextclade_version}
        for dataset in resources/nextclade/* ; do
	    name=$(basename ${dataset})
	    echo "Updating: ${name}"
	    nextclade dataset get --name ${name} --output-dir ${dataset}/
        done
        conda deactivate
    else
        echo -e "
Network: ${red}${network}${nc}.
Nextclade dataset updates: ${red}not available${nc}.
"
    fi
fi
 

###############################################################################
### RENAME FASTQ SYMLINKS ###
#############################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}Rename FASTQ Symlinks${nc} ${green}#####${nc}
${green}---------------------------------${nc}
"

# Remove tags from symlinks:
## barcode-ID like {_S001_}
## line-ID ID like {_L001_}
## end-name ID like {_001}.fastq.gz
mkdir -p ${workdir}/resources/symlinks/
for fastq in ${workdir}/resources/reads/*.fastq.gz; do
    symlinks=$(echo $(basename "${fastq}") | \
		   sed -E "s/_S\d+_//" | \
		   sed -E "s/_L\d+_//" | \
		   sed -E "s/_001.fastq.gz/.fastq.gz/")
    ln -s "${fastq}" "${workdir}/resources/symlinks/${symlinks}"
done

echo -e "
If you want to keep Illumina ${blue}barcode-ID${nc} and/or Illumina ${blue}line-ID${nc}, please edit ${ylo}Run_GeVarLi.sh${nc} script (l.335).
"


###############################################################################
### RUN SNAKEMAKE ###
######################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}Run Snakemake${nc} ${green}#####${nc}
${green}-------------------------${nc}
"

echo -e "
${blue}## Unlocking Working Directory ##${nc}
${blue}---------------------------------${nc}
"

snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --rerun-incomplete \
    --unlock

echo -e "
${blue}## Conda Environments List ##${nc}
${blue}-----------------------------${nc}
"

 snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --list-conda-envs

echo -e "
${blue}## Conda Environments Setup ##${nc}
${blue}------------------------------${nc}
"

snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --conda-create-envs-only \
    --use-conda

echo -e "
${blue}## Dry Run ##${nc}
${blue}-------------${nc}
"

snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile \
    --use-conda \
    --dry-run \
    --quiet host rules

echo -e "
${blue}## Let's Run! ##${nc}
${blue}----------------${nc}
"

snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/Snakefile\
    --cores ${max_threads} \
    --max-threads ${max_threads} \
    --resources mem_gb=${max_memory} \
    --rerun-incomplete \
    --keep-going \
    --use-conda \
    --quiet host progress

###############################################################################
### CONCATENATE RESULTS ###
###########################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}Concatenate Results${nc} ${green}#####${nc}
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
### GRAPHS SUMMARY LOGS ###
###########################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}Graphs, Summary and Logs${nc} ${green}#####${nc}
${green}------------------------------------${nc}
"

# Make directories
mkdir -p ${workdir}/results/10_Reports/graphs/ 2> /dev/null
mkdir -p ${workdir}/results/10_Reports/files-summaries/ 2> /dev/null

graph_list="dag rulegraph filegraph"
extention_list="pdf png"

for graph in ${graph_list} ; do
    for extention in ${extention_list} ; do
        snakemake \
            --directory ${workdir}/ \
            --snakefile ${workdir}/workflow/Snakefile \
            --${graph} \
	| dot -T${extention} \
        2> /dev/null \
	1> ${workdir}/results/10_Reports/graphs/${graph}.${extention} ;
    done ;
done

snakemake \
    --directory ${workdir} \
    --snakefile ${workdir}/workflow/Snakefile \
    --summary > ${workdir}/results/10_Reports/files-summaries/files-summary.txt \
    2> /dev/null

cp ${config_file} ${workdir}/results/10_Reports/config.log 2> /dev/null


###############################################################################
### CLEAN and SAVE ###
######################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}Clean & Save${nc} ${green}#####${nc}
${green}------------------------${nc}
"

# Save and deactive environments
mkdir -p ${workdir}/results/10_Reports/conda_envs/ 2> /dev/null
cp ${workdir}/workflow/envs/*.yaml ${workdir}/results/10_Reports/conda_envs/
conda deactivate

# Cleanup
find ${workdir}/results/ -type f -empty -delete # Remove empty file (like empty log)
find ${workdir}/results/ -type d -empty -delete # Remove empty directory
rm -f ${workdir}/resources/reads/${sample_test}_R*.fastq.gz 2> /dev/null
rm -rf ${workdir}/resources/symlinks/ 2> /dev/null

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
Name ___________________ Run_GeVarLi.sh
Version ________________ ${gevarli_version}
Author _________________ Nicolas Fernandez
Affiliation ____________ IRD_U233_TransVIHMI
Aim ____________________ Bash script for GeVarLi
Date ___________________ 2021.10.12
Latest modifications ___ 2025.01.08 (Prepare for Snakedeploy)
Run ____________________ 'bash Run_GeVarLi.sh'

Operating System _______ ${os}
Shell __________________ ${shell}

                   Brand(R) | Type(R) | Model | @ Speed GHz
Chip Model Name ________ ${model_name}
Physical CPUs __________ ${physical_cpu} cores
Logical CPUs ___________ ${logical_cpu} threads
System Memory __________ ${ram_size} Gb of RAM

Max threads ____________ ${max_threads} of ${logical_cpu} threads available
Max memory _____________ ${max_memory} of ${ram_size} Gb available
Jobs memory ____________ ${memory_per_job} Gb per job maximum

Snakemake version _______ ${snakemake_version}
Conda version ___________ ${conda_version}
Mamba version ___________ ${mamba_version}  

Start time _____________ ${time_stamp_start}
End time _______________ ${time_stamp_end}
Processing time ________ ${minutes} minutes and ${seconds} seconds elapsed

Working directory _______ ${workdir}/
Samples processed _______ ${samples} samples (${ylo}${fastq} fastq files)

Quality Ccontrol ________ [ ${quality} ]
KeepTrim ________________ [ ${trimming} ]
Cleapping _______________ [ ${cleapping} ]
Consensus _______________ [ ${consensus} ]
Covstats ________________ [ ${covstats} ]
Nextclade _______________ [ ${nextclade} ]
Pangolin ________________ [ ${pangolin} ]
Gisaid __________________ [ ${gisaid} ]

Reference genome ________ ${reference}
Aligner _________________ ${aligner}
Min coverage ____________ ${min_cov} X
Min allele frequency ____ ${min_freq}

Nextclade dataset _______ ${nextclade_dataset}
Fastq-Screen subset _____ ${fastqscreen_subset}
Cutadapt clipping$ ______ ${cutadapt_clipping}
" > ${workdir}/results/10_Reports/settings.log

# Gzip reports directory
cd ${workdir}/results/
tar -zcf 10_Reports_archive.tar.gz 10_Reports
cd ${workdir}

# Gzip results directory
#mkdir -p ${workdir}/archives/ 2> /dev/null
#tar -zcf archives/Results_${time_stamp_archive}_${reference}_${aligner}-${min_cov}X_${samples}sp_archive.tar.gz results/

echo -e "
${green}------------------------------------------------------------------------${nc}
"


###############################################################################
