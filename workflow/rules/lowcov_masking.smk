###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ lowcov_masking.smk
# Version ________________ v.2025.04
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Mask low coverage regions
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.04.04
# Use ____________________ snakemake -s Snakefile --use-conda
###############################################################################

###############################################################################
rule bedtools_masking:
    # Aim: masking low coverage regions
    # Use: bedtools maskfasta [OPTIONS] -fi [REFERENCE.fasta] -bed [RANGE.bed] -fo [MASKEDREF.fasta]
    message:
        """
        ~ BedTools ∞ Mask Low Coverage Regions ~
        Sample: _______ {wildcards.sample}
        Reference: ____ {wildcards.reference}
        Mapper: _______ {wildcards.mapper}
        Min. depth: ___ {wildcards.min_depth}x
        """
    conda:
        BEDTOOLS
    input:
        reference = "resources/genomes/{reference}.fasta",
        low_cov_mask = "results/03_Coverage/bed/{sample}_{reference}_{mapper}_{min_depth}x_low-cov-mask.bed"
    output:
        masked_ref = "results/04_Variants/{sample}_{reference}_{mapper}_{min_depth}x_masked-ref.fasta"
    log:
        "results/10_Reports/tools-log/bedtools/{sample}_{reference}_{mapper}_{min_depth}x_masking.log"
    shell:
        "bedtools maskfasta "       # Bedtools maskfasta, mask a fasta file based on feature coordinates
        "-fi {input.reference} "     # Input FASTA file 
        "-bed {input.low_cov_mask} " # BED/GFF/VCF file of ranges to mask in -fi
        "-fo {output.masked_ref} "   # Output masked FASTA file
        "&> {log}"                   # Log redirection 

###############################################################################
rule bedtools_merged_mask:
    # Aim: merging overlaps
    # Use: bedtools merge [OPTIONS] -i [FILTERED.bed] -g [GENOME.fasta] 
    message:
        """
        ~ BedTools ∞ Merge Overlaps ~
        Sample: _______ {wildcards.sample}
        Reference: ____ {wildcards.reference}
        Mapper: _______ {wildcards.mapper}
        Min. depth: ___ {wildcards.min_depth}x
        """
    conda:
        BEDTOOLS
    input:
        min_cov_filt = "results/03_Coverage/bed/{sample}_{reference}_{mapper}_{min_depth}x_min-cov-filt.bed"
    output:
        low_cov_mask = temp("results/03_Coverage/bed/{sample}_{reference}_{mapper}_{min_depth}x_low-cov-mask.bed")
    log:
        "results/10_Reports/tools-log/bedtools/{sample}_{reference}_{mapper}_{min_depth}x_merge-overlaps.log"
    shell:
        "bedtools merge "          # Bedtools merge, merges overlapping BED/GFF/VCF entries into a single interval
        "-i {input.min_cov_filt} "  # -i: BED/GFF/VCF input to merge 
        "1> {output.low_cov_mask} " # merged output
        "2> {log}"                  # Log redirection

###############################################################################
rule awk_min_covfilt:
    # Aim: minimum coverage filtration
    # Use: awk '$4 < [MIN_COV]' [BEDGRAPH.bed] 1> [FILTERED.bed]
    message:
        """
        ~ Awk ∞ Minimum Coverage Filtration ~
        Sample: _______ {wildcards.sample}
        Reference: ____ {wildcards.reference}
        Mapper: _______ {wildcards.mapper}
        Min. depth: ___ {wildcards.min_depth}x
        """
    conda:
        GAWK
    input:
        genome_cov = "results/02_Mapping/{sample}_{reference}_{mapper}_genome-cov.bed"
    output:
        min_cov_filt = temp("results/03_Coverage/bed/{sample}{reference}_{mapper}_{min_depth}x_min-cov-filt.bed")
    log:
        "results/10_Reports/tools-log/awk/{sample}_{reference}_{mapper}_{min_depth}x_min-cov-filt.log"
    shell:
        "awk "                      # Awk, a program that you can use to select particular records in a file and perform operations upon them
        "'$4 < {wildcards.min_depth}' " # Minimum coverage for masking regions in consensus sequence
        "{input.genome_cov} "         # BedGraph coverage input
        "1> {output.min_cov_filt} "   # Minimum coverage filtered bed output
        "2> {log} "                   # Log redirection

###############################################################################
###############################################################################