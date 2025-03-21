###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ symlinks_renamming.smk
# Version ________________ v.2025.01
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Create fastq symlinks
# Date ___________________ 2025.01.31
# Latest modifications ___ 2025.03.12
# Use ____________________ snakemake -s Snakefile --use-conda -j
###############################################################################

###############################################################################
rule config:
    # Aim: Load configuration file
    # Use: 
    message:
        """
        ~ Configuration ∞ Show analyses settings ~
        """
    input:
        config_file = "config/config.yaml"
    output:
        setting_log = "results/10_Reports/settings.log"
    script:
        "workflow/scripts/settings.py "

###############################################################################
rule symlinks:
    # Aim: Create fastq files symlinks
    # Use: ln -s <SOURCE> <LINK>
    message:
        """
        ~ Symlinks ∞ Creating symbolic links ~
        Sample: __________ {wildcards.sample}
        Reads: ___________ R{wildcards.mate}
        """
    input:
        setting_log = "results/10_Reports/settings.log",
        valid_fastq = lambda wildcards: os.path.abspath(VALID_FASTQ[wildcards.sample][wildcards.mate])
    output:
        symlink = temp("results/symlinks/{sample}_R{mate}.fastq.gz")
    log:
        "results/10_Reports/tools-log/symlinks/{sample}_R{mate}.log"
    shell:
        "mkdir -p $(dirname {output.symlink}) "
        "&& "
        "ln -sf "
        "{input.valid_fastq} "
        "{output.symlink} "
        "&> {log}"

###############################################################################
