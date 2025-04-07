###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ primers_clipping.smk
# Version ________________ v.2025.04
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Soft clip amplicons primers
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.04.04
# Use ____________________ snakemake -s Snakefile --use-conda
###############################################################################

###############################################################################
rule ivar_trim:
    # Aim: soft-clip amplicon PCR primers from BAM alignments
    # Use: ivar trim -i [INPUT.bam] -b [PRIMER.bed] -p [PREFIX] -e -m 20 -q 20
    message:
        """
        ~ iVar ∞ soft-clipping amplicon PCR primers from BAM alignments ~
        Sample _________ {wildcards.sample}
        Reference ______ {wildcards.reference}
        Mapper _________ {wildcards.mapper}
        """
    conda:
        IVAR
    params:
        path = PRIMER_BED_PATH,
        bed = PRIMER_BED_SCHEME,
        #path = PRIMER_BEDPE_PATH,
        #bedpe = PRIMER_BEDPE_SCHEME,
        offset = IVAR_OFFSET,
        min_len = IVAR_MIN_LENGTH,
        min_qual = IVAR_MIN_QUAL,
        slide = IVAR_SLIDE
    input:
        bam = "results/02_Mapping/{reference}/{sample}_{mapper}_markdup.bam",
        bai = "results/02_Mapping/{reference}/{sample}_{mapper}_markdup.bam.bai"
    output:
        prefix = temp("results/02_Mapping/{reference}/{sample}_{mapper}_markdup_trimmed"),
        trimmed_bam = "results/02_Mapping/{reference}/{sample}_{mapper}_markdup_trimmed.bam",
        #trimmed_bai = "results/02_Mapping/{reference}/{sample}_{mapper}_markdup_trimmed.bam.bai"
    log:
        "results/10_Reports/tools-log/ivar_trim/{reference}/{sample}_{mapper}.log"
    shell:
        "ivar trim "                   # iVar, with command 'trim': soft-clip amplicon PCR primers from BAM alignments
        "-i {input.bam} "               # Input BAM file, with aligned reads, to trim primers and quality
        "-p {output.prefix} "           # Prefix for the output BAM file
        "-b {params.path}{params.bed} " # BED file with primer sequences and positions
                                        # If no BED file is specified, only quality trimming will be done.
        #"-f {params.path}{params.bedpe} " # Primer pair information file containing left and right primer names for the same amplicon separated by a tab
                                        # If provided, reads that do not fall within atleat one amplicon will be ignored prior to primer trimming.
        "-x {params.offset} "           # primer position offset (Default: 0)
        "-m {params.min_len} "          # Minimum length of read to retain after trimming (Default: 50% average length of the first 1000 reads)
        "-q {params.min_qual} "         # Minimum quality threshold for sliding window to pass (Default: 20)
        "-s {params.slide} "            # Width of sliding window (Default: 4)
        "-e "                           # Include reads with no primers. By default, reads with no primers are excluded
        "-k "                           # Keep reads to allow for reanalysis
                                         # Keep reads which would be dropped by alignment length filter or primer requirements, but mark them QCFAIL
        "&> {log}"                      # Log redirection

###############################################################################
###############################################################################