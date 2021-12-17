#!/bin/bash
                                                                                                                           
###### About ######
echo ""
echo "##### ABOUT #####"
echo "-----------------"
echo "Name: GeVarLi pipeline"
echo "Author: Nicolas Fernandez"
echo "Affiliation: IRD_U233_TransVIHMI"
echo "Aim: SARS-CoV-2 Genome assembling, Variant and Lineage (pangolin) calling"
echo "Date: 2021.10.12"
echo "Run: snakemake -s path/to/gevarli.smk --cores --use-conda"
echo "Latest modification: 2021.12.08"
echo "Todo: ..."
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

seconds=0
timestampstart=$(date +'%Y-%m-%d %H:%M')
echo "Start: ${timestampstart}"

echo "________________________________________________________________________"

###### Rename samples ######
# de/comment first line if you want to keep or remove barcode-ID in sample name
echo ""
echo "##### RENAME FASTQ FILES #####"
echo "------------------------------"

rename -v 's/_S\d+_/_/' ${workdir}/resources/reads/*.fastq.gz 2> /dev/null                # Remove barcode-ID like {_S001_}
rename -v 's/_L\d+_/_/' ${workdir}/resources/reads/*.fastq.gz 2> /dev/null                # Remove line-ID ID like {_L001_}
rename -v 's/_001.fastq.gz/.fastq.gz/' ${workdir}/resources/reads/*.fastq.gz 2> /dev/null # Remove end-name ID like {_001}.fastq.gz

echo "________________________________________________________________________"

###### Call snakemake pipeline ######
echo ""
echo "##### SNAKEMAKE PIPELINE #####"
echo "-----------------------------"

echo "Unlocking working directory:"
# Specify working directory (relative paths in the snakefile will use this as their origin)
# The workflow definition in form of a snakefile.
# Remove a lock on the working directory.
snakemake \
    --directory ${workdir}/ \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --unlock

echo ""
echo "Dry run:"
# The workflow definition in form of a snakefile.
# Specify working directory (relative paths in the snakefile will use this as their origin)
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# If defined in the rule, run job in a conda environment.
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
# The workflow definition in form of a snakefile.
# Specify working directory (relative paths in the snakefile will use this as their origin)
# Use at most N CPU cores/jobs in parallel. If N is omitted or ‘all’, the limit is set to the number of available CPU cores.
# If defined in the rule, run job in a conda environment.
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
    --rerun-incomplete \
    --prioritize multiqc_reports_aggregation

echo "________________________________________________________________________"

###### Create usefull graphs and summary ######
echo ""
echo "##### SNAKEMAKE PIPELINE GRAPHS ######"
echo "--------------------------------------"

mkdir ${workdir}/results/graphs/ 2> /dev/null

graphList="dag rulegraph filegraph"
extentionList="pdf png"

for graph in ${graphList} ; do
    for extention in ${extentionList} ; do
	snakemake \
	    --directory ${workdir}/ \
            --snakefile ${workdir}/workflow/rules/gevarli.smk \
            --${graph} | \
	    dot -T${extention} > \
		${workdir}/results/graphs/${graph}.${extention} ;
    done ;
done

snakemake \
    --directory ${workdir} \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --summary > ${workdir}/results/graphs/summary.txt

echo "________________________________________________________________________"

###### Concatenate all consensus fasta in one unique fasta file ######
echo ""
echo "##### CONCATENATE FASTA FILES #####"
echo "-----------------------------------"

cat ${workdir}/results/assembling/*_consensus.fasta > ${workdir}/results/All_cconsensus_sequences.fasta

echo "________________________________________________________________________"

###### Concatenate all Pangolin lienage reports ######
echo ""
echo "##### CONCATENATE PANGOLIN REPORTS #####"
echo "----------------------------------------"

cat ${workdir}/results/lineage/*_pangolin-report.csv > ${workdir}/results/All_lineage_pangolin-reports.csv

awk "NR==1 || NR%2==0" ${workdir}/results/All_lineage_pangolin-reports.csv > ${workdir}/results/Pangolin.tmp \
    && mv ${workdir}/results/Pangolin.tmp ${workdir}/results/All_lineage_pangolin-reports.csv

sed "s/,/\t/g" ${workdir}/results/All_lineage_pangolin-reports.csv > ${workdir}/results/All_lineage_pangolin-reports.tsv

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
echo "End: ${timestampend}"

elapsedtime=${seconds}
echo "Processing time: ${elapsedtime} elapsed seconds"

echo "________________________________________________________________________"
