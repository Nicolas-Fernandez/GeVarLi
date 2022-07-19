#!/bin/bash

##### colors ######
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
echo -e "${blue}Name${nc} __________________ GeVarLi.sh"
echo -e "${blue}Author${nc} ________________ Nicolas Fernandez"
echo -e "${blue}Affiliation${nc} ___________ IRD_U233_TransVIHMI"
echo -e "${blue}Aim${nc} ___________________ Bash script for ${red}GE${nc}ome assembling, ${red}VAR${nc}iant calling and ${red}LI${nc}neage assignation"
echo -e "${blue}Date${nc} __________________ 2021.10.12"
echo -e "${blue}Run${nc} ___________________ bash GeVarLi.sh"
echo -e "${blue}Latest Modification${nc} ___ 2022.07.19"
echo -e "${blue}Todo${nc} __________________ done"


###### Hardware ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}HARDWARE${nc} ${green}#####${nc}"
echo -e "${green}--------------------${nc}"
echo ""

model_name=$(sysctl -n machdep.cpu.brand_string) # Get chip model name
physical_cpu=$(sysctl -n hw.physicalcpu)         # Get physical cpu
logical_cpu=$(sysctl -n hw.logicalcpu)           # Get logical cpu
mem_size=$(sysctl -n hw.memsize)                 # Get memory size (bit)
ram_size=$(expr ${mem_size} \/ $((1024**3)) )    # / 1024**3 = Gb

echo -e "                        ${ylo}Brand(R)${nc} | ${ylo}Type(R)${nc} | ${ylo}Model${nc} | ${ylo}@ Speed GHz${nc}" # Print header chip model name
echo -e "${blue}Chip Model Name${nc} _______ ${model_name}"                     # Print chip model name
echo -e "${blue}Physical CPUs${nc} _________  ${red}${physical_cpu}${nc} cores" # Print physical cpu
echo -e "${blue}Logical CPUs${nc} __________ ${red}${logical_cpu}${nc} threads" # Print logical cpu
echo -e "${blue}System Memory${nc} _________ ${red}${ram_size}${nc} Gb of RAM"  # Print RAM size

###### Settings ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}SETTINGS${nc} ${green}#####${nc}"
echo -e "${green}--------------------${nc}"
echo ""

workdir=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)                                          # Get working directory
fastq=$(expr $(ls -l ${workdir}/resources/reads/*.fastq.gz | wc -l))                            # Count fastq.gz files
samples=$(expr ${fastq} \/ 2)                                                                   # / 2 = samples (paired-end)
max_threads=$(grep -o -E "cpus: [0-9]+" ${workdir}/config/config.yaml | sed "s/cpus: //")       # Get user config for max threads
max_memory=$(grep -o -E "mem_gb: [0-9]+" ${workdir}/config/config.yaml | sed "s/mem_gb: //")    # Get user config for max memory
reference=$(grep -o -E "reference: '.+'" ${workdir}/config/config.yaml | sed "s/reference: //") # Get user config genome reference
aligner=$(grep -o -E "^aligner: '[a-z]+'" ${workdir}/config/config.yaml | sed "s/aligner: //")  # Get user config aligner
min_cov=$(grep -o -E "mincov: [0-9]+" ${workdir}/config/config.yaml | sed "s/mincov: //")       # Get user config minimum coverage
min_af=$(grep -o -E "minaf: [0-1]\.[0-9]+" ${workdir}/config/config.yaml | sed "s/minaf: //")   # Get user config minimum allele frequency
time_stamp_start=$(date +"%Y-%m-%d %H:%M")                                                      # Get analyzes starting time
SECONDS=0                                                                                       # Initialize SECONDS counter

echo -e "${blue}Working Directory${nc} _____ ${workdir}/"                                                     # Print working directory
echo -e "${blue}Samples Processed${nc} _____ ${red}${samples}${nc} samples (${ylo}${fastq}${nc} fastq files)" # Print samples number 
echo -e "${blue}Maximum Threads${nc} _______ ${red}${max_threads}${nc} of ${ylo}${logical_cpu}${nc} threads available" # Print max threads
echo -e "${blue}Maximum Memory${nc} ________ ${red}${max_memory}${nc} of ${ylo}${ram_size}${nc} Gb available" # Print max memory
echo -e "${blue}Genome Reference${nc} ______ ${red}${reference}${nc}"                                         # Print user config genome reference
echo -e "${blue}Aligner${nc} _______________ ${ylo}${aligner}${nc}"                                           # Print user config aligner
echo -e "${blue}Min. Coverage${nc} _________ ${red}${min_cov}${nc}x"                                          # Print user config minimum coverage
echo -e "${blue}Min. Allele Frequency${nc} _ ${red}${min_af}${nc}"                                            # Print user config snvs cov min
echo -e "${blue}Start Time${nc} ____________ ${time_stamp_start}"                                             # Print analyzes starting time


###### Snakemake installation ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}SNAKEMAKE INSTALLATION${nc} ${green}#####${nc}"
echo -e "${green}----------------------------------${nc}"
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
    mamba install -n base -c conda-forge -c bioconda snakemake==${snake_ver} --yes
fi
# Rename
if ls ~/miniconda3/bin/rename 2> /dev/null
then
    echo ""
else
    mamba install -n base -c bioconda rename --yes
fi


###### Rename samples ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}RENAME FASTQ FILES${nc} ${green}#####${nc}"
echo -e "${green}------------------------------${nc}"
echo ""

# Rename fastq files to remove "_001" Illumina pattern. De/comment (#) if you want keep Illumina barcode-ID and/or Illumina line-ID
rename "s/_S\d+_/_/" ${workdir}/resources/reads/*.fastq.gz                # Remove barcode-ID like {_S001_}
rename "s/_L\d+_/_/" ${workdir}/resources/reads/*.fastq.gz               # Remove line-ID ID like {_L001_}
rename "s/_001.fastq.gz/.fastq.gz/" ${workdir}/resources/reads/*.fastq.gz # Remove end-name ID like {_001}.fastq.gz


###### Call snakemake pipeline ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}SNAKEMAKE PIPELINE${nc} ${green}#####${nc}"
echo -e "${green}------------------------------${nc}"
echo ""

echo -e "${blue}Unlocking working directory:${nc}"
echo ""
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Re-run all jobs the output of which is recognized as incomplete.
# Remove a lock on the working directory.
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --rerun-incomplete \
    --unlock

echo ""
echo -e "${blue}Conda environments list:${nc}"
echo ""
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Re-run all jobs the output of which is recognized as incomplete.
# List all conda environments and their location on disk.
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --rerun-incomplete \
    --list-conda-envs

echo ""
echo -e "${blue}Conda environments update:${nc}"
echo ""
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# Re-run all jobs the output of which is recognized as incomplete.
# Cleanup unused conda environments.
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --cores \
    --rerun-incomplete \
    --conda-cleanup-envs

echo ""
echo -e "${blue}Conda environments setup:${nc}"
echo ""
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# Re-run all jobs the output of which is recognized as incomplete.
# If defined in the rule, run job in a conda environment.
# If specified, only creates the job-specific conda environments then exits. The –use-conda flag must also be set.
# If mamba package manager is not available, or if you still prefer to use conda, you can enforce that with this setting (default: 'mamba').
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --cores \
    --rerun-incomplete \
    --use-conda \
    --conda-create-envs-only \
    --conda-frontend mamba

echo ""
echo -e "${blue}Dry run:${nc}"
echo ""
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# Re-run all jobs the output of which is recognized as incomplete.
# If defined in the rule, run job in a conda environment.
# Tell the scheduler to assign creation of given targets (and all their dependencies) highest priority.
# Do not execute anything, and display what would be done. If very large workflow, use –dry-run –quiet to just print a summary of the DAG of jobs.
# Do not output any progress or rule information.
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --cores \
    --rerun-incomplete \
    --use-conda \
    --prioritize multiqc_reports_aggregation \
    --dry-run \
    --quiet

echo ""
echo -e "${blue}Let's run!${nc}"
echo ""
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# Re-run all jobs the output of which is recognized as incomplete.
# Go on with independent jobs if a job fails.
# If defined in the rule, run job in a conda environment.
# Tell the scheduler to assign creation of given targets (and all their dependencies) highest priority.
# Print out the shell commands that will be executed.
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --cores 1 \
    --rerun-incomplete \
    --keep-going \
    --use-conda \
    --prioritize multiqc_reports_aggregation \
    --printshellcmds


###### Create usefull graphs, summary and logs ######
echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo -e "${green}#####${nc} ${red}SNAKEMAKE PIPELINE LOGS${nc} ${green}#####${nc}"
echo -e "${green}-------------------------------------${nc}"
echo ""

mkdir ${workdir}/results/10_Graphs/ 2> /dev/null

graph_list="dag rulegraph filegraph"
extention_list="pdf png"

for graph in ${graph_list} ; do
    for extention in ${extention_list} ; do
	snakemake \
	    --directory ${workdir}/ \
            --snakefile ${workdir}/workflow/rules/gevarli.smk \
            --${graph} | \
	    dot -T${extention} > \
		${workdir}/results/10_Graphs/${graph}.${extention} ;
    done ;
done

snakemake \
    --directory ${workdir} \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --summary > ${workdir}/results/11_Reports/files_summary.txt

cp ${workdir}/config/config.yaml ${workdir}/results/11_Reports/config.yaml

echo "                        Brand(R) | Type(R) | Model | @ Speed GHz" >> ${workdir}/results/11_Reports/settings.log # Log header chip model name
echo "Chip Model Name _______ ${model_name}" >> ${workdir}/results/11_Reports/settings.log                            # Log chip model name
echo "Physical CPUs _________  ${physical_cpu} cores" >> ${workdir}/results/11_Reports/settings.log                   # Log physical cpu
echo "Logical CPUs __________ ${logical_cpu} threads" >> ${workdir}/results/11_Reports/settings.log                   # Log logical cpu
echo "System Memory _________ ${ram_size} Gb of RAM" >> ${workdir}/results/11_Reports/settings.log                    # Log RAM size

echo "Working Directory _____ ${workdir}/" >> ${workdir}/results/11_Reports/settings.log                               # Log working directory
echo "Samples Processed _____ ${samples} samples (${fastq} fastq files)" >> ${workdir}/results/11_Reports/settings.log # Log samples number 
echo "Maximum Threads _______ ${max_threads} of ${logical_cpu} threads available" >> ${workdir}/results/11_Reports/settings.log # Log max threads
echo "Maximum Memory ________ ${max_memory} of ${ram_size} Gb available" >> ${workdir}/results/11_Reports/settings.log # Log max memory
echo "Genome Reference ______ ${reference}" >> ${workdir}/results/11_Reports/settings.log                       # Log user config genome reference
echo "Aligner _______________ ${aligner}" >> ${workdir}/results/11_Reports/settings.log                         # Log user config aligner
echo "Min. Coverage _________ ${min_cov}" >> ${workdir}/results/11_Reports/settings.log                         # Log user config minimum coverage
echo "Min. Allele Frequency _ ${min_af}" >> ${workdir}/results/11_Reports/settings.log                          # Log user config snvs cov min
echo "Start Time ____________ ${time_stamp_start}" >> ${workdir}/results/11_Reports/settings.log                # Log analyzes starting time


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
find ${workdir}/results/ -type d -empty -delete # Remove empty directory

time_stamp_end=$(date +"%Y-%m-%d %H:%M") # Get date / hour ending analyzes
elapsed_time=${SECONDS}                  # Get SECONDS counter 
minutes=$((${elapsed_time}/60))          # / 60 = minutes
seconds=$((${elapsed_time}%60))          # % 60 = seconds

echo -e "${blue}End Time${nc} ______________ ${time_stamp_end}"                                                       # Print analyzes ending time
echo -e "${blue}Processing Time${nc} _______ ${ylo}${minutes}${nc} minutes and ${ylo}${seconds}${nc} seconds elapsed" # Print total time elapsed

echo ""
echo -e "${green}------------------------------------------------------------------------${nc}"
echo ""
