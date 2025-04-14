###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ variants_calling.smk
# Version ________________ v.2025.04
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ SNVs and Indels calling
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.04.04
# Use ____________________ snakemake -s Snakefile --use-conda
###############################################################################

###############################################################################
rule convert_tsv2vcf:
    # Aim: convert TSV to VCF file
    # Use: python ivar_variants_to_vcf.py [INPUT.tsv] [OUTPUT.vcf]
    message:
        """
        ~ iVar ∞ Convert TSV to VCF file ~
        Sample: _______ {wildcards.sample}
        Reference: ____ {wildcards.reference}
        Mapper: _______ {wildcards.mapper}
        Min. depth: ___ {wildcards.min_depth}x
        Caller: _______ iVar
        """
    conda:
        TSV2VCF
    params:
        tsv2vcf = "workflow/scripts/ivar_variants_to_vcf.py" # Script (from viralrecon)
    input:
        tsv = "results/04_Variants/{sample}_{reference}_{mapper}_{min_depth}x_ivar_variant-call.tsv"
    output:
        vcf = "results/04_Variants/{sample}_{reference}_{mapper}_{min_depth}x_ivar_variant-filt.vcf"
    log:
        "results/10_Reports/tools-log/tsv2vcf/{sample}_{reference}_{mapper}_{min_depth}x_ivar_tsv2vcf.log"
    shell:
        "python3 "         # Python 3
        "{params.tsv2vcf} " # Script (from viralrecon)
        "{input.tsv} "      # TSV input
        "{output.vcf} "     # VCF output
        "&> {log}"          # Log redirection

###############################################################################
rule ivar_variant_calling:
    # Aim: SNVs and Indels calling 
    # Use: samtools mpileup -aa -A -d 0 -B -Q 0 --reference [<reference-fasta] <input.bam> | ivar variants -p <prefix> [-q <min-quality>] [-t <min-frequency-threshold>] [-m <minimum depth>] [-r <reference-fasta>] [-g GFF file]
    # Note: samtools mpileup output must be piped into ivar variants
    message:
        """
        ~ iVar ∞ Call Variants ~
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
        #min_indel = MIN_INDEL,
        max_depth = MAX_DEPTH,
        min_bq = MIN_BQ,
        min_qual = MIN_QUAL,
        baq = MAP_QUAL
    input:
        masked_ref = "results/04_Variants/{sample}_{reference}_{mapper}_{min_depth}x_masked-ref.fasta",
        mark_dup = get_bam_input
    output:
        variant_call = "results/04_Variants/{sample}_{reference}_{mapper}_{min_depth}x_ivar_variant-call.tsv"
    log:
        "results/10_Reports/tools-log/ivar/{sample}_{reference}_{mapper}_{min_depth}x_ivar_variant-call.log"
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
        "-p {output.variant_call} "       # -p: Prefix for the output tsv variant file
        "-q {params.min_qual} "           # -q: Minimum quality score threshold to count base (Default: 20) [INT]
        "-t {params.min_freq} "           # -t: Minimum frequency threshold (0 to 1) to call variants (Default: 0.03) [FLOAT]
        "-m {params.min_depth} "          # -m: Minimum read depth to call variants (Default: 0) [INT]
        "-r {input.masked_ref} "          # -r: Reference file used for alignment (translate the nuc. sequences and identify intra host single nuc. variants) 
        #"-g "                            # -g: A GFF file in the GFF3 format can be supplied to specify coordinates of open reading frames (ORFs)
        "&> {log}"                        # Log redirection 

###############################################################################
###############################################################################