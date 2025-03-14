###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ functions.py
# Version ________________ v.2025.01
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Snakefile functions
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.03.12
# Use ____________________ import scripts.functions as functions
###############################################################################

###############################################################################
### IMPORTS ###
###############

import os
import re
import glob
from snakemake.io import expand
from collections import defaultdict

###############################################################################
### GLOBAL VARIABLES ###
########################


###############################################################################
### FUNCTIONS ###
##################

# get_valid_fastq
def get_valid_fastq(fastq_dir):
    fastq_files = glob.glob(os.path.join(fastq_dir, "*.fastq.gz"))
    sample_dict = defaultdict(dict)
    warnings = []
    # Parse
    for fastq in fastq_files:
        basename = os.path.basename(fastq)
        # RegEx
        match = re.search(r"^(?P<sample>.+)_R(?P<mate>[12])", basename)
        if match:
            sample = match.group("sample")
            mate = match.group("mate")
            sample_dict[sample][mate] = fastq
        else:
            warnings.append(f"[WARNING] File '{basename}' does not match the expected naming pattern. Skipping.")

    # Is paired ?
    valid_fastq = {}
    for sample, mates in sample_dict.items():
        if "1" in mates and "2" in mates:
            valid_fastq[sample] = mates
        else:
            missing = "R1" if "1" not in mates else "R2"
            warnings.append(f"[WARNING] Sample '{sample}' is incomplete (missing {missing}). Skipping.")

    warnings.append(f"\n[INFO] Total valid samples: {len(valid_fastq)}")

    return valid_fastq

# get_bam_input
def get_bam_input(wildcards):
    markdup = "results/02_Mapping/{reference}/{sample}_{mapper}_mark-dup.bam"
    if "cleapping" in MODULES:
        markdup = "results/02_Mapping/{reference}/{sample}_{mapper}_mark-dup.primerclipped.bam"
    return markdup

# get_bai_input
def get_bai_input(wildcards):
    index = "results/02_Mapping/{reference}/{sample}_{mapper}_mark-dup.bam.bai"
    if "cleapping" in MODULES:
        index = "results/02_Mapping/{reference}/{sample}_{mapper}_mark-dup.primerclipped.bam.bai"
    return index

# GET_FINAL_OUTPUTS
def get_final_outputs():
    final_outputs = []
    # quality_controls
    if MODULES["qualities"]:
        final_outputs.append(expand("results/00_Quality_Control/fastqc/{sample}_R{mate}/",
                                    sample = SAMPLE,
                                    mate = MATE))
        final_outputs.append(expand("results/00_Quality_Control/fastq-screen/{sample}_R{mate}/",
                                    sample = SAMPLE,
                                    mate = MATE))
    # reads_trimming
    if MODULES["keeptrim"]:
        final_outputs.append(expand("results/01_Trimming/sickle/{sample}_cutadapt-sickle-trimmed_R1.fastq.gz",
                                    sample = SAMPLE))
        final_outputs.append(expand("results/01_Trimming/sickle/{sample}_cutadapt-sickle-trimmed_R2.fastq.gz",
                                    sample = SAMPLE))
        final_outputs.append(expand("results/01_Trimming/sickle/{sample}_cutadapt-sickle-trimmed_SE.fastq.gz",
                                    sample = SAMPLE))
    # genomes_indexing
    final_outputs.append(expand("resources/indexes/fastq-screen/{qc_ref}",
                                qc_ref = QC_REF))
    # reads_mapping
    # primers_clipping
    if MODULES["clipping"]:
        final_outputs.append(expand("results/02_Mapping/{reference}/{sample}_{mapper}_mark-dup.primerclipped.bam",
                                    reference = REFERENCE,
                                    sample = SAMPLE,
                                    mapper = MAPPER))
        final_outputs.append(expand("results/02_Mapping/{reference}/{sample}_{mapper}_mark-dup.primerclipped.bam.bai",
                                    reference = REFERENCE,
                                    sample = SAMPLE,
                                    mapper = MAPPER))
    # duplicates_removing
    # coverage_stats
    if MODULES["covstats"]:
        final_outputs.append(expand("results/03_Coverage/{reference}/{sample}_{mapper}_{min_cov}X_coverage-stats.tsv",
                                    reference = REFERENCE,
                                    sample = SAMPLE,
                                    min_cov=MIN_COV,
                                    mapper = MAPPER))
        final_outputs.append(expand("results/03_Coverage/{reference}/histogram/{sample}_{mapper}_coverage-histogram.txt",
                                    reference = REFERENCE,
                                    sample = SAMPLE,
                                    mapper = MAPPER))
        final_outputs.append(expand("results/03_Coverage/{reference}/flagstat/{sample}_{mapper}_flagstat.{ext}",
                                    reference = REFERENCE,
                                    sample = SAMPLE,
                                    mapper = MAPPER,
                                    ext = STAT_EXT))
    # lowcov_masking
    # variants_calling
    # consensus_calling
    if MODULES["consensus"]:
        final_outputs.append(expand("results/05_Consensus/{reference}/{sample}_{mapper}_{min_cov}X_{caller}_consensus.fasta",
                                    reference = REFERENCE,
                                    sample = SAMPLE,
                                    mapper = MAPPER,
                                    min_cov=MIN_COV,
                                    caller=CALLER))
        final_outputs.append(expand("results/04_Variants/{reference}/{sample}_{mapper}_{min_cov}X_{caller}_variant-filt.vcf",
                                    reference = REFERENCE,
                                    sample = SAMPLE,
                                    mapper = MAPPER,
                                    min_cov = MIN_COV,
                                    caller = CALLER))
    # lineages_calling
    if MODULES["lineages"]:
        final_outputs.append(expand("results/06_Lineages/{reference}/{sample}_{mapper}_{min_cov}X_{caller}_{assigner}-report.tsv",
                                    reference = REFERENCE,
                                    sample = SAMPLE,
                                    mapper = MAPPER,
                                    min_cov = MIN_COV,
                                    caller = CALLER,
                                    assigner = ASSIGNER))
    # results_merging
    final_outputs.append(expand("results/All_{reference}_{mapper}_{min_cov}X_{caller}_consensus_sequences.fasta",
                                reference = REFERENCE,
                                mapper = MAPPER,
                                min_cov = MIN_COV,
                                caller = CALLER))
    final_outputs.append(expand("results/All_{reference}_{mapper}_{min_cov}X_genome_coverages.tsv",
                                reference = REFERENCE,
                                mapper = MAPPER,
                                min_cov = MIN_COV))
    final_outputs.append(expand("results/All_{reference}_{mapper}_{min_cov}X_{caller}_{assigner}-lineages.tsv",
                                reference = REFERENCE,
                                mapper = MAPPER,
                                min_cov = MIN_COV,
                                caller = CALLER,
                                assigner = ASSIGNER))
    # final_outpus
    return final_outputs

###############################################################################
