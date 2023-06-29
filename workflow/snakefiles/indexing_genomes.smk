###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __| ___| \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__|_)\_|____|____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ indexing_genomes.smk
# Version ________________ v.2023.06
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Snakefile with indexing genomes rules
# Date ___________________ 2022.09.28
# Latest modifications ___ 2023.06.21
# Use ____________________ snakemake -s indexing_genomes.smk --use-conda 

###############################################################################
### CONFIGURATION ###
#####################

configfile: "configuration/config.yaml"

###############################################################################
### FUNCTIONS ###
#################


###############################################################################
### WILDCARDS ###
#################

REF_SEQ, = glob_wildcards("resources/genomes/{ref_seq}.fasta")

###############################################################################
### RESOURCES ###
#################

OS = config["os"]                  # Operating system
CPUS = config["resources"]["cpus"] # Threads (maximum)

###############################################################################
### ENVIRONMENTS ###
####################

BWA = config["conda"][OS]["bwa"]         # BWA conda env
BOWTIE2 = config["conda"][OS]["bowtie2"] # BT2 conda env

###############################################################################
### PARAMETERS ###
##################

BWA_ALGO = config["bwa"]["algorithm"]     # BWA indexing algorithm
BT2_ALGO = config["bowtie2"]["algorithm"] # BT2 indexing algorithm

###############################################################################
### RULES ###
#############

rule all:
    input:
        bwa_indexes = expand("resources/indexes/bwa/{ref_seq}.{ext}",
                            ref_seq = REF_SEQ,
                            ext = ["amb", "ann", "bwt", "pac", "sa"]),
        bt2_indexes = expand("resources/indexes/bowtie2/{ref_seq}.{ext}",
                            ref_seq = REF_SEQ,
                            ext = ["1.bt2", "2.bt2", "3.bt2", "4.bt2",
                                   "rev.1.bt2", "rev.2.bt2"])
        
###############################################################################
rule bwa_genome_indexing:
    # Aim: index sequences in the FASTA format
    # Use: bwa index -a [ALGO] -p [PREFIX] [GENOME.fasta]
    message:
        "BWA-SW indexing {wildcards.ref_seq} genome (algo: {params.algorithm}"
    conda:
        BWA
    params:
        algorithm = BWA_ALGO
    input:
        fasta = "resources/genomes/{ref_seq}.fasta"
    output:
        prefix = temp("resources/indexes/bwa/{ref_seq}"),
        indexes = multiext("resources/indexes/bwa/{ref_seq}",
                          ".amb", ".ann", ".bwt", ".pac", ".sa")
    log:
        "results/10_Reports/tools-log/bwa-indexes/{ref_seq}.log"
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
        "Bowtie2-build indexing {wildcards.ref_seq} genome"
    conda:
        BOWTIE2
    resources:
        cpus = CPUS
    params:
        algorithm = BT2_ALGO
    input:
        fasta = "resources/genomes/{ref_seq}.fasta"
    output:
        prefix = temp("resources/indexes/bowtie2/{ref_seq}"),
        indexes = multiext("resources/indexes/bowtie2/{ref_seq}",
                           ".1.bt2", ".2.bt2", ".3.bt2", ".4.bt2",
                           ".rev.1.bt2", ".rev.2.bt2")
    log:
        "results/10_Reports/tools-log/bowtie2-indexes/{ref_seq}.log"
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
