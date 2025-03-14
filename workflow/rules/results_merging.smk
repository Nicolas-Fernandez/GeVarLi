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
# Version ________________ v.2025.01
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Merge results
# Date ___________________ 2025.01.31
# Latest modifications ___ 2025.03.12
# Use ____________________ snakemake -s Snakefile --use-conda -j
###############################################################################

###############################################################################
rule merge_consensus:
    message:
        """                                                                                                                                       
        ~ Merge ∞ Concatenating all samples consensus sequences ~
        Reference: _______ {wildcards.reference}
        Mapper: __________ {wildcards.mapper}
        Min. cov.: _______ {wildcards.min_cov}X
        Caller: __________ {wildcards.caller}                                                                                            
        """
    input:
        consensus = lambda wildcards: expand("results/05_Consensus/{reference}/{sample}_{mapper}_{min_cov}X_{caller}_consensus.fasta",
                                            reference = wildcards.reference,
                                            sample = SAMPLE,
                                            mapper = wildcards.mapper,
                                            min_cov = wildcards.min_cov,
                                            caller = wildcards.caller)
    output:
        all_consensus = "results/All_{reference}_{mapper}_{min_cov}X_{caller}_consensus_sequences.fasta"
    log:
        "results/10_Reports/tools-log/merge_consensus/{reference}/{mapper}_{min_cov}X_{caller}_consensus.log"
    shell:
        "cat "                     # Concatenate all consensus sequences
        "{input.consensus} "        # Input files
        "> {output.all_consensus} " # Output file
        "2> {log}"                  # Log redirection

###############################################################################
rule merge_coverage:
    message:
        """                                                                                                                                       
        ~ Merge ∞ Concatenating genome coverage statistics ~
        Reference: _______ {wildcards.reference}
        Mapper: __________ {wildcards.mapper}
        Min. cov.: _______ {wildcards.min_cov}X
        """
    input:
        covstats = lambda wildcards: expand("results/03_Coverage/{reference}/{sample}_{mapper}_{min_cov}X_coverage-stats.tsv",
                                            reference = wildcards.reference,
                                            sample = SAMPLE,
                                            mapper = wildcards.mapper,
                                            min_cov = wildcards.min_cov)
    output:
        all_covstats = "results/All_{reference}_{mapper}_{min_cov}X_genome_coverages.tsv",
        temp_covstats = temp("results/All_{reference}_{mapper}_{min_cov}X_genome_coverages.temp")
    log:
        "results/10_Reports/tools-log/merge_coverage/{reference}/{mapper}_{min_cov}X_covstats.log"
    shell:
        "cat {input.covstats} > {output.temp_covstats} && "                      # Concatenate all coverage statistics          
        "awk 'NR==1 || NR%2==0' {output.temp_covstats} 1> {output.all_covstats} " # Keep only even lines
        "2> {log}"                                                                # Log redirection                  

###############################################################################
rule merge_clade:
    message:
        """                                                                                                                                       
        ~ Merge ∞ Concatenating Pangolin lineage assignments ~
        Reference: _______ {wildcards.reference}
        Mapper: __________ {wildcards.mapper}
        Min. cov.: _______ {wildcards.min_cov}X
        Variant caller: __ {wildcards.caller}
        Assigner: ________ {wildcards.assigner}                                                                               
        """
    input:
        lineages = lambda wildcards: expand("results/06_Lineages/{reference}/{sample}_{mapper}_{min_cov}X_{caller}_{assigner}-report.tsv",
                                        reference = wildcards.reference,
                                        sample = SAMPLE,
                                        mapper = wildcards.mapper,
                                        min_cov = wildcards.min_cov,
                                        caller = wildcards.caller,
                                        assigner = wildcards.assigner)
    output:
        all_lineages = "results/All_{reference}_{mapper}_{min_cov}X_{caller}_{assigner}-lineages.tsv",
        temp_lineages = temp("results/All_{reference}_{mapper}_{min_cov}X_{caller}_{assigner}-lineages.temp")
    log:
        "results/10_Reports/tools-log/merge_clade/{reference}/{mapper}_{min_cov}X_{caller}_{assigner}-lineages.log"
    shell:
        "cat {input.lineages} > {output.temp_lineages} && "                      # Concatenate all clade assignments
        "awk 'NR==1 || NR%2==0' {output.temp_lineages} 1> {output.all_lineages} " # Keep only even lines
        "2> {log}"                                                                # Log redirection

###############################################################################
