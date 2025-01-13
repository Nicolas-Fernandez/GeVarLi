###############################################################################
################################## LINEAGES ###################################
###############################################################################

###############################################################################
rule nextclade_lineage:
    # Aim: nextclade lineage assignation
    # Use: nextclade [QUERY.fasta] -t [THREADS] --outfile [NAME.csv]
    message:
        """
        ~ Nextclade ∞ Assign Lineage ~
        Sample: __________ {wildcards.sample}
        Reference: _______ {wildcards.reference}
        Aligner: _________ {wildcards.aligner}
        Min. cov.: _______ {wildcards.min_cov}X
        Variant caller: __ {wildcards.caller}
        """
    conda:
        NEXTCLADE
    resources:
        cpus = CPUS
    params:
        path = NEXT_PATH,
        dataset = NEXT_DATASET
    input:
        consensus = "results/05_Consensus/{reference}/{sample}_{aligner}_{min_cov}X_{caller}_consensus.fasta"
    output:
        lineage = "results/06_Lineages/{reference}/{sample}_{aligner}_{min_cov}X_{caller}_nextclade-report.tsv",
        alignment = directory("results/06_Lineages/{reference}/{sample}_{aligner}_{min_cov}X_{caller}_nextclade-all/")
    log:
        "results/10_Reports/tools-log/nextclade/{reference}/{sample}_{aligner}_{min_cov}X_{caller}_lineage.log"
    shell:
        "nextclade "                                    # Nextclade, assign queries sequences to clades and reports potential quality issues
        "run "                                           # Run analyzis
        "--jobs {resources.cpus} "                       # -j: Number of CPU threads used by the algorithm (default: all available threads)
        "--input-dataset {params.path}{params.dataset} " # -raq: Path to a directory containing a dataset (root-seq, tree and qc-config required)
        "--output-tsv {output.lineage} "                 # -t: Path to output TSV results file
        "--output-all {output.alignment} "               # -O: Produce all of the output files into this directory, using default basename
        "{input.consensus} "                             # Path to a .fasta file with input sequences
        "&> {log}"                                       # Log redirection

###############################################################################
rule pangolin_lineage:
    # Aim: lineage mapping
    # Use: pangolin [QUERY.fasta] -t [THREADS] --outfile [NAME.csv]
    message:
        """
        ~ Pangolin ∞ Assign Lineage ~
        Sample: __________ {wildcards.sample}
        Reference: _______ {wildcards.reference}
        Aligner: _________ {wildcards.aligner}
        Min. cov.: _______ {wildcards.min_cov}X
        Variant caller: __ {wildcards.caller}
        """
    conda:
        PANGOLIN
    resources:
        cpus = CPUS,
        tmp_dir = TMP_DIR
    input:
        consensus = "results/05_Consensus/{reference}/{sample}_{aligner}_{min_cov}X_{caller}_consensus.fasta"
    output:
        lineage = "results/06_Lineages/{reference}/{sample}_{aligner}_{min_cov}X_{caller}_pangolin-report.csv"
    log:
        "results/10_Reports/tools-log/pangolin/{reference}/{sample}_{aligner}_{min_cov}X_{caller}_lineage.log"
    shell:
        "pangolin "                     # Pangolinn, Phylogenetic Assignment of Named Global Outbreak LINeages
        "{input.consensus} "             # Query fasta file of sequences to analyse
        "--threads {resources.cpus} "    # -t: Number of threads
        "--tempdir {resources.tmp_dir} " # Specify where you want the temp stuff to go (default: $TMPDIR)
        "--outfile {output.lineage} "    # Optional output file name (default: lineage_report.csv)
        "&> {log}"                       # Log redirection

###############################################################################
