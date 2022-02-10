#!/bin/bash
                                                                                                                           
###### About ######
echo ""
echo "##### ABOUT #####"
echo "-----------------"
echo "Name: GeVarLi.sh"
echo "Author: Nicolas Fernandez"
echo "Affiliation: IRD_U233_TransVIHMI"
echo "Aim: Bash script for GEnome assembling, VARiant calling and LIneage assignation"
echo "Date: 2021.10.12"
echo "Run: bash GeVarLi.sh"
echo "Latest modification: 2021.02.08"
echo "Todo: done"
echo "________________________________________________________________________"

###### Hardware check ######
echo ""
echo "##### HARDWARE #####"
echo "--------------------"
echo ""
    
physicalcpu=$(sysctl -n hw.physicalcpu)     # Get physical cpu
echo "Physical CPU: ${physicalcpu}"         # Print physical cpu

logicalcpu=$(sysctl -n hw.logicalcpu)       # Get logical cpu
echo "Logical CPU: ${logicalcpu}"           # Print logical cpu

hwmemsize=$(sysctl -n hw.memsize)           # Get memory size
ramsize=$(expr ${hwmemsize} / $((1024**3))) # 1024**3 = GB
echo "System Memory: ${ramsize} GB"         # Print RAM size

echo "________________________________________________________________________"

###### Working directory ######
echo ""
echo "##### WORKING DIRECTORY #####"
echo "-----------------------------"

workdir=${0%/*}
echo "Working directory: ${workdir}/"

fastq=$(ls -l ${workdir}/resources/reads/*.fastq.gz | wc -l)
echo "Fastq files: ${fastq}"

SECONDS=0
timestampstart=$(date +'%Y-%m-%d %H:%M')
echo "Start time: ${timestampstart}"

echo "________________________________________________________________________"

###### Rename samples ######
# de/comment first line if you want to keep or remove barcode-ID in sample name
echo ""
echo "##### RENAME FASTQ FILES #####"
echo "------------------------------"

# With rename command from macOSX 
rename --verbose 's/_S\d+_/_/' ${workdir}/resources/reads/*.fastq.gz 2> /dev/null                # Remove barcode-ID like {_S001_}
rename --verbose 's/_L\d+_/_/' ${workdir}/resources/reads/*.fastq.gz 2> /dev/null                # Remove line-ID ID like {_L001_}
rename --verbose 's/_001.fastq.gz/.fastq.gz/' ${workdir}/resources/reads/*.fastq.gz 2> /dev/null # Remove end-name ID like {_001}.fastq.gz

# With rename command as part of the util-linux package
rename --verbose _S\d+_ _ ${workdir}/resources/reads/*.fastq.gz 2> /dev/null                # Remove barcode-ID like {_S001_}
rename --verbose _L\d+_ _ ${workdir}/resources/reads/*.fastq.gz 2> /dev/null                # Remove line-ID ID like {_L001_}
rename --verbose _001.fastq.gz .fastq.gz ${workdir}/resources/reads/*.fastq.gz 2> /dev/null # Remove end-name ID like {_001}.fastq.gz

echo "________________________________________________________________________"

###### Call snakemake pipeline ######
echo ""
echo "##### SNAKEMAKE PIPELINE #####"
echo "-----------------------------"

echo "Conda environments list:"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# List all conda environments and their location on disk.
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --list-conda-envs

echo ""
echo "Conda environments update:"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# Cleanup unused conda environments.
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --cores \
    --conda-cleanup-envs

echo ""
echo "Conda environments setup:"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# If defined in the rule, run job in a conda environment.
# If specified, only creates the job-specific conda environments then exits. The –use-conda flag must also be set.
# If mamba package manager is not available, or if you still prefer to use conda, you can enforce that with this setting (default: 'mamba').
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --cores \
    --use-conda \
    --conda-create-envs-only \
    --conda-frontend mamba

echo ""
echo "Unlocking working directory:"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Remove a lock on the working directory.
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --unlock

echo ""
echo "Dry run:"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# If defined in the rule, run job in a conda environment.
# Tell the scheduler to assign creation of given targets (and all their dependencies) highest priority.
# Do not execute anything, and display what would be done. If you have a very large workflow, use –dry-run –quiet to just print a summary of the DAG of jobs.
# Do not output any progress or rule information.
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --cores \
    --use-conda \
    --dryrun \
    --quiet

echo ""
echo "Let's go!"
# Specify working directory (relative paths in the snakefile will use this as their origin).
# The workflow definition in form of a snakefile.
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# If defined in the rule, run job in a conda environment.
# Tell the scheduler to assign creation of given targets (and all their dependencies) highest priority.
# Print out the shell commands that will be executed.
# Go on with independent jobs if a job fails.
# Re-run all jobs the output of which is recognized as incomplete.
# Tell the scheduler to assign creation of given targets (and all their dependencies) highest priority.
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --cores \
    --use-conda \
    --printshellcmds \
    --keep-going \
    --rerun-incomplete

echo "________________________________________________________________________"

###### Create usefull graphs and summary ######
echo ""
echo "##### SNAKEMAKE PIPELINE GRAPHS ######"
echo "--------------------------------------"

mkdir ${workdir}/results/10_Graphs/ 2> /dev/null

graphList="dag rulegraph filegraph"
extentionList="pdf png"

for graph in ${graphList} ; do
    for extention in ${extentionList} ; do
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

echo "________________________________________________________________________"

###### Concatenate all consensus fasta ######
echo ""
echo "##### CONCATENATE FASTA FILES #####"
echo "-----------------------------------"

cat ${workdir}/results/05_Consensus/*_consensus.fasta > ${workdir}/results/All_consensus_sequences.fasta

# and copy multiqc_report.html to results/ dir root
cp ${workdir}/results/00_Quality_Control/multiqc/multiqc_report.html ${workdir}/results/All_readsQC_reports.html

echo "________________________________________________________________________"

###### Concatenate all coverage stats ######
echo ""
echo "##### CONCATENATE COVERAGE STATS #####"
echo "----------------------------------"

cat ${workdir}/results/03_Coverage/*coverage-stats.tsv > ${workdir}/results/All_genome_coverages.tsv

awk "NR==1 || NR%2==0" ${workdir}/results/All_genome_coverages.tsv > ${workdir}/results/GENCOV.tmp \
    && mv ${workdir}/results/GENCOV.tmp ${workdir}/results/All_genome_coverages.tsv

echo "________________________________________________________________________"

###### Concatenate all Pangolin lineage reports ######
echo ""
echo "##### CONCATENATE PANGOLIN REPORTS #####"
echo "----------------------------------------"

cat ${workdir}/results/06_Lineages/*_pangolin-report.csv > ${workdir}/results/All_pangolin_lineages.csv

awk "NR==1 || NR%2==0" ${workdir}/results/All_pangolin_lineages.csv > ${workdir}/results/PANGO.tmp \
    && mv ${workdir}/results/PANGO.tmp ${workdir}/results/All_pangolin_lineages.csv

sed "s/,/\t/g" ${workdir}/results/All_pangolin_lineages.csv > ${workdir}/results/All_pangolin_lineages.tsv

rm -f ${workdir}/results/All_pangolin_lineages.csv

echo "________________________________________________________________________"

###### Concatenate all Nextclade lineage reports ######
echo ""
echo "##### CONCATENATE NEXTCLADE REPORTS #####"
echo "----------------------------------------"

cat ${workdir}/results/06_Lineages/*_nextclade-report.tsv > ${workdir}/results/All_nextclade_lineages.tsv

awk "NR==1 || NR%2==0" ${workdir}/results/All_nextclade_lineages.tsv > ${workdir}/results/NEXT.tmp \
    && mv ${workdir}/results/NEXT.tmp ${workdir}/results/All_nextclade_lineages.tsv

echo "________________________________________________________________________"

###### Clean End ######
echo ""
echo "##### SCRIPT END #####"
echo "----------------------"

find ${workdir}/results/ -type f -empty -delete # Remove empty file (like empty log)
find ${workdir}/results/ -type d -empty -delete # Remove empty directory

echo "________________________________________________________________________"

###### Report time ######
echo ""
echo "##### TIMER #####"
echo "-----------------"

timestampend=$(date +'%Y-%m-%d %H:%M')
echo "End time: ${timestampend}"

elapsedtime=${SECONDS}
echo "Processing time: $((${elapsedtime}/60)) minutes and $((${elapsedtime}%60)) seconds elapsed"

echo "________________________________________________________________________"
