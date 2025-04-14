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
# Version ________________ v.2025.04
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Perform Illumina reads quality controls
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.04.04
# Use ____________________ snakemake -s Snakefile --use-conda
###############################################################################

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
        fastq = "results/symlinks/{sample}_R{mate}.fastq.gz"
    output:
        fastq_screen = directory("results/00_Quality_Control/fastq-screen/{sample}_R{mate}/")
    log:
        "results/10_Reports/tools-log/fastq-screen/{sample}_R{mate}.log"
    shell:
        "fastq_screen "                  # FastqScreen, what did you expect ?
        "-q "                             # --quiet: Only show log warning
        "--threads {resources.cpus} "     # --threads: Specifies across how many aligner  will be allowed to run
        "--aligner 'bwa' "                # -a: choose aligner 'bowtie', 'bowtie2', 'bwa'
        "--conf {params.config} "         # path to configuration file
        "--subset {params.subset} "       # Don't use the whole sequence file, but create a subset of specified size
        "--outdir {output.fastq_screen} " # Output directory
        "{input.fastq} "                  # Input file.fastq
        "&> {log}"                        # Log redirection

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
###############################################################################