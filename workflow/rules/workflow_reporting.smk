###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ workflow_reporting.smk
# Version ________________ v.2025.01
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Generate workflow reports
# Date ___________________ 2025.01.31
# Latest modifications ___ 2025.03.12
# Use ____________________ snakemake -s Snakefile --use-conda -j
###############################################################################



###############################################################################

###############################################################################
rule tar_reports:
    # Aim: compresses reports into a tarball
    # Use: tar -zcf 10_Reports_archive.tar.gz 10_Reports/
    message:
        """
        ~ Archive ∞ Compress reports ~
        """
    input:
        html_report = "results/10_Reports/workflow-report.html"
    output:
        tarball = "results/Reports_archive.tar.gz"
    shell:
        "tar "                     # Tar command
        "-z "                       # Gzip compression
        "-c "                       # Create a new archive
        "-f "                       # Use archive file or device ARCHIVE
        "{output.tarball} "         # Output archive
        "-C results/ "              # Change to directory 'results/'
        "10_Reports/"               # Input directory to compress

###############################################################################
rule snakemake_report:
    # Aim: generates a workflow report in HTML format
    # Use: snakemake --report [OPTIONS] [REPORT]
    message:
        """
        ~ Report ∞ Generate a workflow report in HTML format ~
        """
    conda:
        WORKFLOW
    params:
        #style_sheet = STYLE_SHEET
    input:
        multiqc = "results/10_Reports/multiqc/",
        time = "results/10_Reports/time.log",
        summary = "results/10_Reports/files-summary.txt",
        graph = expand("results/10_Reports/graphs/{graph_type}.{ext}",
            graph_type = GRAPH_TYPE,
            ext = GRAPH_EXT),
    output:
        html_report = "results/10_Reports/workflow-report.html"
    log:
        "results/10_Reports/tools-log/workflow-report.log"
    shell:
        "snakemake "            # Snakemake
        "--report "              # Create an HTML report with results and statistics
        #"--report-stylesheet {params.style_sheet} " # Custom stylesheet to use for report
        " {output.html_report} " # Output report
        "2> {log}"               # Log redirection

###############################################################################
rule snakemake_summary:
    # Aim: generates a workflow summary in txt format
    # Use: snakemake --summary
    message:
        """
        ~ Summary ∞ Generate a files summary in txt format ~
        """
    conda:
        WORKFLOW
    input:
        final_outputs = get_final_outputs()
    output:
        summary = "results/10_Reports/files-summary.txt"
    log:
        "results/10_Reports/tools-log/files-summary.log"
    shell:
        "snakemake "          # Snakemake
        "--summary "           # Print a summary of all files created by the workflow
        "1> {output.summary} " # Output files summary
        "2> {log}"             # Log redirection

###############################################################################
rule snakemake_graph:
    # Aim: generates a workflow graph in png, svg or pdf format
    # Use: snakemake --{graph_type} | dot -T{ext}
    message:
        """
        ~ Graph ∞ Generate {wildcards.graph_type} in {wildcards.ext} format ~
        """
    conda:
        WORKFLOW
    params:
    input:
        final_outputs = get_final_outputs()
    output:
        graph = "results/10_Reports/graphs/{graph_type}.{ext}"
    log:
        "results/10_Reports/tools-log/graphs/{graph_type}-{ext}.log"
    shell:
        "snakemake "               # Snakemake
        "--{wildcards.graph_type} " # Graph types: 'dag', 'rulegraph', 'filegraph'
        "| dot -T{wildcards.ext} "  # Formats: 'png', 'svg', 'pdf'
        "1> {output.graph} "        # Output graph
        "2> {log}"                  # Log redirection

###############################################################################
rule multiqc_aggregation:
    # Aim: aggregates bioinformatics analyses results into a single report
    # Use: multiqc [OPTIONS] --output [MULTIQC/] [FASTQC/] [MULTIQC/]
    message:
        """
        ~ MultiQC ∞ Aggregate HTML Reports ~
        """
    conda:
        MULTIQC
    params:
        #config = MQC_CONFIG,
        #tag = TAG
    input:
        final_outputs = get_final_outputs()
    output:
        multiqc = directory("results/10_Reports/multiqc/"),
        html_report = "results/10_Reports/multiqc/multiqc_report.html",
        copy_report = "results/All_QC_reports.html"
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
        "{input.final_outputs} "     # Input final outputs
        "> {log} 2>&1 "              # Log redirection
        "&& cp {output.html_report} {output.copy_report} " # Copy report to results directory
        "2> /dev/null"               # Suppress error messages

###############################################################################
rule log_time:
    # Aim: log workflow start and end time
    # Use: date +"%Y-%m-%d %H:%M"
    message:
        """
        ~ Log ∞ Workflow time ~
        """
    input:
        final_outputs = get_final_outputs()
    output:
        time_log = "results/10_Reports/time.log"
    run:
        time_stamp_start = time.strftime("%Y-%m-%d %H:%M", time.localtime(start_time)) # Get system: analyzes starting time
        time_stamp_end = time.strftime("%Y-%m-%d %H:%M", time.localtime())             # Get date / hour ending analyzes
        elapsed_time = int(time.time() - start_time) # Get SECONDS counter
        hours = elapsed_time // 3600                 # /3600 = hours
        minutes = (elapsed_time % 3600) // 60        # %3600 /60 = minutes
        seconds = elapsed_time % 60                  # %60 = seconds
        formatted_time = f"{hours:02d}:{minutes:02d}:{seconds:02d}" # Format
        green = "\033[32m" # ANSI green color code
        ylo = "\033[33m"   # ANSI yellow color code
        nc = "\033[0m"     # ANSI no-color code
        message_time = f"""
{green}Start time{nc} _____________ {time_stamp_start}
{green}End time{nc} _______________ {time_stamp_end}
{green}Processing time{nc} ________ {ylo}{formatted_time}{nc}
"""
        print(message_time) # Print time message
        ansi_escape = re.compile(r'\x1B\[[0-?]*[ -/]*[@-~]') # ANSI escape code
        message_clean = ansi_escape.sub('', message_time) # Clean ANSI escape code
        with open(output.time_log, "w") as f: # Log time message
            f.write(message_clean)

###############################################################################
rule log_setup:
    # Aim: log user setup
    # Use:
    message:
        """
        ~ Log ∞ User setup ~
        """
    input:
        setup = "config/config.yaml",
    output:
        setup_log = "results/10_Reports/setup.log"
    run:
        import subprocess
        uname = subprocess.check_output(["uname", "-a"]).decode().strip()
        fastq_dir = subprocess.check_output(["yq", "-Mr", ".fastq_dir", input.setup]).decode().strip()
        try:
            fastq_files = subprocess.check_output(["bash", "-c", "ls -1 {}/*.fastq.gz 2>/dev/null | wc -l".format(fastq_dir)]).decode().strip()
        except Exception:
            fastq_files = "0"
        with open(output.setup_log, "w") as f:
            f.write("OS info: " + uname + "\n")
            f.write("Fastq directory: " + fastq_dir + "\n")
            f.write("Number of fastq files: " + fastq_files + "\n")

###############################################################################
rule log_environments:
    # Aim: copy conda environments files to results
    # Use: cp workflow/envs/*.yaml results/10_Reports/envs/
    message:
        """
        ~ Log ∞ Workflow environments ~
        """
    input:
        envs = "workflow/envs"
    output:
        envs_log = directory("results/10_Reports/envs/")
    shell:
        "mkdir -p {output.envs_log} && "            # Create directory
        "cp {input.envs}/*.yaml {output.envs_log} " # Copy envs files
        "2> /dev/null"                              # Suppress error messages

###############################################################################
rule log_config:
    # Aim: copy settings file to results
    # Use: cp config/config.yaml results/10_Reports/config.log
    message:
        """
        ~ Log ∞ Workflow configuration ~
        """
    input:
        config = "config/config.yaml"
    output:
        config_log = "results/10_Reports/config.log"
    shell:
        "cp {input.config} {output.config_log} " # Copy config file
        "2> /dev/null"                           # Suppress error messages

###############################################################################
