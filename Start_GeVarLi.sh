#!/bin/bash

###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name __________________ Start_GeVarLi.sh
# Version _______________ v.2022.11
# Author ________________ Nicolas Fernandez
# Affiliation ___________ IRD_U233_TransVIHMI
# Aim ___________________ Bash script running gevarli.smk snakefile
# Date __________________ 2021.10.12
# Latest modification ___ 2022.11.03
# Use ___________________ bash Start_GeVarLi.sh

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

${blue}Name${nc} __________________ Start_GeVarLi.sh
${blue}Version${nc} _______________ v.2022.11
${blue}Author${nc} ________________ Nicolas Fernandez
${blue}Affiliation${nc} ___________ IRD_U233_TransVIHMI
${blue}Aim${nc} ___________________ Bash script for ${red}GE${nc}ome assembling, ${red}VAR${nc}iant calling and ${red}LI${nc}neage assignation
${blue}Date${nc} __________________ 2021.10.12
${blue}Latest modification${nc} ___ 2022.11.03
${blue}Run${nc} ___________________ bash Start_GeVarLi.sh
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
    "Please, use 'OSX' or 'Linux' operating system"
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
fastq=$(expr $(ls -l ${workdir}/resources/reads/*.fastq.gz | wc -l))                            # Count fastq.gz files
samples=$(expr ${fastq} \/ 2)                                                                   # fastq files / 2 = samples (paired-end)
snakemake_version=$(grep -o -E "snakemake_version: '[0-9]+\.[0-9]+\.[0-9]+'" ${workdir}/config/config.yaml | \
			sed "s/snakemake_version: //" | sed "s/'//g")                           # Get snakemake version
conda_frontend=$(grep -o -E "conda_frontend: '[a-z]+'"  ${workdir}/config/config.yaml | \
		     sed "s/conda_frontend: //" | sed "s/'//g")                                 # Get conda frontend
max_threads=$(grep -o -E "cpus: [0-9]+" ${workdir}/config/config.yaml | sed "s/cpus: //")       # Get user config for max threads
max_memory=$(grep -o -E "ram: [0-9]+" ${workdir}/config/config.yaml | sed "s/ram: //")          # Get user config for max memory
memory_per_job=$(expr ${max_memory} \/ ${max_threads})                                          # Calcul maximum memory usage per job
reference=$(grep -o -E "reference: '.+'" ${workdir}/config/config.yaml | sed "s/reference: //") # Get user config genome reference
aligner=$(grep -o -E "^aligner: '[a-z]+'" ${workdir}/config/config.yaml | sed "s/aligner: //")  # Get user config aligner
min_cov=$(grep -o -E "mincov: [0-9]+" ${workdir}/config/config.yaml | sed "s/mincov: //")       # Get user config minimum coverage
min_af=$(grep -o -E "minaf: [0-1]\.[0-9]+" ${workdir}/config/config.yaml | sed "s/minaf: //")   # Get user config minimum allele frequency
clipping=$(grep -o -E "clipping: '.+'" ${workdir}/config/config.yaml | sed "s/clipping: //")    # Get user config bamclipper option
primers=$(grep -o -E "primers: '.+'" ${workdir}/config/config.yaml | sed "s/primers: //")       # Get user config bamclipper primers
time_stamp_start=$(date +"%Y-%m-%d %H:%M")                                                      # Get analyzes starting time
SECONDS=0                                                                                       # Initialize SECONDS counter

if [[ "${reference}" = "'SARS-CoV-2_Wuhan_MN908947-3'" ]]
then
    nextclade="Yes"
    pangolin="Yes"
elif [[ "${reference}" = "'Monkeypox-virus_Zaire_AF380138-1'" ]]
then
    nextclade="Yes"
    pangolin="No"
else
    nextclade="No"
    pangolin="No"
fi

if [[ "${clipping}" = "'yes'" ]]
then
    bamclipper="Yes"
    amplicon_kit=${primers}
elif [[ "${clipping}" = "'no'" ]]
then
    bamclipper="No"
    amplicon_kit="'none'"
else
    bamclipper="error_config_file"
    amplicon_kit="'error_config_file'"
fi

# Print some analyzes settings
echo -e "
${blue}Working Directory${nc} ______ ${workdir}/
${blue}Samples Processed${nc} ______ ${red}${samples}${nc} samples (${ylo}${fastq}${nc} fastq files)

${blue}Snakemake version${nc} ______ ${ylo}${snakemake_version}${nc}
${blue}Conda frontend${nc} _________ ${ylo}${conda_frontend}${nc}

${blue}Maximum Threads${nc} ________ ${red}${max_threads}${nc} of ${ylo}${logical_cpu}${nc} threads available
${blue}Maximum Memory${nc} _________ ${red}${max_memory}${nc} of ${ylo}${ram_gb}${nc} Gb available
${blue}Memory per job${nc} _________ ${red}${memory_per_job}${nc} Gb per job

${blue}Genome Reference${nc} _______ ${ylo}${reference}${nc}
${blue}Aligner${nc} ________________ ${ylo}${aligner}${nc}

${blue}Min. Coverage${nc} __________ ${red}${min_cov}${nc}x
${blue}Min. Allele Frequency${nc} __ ${red}${min_af}${nc}

${blue}Nextclade run${nc} __________ ${red}${nextclade}${nc}
${blue}Pangolin run${nc} ___________ ${red}${pangolin}${nc}

${blue}BamClipper run${nc} _________ ${red}${bamclipper}${nc}
${blue}Primers Kit${nc} ____________ ${ylo}${amplicon_kit}${nc}

${blue}Start Time${nc} _____________ ${time_stamp_start}
"

###############################################################################
###### Installations ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}INSTALLATIONS${nc} ${green}#####${nc}
${green}-------------------------${nc}
"

# Mamba (to install environments)
if ls ~/miniconda3/bin/mamba 2> /dev/null
then
    echo ""
else
    conda install -n base -c conda-forge mamba --yes
fi

# Snakemake (to run GeVarLi)
if ls ~/miniconda3/bin/snakemake 2> /dev/null
then
    echo ""
else
    ${conda_frontend} install -n base -c conda-forge -c bioconda snakemake==${snakemake_version} --yes
fi

# Rename (to rename fastq files)
if ls ~/miniconda3/bin/rename 2> /dev/null
then
    echo ""
else
    ${conda_frontend} install -n base -c bioconda rename --yes
fi

# Graphviz (to dot snakemake DAG)
if ls ~/miniconda3/bin/graphviz 2> /dev/null
then
    echo ""
else
    ${conda_frontend} install -n base -c anaconda graphviz --yes
fi

###############################################################################
###### Rename samples ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}RENAME FASTQ FILES${nc} ${green}#####${nc}
${green}------------------------------${nc}
"

# Rename fastq files to remove "_001" Illumina pattern.
## De/comment (#) if you want keep Illumina barcode-ID and/or Illumina line-ID
rename "s/_S\d+_/_/" ${workdir}/resources/reads/*.fastq.gz                # Remove barcode-ID like {_S001_}
rename "s/_L\d+_/_/" ${workdir}/resources/reads/*.fastq.gz                # Remove line-ID ID like {_L001_}
rename "s/_001.fastq.gz/.fastq.gz/" ${workdir}/resources/reads/*.fastq.gz # Remove end-name ID like {_001}.fastq.gz


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
    echo -e "${blue}For ${snakefile}:${nc}"
    snakemake \
	--directory ${workdir}/ \
        --snakefile ${workdir}/workflow/rules/${snakefile}.smk \
        --config os=${os} \
        --rerun-incomplete \
        --unlock
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
    echo -e "${blue}For ${snakefile}:${nc}"
    snakemake \
        --directory ${workdir}/ \
        --snakefile ${workdir}/workflow/rules/${snakefile}.smk \
        --cores ${max_threads} \
        --config os=${os} \
        --rerun-incomplete \
        --list-conda-envs
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
# If mamba package manager is not available, or if you still prefer to use conda, you can enforce that with this setting (default: 'mamba').
# Default "mamba", recommended because much faster, but : "Library not loaded: @rpath/libarchive.13.dylib"
# If specified, only creates the job-specific conda environments then exits. The –use-conda flag must also be set.

for snakefile in ${snakefile_list} ; do
    echo -e "${blue}For ${snakefile}:${nc}"
    snakemake \
        --directory ${workdir}/ \
        --snakefile ${workdir}/workflow/rules/${snakefile}.smk \
        --cores ${max_threads} \
        --config os=${os} \
        --rerun-incomplete \
        --use-conda \
        --conda-frontend conda \
        --conda-create-envs-only 
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
# If mamba package manager is not available, or if you still prefer to use conda, you can enforce that with this setting (default: 'mamba').
# Default "mamba", recommended because much faster, but : "Library not loaded: @rpath/libarchive.13.dylib"
# Tell the scheduler to assign creation of given targets (and all their dependencies) highest priority.
# Do not execute anything, and display what would be done. If very large workflow, use –dry-run –quiet to just print a summary of the DAG of jobs.
# Do not output any progress or rule information.

for snakefile in ${snakefile_list} ; do
    echo -e "${blue}For ${snakefile}:${nc}"
    snakemake \
        --directory ${workdir}/ \
        --snakefile ${workdir}/workflow/rules/${snakefile}.smk \
        --cores ${max_threads}\
        --config os=${os} \
        --rerun-incomplete \
        --use-conda \
        --conda-frontend conda \
        --dry-run \
        --quiet
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
# If mamba package manager is not available, or if you still prefer to use conda, you can enforce that with this setting (default: 'mamba').
# Default "mamba", recommended because much faster, but : "Library not loaded: @rpath/libarchive.13.dylib"
# Tell the scheduler to assign creation of given targets (and all their dependencies) highest priority.
# Print out the shell commands that will be executed.

for snakefile in ${snakefile_list} ; do
    echo -e "${blue}For ${snakefile}:${nc}"
    snakemake \
        --directory ${workdir}/ \
        --snakefile ${workdir}/workflow/rules/${snakefile}.smk \
        --cores ${max_threads} \
        --max-threads ${max_threads} \
        --config os=${os} \
        --rerun-incomplete \
        --keep-going \
        --use-conda \
        --conda-frontend conda \
        --printshellcmds
done

###############################################################################
###### Concatenate all consensus fasta ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}CONCATENATE FASTA FILES${nc} ${green}#####${nc}
${green}-----------------------------------${nc}
"
cat ${workdir}/results/05_Consensus/*_consensus.fasta > ${workdir}/results/All_consensus_sequences.fasta

cp ${workdir}/results/00_Quality_Control/multiqc/multiqc_report.html ${workdir}/results/All_readsQC_reports.html

###############################################################################
###### Concatenate all coverage stats ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}CONCATENATE COVERAGE STATS${nc} ${green}#####${nc}
${green}--------------------------------------${nc}
"
cat ${workdir}/results/03_Coverage/*coverage-stats.tsv > ${workdir}/results/All_genome_coverages.tsv

awk "NR==1 || NR%2==0" ${workdir}/results/All_genome_coverages.tsv > ${workdir}/results/GENCOV.tmp \
    && mv ${workdir}/results/GENCOV.tmp ${workdir}/results/All_genome_coverages.tsv

###############################################################################
###### Concatenate all Pangolin lineage reports ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}CONCATENATE PANGOLIN REPORTS${nc} ${green}#####${nc}
${green}----------------------------------------${nc}
"

cat ${workdir}/results/06_Lineages/*_pangolin-report.csv > ${workdir}/results/All_pangolin_lineages.csv

awk "NR==1 || NR%2==0" ${workdir}/results/All_pangolin_lineages.csv > ${workdir}/results/PANGO.tmp \
    && mv ${workdir}/results/PANGO.tmp ${workdir}/results/All_pangolin_lineages.csv

sed "s/,/\t/g" ${workdir}/results/All_pangolin_lineages.csv > ${workdir}/results/All_pangolin_lineages.tsv

rm -f ${workdir}/results/All_pangolin_lineages.csv

###############################################################################
###### Concatenate all Nextclade lineage reports ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}CONCATENATE NEXTCLADE REPORTS${nc} ${green}#####${nc}
${green}-----------------------------------------${nc}
"

cat ${workdir}/results/06_Lineages/*_nextclade-report.tsv > ${workdir}/results/All_nextclade_lineages.tsv

awk "NR==1 || NR%2==0" ${workdir}/results/All_nextclade_lineages.tsv > ${workdir}/results/NEXT.tmp \
    && mv ${workdir}/results/NEXT.tmp ${workdir}/results/All_nextclade_lineages.tsv

###############################################################################
###### Create usefull graphs, summary and logs ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}SNAKEMAKE PIPELINE LOGS${nc} ${green}#####${nc}
${green}-------------------------------------${nc}
"
mkdir ${workdir}/results/10_Reports/graphs/ 2> /dev/null

graph_list="dag rulegraph filegraph"
extention_list="pdf png"

for snakefile in ${snakefile_list} ; do
    for graph in ${graph_list} ; do
	for extention in ${extention_list} ; do
	    snakemake \
		--directory ${workdir}/ \
                --snakefile ${workdir}/workflow/rules/${snakefile}.smk \
                --${graph} | \
	        dot -T${extention} > \
		${workdir}/results/10_Reports/graphs/${snakefile}_${graph}.${extention} ;
	done ;
    done ;
done

for snakefile in ${snakefile_list} ; do
    snakemake \
        --directory ${workdir} \
        --snakefile ${workdir}/workflow/rules/${snakefile}.smk \
        --summary > ${workdir}/results/10_Reports/${snakefile}_files_summary.txt ;
done

cp ${workdir}/config/config.yaml ${workdir}/results/10_Reports/config_used.yaml

###############################################################################
###### End managment ######
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}SCRIPT END${nc} ${green}#####${nc}
${green}----------------------${nc}
"
# Cleanup
#find ${workdir}/results/ -type f -empty -delete # Remove empty file (like empty log)
#find ${workdir}/results/ -type d -empty -delete # Remove empty directory

# Timer
time_stamp_end=$(date +"%Y-%m-%d %H:%M") # Get date / hour ending analyzes
elapsed_time=${SECONDS}                  # Get SECONDS counter 
minutes=$((${elapsed_time}/60))          # / 60 = minutes
seconds=$((${elapsed_time}%60))          # % 60 = seconds

# Print timer
echo -e "
${blue}End Time${nc} _______________ ${time_stamp_end}
${blue}Processing Time${nc} ________ ${ylo}${minutes}${nc} minutes and ${ylo}${seconds}${nc} seconds elapsed
"

# Log analyzes settings
echo "
${blue}Name${nc} __________________ Start_GeVarLi.sh
${blue}Version${nc} _______________ v.2022.11
${blue}Author${nc} ________________ Nicolas Fernandez
${blue}Affiliation${nc} ___________ IRD_U233_TransVIHMI
${blue}Aim${nc} ___________________ Bash script for GeVarLi
${blue}Date${nc} __________________ 2021.10.12
${blue}Latest modification${nc} ___ 2022.11.03
${blue}Run${nc} ___________________ bash Start_GeVarLi.sh

Operating system __________________ ${os}

                                   Brand(R) | Type(R) | Model | @ Speed GHz
Chip Model Name ___________________ ${model_name}
Physical CPUs _____________________ ${physical_cpu} cores
Logical CPUs ______________________ ${logical_cpu} threads
System Memory _____________________ ${ram_size} Gb of RAM

Working Directory _________________ ${workdir}/
Samples Processed _________________ ${samples} samples (${fastq} fastq files)

Maximum Threads ___________________ ${max_threads} of ${logical_cpu} threads available
Maximum Memory ____________________ ${max_memory} of ${ram_size} Gb available
Memory per job ____________________ ${memory_per_job} Gb per job maximum

Genome Reference __________________ ${reference}
Aligner ___________________________ ${aligner}

Min. Coverage _____________________ ${min_cov}
Min. Allele Frequency _____________ ${min_af}

Nextclade run _____________________ ${nextclade}
Pangolin run ______________________ ${pangolin}

BamClipper run ____________________ ${bamclipper}
Primers Kit _______________________ ${amplicon_kit}

Start Time ________________________ ${time_stamp_start}
End Time __________________________ ${time_stamp_end}
Processing Time ___________________ ${minutes} minutes and ${seconds} seconds elapsed
" > ${workdir}/results/10_Reports/settings_logs.txt

echo -e "
${green}------------------------------------------------------------------------${nc}
"
###############################################################################
