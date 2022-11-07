#!/bin/bash

gevarli_version="v.2022.11"
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ Start_GeVarLi.sh
# Version ________________ v.2022.11
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Bash script running gevarli.smk snakefile
# Date ___________________ 2021.10.12
# Latest modifications ___ 2022.11.07
# Use ____________________ bash Start_GeVarLi.sh

###############################################################################
##### Colors ######
red="\033[1;31m"   # red
green="\033[1;32m" # green
ylo="\033[1;33m"   # yellow
blue="\033[1;34m"  # blue
nc="\033[0m"       # no color

###############################################################################
###### About ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}ABOUT${nc} ${green}#####${nc}
${green}-----------------${nc}

${blue}Name${nc} ___________________ Start_GeVarLi.sh
${blue}Version${nc} ________________ ${gevarli_version}
${blue}Author${nc} _________________ Nicolas Fernandez
${blue}Affiliation${nc} ____________ IRD_U233_TransVIHMI
${blue}Aim${nc} ____________________ Bash script for ${red}Ge${nc}ome assembling, ${red}Var${nc}iant calling and ${red}Li${nc}neage assignation
${blue}Date${nc} ___________________ 2021.10.12
${blue}Latest modifications${nc} ___ 2022.11.07
${blue}Run${nc} ____________________ bash Start_GeVarLi.sh
"

###############################################################################
###### Operating System ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}OPERATING SYSTEM${nc} ${green}#####${nc}
${green}--------------------${nc}
"

case "$OSTYPE" in
  linux*)   os="Linux" ;;
  bsd*)     os="BSD" ;;
  darwin*)  os="OSX" ;;
  solaris*) os="Solaris" ;;
  msys*)    os="Windows" ;;
  cygwin*)  os="Windows" ;;
  *)        os="Unknown (${OSTYPE})" ;;
esac

# Print operating system 
echo -e "
${blue}Operating system${nc} _______ ${red}${os}${nc}
"

###############################################################################
###### Hardware ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}HARDWARE${nc} ${green}#####${nc}
${green}--------------------${nc}
"

if [[ ${os} == "OSX" ]]
then
    model_name=$(sysctl -n machdep.cpu.brand_string) # Get chip model name
    physical_cpu=$(sysctl -n hw.physicalcpu)         # Get physical cpu
    logical_cpu=$(sysctl -n hw.logicalcpu)           # Get logical cpu
    mem_size=$(sysctl -n hw.memsize)                 # Get memory size (bit)
    ram_gb=$(expr ${mem_size} \/ $((1024**3)) )      # mem_size / 1024**3 = Gb
elif [[ ${os} == "Linux" ]]
then
    model_name=$(lscpu | grep -o -E "Model name: +.+" | sed -r "s/Model name: +//")                           # Get chip model name
    physical_cpu=$(lscpu | grep -o -E "^CPU\(s\): +[0-9]+" | sed -r "s/CPU\(s\): +//")                        # Get physical cpu
    threads_cpu=$(lscpu | grep -o -E "^Thread\(s\) per core: +[0-9]+" | sed -r "s/Thread\(s\) per core: +//") # Get thread(s) per core
    logical_cpu=$(expr ${physical_cpu} \* ${threads_cpu})                                                     # Calcul logical cpu
    mem_size=$(grep -o -E "MemTotal: +[0-9]+" /proc/meminfo | sed -r "s/MemTotal: +//")                       # Get memory size (Kb)
    ram_gb=$(expr ${mem_size} \/ $((1024**2)) )                                                               # mem_size / 1024**2 = Gb
else
    echo -e "Please, use '${red}OSX${nc}' or '${red}Linux${nc}' operating systems"
    exit 1
fi

# Print some hardware specifications
echo -e "
                         ${ylo}Brand(R)${nc} | ${ylo}Type(R)${nc} | ${ylo}Model${nc} | ${ylo}@ Speed GHz${nc}
${blue}Chip Model Name${nc} ________ ${model_name}
${blue}Physical CPUs${nc} __________ ${red}${physical_cpu}${nc} cores
${blue}Logical CPUs${nc} ___________ ${red}${logical_cpu}${nc} threads
${blue}System Memory${nc} __________ ${red}${ram_gb}${nc} Gb of RAM
"

###############################################################################
###### Settings ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}SETTINGS${nc} ${green}#####${nc}
${green}--------------------${nc}
"

workdir=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)                                          # Get working directory
fastq=$(expr $(ls -l ${workdir}/resources/reads/*.fastq.gz | wc -l))                            # Get fastq.gz files count
samples=$(expr ${fastq} \/ 2)                                                                   # {fastq.gz count} / 2 = samples count (paired-end)
conda_version=$(conda --version | sed "s/conda//")                                              # Get conda version
snakemake_version=$(grep -o -E "snakemake_version: '.+'" ${workdir}/config/config.yaml | \
		    sed "s/snakemake_version: //" | sed "s/'//g")                               # Get snakemake version
conda_frontend=$(grep -o -E "conda_frontend: '.+'"  ${workdir}/config/config.yaml | \
		 sed "s/conda_frontend: //" | sed "s/'//g")                                     # Get conda frontend
max_threads=$(grep -o -E "cpus: [0-9]+" ${workdir}/config/config.yaml | sed "s/cpus: //")       # Get user config for max threads
max_memory=$(grep -o -E "ram: [0-9]+" ${workdir}/config/config.yaml | sed "s/ram: //")          # Get user config for max memory
memory_per_job=$(expr ${max_memory} \/ ${max_threads})                                          # Calcul maximum memory usage per job
reference=$(grep -o -E "reference: '.+'" ${workdir}/config/config.yaml | \
	    sed "s/reference: //" | sed "s/'//g")                                               # Get user config genome reference
aligner=$(grep -o -E "aligner: '.+'" ${workdir}/config/config.yaml | \
	  sed "s/aligner: //" | sed "s/'//g")                                                   # Get user config aligner
min_cov=$(grep -o -E "mincov: [0-9]+" ${workdir}/config/config.yaml | sed "s/mincov: //")       # Get user config minimum coverage
min_af=$(grep -o -E "minaf: [0-1]\.[0-9]+" ${workdir}/config/config.yaml | sed "s/minaf: //")   # Get user config minimum allele frequency
clipping=$(grep -o -E "clipping: '.+'" ${workdir}/config/config.yaml | \
	   sed "s/clipping: //"  | sed "s/'//g")                                                # Get user config bamclipper option
primers_kit=$(grep -o -E "primers: '.+'" ${workdir}/config/config.yaml | \
	      sed "s/primers: //" | sed "s/'//g")                                               # Get user config bamclipper primers
time_stamp_start=$(date +"%Y-%m-%d %H:%M")                                                      # Get analyzes starting time
SECONDS=0                                                                                       # Initialize SECONDS counter

if [[ "${reference}" == *"SARS-CoV-2"* ]]
then
    nextclade="Yes"
    pangolin="Yes"
elif [[ "${reference}" == *"Monkeypox-virus"* ]]
then
    nextclade="Yes"
    pangolin="No"
else
    nextclade="No"
    pangolin="No"
fi

if [[ "${clipping}" == "yes" ]]
then
    bamclipper="Yes"
    amplicons_kit=${primers_kit}
elif [[ "${clipping}" == "no" ]]
then
    bamclipper="No"
    amplicons_kit="None"
else
    bamclipper="error_config_file"
    amplicons_kit="'error_config_file'"
fi

# Print some analyzes settings
echo -e "
${blue}Working Directory${nc} ______ ${workdir}/
${blue}Samples processed${nc} ______ ${red}${samples}${nc} samples (${ylo}${fastq}${nc} fastq files)

${blue}Conda version${nc} __________ ${ylo}${conda_version}${nc}
${blue}Snakemake version${nc} ______ ${ylo}${snakemake_version}${nc}
${blue}Conda frontend${nc} _________ ${ylo}${conda_frontend}${nc}

${blue}max Threads${nc} ________ ${red}${max_threads}${nc} of ${ylo}${logical_cpu}${nc} threads available
${blue}max Memory${nc} _________ ${red}${max_memory}${nc} of ${ylo}${ram_gb}${nc} Gb available
${blue}job Memory${nc} _________ ${red}${memory_per_job}${nc} Gb per job

${blue}genome Reference${nc} _______ ${ylo}${reference}${nc}
${blue}Aligner${nc} ________________ ${ylo}${aligner}${nc}

${blue}min Coverage${nc} __________ ${red}${min_cov}${nc}x
${blue}min Allele Frequency${nc} __ ${red}${min_af}${nc}

${blue}run Nextclade${nc} __________ ${red}${nextclade}${nc}
${blue}run Pangolin ${nc} ___________ ${red}${pangolin}${nc}

${blue}run BamClipper${nc} _________ ${red}${bamclipper}${nc}
${blue}Primers kit${nc} ____________ ${ylo}${amplicons_kit}${nc}

${blue}Start time${nc} _____________ ${time_stamp_start}
"

###############################################################################
###### Conda Installations ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}CONDA INSTALLATIONS${nc} ${green}#####${nc}
${green}-------------------------${nc}
"


# Test if a 'gevarli' environment exist
if [[ conda info --envs | grep -o -E "^gevarli_${gevarli_version}" ]]
then
    echo "Conda environment ${ylo}gevarli_${gevarli_version}${nc} already installed"
else
    echo "Conda environment ${ylo}gevarli_${gevarli_version}${nc} will be installed"
    # Create an empty 'gevarli' environment
    conda create --name gevarli_${gevarli_version} --yes
    # Mamba (to install conda environments faster)
    conda install \
        --name gevarli_${gevarli_version} \
	--channel conda-forge \
	mamba \
	--yes
    # Snakemake (to run GeVarLi)
    ${conda_frontend} install \
	--name gevarli_${gevarli_version} \
	---channel conda-forge \
	--channel bioconda \
	snakemake==${snakemake_version} \
	--yes
    # Rename (to rename fastq files)
    ${conda_frontend} install \
	--name gevarli_${gevarli_version} \
	--channel bioconda \
	rename \
	--yes
    # Graphviz (to dot snakemake DAG)
    ${conda_frontend} install \
	--name gevarli_${gevarli_version} \
	--channel anaconda \
	graphviz \
	--yes
fi

# Active Gevarli env.
conda activate gevarli_${gevarli_version}

###############################################################################
###### Rename samples ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}RENAME FASTQ FILES${nc} ${green}#####${nc}
${green}------------------------------${nc}
"

# Rename fastq files to remove "_001" Illumina pattern.
## De/comment (#) if you want keep Illumina barcode-ID and/or Illumina line-ID
rename "s/_S\d+_/_/" ${workdir}/resources/reads/*.fastq.gz 2> /dev/null                # Remove barcode-ID like {_S001_}
rename "s/_L\d+_/_/" ${workdir}/resources/reads/*.fastq.gz 2> /dev/null                # Remove line-ID ID like {_L001_}
rename "s/_001.fastq.gz/.fastq.gz/" ${workdir}/resources/reads/*.fastq.gz 2> /dev/null # Remove end-name ID like {_001}.fastq.gz


###############################################################################
###### Call snakemake pipelines ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}SNAKEMAKE PIPELINE${nc} ${green}#####${nc}
${green}------------------------------${nc}
"

snakefile_list="indexing_genomes quality_control gevarli"

echo -e "
${blue}Unlocking working directory:${nc}
"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Set or overwrite values in the workflow config object.
# Re-run all jobs the output of which is recognized as incomplete.
# Remove a lock on the working directory.

for snakefile in ${snakefile_list} ; do
    echo -e "${blue}For ${snakefile}:${nc}" ;
    snakemake \
	--directory ${workdir}/ \
        --snakefile ${workdir}/workflow/rules/${snakefile}.smk \
        --config os=${os} \
        --rerun-incomplete \
        --unlock ;
    echo ""
done

echo -e "
${blue}Conda environments list:${nc}
"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# Set or overwrite values in the workflow config object.
# Re-run all jobs the output of which is recognized as incomplete.
# List all conda environments and their location on disk.

for snakefile in ${snakefile_list} ; do
    echo -e "${blue}For ${snakefile}:${nc}" ;
    snakemake \
        --directory ${workdir}/ \
        --snakefile ${workdir}/workflow/rules/${snakefile}.smk \
        --cores ${max_threads} \
        --config os=${os} \
        --rerun-incomplete \
        --list-conda-envs ;
done

echo -e "
${blue}Conda environments setup:${nc}
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

for snakefile in ${snakefile_list} ; do
    echo -e "${blue}For ${snakefile}:${nc}" ;
    snakemake \
        --directory ${workdir}/ \
        --snakefile ${workdir}/workflow/rules/${snakefile}.smk \
        --cores ${max_threads} \
        --config os=${os} \
        --rerun-incomplete \
        --use-conda \
        --conda-frontend ${conda_frontend} \
        --conda-create-envs-only ;
done

echo -e "
${blue}Dry run:${nc}
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

for snakefile in ${snakefile_list} ; do
    echo -e "${blue}For ${snakefile}:${nc}" ;
    snakemake \
        --directory ${workdir}/ \
        --snakefile ${workdir}/workflow/rules/${snakefile}.smk \
        --cores ${max_threads}\
        --config os=${os} \
        --rerun-incomplete \
        --use-conda \
        --conda-frontend ${conda_frontend} \
        --dry-run \
        --quiet ;
done

echo -e "
${blue}Let's run!${nc}
"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# Define a global maximum number of threads available to any rule. Rules requesting more threads will have their values reduced to the maximum. 
# Set or overwrite values in the workflow config object.
# Re-run all jobs the output of which is recognized as incomplete.
# Go on with independent jobs if a job fails.
# If defined in the rule, run job in a conda environment.
# If mamba package manager is not available, or if you still prefer to use conda, you can enforce that with this setting.
## Default "mamba", recommended because much faster !
# Tell the scheduler to assign creation of given targets (and all their dependencies) highest priority.
# Print out the shell commands that will be executed.

for snakefile in ${snakefile_list} ; do
    echo -e "${blue}For ${snakefile}:${nc}" ;
    snakemake \
        --directory ${workdir}/ \
        --snakefile ${workdir}/workflow/rules/${snakefile}.smk \
        --cores ${max_threads} \
        --max-threads ${max_threads} \
        --config os=${os} \
        --rerun-incomplete \
        --keep-going \
        --use-conda \
        --conda-frontend ${conda_frontend} \
        --printshellcmds ;
done

###############################################################################
###### Concatenate all consensus fasta ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}CONCATENATE FASTA FILES${nc} ${green}#####${nc}
${green}-----------------------------------${nc}
"
cat ${workdir}/results/05_Consensus/*_consensus.fasta \
    1> ${workdir}/results/All_consensus_sequences.fasta \
    2> /dev/null

cp ${workdir}/results/00_Quality_Control/multiqc/multiqc_report.html \
   ${workdir}/results/All_readsQC_reports.html \
   2> /dev/null

###############################################################################
###### Concatenate all coverage stats ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}CONCATENATE COVERAGE STATS${nc} ${green}#####${nc}
${green}--------------------------------------${nc}
"
cat ${workdir}/results/03_Coverage/*coverage-stats.tsv \
    1> ${workdir}/results/All_genome_coverages.tsv \
    2> /dev/null

awk "NR==1 || NR%2==0" ${workdir}/results/All_genome_coverages.tsv \
    1> ${workdir}/results/GENCOV.tmp \
    2> /dev/null \
    && mv ${workdir}/results/GENCOV.tmp ${workdir}/results/All_genome_coverages.tsv \
    2> /dev/null

###############################################################################
###### Concatenate all Pangolin lineage reports ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}CONCATENATE PANGOLIN REPORTS${nc} ${green}#####${nc}
${green}----------------------------------------${nc}
"

cat ${workdir}/results/06_Lineages/*_pangolin-report.csv \
    1> ${workdir}/results/All_pangolin_lineages.csv \
    2> /dev/null

awk "NR==1 || NR%2==0" ${workdir}/results/All_pangolin_lineages.csv \
    > ${workdir}/results/PANGO.tmp \
    && mv ${workdir}/results/PANGO.tmp ${workdir}/results/All_pangolin_lineages.csv \
    2> /dev/null

sed "s/,/\t/g" ${workdir}/results/All_pangolin_lineages.csv \
    1> ${workdir}/results/All_pangolin_lineages.tsv \
    2> /dev/null

rm -f ${workdir}/results/All_pangolin_lineages.csv 2> /dev/null

###############################################################################
###### Concatenate all Nextclade lineage reports ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}CONCATENATE NEXTCLADE REPORTS${nc} ${green}#####${nc}
${green}-----------------------------------------${nc}
"

cat ${workdir}/results/06_Lineages/*_nextclade-report.tsv \
    1> ${workdir}/results/All_nextclade_lineages.tsv \
    2> /dev/null

awk "NR==1 || NR%2==0" ${workdir}/results/All_nextclade_lineages.tsv \
    1> ${workdir}/results/NEXT.tmp \
    2> /dev/null \
    && mv ${workdir}/results/NEXT.tmp ${workdir}/results/All_nextclade_lineages.tsv \
    2> /dev/null

###############################################################################
###### Create usefull graphs, summary and logs ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}SNAKEMAKE PIPELINE LOGS${nc} ${green}#####${nc}
${green}-------------------------------------${nc}
"
mkdir -p ${workdir}/results/10_Reports/graphs/ 2> /dev/null

graph_list="dag rulegraph filegraph"
extention_list="pdf png"

for snakefile in ${snakefile_list} ; do
    for graph in ${graph_list} ; do
	for extention in ${extention_list} ; do
	    snakemake \
		--directory ${workdir}/ \
                --snakefile ${workdir}/workflow/rules/${snakefile}.smk \
                --${graph} \
	    | dot -T${extention} \
	    1> ${workdir}/results/10_Reports/graphs/${snakefile}_${graph}.${extention} \
	    2> /dev/null ;
	done ;
    done ;
done

for snakefile in ${snakefile_list} ; do
    snakemake \
        --directory ${workdir} \
        --snakefile ${workdir}/workflow/rules/${snakefile}.smk \
        --summary > ${workdir}/results/10_Reports/${snakefile}_files_summary.txt \
    2> /dev/null ;
done

cp ${workdir}/config/config.yaml \
   ${workdir}/results/10_Reports/config_used.yaml \
   2> /dev/null

###############################################################################
###### End managment ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}SCRIPT END${nc} ${green}#####${nc}
${green}----------------------${nc}
"

# Save and Deactive Gevarli environment
conda env export > ${workdir}/results/10_Reports/gevarli_${gevarli_version}.yaml
conda deactivate gevarli_${gevarli_version}

# Cleanup
find ${workdir}/results/ -type f -empty -delete # Remove empty file (like empty log)
#find ${workdir}/results/ -type d -empty -delete # Remove empty directory

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
Latest modifications ___ 2022.11.03
Run ____________________ bash Start_GeVarLi.sh

Operating System _______ ${os}

                   Brand(R) | Type(R) | Model | @ Speed GHz
Chip Model Name ________ ${model_name}
Physical CPUs __________ ${physical_cpu} cores
Logical CPUs ___________ ${logical_cpu} threads
System Memory __________ ${ram_size} Gb of RAM

Conda version __________ ${conda_version}
Snakemake version ______ ${snakemake_version}
Conda frontend _________ ${conda_frontend}

Working directory ______ ${workdir}/
Samples processed ______ ${samples} samples (${fastq} fastq files)

max Threads ____________ ${max_threads} of ${logical_cpu} threads available
max Memory _____________ ${max_memory} of ${ram_size} Gb available
job Memory  ____________ ${memory_per_job} Gb per job maximum

genome Reference _______ ${reference}
Aligner ________________ ${aligner}

min Coverage ___________ ${min_cov}
min Allele Frequency ___ ${min_af}

run Nextclade __________ ${nextclade}
run Pangolin ___________ ${pangolin}

run BamClipper _________ ${bamclipper}
Primers kit ____________ ${amplicons_kit}

Start time _____________ ${time_stamp_start}
End time _______________ ${time_stamp_end}
Processing time ________ ${minutes} minutes and ${seconds} seconds elapsed
" > ${workdir}/results/10_Reports/settings_logs.txt

echo -e "
${green}------------------------------------------------------------------------${nc}
"
###############################################################################
