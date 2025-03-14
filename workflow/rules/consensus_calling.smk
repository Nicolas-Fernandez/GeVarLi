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
# Version ________________ v.2025.01
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Call a consensus genome
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.03.12
# Use ____________________ snakemake -s Snakefile --use-conda -j
###############################################################################

###############################################################################
rule sed_rename_headers:
    # Aim: rename all fasta header with sample name
    # Use: sed 's/[OLD]/[NEW]/' [IN] > [OUT]
    message:
        """
        ~ Sed ∞ Rename Fasta Header ~
        Sample: __________ {wildcards.sample}
        Reference: _______ {wildcards.reference}
        Mapper: __________ {wildcards.mapper}
        Min. cov.: _______ {wildcards.min_cov}X
        Caller: __________ {wildcards.caller}
        """
    conda:
        GAWK
    input:
        cons_tmp = "results/05_Consensus/{reference}/{sample}_{mapper}_{min_cov}X_{caller}_consensus.fasta.tmp"
    output:
        consensus = "results/05_Consensus/{reference}/{sample}_{mapper}_{min_cov}X_{caller}_consensus.fasta"
    log:
        "results/10_Reports/tools-log/sed/{reference}/{sample}_{mapper}_{min_cov}X_{caller}_fasta-header.log"
    shell:
        "sed " # Sed, a Stream EDitor used to perform basic text transformations on an input stream
        "'s/^>.*$/>{wildcards.sample}_{wildcards.mapper}_{wildcards.min_cov}X_{wildcards.caller}/' "
        "{input.cons_tmp} "      # Input file
        "1> {output.consensus} " # Output file
        "2> {log}"               # Log redirection

###############################################################################
rule ivar_consensus:
    # Aim: call a consensus genome
    # Use: samtools mpileup [INPUT.bam] | ivar consensus -p [prefix] 
    message:
        """
        ~ iVar ∞ Call Consensus ~
        Sample: __________ {wildcards.sample}
        Reference: _______ {wildcards.reference}
        Mapper: _________ {wildcards.mapper}
        Min. cov.: _______ {wildcards.min_cov}X
        Caller: __ iVar
        """
    conda:
        IVAR
    params:
        min_depth = IVAR_MIN_DEPTH,
        min_freq = IVAR_MIN_FREQ,
        min_insert = IVAR_MIN_INSERT,
        max_depth = IVAR_MAX_DEPTH,
        min_bq = IVAR_MIN_BQ,
        min_qual = IVAR_MIN_QUAL,
        baq = IVAR_MAP_QUAL
    input:
        mark_dup = get_bam_input,
        variant_call = "results/04_Variants/{reference}/{sample}_{mapper}_{min_cov}X_ivar_variant-call.tsv"
    output:
        prefix = temp("results/05_Consensus/{reference}/{sample}_{mapper}_{min_cov}X_ivar_consensus"),
        cons_tmp = temp("results/05_Consensus/{reference}/{sample}_{mapper}_{min_cov}X_ivar_consensus.fasta.tmp"),
        qual_txt = "results/05_Consensus/{reference}/ivar_consensus-quality/{sample}_{mapper}_{min_cov}X_ivar_consensus.qual.txt",
    log:
        "results/10_Reports/tools-log/ivar/{reference}/{sample}_{mapper}_{min_cov}X_ivar_consensus.log"
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
        "-q {params.min_qual} "           # -q: Minimum quality score threshold to count base [INT] (Default: 20)
        "-t {params.min_freq} "           # -t: Minimum frequency threshold to call variants [FLOAT] (Default: 0.03)
        "-c {params.min_insert} "         # -c: Minimum insertion frequency threshold to call consensus [FLOAT] (Default: 0.8)    
        "-m {params.min_depth} "          # -m: Minimum read depth to call variants [INT] (Default: 0)
        "-n N "                           # -n: Character to print in regions with less than minimum coverage (Default: N)
        #"-i {wildcards.sample} "          # -i: Name of fasta header (default: Consensus_<prefix>_threshold_<min_freq>_quality_<min_qual>_<min_insert>
        "&> {log} "                       # Log redirection
        "&& mv {output.prefix}.fa {output.cons_tmp} "       # copy consensus.fa (temp) to consensus.fasta.tmp (tmp)
        "&& mv {output.prefix}.qual.txt {output.qual_txt} " # cppty consensus.qual.txt (tmp) to ivar_consensus-quality/ directory
        "&& touch {output.prefix}"                          # Touch done

###############################################################################
