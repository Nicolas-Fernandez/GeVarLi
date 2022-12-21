###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ quality_control.smk
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Snakefile with quality control rules
# Date ___________________ 2021.09.28
# Latest modifications ___ 2022.12.20
# Run ____________________ snakemake -s quality_control.smk --use-conda 

###############################################################################
###### CONFIGURATION ######

configfile: "configuration/config.yaml"

###############################################################################
###### FUNCTIONS ######

###############################################################################
###### WILDCARDS ######

FASTQ, = glob_wildcards("resources/reads/{fastq}.fastq.gz")

###############################################################################
###### RESOURCES ######

OS = config["os"]                  # Operating system
CPUS = config["resources"]["cpus"] # Threads (maximum)

###############################################################################
###### ENVIRONMENTS ######

FASTQC = config["conda"][OS]["fastqc"]            # FastQC
FASTQSCREEN = config["conda"][OS]["fastq-screen"] # Fastq-Screen
MULTIQC = config["conda"][OS]["multiqc"]          # MultiQC

###############################################################################
###### PARAMETERS ######

MAPPER = config["aligner"]                    # Fastq-Screen --aligner
SUBSET = config["fastq-screen"]["subset"]     # Fastq-Screen --subset
FQS_CONFIG = config["fastq-screen"]["config"] # Fastq-Screen --conf
MQC_CONFIG = config["multiqc"]["config"]      # MultiQC --conf

###############################################################################
###### RULES ######

rule all:
    input:
        multiqc = "results/00_Quality_Control/multiqc/",
        fastqscreen = expand("results/00_Quality_Control/fastq-screen/{fastq}/",
                             fastq = FASTQ),
        fastqc = expand("results/00_Quality_Control/fastqc/{fastq}/",
                        fastq = FASTQ)

###############################################################################
rule multiqc_reports_aggregation:
    # Aim: aggregates bioinformatics analyses results into a single report
    # Use: multiqc [OPTIONS] --output [MULTIQC/] [FASTQC/] [MULTIQC/]
    message:
        "MultiQC reports aggregating"
    conda:
        MULTIQC
    params:
        config = MQC_CONFIG
    input:
        fastqc = expand("results/00_Quality_Control/fastqc/{fastq}",
                        fastq = FASTQ),
        fastqscreen = expand("results/00_Quality_Control/fastq-screen/{fastq}",
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
        "--tag pangolin "            # Use only modules which tagged with this keyword (eg. pangolin)
        "--pdf "                     # Creates PDF report with 'simple' template (Requires Pandoc to be installed)
        "--export "                  # Export plots as static images in addition to the report
        "--outdir {output.multiqc} " # -o: Create report in the specified output directory
        "{input.fastqc} "            # Input FastQC files
        "{input.fastqscreen} "       # Input Fastq-Screen
        "&> {log}"                   # Log redirection

###############################################################################
rule fastqscreen_contamination_checking:
    # Aim: screen if the composition of the library matches with  what you expect
    # Use fastq_screen [OPTIONS] --outdir [DIR/] [SAMPLE_1.fastq] ... [SAMPLE_n.fastq]
    message:
        "Fastq-Screen reads contamination checking"
    conda:
        FASTQSCREEN
    resources:
        cpus = CPUS
    params:
        mapper = MAPPER,
        config = FQS_CONFIG,
        subset = SUBSET
    input:
        fastq = "resources/reads/{fastq}.fastq.gz"
    output:
        fastqscreen = directory("results/00_Quality_Control/fastq-screen/{fastq}/")
    log:
        "results/10_Reports/tools-log/fastq-screen/{fastq}.log"
    shell:
        "fastq_screen "                               # FastqScreen, what did you expect ?
        "-q "                                          # --quiet: Only show log warning
        "--threads {resources.cpus} "                  # --threads: Specifies across how many threads bowtie will be allowed to run
        "--aligner {params.mapper}  "                  # -a: choose aligner 'bowtie', 'bowtie2', 'bwa'
        "--conf {params.config}_{params.mapper}.conf " # path to configuration file
        "--subset {params.subset} "                    # Don't use the whole sequence file, but create a subset of specified size
        "--outdir {output.fastqscreen} "               # Output directory
        "{input.fastq} "                               # Input file.fastq
        "&> {log}"                                     # Log redirection

###############################################################################
rule fastqc_quality_control:
    # Aim: reads sequence files and produces a quality control report
    # Use: fastqc [OPTIONS] --output [DIR/] [SAMPLE_1.fastq] ... [SAMPLE_n.fastq]
    message:
        "FastQC reads quality controling"
    conda:
        FASTQC
    resources:
        cpus = CPUS
    input:
        fastq = "resources/reads/{fastq}.fastq.gz"
    output:
        fastqc = directory("results/00_Quality_Control/fastqc/{fastq}")
    log:
        "results/10_Reports/tools-log/fastqc/{fastq}.log"
    shell:
        "mkdir -p {output.fastqc} " # (*) this directory must exist as the program will not create it
        "2> /dev/null && "          # in silence and then... 
        "fastqc "                    # FastQC, a high throughput sequence QC analysis tool
        "--quiet "                    # -q: Supress all progress messages on stdout and only report errors
        "--threads {resources.cpus} " # -t: Specifies files number which can be processed simultaneously
        "--outdir {output.fastqc} "   # -o: Create all output files in the specified output directory (*)
        "{input.fastq} "              # Input file.fastq
        "&> {log}"                    # Log redirection

###############################################################################
