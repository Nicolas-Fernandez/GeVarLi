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
# Latest modifications ___ 2024.01.31 (edit message format)
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

MINIMAP2 = config["conda"][OS]["minimap2"] # MM2 conda env
BWA = config["conda"][OS]["bwa"]           # BWA conda env
BOWTIE2 = config["conda"][OS]["bowtie2"]   # BT2 conda env

###############################################################################
### PARAMETERS ###
##################

KMER_SIZE = config["minimap2"]["algorithm"]["k-mer_size"]          # MM2 k-mer size
MINIMIZER_SIZE = config["minimap2"]["algorithm"]["minimizer_size"] # MM2 minimizer window size
SPLIT_SIZE = config["minimap2"]["algorithm"]["split_size"]         # MM2 split index
#HOMOPOLYMER = config["minimap2"]["algorithm"]["homopolymer"]       # MM2 if PacBio

BWA_ALGO = config["bwa"]["algorithm"]     # BWA indexing algorithm
BT2_ALGO = config["bowtie2"]["algorithm"] # BT2 indexing algorithm

###############################################################################
### RULES ###
#############

rule all:
    input:
        mm2_indexes = expand("resources/indexes/minimap2/{ref_seq}.{ext}",
                            ref_seq = REF_SEQ,
                            ext = ["mmi"]),
        bwa_indexes = expand("resources/indexes/bwa/{ref_seq}.{ext}",
                            ref_seq = REF_SEQ,
                            ext = ["amb", "ann", "bwt", "pac", "sa"]),
        bt2_indexes = expand("resources/indexes/bowtie2/{ref_seq}.{ext}",
                            ref_seq = REF_SEQ,
                            ext = ["1.bt2", "2.bt2", "3.bt2", "4.bt2",
                                   "rev.1.bt2", "rev.2.bt2"])
        
###############################################################################
rule minimap2_genome_indexing:
    # Aim: index sequences in the FASTA format
    # Use: minimap2 [OPTIONS] -d [INDEX.mmi] <query.fasta>
    message:
        """
        ~ Minimap2 ∞ Index Genome ~
        Reference: _______ {wildcards.ref_seq}
        """
    conda:
        MINIMAP2
    params:
        kmer_size = KMER_SIZE,
        minimizer_size = MINIMIZER_SIZE,
        split_size = SPLIT_SIZE,
        #homopolymer = HOMOPOLYMER
    input:
        fasta = "resources/genomes/{ref_seq}.fasta"
    output:
        indexes = multiext("resources/indexes/minimap2/{ref_seq}",
                           ".mmi")
    log:
        "results/10_Reports/tools-log/minimap2-indexes/{ref_seq}.log"
    shell:
        "minimap2 "                  # Minimap2, index sequences
        "-k {params.kmer_size} "      # -k: k-mer size (default: "21", no larger than "28") [INT]
        "-w {params.minimizer_size} " # -w: minimizer window size (default: "11") [INT]
        "-I {params.split_size} "     # -I: split index for every {NUM} input bases (default: "8G") [INT]
        #"{params.homopolymer} "       # use homopolymer-compressed k-mer (preferrable for PacBio)
        "-d {output.indexes} "        # -d: dump index to FILE []
        "{input.fasta} "              # Reference sequences in the FASTA format
        "&> {log}"                    # Log redirection

###############################################################################
rule bwa_genome_indexing:
    # Aim: index sequences in the FASTA format
    # Use: bwa index -a [ALGO] -p [PREFIX] <genome.fasta>
    message:
        """
        ~ BWA-SW ∞ Index Genome ~
        Reference: _______ {wildcards.ref_seq}
        """
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
    # Use: bowtie2-build [OPTIONS] <reference_in> <bt2_index_base>
    message:
        """
        ~ Bowtie2-build ∞ Index Genome ~
        Reference: _______ {wildcards.ref_seq}
        """
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
