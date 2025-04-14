###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ results_merging.smk
# Version ________________ v.2025.04
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Merge results
# Date ___________________ 2025.01.31
# Latest modifications ___ 2025.04.04
# Use ____________________ snakemake -s Snakefile --use-conda
###############################################################################

###############################################################################
rule merge_consensus:
    message:
        """
        ~ Merge ∞ Concatenating all samples consensus sequences ~
        Reference: ____ {wildcards.reference}
        Mapper: _______ {wildcards.mapper}
        Min. depth: ___ {wildcards.min_depth}x
        Caller: _______ {wildcards.caller}
        """
    input:
        consensus = lambda wildcards: expand("results/05_Consensus/{sample}_{reference}_{mapper}_{min_depth}x_{caller}_consensus.fasta",
                                            sample = SAMPLE,
                                            reference = wildcards.reference,
                                            mapper = wildcards.mapper,
                                            min_cov = wildcards.min_cov,
                                            caller = wildcards.caller)
    output:
        all_consensus = "results/All_{reference}_{mapper}_{min_depth}x_{caller}_consensus_sequences.fasta"
    log:
        "results/10_Reports/tools-log/merge_consensus/{reference}_{mapper}_{min_depth}x_{caller}_consensus.log"
    shell:
        "cat "                      # Concatenate all consensus sequences
        "{input.consensus} "         # Input files
        "1> {output.all_consensus} " # Output file
        "2> {log}"                   # Log redirection

###############################################################################
rule merge_coverage:
    message:
        """
        ~ Merge ∞ Concatenating genome coverage statistics ~
        Reference: ____ {wildcards.reference}
        Mapper: _______ {wildcards.mapper}
        Min. depth: ___ {wildcards.min_depth}x
        """
    input:
        covstats = lambda wildcards: expand("results/03_Coverage/{sample}_{reference}_{mapper}_{min_depth}x_coverage-stats.tsv",
                                            sample = SAMPLE,
                                            reference = wildcards.reference,
                                            mapper = wildcards.mapper,
                                            min_cov = wildcards.min_cov)
    output:
        all_covstats = "results/All_{reference}_{mapper}_{min_depth}x_genome_coverages.tsv"
    log:
        "results/10_Reports/tools-log/merge_coverage/{reference}_{mapper}_{min_depth}x_covstats.log"
    shell:
        "cat {input.covstats} | "  # Concatenate all coverage statistics
        "awk 'NR==1 || NR%2==0' "   # Keep only even lines
        "1> {output.all_covstats} " # Output file
        "2> {log}"                  # Log redirection

###############################################################################
rule merge_clade:
    message:
        """
        ~ Merge ∞ Concatenating lineage assignments ~
        Reference: ____ {wildcards.reference}
        Mapper: _______ {wildcards.mapper}
        Min. depth: ___ {wildcards.min_depth}x
        Caller: _______ {wildcards.caller}
        Assigner: _____ {wildcards.assigner}
        """
    input:
        lineages = lambda wildcards: expand("results/06_Lineages/{sample}_{reference}_{mapper}_{min_depth}x_{caller}_{assigner}-report.tsv",
                                        sample = SAMPLE,
                                        reference = wildcards.reference,
                                        mapper = wildcards.mapper,
                                        min_cov = wildcards.min_cov,
                                        caller = wildcards.caller,
                                        assigner = wildcards.assigner)
    output:
        all_lineages = "results/All_{reference}_{mapper}_{min_depth}x_{caller}_{assigner}-lineages.tsv"
    log:
        "results/10_Reports/tools-log/merge_clade/{reference}_{mapper}_{min_depth}x_{caller}_{assigner}-lineages.log"
    shell:
        "cat {input.lineages} | "  # Concatenate all lineage assignments
        "awk 'NR==1 || NR%2==0' "   # Keep only even lines
        "1> {output.all_lineages} " # Output file
        "2> {log}"                  # Log redirection

###############################################################################
###############################################################################