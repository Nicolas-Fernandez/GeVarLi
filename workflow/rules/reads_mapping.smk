###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ reads_mapping.smk
# Version ________________ v.2025.01
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Map Illumina reads on virus reference genomes
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.03.12
# Use ____________________ snakemake -s Snakefile --use-conda -j
###############################################################################

###############################################################################
rule minimap2_mapping:
    # Aim: reads mapping against reference sequence
    # Use: minimap2
    message:
        """
        ~ Minimap2 ∞ Map Reads ~
        Sample: __________ {wildcards.sample}
        Reference: _______ {wildcards.reference}
        Mapper: __________ MiniMap2
        """
    conda:
        MINIMAP2
    resources:
        cpus = CPUS
    params:
        preset = MM2_PRESET
        #length = LENGTH
    input:
        mm2_indexes = "resources/indexes/minimap2/{reference}.mmi",
        fwd_reads = "results/01_Trimming/sickle/{sample}_cutadapt-sickle-trimmed_R1.fastq.gz",
        rev_reads = "results/01_Trimming/sickle/{sample}_cutadapt-sickle-trimmed_R2.fastq.gz"
    output:
        mapped = temp("results/02_Mapping/{reference}/{sample}_minimap2-mapped.sam")
    log:
        "results/10_Reports/tools-log/minimap2/{sample}_{reference}.log"
    shell:
        "minimap2 "           # Minimap2, a versatile sequence alignment program
        "-x {params.preset} "  # -x: presets (always applied before other options)
        "-t {resources.cpus} " # -t: Number of threads (default: 3)
        "-a "                  # -a: output in the SAM format (PAF by default)
        #"-F {params.length} "  # -F: max fragment length, effective with -x sr mode (default: 800)
        "{input.mm2_indexes} " # Reference index filename prefix.mmi
                               # (-k, -w, -I and -H can't be changed during mapping)
        #"resources/genomes/{wildcards.reference}.fasta " # Reference genome fasta format (for custom -kwIH)
        #"-k {params.kmer_size} "      # -k: k-mer size (default: "21", no larger than "28") [INT]
        #"-w {params.minimizer_size} " # -w: minimizer window size (default: "11") [INT]
        #"-I {params.split_size} "     # -I: split index for every {NUM} input bases (default: "8G") [INT]
        #"{params.homopolymer} "       # -H: use homopolymer-compressed k-mer (preferrable for PacBio)
        "{input.fwd_reads} "   # Forward input reads
        "{input.rev_reads} "   # Reverse input reads
        "1> {output.mapped} "  # SAM output
        "2> {log}"             # Log redirection 

###############################################################################
rule bwa_mapping:
    # Aim: reads mapping against reference sequence
    # Use: bwa mem -t [THREADS] -x [REFERENCE] [FWD_R1.fq] [REV_R2.fq] 1> [MAPPED.sam]
    message:
        """
        ~ BWA-MEM ∞ Map Reads ~
        Sample: __________ {wildcards.sample}
        Reference: _______ {wildcards.reference}
        Aligner: _________ BWA
        """
    conda:
        BWA
    resources:
        cpus = CPUS
    input:
        bwa_indexes = "resources/indexes/bwa/{reference}",
        fwd_reads = "results/01_Trimming/sickle/{sample}_cutadapt-sickle-trimmed_R1.fastq.gz",
        rev_reads = "results/01_Trimming/sickle/{sample}_cutadapt-sickle-trimmed_R2.fastq.gz"
    output:
        mapped = temp("results/02_Mapping/{reference}/{sample}_bwa-mapped.sam")
    log:
        "results/10_Reports/tools-log/bwa/{sample}_{reference}.log"
    shell:
        "bwa mem "            # BWA-MEM algorithm, performs local alignment
        "-t {resources.cpus} " # -t: Number of threads (default: 12)
        "-v 1 "                # -v: Verbosity level: 1=error, 2=warning, 3=message, 4+=debugging
        "{input.bwa_indexes} " # Reference index filename prefix
        "{input.fwd_reads} "   # Forward input reads
        "{input.rev_reads} "   # Reverse input reads
        "1> {output.mapped} "  # SAM output
        "2> {log}"             # Log redirection 

###############################################################################
rule bowtie2_mapping:
    # Aim: reads mapping against reference sequence
    # Use: bowtie2 -p [THREADS] -x [REFERENCE] -1 [FWD_R1.fq] -2 [REV_R2.fq] -S [MAPPED.sam]
    message:
        """
        ~ Bowtie2 ∞ Map Reads ~
        Sample: __________ {wildcards.sample}
        Reference: _______ {wildcards.reference}
        Aligner: _________ Bowtie2
        """
    conda:
        BOWTIE2
    resources:
        cpus = CPUS
    params:
        sensitivity = BT2_SENSITIVITY
    input:
        bt2_indexes = "resources/indexes/bowtie2/{reference}",
        fwd_reads = "results/01_Trimming/sickle/{sample}_cutadapt-sickle-trimmed_R1.fastq.gz",
        rev_reads = "results/01_Trimming/sickle/{sample}_cutadapt-sickle-trimmed_R2.fastq.gz"
    output:
        mapped = temp("results/02_Mapping/{reference}/{sample}_bowtie2-mapped.sam")
    log:
        "results/10_Reports/tools-log/bowtie2/{sample}_{reference}.log"
    shell:
        "bowtie2 "                   # Bowtie2, an ultrafast and memory-efficient tool for aligning sequencing reads to long reference sequences
        "--threads {resources.cpus} " # -p: Number of alignment threads to launch (default: 1)
        "--reorder "                  # Keep the original read order (if multi-processor option -p is used)
        "-x {input.bt2_indexes} "     # -x: Reference index filename prefix (minus trailing .X.bt2)
        "{params.sensitivity} "       # Preset (default: "--sensitive")
                                       # sensitive: same as [-D 15 -R 2 -N 0 -L 22 -i S,1,1.15]
        "-q "                         # -q: Query input files are FASTQ .fq/.fastq (default)
        "-1 {input.fwd_reads} "       # Forward input reads
        "-2 {input.rev_reads} "       # Reverse input reads
        "1> {output.mapped} "         # -S: File for SAM output (default: stdout) 
        "2> {log}"                    # Log redirection 

###############################################################################
