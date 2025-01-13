###############################################################################
################################## INDEXING ###################################
###############################################################################

###############################################################################
rule bwa_genome_indexing:
    # Aim: index sequences in the FASTA format
    # Use: bwa index -a [ALGO] -p [PREFIX] <genome.fasta>
    message:
        """
        ~ BWA-SW ∞ Index Genome ~
        Reference: _______ {wildcards.reference}
        """
    conda:
        BWA
    params:
        algorithm = BWA_ALGO
    input:
        fasta = "resources/genomes/{reference}.fasta"
    output:
        prefix = "resources/indexes/bwa/{reference}",
        bwa_indexes = multiext("resources/indexes/bwa/{reference}",
                               ".amb", ".ann", ".bwt", ".pac", ".sa")
    log:
        "results/10_Reports/tools-log/bwa-indexes/{reference}.log"
    shell:
        "bwa index "              # BWA-SW algorithm, index sequences
        "{params.algorithm} "      # -a: Algorithm for constructing BWT index (default: auto)
        "-p {output.prefix} "      # -p: Prefix of the output database
        "{input.fasta} "           # Reference sequences in the FASTA format
        "&> {log} "                # Log redirection
        "&& touch {output.prefix}" # Touch done

###############################################################################
rule minimap2_genome_indexing:
    # Aim: index sequences in the FASTA format
    # Use: minimap2 [OPTIONS] -d [INDEX.mmi] <query.fasta>
    message:
        """
        ~ Minimap2 ∞ Index Genome ~
        Reference: _______ {wildcards.reference}
        """
    conda:
        MINIMAP2
    params:
        kmer_size = KMER_SIZE,
        minimizer_size = MINIMIZER_SIZE,
        split_size = SPLIT_SIZE
        #homopolymer = HOMOPOLYMER
    input:
        fasta = "resources/genomes/{reference}.fasta"
    output:
        mm2_indexes = multiext("resources/indexes/minimap2/{reference}",
                               ".mmi")
    log:
        "results/10_Reports/tools-log/minimap2-indexes/{reference}.log"
    shell:
        "minimap2 "                  # Minimap2, index sequences
        "-k {params.kmer_size} "      # -k: k-mer size (default: "21", no larger than "28") [INT]
        "-w {params.minimizer_size} " # -w: minimizer window size (default: "11") [INT]
        "-I {params.split_size} "     # -I: split index for every {NUM} input bases (default: "8G") [INT]
        #"{params.homopolymer} "       # use homopolymer-compressed k-mer (preferrable for PacBio)
        "-d {output.mm2_indexes} "    # -d: dump index to FILE []
        "{input.fasta} "              # Reference sequences in the FASTA format
        "&> {log}"                    # Log redirection

###############################################################################
rule bowtie2_genome_indexing:
    # Aim: index sequences in the FASTA format
    # Use: bowtie2-build [OPTIONS] <reference_in> <bt2_index_base>
    message:
        """
        ~ Bowtie2-build ∞ Index Genome ~
        Reference: _______ {wildcards.reference}
        """
    conda:
        BOWTIE2
    resources:
        cpus = CPUS
    params:
        algorithm = BT2_ALGO
    input:
        fasta = "resources/genomes/{reference}.fasta"
    output:
        prefix = "resources/indexes/bowtie2/{reference}",
        bt2_indexes = multiext("resources/indexes/bowtie2/{reference}",
                               ".1.bt2", ".2.bt2", ".3.bt2", ".4.bt2",
                               ".rev.1.bt2", ".rev.2.bt2")
    log:
        "results/10_Reports/tools-log/bowtie2-indexes/{reference}.log"
    shell:
        "bowtie2-build "             # Bowtie2-build, index sequences
        "--quiet "                    # -q: quiet
        "--threads {resources.cpus} " # Number of threads
        "{params.algorithm} "         # Force (or no by default) generated index to be 'large',
                                       # even if ref has fewer than 4 billion nucleotides
        "-f "                         # Reference files are FASTA (default)
        "{input.fasta} "              # Reference sequences files (comma-separated list) in the FASTA format
        "{output.prefix} "            # Write bt2 data to files with this dir/basename
        "&> {log} "                   # Log redirection
        "&& touch {output.prefix}"    # Touch done

###############################################################################
