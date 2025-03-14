###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ reads_cleanning.smk
# Version ________________ v.2025.01
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Perform Illumina reads quality trimming
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.03.12
# Use ____________________ snakemake -s Snakefile --use-conda -j
###############################################################################

###############################################################################
rule sickle_trim_quality:
    # Aim: windowed adaptive trimming tool for FASTQ files using quality
    # Use: sickle [COMMAND] [OPTIONS]
    message:
        """
        ~ Sickle-trim ∞ Trim Low Quality Sequences ~
        Sample: __________ {wildcards.sample}
        """
    conda:
        SICKLE_TRIM
    params:
        command = SIC_COMMAND,
        encoding = SIC_ENCODING,
        quality = SIC_QUALITY,
        length = SIC_LENGTH
    input:
        fwd_reads = "results/01_Trimming/cutadapt/{sample}_cutadapt-removed_R1.fastq.gz",
        rev_reads = "results/01_Trimming/cutadapt/{sample}_cutadapt-removed_R2.fastq.gz"
    output:
        fwd_reads = temp("results/01_Trimming/sickle/{sample}_cutadapt-sickle-trimmed_R1.fastq.gz"),
        rev_reads = temp("results/01_Trimming/sickle/{sample}_cutadapt-sickle-trimmed_R2.fastq.gz"),
        single = temp("results/01_Trimming/sickle/{sample}_cutadapt-sickle-trimmed_SE.fastq.gz")
    log:
        "results/10_Reports/tools-log/sickle-trim/{sample}.log"
    shell:
        "sickle "               # Sickle, a windowed adaptive trimming tool for FASTQ files using quality
        "{params.command} "      # Paired-end or single-end sequence trimming
        "-t {params.encoding} "  # --qual-type: Type of quality values, solexa ; illumina ; sanger ; CASAVA, < 1.3 ; 1.3 to 1.7 ; >= 1.8
        "-q {params.quality} "   # --qual-threshold: Threshold for trimming based on average quality in a window (default: 20)
        "-l {params.length} "    # --length-threshold: Threshold to keep a read based on length after trimming (default: 20)
        "-f {input.fwd_reads} "  # --pe-file1: Input paired-end forward fastq file
        "-r {input.rev_reads} "  # --pe-file2: Input paired-end reverse fastq file
        "-g "                    # --gzip-output: Output gzipped files
        "-o {output.fwd_reads} " # --output-pe1: Output trimmed forward fastq file
        "-p {output.rev_reads} " # --output-pe2: Output trimmed reverse fastq file (must use -s option)
        "-s {output.single} "    # --output-single: Output trimmed singles fastq file
        "&> {log} "              # Log redirection

###############################################################################
rule cutadapt_adapters_removing:
    # Aim: finds and removes adapter sequences, primers, poly-A tails and other types of unwanted sequence from your high-throughput sequencing reads
    # Use: cutadapt [OPTIONS] -a/-A [ADAPTER] -o [OUT_FWD.fastq.gz] -p [OUT_REV.fastq.gz] [IN_FWD.fastq.gz] [IN_REV.fastq.gz]
    # Rmq: multiple adapter sequences can be given using further -a options, but only the best-matching adapter will be removed
    message:
        """
        ~ Cutadapt ∞ Remove Adapters ~
        Sample: __________ {wildcards.sample}
        """
    conda:
        CUTADAPT
    resources:
        cpus = CPUS
    params:
        length = CUT_LENGTH,
        truseq = CUT_TRUSEQ,
        nextera = CUT_NEXTERA,
        small = CUT_SMALL,
        cut = CUT_CLIPPING
    input:
        fwd_reads = "results/symlinks/{sample}_R1.fastq.gz",
        rev_reads = "results/symlinks/{sample}_R2.fastq.gz"
    output:
        fwd_reads = temp("results/01_Trimming/cutadapt/{sample}_cutadapt-removed_R1.fastq.gz"),
        rev_reads = temp("results/01_Trimming/cutadapt/{sample}_cutadapt-removed_R2.fastq.gz")
    log:
        "results/10_Reports/tools-log/cutadapt/{sample}.log"
    shell:
        "cutadapt "                          # Cutadapt, finds and removes unwanted sequence from your HT-seq reads
        "--cores {resources.cpus} "           # -j: Number of CPU cores to use. Use 0 to auto-detect (default: 1)
        "--cut {params.cut} "                 # -u: Remove 'n' first bases (5') from forward R1 (hard-clipping, default: 0)
        "-U {params.cut} "                    # -U: Remove 'n' first bases (5') from reverse R2 (hard-clipping, default: 0)
        "--trim-n "                           # --trim-n: Trim N's on ends (3') of reads
        "--minimum-length {params.length} "   # -m: Discard reads shorter than length
        "--adapter {params.truseq} "          # -a: Sequence of an adapter ligated to the 3' end of the first read
        "-A {params.truseq} "                 # -A: 3' adapter to be removed from second read in a pair
        "--adapter {params.nextera} "         # -a: Sequence of an adapter ligated to the 3' end of the first read
        "-A {params.nextera} "                # -A: 3' adapter to be removed from second read in a pair
        "--adapter {params.small} "           # -a: Sequence of an adapter ligated to the 3' end of the first read
        "-A {params.small} "                  # -A: 3' adapter to be removed from second read in a pair
        "--output {output.fwd_reads} "        # -o: Write trimmed reads to FILE
        "--paired-output {output.rev_reads} " # -p: Write second read in a pair to FILE
        "{input.fwd_reads} "                  # Input forward reads R1.fastq
        "{input.rev_reads} "                  # Input reverse reads R2.fastq
        "&> {log} "                           # Log redirection

###############################################################################
