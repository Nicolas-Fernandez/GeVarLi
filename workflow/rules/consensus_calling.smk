###############################################################################
################################## CONSENSUS ##################################
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
        Aligner: _________ {wildcards.aligner}
        Min. cov.: _______ {wildcards.min_cov}X
        Variant caller: __ {wildcards.caller}
        """
    conda:
        GAWK
    input:
        cons_tmp = "results/05_Consensus/{reference}/{sample}_{aligner}_{min_cov}X_{caller}_consensus.fasta.tmp"
    output:
        consensus = "results/05_Consensus/{reference}/{sample}_{aligner}_{min_cov}X_{caller}_consensus.fasta"
    log:
        "results/10_Reports/tools-log/sed/{reference}/{sample}_{aligner}_{min_cov}X_{caller}_fasta-header.log"
    shell:
        "sed " # Sed, a Stream EDitor used to perform basic text transformations on an input stream
        "'s/^>.*$/>{wildcards.sample}_{wildcards.aligner}_{wildcards.min_cov}X_{wildcards.caller}/' "
        "{input.cons_tmp} "      # Input file
        "1> {output.consensus} " # Output file
        "2> {log}"               # Log redirection

###############################################################################
