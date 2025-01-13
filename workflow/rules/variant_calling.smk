###############################################################################
########################### VARIANTS CALLING - IVAR ###########################
###############################################################################

###############################################################################
rule convert_tsv2vcf:
    message:
        """
        ~ iVar ∞ Convert TSV to VCF file ~
        Sample: __________ {wildcards.sample}
        Reference: _______ {wildcards.reference}
        Aligner: _________ {wildcards.aligner}
        Min. cov.: _______ {wildcards.min_cov}X
        Variant caller: __ iVar
        """
    conda:
        TSV2VCF
    input:
        tsv = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_ivar_variant-call.tsv"
    output:
        vcf = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_ivar_variant-filt.vcf"
    log:
        "results/10_Reports/tools-log/tsv2vcf/{reference}/{sample}_{aligner}_{min_cov}X_ivar_tsv2vcf.log"
    shell:
        "python3 "                                  # Python 3
        "workflow/scripts/ivar_variants_to_vcf.py "  # Script (from viralrecon)
        "{input.tsv} "                               # TSV input
        "{output.vcf} "                              # VCF output
        "&> {log}"                                   # Log redirection

###############################################################################
rule ivar_consensus:
    # Aim:
    # Use:
    message:
        """
        ~ iVar ∞ Call Consensus ~
        Sample: __________ {wildcards.sample}
        Reference: _______ {wildcards.reference}
        Aligner: _________ {wildcards.aligner}
        Min. cov.: _______ {wildcards.min_cov}X
        Variant caller: __ iVar
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
        variant_call = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_ivar_variant-call.tsv"
    output:
        prefix = temp("results/05_Consensus/{reference}/{sample}_{aligner}_{min_cov}X_ivar_consensus"),
        cons_tmp = temp("results/05_Consensus/{reference}/{sample}_{aligner}_{min_cov}X_ivar_consensus.fasta.tmp"),
        qual_txt = "results/05_Consensus/{reference}/ivar_consensus-quality/{sample}_{aligner}_{min_cov}X_ivar_consensus.qual.txt",
    log:
        "results/10_Reports/tools-log/ivar/{reference}/{sample}_{aligner}_{min_cov}X_ivar_consensus.log"
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
rule ivar_variant_calling:
    # Aim: SNVs and Indels calling 
    # Use: samtools mpileup -aa -A -d 0 -B -Q 0 --reference [<reference-fasta] <input.bam> | ivar variants -p <prefix> [-q <min-quality>] [-t <min-frequency-threshold>] [-m <minimum depth>] [-r <reference-fasta>] [-g GFF file]
    # Note: samtools mpileup output must be piped into ivar variants
    message:
        """
        ~ iVar ∞ Call Variants ~
        Sample: __________ {wildcards.sample}
        Reference: _______ {wildcards.reference}
        Aligner: _________ {wildcards.aligner}
        Min. cov.: _______ {wildcards.min_cov}X
        Variant caller: __ iVar
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
        masked_ref = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_masked-ref.fasta",
        mark_dup = get_bam_input
    output:
        variant_call = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_ivar_variant-call.tsv"
    log:
        "results/10_Reports/tools-log/ivar/{reference}/{sample}_{aligner}_{min_cov}X_ivar_variant-call.log"
    shell:
        "samtools mpileup "              # Samtools mpileup, tools for alignments in the SAM format with command multi-way pileup
        "--verbosity 0 "                  # Set level of verbosity [INT]
        "-a "                             # -a: output all positions (including zero depth)
        "-a "                             # -a -a / -aa: output absolutely all positions, including unused ref. sequences
        "--count-orphans "                # -A: do not discard anomalous read pairs
        "--max-depth {params.max_depth} " # -d: max per-file depth; avoids excessive memory usage (default: 8000) [INT]
        "{params.baq} "                   # --no-BAQ / -B: disable BAQ (per-Base Alignment Quality)
        "--min-BQ {params.min_bq} "       # -Q: skip bases with baseQ/BAQ smaller than (default: 13) [INT]
        "--reference {input.masked_ref} " # Reference sequence FASTA FILE
        "{input.mark_dup} "               # Markdup BAM input
        "2>&1 | grep -v '[mpileup] 1 samples in 1 input files' " # Remove this stdout
        "| "                               ### pipe to iVar
        "ivar variants "                 # iVar, with command 'variants': Call variants from aligned BAM file
        "-p {output.variant_call} "       # -p: prefix
        "-q {params.min_qual} "           # -q: Minimum quality score threshold to count base (Default: 20) [INT]
        "-t {params.min_freq} "           # -t: Minimum frequency threshold to call variants (Default: 0.03) [FLOAT]
        "-m {params.min_depth} "          # -m: Minimum read depth to call variants (Default: 0) [INT]
        "-r {input.masked_ref} "          # -r: Reference file used for alignment (translate the nuc. sequences and identify intra host single nuc. variants) 
        #"-g "                            # -g: A GFF file in the GFF3 format can be supplied to specify coordinates of open reading frames (ORFs)
        "&> {log}"                        # Log redirection 

###############################################################################
