###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ quality_controls.smk
# Version ________________ v.2025.06
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Perform Illumina reads quality controls
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.06.10
# Use ____________________ snakemake --use-conda -s <SNAKEFILE>
###############################################################################

###############################################################################
rule fastqc_quality_control:
    # Aim: reads sequence files and produces a quality control report
    # Use: fastqc [OPTIONS] --output [DIR/] [FASTQ.GZ]
    message:
        """
        ~ FastQC ∞ Quality Control ~
        Sample: ________ {wildcards.sample}
        Reads: _________ R{wildcards.mate}
        """
    conda:
        FASTQC
    resources:
        cpus = CPUS
    input:
        fastq = "results/symlinks/{sample}_R{mate}.fastq.gz"
    output:
        fastqc = directory("results/00_Quality_Control/fastqc/{sample}_R{mate}/")
    log:
        "results/10_Reports/tools-log/fastqc/{sample}_R{mate}.log"
    shell:
        "mkdir -p {output.fastqc} "    # (*) this directory must exist as the program will not create it
        "2> /dev/null && "             # in silence and then... 
        "fastqc "                    # FastQC, a high throughput sequence QC analysis tool
        "--quiet "                    # -q: Supress all progress messages on stdout and only report errors
        "--threads {resources.cpus} " # -t: Specifies files number which can be processed simultaneously
        "--outdir {output.fastqc} "   # -o: Create all output files in the specified output directory (*)
        "{input.fastq} "              # Input file.fastq
        "&> {log}"                    # Log redirection

###############################################################################
rule fastqscreen_contamination_check:
    # Aim: screen if the composition of the library matches with  what you expect
    # Use fastq_screen [OPTIONS] --outdir [DIR/] [FASTQ.GZ]
    message:
        """
        ~ Fasts-Screen ∞ Screen Contamination ~
        Sample: ________ {wildcards.sample}
        Reads: _________ R{wildcards.mate} 
        """
    conda:
        FASTQ_SCREEN
    resources:
        cpus = CPUS
    params:
        config = FQC_CONFIG,
        subset = FQC_SUBSET
    input:
        fastq = "results/symlinks/{sample}_R{mate}.fastq.gz",
        indexes = expand("resources/indexes/fastq-screen/{qc_ref}",
                        qc_ref = QC_REF)
    output:
        fastq_screen = directory("results/00_Quality_Control/fastq-screen/{sample}_R{mate}/")
    log:
        "results/10_Reports/tools-log/fastq-screen/{sample}_R{mate}.log"
    shell:
        "fastq_screen "                  # FastqScreen, what did you expect ?
        "-q "                             # --quiet: Only show log warning
        "--threads {resources.cpus} "     # --threads: Specifies across how many aligner  will be allowed to run
        "--aligner 'bowtie2' "            # -a: choose aligner 'bowtie', 'bowtie2', 'bwa', 'minimap2'
        "--conf {params.config} "         # path to configuration file
        "--subset {params.subset} "       # Don't use the whole sequence file, but create a subset of specified size
        "--outdir {output.fastq_screen} " # Output directory
        "{input.fastq} "                  # Input file.fastq
        "&> {log}"                        # Log redirection

###############################################################################
rule bowtie2_qc_indexing:
    # Aim: index sequences in the FASTA format
    # Use: bowtie2-build [OPTIONS] <reference_in> <bt2_index_base>
    message:
        """
        ~ Bowtie2-build ∞ Index QC ~
        Reference: _____ {wildcards.qc_ref}
        """
    conda:
        BOWTIE2
    resources:
        cpus = CPUS
    params:
        algorithm = BT2_ALGO
    input:
        fasta = "resources/genomes/fastq-screen/{qc_ref}.fasta"
    output:
        prefix = "resources/indexes/fastq-screen/{qc_ref}",
        bt2_indexes = multiext("resources/indexes/fastq-screen/{qc_ref}",
                               ".1.bt2", ".2.bt2", ".3.bt2", ".4.bt2",
                               ".rev.1.bt2", ".rev.2.bt2")
    log:
        "results/10_Reports/tools-log/bowtie2-indexes/{qc_ref}.log"
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
###############################################################################