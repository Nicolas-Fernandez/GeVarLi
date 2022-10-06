#!/bin/bash

##### Colors ######
red="\033[1;31m"   # red
green="\033[1;32m" # green
ylo="\033[1;33m"   # yellow
blue="\033[1;34m"  # blue
nc="\033[0m"       # no color

###### About ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}ABOUT${nc} ${green}#####${nc}"
echo -e "${green}-----------------${nc}"
echo ""
echo -e "${blue}Name${nc} __________________ Start_GeVarLi.sh"
echo -e "${blue}Author${nc} ________________ Nicolas Fernandez"
echo -e "${blue}Affiliation${nc} ___________ IRD_U233_TransVIHMI"
echo -e "${blue}Aim${nc} ___________________ Bash script for ${red}GE${nc}ome assembling, ${red}VAR${nc}iant calling and ${red}LI${nc}neage assignation"
echo -e "${blue}Date${nc} __________________ 2021.10.12"
echo -e "${blue}Run${nc} ___________________ bash Start_GeVarLi.sh"
echo -e "${blue}Latest Modification${nc} ___ 2022.09.16"


###### Hardware ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}OPERATING SYSTEM${nc} ${green}#####${nc}"
echo -e "${green}--------------------${nc}"
echo ""

# Operating System
case "$OSTYPE" in
  linux*)   os="Linux" ;;
  bsd*)     os="BSD" ;;
  darwin*)  os="OSX" ;;
  solaris*) os="Solaris" ;;
  msys*)    os="Windows" ;;
  cygwin*)  os="Windows" ;;
  *)        os="Unknown (${OSTYPE})" ;;
esac

echo -e "${blue}Operating system${nc} _______ ${red}${os}${nc}" # Print operating system 


###### Hardware ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}HARDWARE${nc} ${green}#####${nc}"
echo -e "${green}--------------------${nc}"
echo ""

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

echo -e "                         ${ylo}Brand(R)${nc} | ${ylo}Type(R)${nc} | ${ylo}Model${nc} | ${ylo}@ Speed GHz${nc}" # Print header chip model name
echo -e "${blue}Chip Model Name${nc} ________ ${model_name}"                     # Print chip model name
echo -e "${blue}Physical CPUs${nc} __________ ${red}${physical_cpu}${nc} cores"  # Print physical cpu
echo -e "${blue}Logical CPUs${nc} ___________ ${red}${logical_cpu}${nc} threads" # Print logical cpu
echo -e "${blue}System Memory${nc} __________ ${red}${ram_gb}${nc} Gb of RAM"    # Print RAM size in Gb

###### Settings ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}SETTINGS${nc} ${green}#####${nc}"
echo -e "${green}--------------------${nc}"
echo ""

workdir=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)                                          # Get working directory
fastq=$(expr $(ls -l ${workdir}/resources/reads/*.fastq.gz | wc -l))                            # Count fastq.gz files
samples=$(expr ${fastq} \/ 2)                                                                   # fastq files / 2 = samples (paired-end)
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

echo -e "${blue}Working Directory${nc} ______ ${workdir}/"                                                     # Print working directory
echo -e "${blue}Samples Processed${nc} ______ ${red}${samples}${nc} samples (${ylo}${fastq}${nc} fastq files)" # Print samples number 
echo ""                                                                                                        # 
echo -e "${blue}Maximum Threads${nc} ________ ${red}${max_threads}${nc} of ${ylo}${logical_cpu}${nc} threads available" # Print max threads
echo -e "${blue}Maximum Memory${nc} _________ ${red}${max_memory}${nc} of ${ylo}${ram_gb}${nc} Gb available"   # Print max memory
echo -e "${blue}Memory per job${nc} _________ ${red}${memory_per_job}${nc} Gb per job"                         # Print max memory per job
echo ""       	      	      	      	      	      	      	      	      	      	      	      	       # 
echo -e "${blue}Genome Reference${nc} _______ ${ylo}${reference}${nc}"                                         # Print user config genome reference
echo -e "${blue}Aligner${nc} ________________ ${ylo}${aligner}${nc}"                                           # Print user config aligner
echo -e "${blue}Min. Coverage${nc} __________ ${red}${min_cov}${nc}x"                                          # Print user config minimum coverage
echo -e "${blue}Min. Allele Frequency${nc} __ ${red}${min_af}${nc}"                                            # Print user config minimum Al.Freq.
echo ""       	      	      	      	      	      	      	      	      	      	      	      	       # 
echo -e "${blue}Nextclade run${nc} __________ ${red}${nextclade}${nc}"                                         # Print if nexclade will run
echo -e "${blue}Pangolin run${nc} ___________ ${red}${pangolin}${nc}"                                          # Print if pangolin will run
echo -e "${blue}BamClipper run${nc} _________ ${red}${bamclipper}${nc}"                                        # Print if bamclipper will run
echo -e "${blue}Primers Kit${nc} ____________ ${ylo}${amplicon_kit}${nc}"                                      # Print if amplicon kit used
echo ""                                                                                                        #
echo -e "${blue}Start Time${nc} _____________ ${time_stamp_start}"                                             # Print analyzes starting time


###### Installations ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}INSTALLATIONS${nc} ${green}#####${nc}"
echo -e "${green}-------------------------${nc}"
echo ""

# Mamba
if ls ~/miniconda3/bin/mamba 2> /dev/null
then
    echo ""
else
    conda install -n base -c conda-forge mamba --yes
fi

# Snakemake
#snake_ver="7.8.2"
snake_ver="6.12.3"
if ls ~/miniconda3/bin/snakemake 2> /dev/null
then
    echo ""
else
    #mamba install -n base -c conda-forge -c bioconda snakemake==${snake_ver} --yes
    conda install -n base -c conda-forge -c bioconda snakemake==${snake_ver} --yes
fi

# Rename
if ls ~/miniconda3/bin/rename 2> /dev/null
then
    echo ""
else
    #mamba install -n base -c bioconda rename --yes
    conda install -n base -c bioconda rename --yes
fi


###### Rename samples ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}RENAME FASTQ FILES${nc} ${green}#####${nc}"
echo -e "${green}------------------------------${nc}"
echo ""

# Rename fastq files to remove "_001" Illumina pattern.
## De/comment (#) if you want keep Illumina barcode-ID and/or Illumina line-ID
rename "s/_S\d+_/_/" ${workdir}/resources/reads/*.fastq.gz                # Remove barcode-ID like {_S001_}
rename "s/_L\d+_/_/" ${workdir}/resources/reads/*.fastq.gz                # Remove line-ID ID like {_L001_}
rename "s/_001.fastq.gz/.fastq.gz/" ${workdir}/resources/reads/*.fastq.gz # Remove end-name ID like {_001}.fastq.gz


###### Call snakemake pipeline ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}SNAKEMAKE PIPELINE${nc} ${green}#####${nc}"
echo -e "${green}------------------------------${nc}"
echo ""

snakefile_list="indexing_genomes quality_control gevarli"

echo -e "${blue}Unlocking working directory:${nc}"
echo ""
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

echo ""
echo -e "${blue}Conda environments list:${nc}"
echo ""
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

echo ""
echo -e "${blue}Conda environments setup:${nc}"
echo ""
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

echo ""
echo -e "${blue}Dry run:${nc}"
echo ""
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

echo ""
echo -e "${blue}Let's run!${nc}"
echo ""
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

###### Create usefull graphs, summary and logs ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}SNAKEMAKE PIPELINE LOGS${nc} ${green}#####${nc}"
echo -e "${green}-------------------------------------${nc}"
echo ""

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

cp ${workdir}/config/config.yaml ${workdir}/results/10_Reports/config.yaml


settings_log="${workdir}/results/10_Reports/settings.txt"
echo ""                                                                            >> ${settings_log} #  
echo "Operating system _______ ${os}"                                              >> ${settings_log} # Log operating system
echo ""                                                                            >> ${settings_log} #
echo "                        Brand(R) | Type(R) | Model | @ Speed GHz"            >> ${settings_log} # Log header chip model name
echo "Chip Model Name ________ ${model_name}"                                      >> ${settings_log} # Log chip model name
echo "Physical CPUs __________ ${physical_cpu} cores"                              >> ${settings_log} # Log physical cpu
echo "Logical CPUs ___________ ${logical_cpu} threads"                             >> ${settings_log} # Log logical cpu
echo "System Memory __________ ${ram_size} Gb of RAM"                              >> ${settings_log} # Log RAM size
echo ""                                                                            >> ${settings_log} #
echo "Working Directory ______ ${workdir}/"                                        >> ${settings_log} # Log working directory
echo "Samples Processed ______ ${samples} samples (${fastq} fastq files)"          >> ${settings_log} # Log samples number 
echo "Maximum Threads ________ ${max_threads} of ${logical_cpu} threads available" >> ${settings_log} # Log max threads
echo "Maximum Memory _________ ${max_memory} of ${ram_size} Gb available"          >> ${settings_log} # Log max memor
echo "Memory per job _________ ${memory_per_job} Gb per job maximum"               >> ${settings_log} # Log max memory per job
echo "Genome Reference _______ ${reference}"                                       >> ${settings_log} # Log user config genome reference
echo "Aligner ________________ ${aligner}"                                         >> ${settings_log} # Log user config aligner
echo "Min. Coverage __________ ${min_cov}"                                         >> ${settings_log} # Log user config minimum coverage
echo "Min. Allele Frequency __ ${min_af}"                                          >> ${settings_log} # Log user config snvs cov min
echo ""                                                                            >> ${settings_log} #
echo "Nextclade run __________ ${nextclade}"                                       >> ${settings_log} # Log if nexclade will run
echo "Pangolin run ___________ ${pangolin}"                                        >> ${settings_log} # Log if pangolin will run
echo "BamClipper run _________ ${bamclipper}"                                      >> ${settings_log} # Log if bamclipper will run
echo "Primers Kit ____________ ${amplicon_kit}"                                    >> ${settings_log} # Log if amplicon kit used


###### Concatenate all consensus fasta ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}CONCATENATE FASTA FILES${nc} ${green}#####${nc}"
echo -e "${green}-----------------------------------${nc}"
echo ""

cat ${workdir}/results/05_Consensus/*_consensus.fasta > ${workdir}/results/All_consensus_sequences.fasta

# and copy multiqc_report.html to results/ dir root
cp ${workdir}/results/00_Quality_Control/multiqc/multiqc_report.html ${workdir}/results/All_readsQC_reports.html


###### Concatenate all coverage stats ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}CONCATENATE COVERAGE STATS${nc} ${green}#####${nc}"
echo -e "${green}--------------------------------------${nc}"
echo ""

cat ${workdir}/results/03_Coverage/*coverage-stats.tsv > ${workdir}/results/All_genome_coverages.tsv

awk "NR==1 || NR%2==0" ${workdir}/results/All_genome_coverages.tsv > ${workdir}/results/GENCOV.tmp \
    && mv ${workdir}/results/GENCOV.tmp ${workdir}/results/All_genome_coverages.tsv


###### Concatenate all Pangolin lineage reports ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}CONCATENATE PANGOLIN REPORTS${nc} ${green}#####${nc}"
echo -e "${green}----------------------------------------${nc}"
echo ""

cat ${workdir}/results/06_Lineages/*_pangolin-report.csv > ${workdir}/results/All_pangolin_lineages.csv

awk "NR==1 || NR%2==0" ${workdir}/results/All_pangolin_lineages.csv > ${workdir}/results/PANGO.tmp \
    && mv ${workdir}/results/PANGO.tmp ${workdir}/results/All_pangolin_lineages.csv

sed "s/,/\t/g" ${workdir}/results/All_pangolin_lineages.csv > ${workdir}/results/All_pangolin_lineages.tsv

rm -f ${workdir}/results/All_pangolin_lineages.csv


###### Concatenate all Nextclade lineage reports ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}CONCATENATE NEXTCLADE REPORTS${nc} ${green}#####${nc}"
echo -e "${green}-----------------------------------------${nc}"
echo ""

cat ${workdir}/results/06_Lineages/*_nextclade-report.tsv > ${workdir}/results/All_nextclade_lineages.tsv

awk "NR==1 || NR%2==0" ${workdir}/results/All_nextclade_lineages.tsv > ${workdir}/results/NEXT.tmp \
    && mv ${workdir}/results/NEXT.tmp ${workdir}/results/All_nextclade_lineages.tsv


###### End managment ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}SCRIPT END${nc} ${green}#####${nc}"
echo -e "${green}----------------------${nc}"
echo ""

find ${workdir}/results/ -type f -empty -delete # Remove empty file (like empty log)
#find ${workdir}/results/ -type d -empty -delete # Remove empty directory

time_stamp_end=$(date +"%Y-%m-%d %H:%M") # Get date / hour ending analyzes
elapsed_time=${SECONDS}                  # Get SECONDS counter 
minutes=$((${elapsed_time}/60))          # / 60 = minutes
seconds=$((${elapsed_time}%60))          # % 60 = seconds

echo -e "${blue}End Time${nc} _______________ ${time_stamp_end}"                                                       # Print analyzes ending time
echo -e "${blue}Processing Time${nc} ________ ${ylo}${minutes}${nc} minutes and ${ylo}${seconds}${nc} seconds elapsed" # Print total time elapsed

echo ""
echo "Start Time _____________ ${time_stamp_start}"                               >> ${settings_log} # Log analyzes starting time
echo "End Time _______________ ${time_stamp_end}"                                 >> ${settings_log} # Log analyzes ending time
echo "Processing Time ________ ${minutes} minutes and ${seconds} seconds elapsed" >> ${settings_log} # Log analyzes total time


echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo ""
