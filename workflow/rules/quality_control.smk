
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name __________________ quality_control.smk
# Author ________________ Nicolas Fernandez
# Affiliation ___________ IRD_U233_TransVIHMI
# Aim ___________________ Snakefile with quality control rules
# Date __________________ 2021.09.28
# Latest modification ___ 2022.11.03
# Run ___________________ snakemake -s quality_control.smk --use-conda 

###############################################################################
###### CONFIGURATION ######

configfile: "config/config.yaml"

###############################################################################
###### FUNCTIONS ######

def get_memory_per_thread(wildcards):
    memory_per_thread = RAM // CPUS
    return memory_per_thread

###############################################################################
###### WILDCARDS ######

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

CONFIG = config["fastq-screen"]["config"]   # Fastq-screen --conf
ALIGNER = config["fastq-screen"]["aligner"] # Fastq-screen --aligner
SUBSET = config["fastq-screen"]["subset"]   # Fastq-screen --subset


###############################################################################
###### RULES ######

rule all:
    input:
        multiqc = "results/00_Quality_Control/multiqc/"

###############################################################################
rule multiqc_reports_aggregation:
    # Aim: aggregates bioinformatics analyses results into a single report
    # Use: multiqc [OPTIONS] --output [MULTIQC/] [FASTQC/] [MULTIQC/]
    message:
        "MultiQC reports aggregating"
    conda:
        MULTIQC
    input:
        fastqc = "results/00_Quality_Control/fastqc/",
        fastqscreen = "results/00_Quality_Control/fastq-screen/"
    output:
        multiqc = directory("results/00_Quality_Control/multiqc/")
    log:
        "results/10_Reports/tools-log/multiqc.log"
    shell:
        "multiqc "                  # Multiqc, searches in given directories for analysis & compiles a HTML report
        "--quiet "                   # -q: Only show log warning
        "--outdir {output.multiqc} " # -o: Create report in the specified output directory
        "{input.fastqc} "            # Input FastQC files
        "{input.fastqscreen} "       # Input Fastq-Screen
        "--no-ansi "                 # Disable coloured log
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
        config = CONFIG,
        aligner = ALIGNER,
        subset = SUBSET
    input:
        fastq = "resources/reads/"
    output:
        fastqscreen = directory("results/00_Quality_Control/fastq-screen/")
    log:
        "results/10_Reports/tools-log/fastq-screen.log"
    shell:
        "fastq_screen "                 # FastqScreen, what did you expect ?
        "-q "                            # --quiet: Only show log warning
        "--threads {resources.cpus} "    # --threads: Specifies across how many threads bowtie will be allowed to run
        "--conf {params.config} "        # path to configuration file
        "--aligner {params.aligner} "    # -a: choose aligner 'bowtie', 'bowtie2', 'bwa'
        "--subset {params.subset} "      # Don't use the whole sequence file, but create a subset of specified size
        "--outdir {output.fastqscreen} " # Output directory
        "{input.fastq}/*.fastq.gz "      # Input file.fastq
        "&> {log}"                       # Log redirection

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
        fastq = "resources/reads/"
    output:
        fastqc = directory("results/00_Quality_Control/fastqc/")
    log:
        "results/10_Reports/tools-log/fastqc.log"
    shell:
        "mkdir -p {output.fastqc} " # (*) this directory must exist as the program will not create it
        "2> /dev/null && "          # in silence and then... 
        "fastqc "                    # FastQC, a high throughput sequence QC analysis tool
        "--quiet "                    # -q: Supress all progress messages on stdout and only report errors
        "--threads {resources.cpus} " # -t: Specifies files number which can be processed simultaneously
        "--outdir {output.fastqc} "   # -o: Create all output files in the specified output directory (*)
        "{input.fastq}/*.fastq.gz "   # Input file.fastq
        "&> {log}"                    # Log redirection

###############################################################################
