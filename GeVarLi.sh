#!/bin/bash
                                                                                                                           
##### About #####
echo ""
echo "##### ABOUT #####"
echo "-----------------"

echo "Name: GeVarLi pipeline"
echo "Author: Nicolas Fernandez"
echo "Affiliation: IRD_U233_TransVIHMI"
echo "Aim: SARS-CoV-2 Genome assembling, Variant and Lineage (pangolin) calling"
echo "Date: 2021.10.12"
echo "Run: snakemake --use-conda -s gevarli.smk --cores"
echo "Latest modification: 2021.11.26"
echo "Todo: ..."

echo "________________________________________________________________________"

##### Hardware check #####
echo ""
echo "##### HARDWARE #####"
echo "--------------------"

physicalcpu=$(sysctl -n hw.physicalcpu)   # Get physical cpu
echo "Physical CPU: ${physicalcpu}"       # Print physical cpu
logicalcpu=$(sysctl -n hw.logicalcpu)     # Get logical cpu
echo "Logical CPU: ${logicalcpu}"         # Print logical cpu
hwmemsize=$(sysctl -n hw.memsize)         # Get memory size
ramsize=$(expr $hwmemsize / $((1024**3))) # 1024**3 = GB
echo "System Memory: ${ramsize} GB"       # Print RAM size

echo "________________________________________________________________________"

##### Working directory #####
echo ""
echo "##### WORKING DIRECTORY #####"
echo "-----------------------------"

workdir=${0%/*}
echo "CWD: ${workdir}"

echo "________________________________________________________________________"

###### Rename samples #####
# de/comment first line if you want to keep or remove barcode-ID in sample name
echo ""
echo "##### RENAME FASTQ FILES #####"
echo "------------------------------"

#rename -v 's/_S\d+_/_/' ${workdir}/resources/reads/*.fastq.gz 2> /dev/null                # Remove barcode-ID like {_S001_}, quiet: 2> /dev/null
rename -v 's/_L\d+_/_/' ${workdir}/resources/reads/*.fastq.gz 2> /dev/null                # Remove line-ID ID like {_L001_}, quiet: 2> /dev/null
rename -v 's/_\d+.fastq.gz/.fastq.gz/' ${workdir}/resources/reads/*.fastq.gz 2> /dev/null # Remove end-name ID like {_001}.fastq.gz, quiet: 2> /dev/null
echo "Quiet."

echo "________________________________________________________________________"

###### Call snakemake pipeline #####
echo ""
echo "##### SNAKEMAKE PIPELINE #####"
echo "-----------------------------"

echo ""
echo "Unlocking working directory:"
snakemake \
    --directory ${workdir} \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --cores \
    --use-conda \
    --printshellcmds \
    --keep-going \
    --rerun-incomplete \
    --unlock # unlock first, if previous error

echo ""
echo "Dry run:"
snakemake \
    --directory ${workdir} \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --cores \
    --use-conda \
    --printshellcmds \
    --keep-going \
    --rerun-incomplete \
    --dryrun # then dry run, check error like missing file

echo ""
echo "Let's go!"
snakemake \
    --directory ${workdir} \
    --snakefile ${workdir}/workflow/rules/gevarli.smk \
    --cores \
    --use-conda \
    --printshellcmds \
    --keep-going \
    --rerun-incomplete # last, real run 

echo "________________________________________________________________________"

###### Create usefull graphs and summary ######
echo ""
echo "##### SNAKEMAKE PIPELINE GRAPHS ######"
echo "--------------------------------------"

mkdir ${workdir}/results/graphs/ 2> /dev/null

for graph in "dag rulegraph filegraph" ; do
    for extention in "pdf png" ; do
	snakemake \
            --directory ${workdir} \
            --snakefile ${workdir}/workflow/rules/gevarli.smk \
            --$graph | dot -T$extention > ${workdir}/results/graphs/$graph.$extention ;
    done ;
done

echo "________________________________________________________________________"


###### Rename all fasta header with sample name ######
echo ""
echo "##### RENAME FASTA HEADERS ######"
echo "---------------------------------"

for fasta in ${workdir}/results/bcftools/*_consensus.fasta ; do
    sample=$(basename $fasta \_consensus\.fasta) ;
    echo $sample ;
    sed "s/^>.*$/>$sample/" $fasta > ${workdir}/results/$sample.tmp &&
	mv ${workdir}/results/$sample.tmp $fasta ;
done
echo "________________________________________________________________________"

###### Concatenate all consensus fasta in one unique fasta file ######
echo ""
echo "##### CONCATENATE FASTA FILES ######"
echo "------------------------------------"

cat ${workdir}/results/bcftools/*_consensus.fasta > ${workdir}/results/All_cconsensus_sequences.fasta

echo "________________________________________________________________________"

###### Rename all pangolin report header with sample name ######
echo ""
echo "##### RENAME LINEAGE taxon ID ######"
echo "-------------------------------------"

for report in ${workdir}/results/pangolin/*_lineage_report.csv ; do
    sample=$(basename $report \_lineage\_report\.csv) ;
    echo $sample ;
    taxon=$(awk '{if(NR==2){ print $1; }}' $report) ;
    sed "s/$taxon/$sample,/" $report > ${workdir}/results/$sample.tmp &&
	mv ${workdir}/results/$sample.tmp $report ;
done

echo "________________________________________________________________________"

###### Concatenate all Pangolin lienage reports ######
echo ""
echo "##### CONCATENATE PANGOLIN REPORTS ######"
echo "-----------------------------------------"

cat ${workdir}/results/pangolin/*_lineage_report.csv > ${workdir}/results/All_Pangolin_lineage_reports.csv
awk "NR==1 || NR%2==0" ${workdir}/results/All_Pangolin_lineage_reports.csv > ${workdir}/results/Pangolin.tmp &&
    mv ${workdir}/results/Pangolin.tmp ${workdir}/results/All_Pangolin_lineage_reports.csv
sed "s/,/\t/g" ${workdir}/results/All_Pangolin_lineage_reports.csv > ${workdir}/results/All_pangolin_lineage_reports.tsv

echo "________________________________________________________________________"


###### END ######
echo ""
echo "##### SCRIPT END ######"
echo "-----------------------"

echo "________________________________________________________________________"
