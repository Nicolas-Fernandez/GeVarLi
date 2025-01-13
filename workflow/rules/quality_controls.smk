###############################################################################
############################### QUALITY CONTROL ###############################
###############################################################################

###############################################################################
rule multiqc_reports_aggregation:
    # Aim: aggregates bioinformatics analyses results into a single report
    # Use: multiqc [OPTIONS] --output [MULTIQC/] [FASTQC/] [MULTIQC/]
    priority: 999 # Explicit high priority
    message:
        """
        ~ MultiQC ∞ Aggregat HTML Qualities Reports ~
        """
    conda:
        MULTIQC
    params:
        #config = MQC_CONFIG,
        #tag = TAG
    input:
        fastqc = expand("results/00_Quality_Control/fastqc/{fastq}/",
                        fastq = FASTQ),
        fastq_screen = expand("results/00_Quality_Control/fastq-screen/{fastq}/",
                             fastq = FASTQ)
    output:
        multiqc = directory("results/00_Quality_Control/multiqc/")
    log:
        "results/10_Reports/tools-log/multiqc.log"
    shell:
        "multiqc "                  # Multiqc, searches in given directories for analysis & compiles a HTML report
        "--quiet "                   # -q: Only show log warning
        "--no-ansi "                 # Disable coloured log
        #"--config {params.config} "  # Specific config file to load
        #"--tag {params.tag} "        # Use only modules which tagged with this keyword
        #"--pdf "                     # Creates PDF report with 'simple' template (require xelatex)
        "--export "                  # Export plots as static images in addition to the report
        "--outdir {output.multiqc} " # -o: Create report in the specified output directory
        "{input.fastqc} "            # Input FastQC files
        "{input.fastq_screen} "      # Input Fastq-Screen
        "&> {log}"                   # Log redirection

###############################################################################
rule fastqscreen_contamination_checking:
    # Aim: screen if the composition of the library matches with  what you expect
    # Use fastq_screen [OPTIONS] --outdir [DIR/] [FASTQ.GZ]
    message:
        """
        ~ Fasts-Screen ∞ Screen Contamination ~
        Fastq: __________ {wildcards.fastq}
        """
    conda:
        FASTQ_SCREEN
    resources:
        cpus = CPUS
    params:
        config = FQC_CONFIG,
        subset = SUBSET
    input:
        fastq = "resources/symlinks/{fastq}.fastq.gz"
    output:
        fastq_screen = directory("results/00_Quality_Control/fastq-screen/{fastq}/")
    log:
        "results/10_Reports/tools-log/fastq-screen/{fastq}.log"
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
        Fastq: __________ {wildcards.fastq}
        """
    conda:
        FASTQC
    resources:
        cpus = CPUS
    input:
        fastq = "resources/symlinks/{fastq}.fastq.gz"
    output:
        fastqc = directory("results/00_Quality_Control/fastqc/{fastq}/")
    log:
        "results/10_Reports/tools-log/fastqc/{fastq}.log"
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
