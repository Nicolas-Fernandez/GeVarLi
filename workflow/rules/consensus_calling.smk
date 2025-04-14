###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ consensus_calling.smk
# Version ________________ v.2025.04
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Call a consensus genome
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.04.04
# Use ____________________ snakemake -s Snakefile --use-conda
###############################################################################

###############################################################################
rule ivar_consensus:
    # Aim: call a consensus genome
    # Use: samtools mpileup [INPUT.bam] | ivar consensus -p [prefix] 
    message:
        """
        ~ iVar ∞ Call Consensus ~
        Sample: _______ {wildcards.sample}
        Reference: ____ {wildcards.reference}
        Mapper: _______ {wildcards.mapper}
        Min. depth: ___ {wildcards.min_depth}x
        Caller: _______ iVar
        """
    conda:
        IVAR
    params:
        min_depth = MIN_DEPTH,
        min_freq = MIN_FREQ,
        min_insert = MIN_INSERT,
        max_depth = MAX_DEPTH,
        min_bq = MIN_BQ,
        min_qual = MIN_QUAL,
        baq = MAP_QUAL
    input:
        mark_dup = get_bam_input,
        variant_call = "results/04_Variants/{sample}_{reference}_{mapper}_{min_depth}X_ivar_variant-call.tsv"
    output:
        prefix = temp("results/05_Consensus/{sample}_{reference}_{mapper}_{min_depth}X_ivar_consensus"),
        header = temp("{sample}_{reference}_{mapper}_{min_depth}X_ivar_consensus"),
        consensus = "results/05_Consensus/{sample}_{reference}_{mapper}_{min_depth}X_ivar_consensus.fasta",
        qual_txt = "results/05_Consensus/ivar_consensus-quality/{sample}_{reference}_{mapper}_{min_depth}X_ivar_consensus.qual.txt"
    log:
        "results/10_Reports/tools-log/ivar/{sample}_{reference}_{mapper}_{min_depth}x_ivar_consensus.log"
    shell:
        "samtools mpileup "              # Samtools mpileup, tools for alignments in the SAM format with command multi-way pileup
        "--verbosity 0 "                  # Set level of verbosity [INT]
        "-a "                             # -a: output all positions (including zero depth)
        "-a "                             # -a -a / -aa: output absolutely all positions, including unused ref. sequences
        "--count-orphans "                # -A: do not discard anomalous read pairs
        "--max-depth {params.max_depth} " # -d: max per-file depth; avoids excessive memory usage [INT] (default: 8000)
        "{params.baq} "                   # --no-BAQ / -B: disable BAQ (per-Base Alignment Quality)
        "--min-BQ {params.min_bq} "       # -Q: skip bases with baseQ/BAQ smaller than [INT] (default: 13)
        #"--reference {input.masked_ref} " # Reference sequence FASTA FILE
        "{input.mark_dup} "               # Markdup BAM input
        "2>&1 | grep -v '[mpileup] 1 samples in 1 input files' " # Remove this stdout
        "| "                               ### PIPE to iVar
        "ivar consensus "                # iVar, with command 'consensus': Call consensus from aligned BAM file
        "-p {output.prefix} "             # -p: prefix
        "-i {output.header} "             # -i: Name of fasta header (default: Consensus_<prefix>_threshold_<min_freq>_quality_<min_qual>_<min_insert>)
        "-q {params.min_qual} "           # -q: Minimum quality score threshold to count base [INT] (Default: 20)
        "-t {params.min_freq} "           # -t: Minimum frequency threshold (0 to 1) to call consensus [FLOAT] (Default: 0)
        "-c {params.min_insert} "         # -c: Minimum insertion frequency threshold (0 to 1) to call consensus [FLOAT] (Default: 0.8)    
        "-m {params.min_depth} "          # -m: Minimum depth to call consensus [INT] (Default: 10)
        "-n N "                           # -n: Character to print in regions with less than minimum coverage (Default: N)
        "&> {log} "                       # Log redirection
        "&& mv {output.prefix}.fa {output.consensus} "      # move consensus.fa (temp) to consensus.fasta
        "&& mv {output.prefix}.qual.txt {output.qual_txt} " # move consensus.qual.txt (tmp) to ivar_consensus-quality/ directory
        "&& touch {output.prefix} "                         # Touch prefix (temp)
        "&& touch {output.header} "                         # Touch header (temp)

###############################################################################
###############################################################################