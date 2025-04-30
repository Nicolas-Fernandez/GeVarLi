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
# Version ________________ v.2025.04
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Generate workflow reports
# Date ___________________ 2025.01.31
# Latest modifications ___ 2025.04.04
# Use ____________________ snakemake -s Snakefile --use-conda
###############################################################################

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
        summary = "results/10_Reports/files-summary.tsv",
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
        summary = "results/10_Reports/files-summary.tsv"
    log:
        "results/10_Reports/tools-log/files-summary.log"
    shell:
        "snakemake "          # Snakemake
        "--summary "           # Print a summary of all files created by the workflow
        "1> {output.summary} " # Output files summary
        "2> {log}"             # Log redirection

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
        copy_report = "results/MultiQC_reports.html"
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
###############################################################################