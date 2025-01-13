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
# Latest modifications ___ 2025.01.13
# Use ____________________ import scripts.functions as functions
###############################################################################

# import
from snakemake.io import temp
from snakemake.io import expand

# global variable
MODULES = []

# functions
def get_memory_per_thread(wildcards):
    memory_per_thread = int(RAM) // int(CPUS)
    if memory_per_thread < 1:
        memory_per_thread = 1
    return memory_per_thread

def get_quality_input(wildcards):
    if "quality" in MODULES:
        return "results/00_Quality_Control/multiqc/"
    return []

def get_trimming_input(wildcards):
    if "trimming" in MODULES:
        return expand("results/01_Trimming/sickle/{sample}_sickle-trimmed_SE.fastq.gz",
                      sample = SAMPLE)
    return []

def stash_or_trash(path):
    if "keeptrim" in MODULES:
        return path
    else:
        return temp(path)

def get_bam_input(wildcards):
    markdup = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.bam"
    if "cleapping" in MODULES:
        markdup = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.primerclipped.bam"
    return markdup

def get_bai_input(wildcards):
    index = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.bam.bai"
    if "cleapping" in MODULES:
        index = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.primerclipped.bam.bai"
    return index

def get_flagstat_input(wildcards):
    if "covstats" in MODULES:
        return expand("results/03_Coverage/{reference}/flagstat/{sample}_{aligner}_flagstat.{ext}",
                      reference = REFERENCE,
                      sample = SAMPLE,
                      aligner = ALIGNER,
                      ext = ["txt", "tsv", "json"])
    return []

def get_covstats_input(wildcards):
    if "covstats" in MODULES:
        return expand("results/03_Coverage/{reference}/{sample}_{aligner}_{min_cov}X_coverage-stats.tsv",
                      reference = REFERENCE,
                      sample = SAMPLE,
                      aligner = ALIGNER,
                      min_cov = MIN_COV)
    return []

def get_consensus_input(wildcards):
    if "consensus" in MODULES:
        return expand("results/05_Consensus/{reference}/{sample}_{aligner}_{min_cov}X_{caller}_consensus.fasta",
                      reference = REFERENCE,
                      sample = SAMPLE,
                      aligner = ALIGNER,
                      min_cov = MIN_COV,
                      caller = CALLER)
    return []

def get_vcf_input(wildcards):
    if "consensus" in MODULES:
        return expand("results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_{caller}_variant-filt.vcf",
                      reference = REFERENCE,
                      sample = SAMPLE,
                      aligner = ALIGNER,
                      min_cov = MIN_COV,
                      caller = CALLER)
    return []

def get_nextclade_input(wildcards):
    if "nextclade" in MODULES:
        return expand("results/06_Lineages/{reference}/{sample}_{aligner}_{min_cov}X_{caller}_nextclade-report.tsv",
                      reference = REFERENCE,
                      sample = SAMPLE,
                      aligner = ALIGNER,
                      min_cov = MIN_COV,
                      caller = CALLER)
    return []

def get_pangolin_input(wildcards):
    if "pangolin" in MODULES:
        return expand("results/06_Lineages/{reference}/{sample}_{aligner}_{min_cov}X_{caller}_pangolin-report.csv",
                      reference = REFERENCE,
                      sample = SAMPLE,
                      aligner = ALIGNER,
                      min_cov = MIN_COV,
                      caller = CALLER)
    return []

def get_gisaid_input(wildcards):
    if "gisaid" in MODULES:
        return expand("",
                      )
    return []

###############################################################################
