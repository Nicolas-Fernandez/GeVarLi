#######T######R#####A#####N######S######V######I######H#######M######I#########
# Name: indexing_genomes.smk
# Author: Nicolas Fernandez
# Affiliation: IRD_U233_TransVIHMI
# Aim: Snakefile for Indexing Genomes
# Date: 2022.09.28
# Run: snakemake --snakefile indexing_genomes.smk --cores --use-conda 
# Latest modification: 2022.09.30
# Done: Produce indexes for BWA and Bowtie2 aligners, and primers BEDPE files

###############################################################################
# PUBLICATIONS #

###############################################################################
# CONFIGURATION #

configfile: "config/config.yaml"

###############################################################################
# FUNCTIONS #

###############################################################################
# WILDCARDS #

REFSEQ, = glob_wildcards("resources/genomes/{refseq}.fasta")
AMPLICON, = glob_wildcards("resources/primers/bed/{amplicon}.bed")

###############################################################################
# RESOURCES #

OS = config["os"]                  # Operating system
CPUS = config["resources"]["cpus"] # Threads (maximum)

###############################################################################
# ENVIRONMENTS #

BOWTIE2 = config["conda"][OS]["bowtie2"] # Bowtie2
BWA = config["conda"][OS]["bwa"]         # Bwa
GAWK = config["conda"][OS]["gawk"]       # Gawk

###############################################################################
# PARAMETERS #

ALIGNER = config["aligner"]              # Aligners ('bwa' or 'bowtie2')
BWAALGO = config["bwa"]["algorithm"]     # BWA indexing algorithm
BT2ALGO = config["bowtie2"]["algorithm"] # BT2 indexing algorithm

###############################################################################
# RULES #

rule all:
    input:
        index = expand("resources/indexes/{aligner}/{refseq}",
                       aligner = ['bwa', ALIGNER], refseq = REFSEQ),
        bedpe = expand("resources/primers/bedpe/{amplicon}.bedpe",
                         amplicon = AMPLICON),

###############################################################################
rule bowtie2_genome_indexing:
    # Aim: index sequences in the FASTA format
    # Use: bowtie2-build [options]* <reference_in> <bt2_index_base>
    message:
        "Bowtie2-build indexing {wildcards.refseq} genome"
    conda:
        BOWTIE2
    resources:
        cpus = CPUS
    params:
        algorithm = BT2ALGO
    input:
        fasta = "resources/genomes/{refseq}.fasta"
    output:
        prefix = "resources/indexes/bowtie2/{refseq}",
        indexes = multiext("resources/indexes/bowtie2/{refseq}",
                          ".1.bt2", ".2.bt2", ".3.bt2", ".4.bt2",
                           ".rev.1.bt2", ".rev.2.bt2")
    log:
        "results/10_Reports/tools-log/bowtie2-build/{refseq}.log"
    shell:
        "bowtie2-build "             # Bowtie2-build, index sequences
        "--quiet "                    # -q: quiet
        "--threads {resources.cpus} " # Number of threads
        "{params.algorithm} "         # Force (or no by default) generated index to be 'large', even if ref has fewer than 4 billion nucleotides
        "-f "                         # Reference files are FASTA (default)
        "{input.fasta} "              # Reference sequences files (comma-separated list) in the FASTA format
        "{output.prefix} "            # Write bt2 data to files with this dir/basename
        "&> {log} "                   # Log redirection
        "&& touch {output.prefix}"    # Touch done

###############################################################################
rule bwa_genome_indexing:
    # Aim: index sequences in the FASTA format
    # Use: bwa index -a [ALGO] -p [PREFIX] [GENOME.fasta]
    message:
        "BWA-SW indexing {wildcards.refseq} genome (algo: {params.algorithm}"
    conda:
        BWA
    params:
        algorithm = BWAALGO
    input:
        fasta = "resources/genomes/{refseq}.fasta"
    output:
        prefix = "resources/indexes/bwa/{refseq}",
        indexes = multiext("resources/indexes/bwa/{refseq}",
                          ".amb", ".ann", ".bwt", ".pac", ".sa")
    log:
        "results/10_Reports/tools-log/bwa-sw/{refseq}.log"
    shell:
        "bwa index "              # BWA-SW algorithm, index sequences
        "{params.algorithm} "      # -a: Algorithm for constructing BWT index (default: auto)                                  
        "-p {output.prefix} "      # -p: Prefix of the output database
        "{input.fasta} "           # Reference sequences in the FASTA format
        "&> {log} "                # Log redirection
        "&& touch {output.prefix}" # Touch done

###############################################################################
rule convert_bed_bedpe:
    # Aim: Convert BED file (Artic primers) to BEDPE file (BamClipper)
    # Use: Paste and Awk
    message:
        "Convert BED file to BEDPE file for {wildcards.amplicon} genome"
    conda:
        GAWK
    input:
        bed = "resources/primers/bed/{amplicon}.bed"
    output:
        bedpe = "resources/primers/bedpe/{amplicon}.bedpe"
    log:
        "results/10_Reports/tools-log/awk/{amplicon}_bed-to-bedpe.log"
    shell:
        "paste "                                                            # Paste, some Awk picking outputs
        "<(awk -v OFS='\t' 'NR%2 {{print $1, $2, $3}}' {input.bed}) "        # Get 'chrom1', 'start1', 'end1'
        "<(awk -v OFS='\t' '!(NR%2) {{print $1, $2, $3, $4}}' {input.bed}) " # Get 'chrom2', 'start2', 'end2' and 'name' (_RIGHT)
        "<(awk -v OFS='\t' 'NR%2 {{print $6}}' {input.bed}) "                # Get 'strand1' (+)
        "<(awk -v OFS='\t' '!(NR%2) {{print $6}}' {input.bed}) "             # Get 'strand2' (-)
        "| sed -E 's|\_RIGHT|\_PRIMERS|g' "                                  # Rename sequence as 'PRIMERS' (no more LEFT or RIGHT)
        "1> {output.bedpe} "                                                 # Output bedpe file
        "2> {log}"                                                           # Log redirection

###############################################################################
