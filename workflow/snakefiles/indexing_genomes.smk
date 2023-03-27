###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ indexing_genomes.smk
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Snakefile with indexing genomes rules
# Date ___________________ 2022.09.28
# Latest modifications ___ 2023.03.27
# Use ____________________ snakemake -s indexing_genomes.smk --use-conda 

###############################################################################
###### CONFIGURATION ######

configfile: "configuration/config.yaml"

###############################################################################
###### FUNCTIONS ######


###############################################################################
###### WILDCARDS ######

REFSEQ, = glob_wildcards("resources/genomes/{refseq}.fasta")

###############################################################################
###### RESOURCES ######

OS = config["os"]                  # Operating system
CPUS = config["resources"]["cpus"] # Threads (maximum)

###############################################################################
###### ENVIRONMENT(S) ######

GEVARLI = config["conda"][OS]["gevarli-tools"] # GeVarLi all tools

###############################################################################
###### PARAMETERS ######

BWAALGO = config["bwa"]["algorithm"]     # BWA indexing algorithm
BT2ALGO = config["bowtie2"]["algorithm"] # BT2 indexing algorithm

###############################################################################
###### RULES ######

rule all:
    input:
        bwaindexes = expand("resources/indexes/bwa/{refseq}.{ext}",
                            refseq = REFSEQ,
                            ext = ["amb", "ann", "bwt", "pac", "sa"]),
        bt2indexes = expand("resources/indexes/bowtie2/{refseq}.{ext}",
                            refseq = REFSEQ,
                            ext = ["1.bt2", "2.bt2", "3.bt2", "4.bt2",
                                   "rev.1.bt2", "rev.2.bt2"])
        
###############################################################################
rule bwa_genome_indexing:
    # Aim: index sequences in the FASTA format
    # Use: bwa index -a [ALGO] -p [PREFIX] [GENOME.fasta]
    message:
        "BWA-SW indexing {wildcards.refseq} genome (algo: {params.algorithm}"
    conda:
        GEVARLI
    params:
        algorithm = BWAALGO
    input:
        fasta = "resources/genomes/{refseq}.fasta"
    output:
        prefix = temp("resources/indexes/bwa/{refseq}"),
        indexes = multiext("resources/indexes/bwa/{refseq}",
                          ".amb", ".ann", ".bwt", ".pac", ".sa")
    log:
        "results/10_Reports/tools-log/bwa-indexes/{refseq}.log"
    shell:
        "bwa index "              # BWA-SW algorithm, index sequences
        "{params.algorithm} "      # -a: Algorithm for constructing BWT index (default: auto)                                  
        "-p {output.prefix} "      # -p: Prefix of the output database
        "{input.fasta} "           # Reference sequences in the FASTA format
        "&> {log} "                # Log redirection
        "&& touch {output.prefix}" # Touch done

###############################################################################
rule bowtie2_genome_indexing:
    # Aim: index sequences in the FASTA format
    # Use: bowtie2-build [options]* <reference_in> <bt2_index_base>
    message:
        "Bowtie2-build indexing {wildcards.refseq} genome"
    conda:
        GEVARLI
    resources:
        cpus = CPUS
    params:
        algorithm = BT2ALGO
    input:
        fasta = "resources/genomes/{refseq}.fasta"
    output:
        prefix = temp("resources/indexes/bowtie2/{refseq}"),
        indexes = multiext("resources/indexes/bowtie2/{refseq}",
                           ".1.bt2", ".2.bt2", ".3.bt2", ".4.bt2",
                           ".rev.1.bt2", ".rev.2.bt2")
    log:
        "results/10_Reports/tools-log/bowtie2-indexes/{refseq}.log"
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
