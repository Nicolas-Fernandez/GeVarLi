###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ sample_prep.smk
# Version ________________ v.2025.04
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Prepare samples
# Date ___________________ 2025.01.31
# Latest modifications ___ 2025.04.04
# Use ____________________ snakemake -s Snakefile --use-conda
###############################################################################

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
        valid_fastq = lambda wildcards: os.path.abspath(VALID_FASTQ[wildcards.sample][wildcards.mate])
    output:
        symlink = temp("results/symlinks/{sample}_R{mate}.fastq.gz")
    log:
        "results/10_Reports/tools-log/symlinks/{sample}_R{mate}.log"
    shell:
        "mkdir -p $(dirname {output.symlink}) " # Create output directory
        "&& "                                   # Create symlink directory
        "ln -sf "                               # Create symbolic link
        "{input.valid_fastq} "                  # Source file
        "{output.symlink} "                     # Link
        "&> {log}"                              # Log redirection

###############################################################################
###############################################################################