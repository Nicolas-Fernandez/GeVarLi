###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ duplicates_removing.smk
# Version ________________ v.2025.04
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Remove duplicated reads
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.04.04
# Use ____________________ snakemake -s Snakefile --use-conda
###############################################################################

###############################################################################
rule samtools_index_markdup:
    # Aim: indexing marked as duplicate BAM file
    # Use: samtools index -@ [THREADS] -b [MARK-DUP.bam] [INDEX.bai]
    message:
        """
        ~ SamTools ∞ Index 'Marked as Duplicate' BAM file ~
        Sample: __________ {wildcards.sample}
        Reference: _______ {wildcards.reference}
        Mapper: __________ {wildcards.mapper}
        """
    conda:
        SAMTOOLS
    resources:
       cpus = 6
    input:
        mark_dup = "results/02_Mapping/{reference}/{sample}_{mapper}_markdup.bam"
    output:
        index = "results/02_Mapping/{reference}/{sample}_{mapper}_markdup.bam.bai"
    log:
        "results/10_Reports/tools-log/samtools/{reference}/{sample}_{mapper}_markdup-index.log"
    shell:
        "samtools index "     # Samtools index, tools for alignments in the SAM format with command to index alignment
        "-@ {resources.cpus} " # --threads: Number of additional threads to use (default: 1)(NB, --threads form dose'nt work)
        "-b "                  # -b: Generate BAI-format index for BAM files (default)
        "{input.mark_dup} "    # Mark_dup bam input
        "{output.index} "      # Mark_dup index output
        "&> {log}"             # Log redirection

###############################################################################
rule samtools_markdup:
    # Aim: marking duplicate alignments
    # Use: samtools markdup -@ [THREADS] -r -s -O BAM [SORTED.bam] [MARK-DUP.bam] 
    message:
        """
        ~ SamTools ∞ Mark Duplicate Alignments ~
        Sample: __________ {wildcards.sample}
        Reference: _______ {wildcards.reference}
        Mapper: _________ {wildcards.mapper}
        """
    conda:
        SAMTOOLS
    resources:
       cpus = 6
    input:
        sorted = "results/02_Mapping/{reference}/{sample}_{mapper}_sorted.bam"
    output:
        mark_dup = "results/02_Mapping/{reference}/{sample}_{mapper}_markdup.bam"
    log:
        "results/10_Reports/tools-log/samtools/{reference}/{sample}_{mapper}_markdup.log"
    shell:
        "samtools markdup "          # Samtools markdup, tools for alignments in the SAM format with command mark duplicates
        "--threads {resources.cpus} " # -@: Number of additional threads to use (default: 1)
        "-r "                         # -r: Remove duplicate reads
        "-s "                         # -s: Report stats
        "--output-fmt BAM "           # -O: Specify output format: SAM, BAM, CRAM (here, BAM format)
        "{input.sorted} "             # Sorted bam input
        "{output.mark_dup} "          # Mark_dup bam output
        "&> {log}"                    # Log redirection 

###############################################################################
rule samtools_sorting:
    # Aim: sorting
    # Use: samtools sort -@ [THREADS] -m [MEM_GB] -T [TMP_DIR] -O BAM -o [SORTED.bam] [FIX-MATE.bam] 
    message:
        """
        ~ SamTools ∞ Sort BAM file ~
        Sample: __________ {wildcards.sample}
        Reference: _______ {wildcards.reference}
        Mapper: _________ {wildcards.mapper}
        """
    conda:
        SAMTOOLS
    resources:
       cpus = 6,
       mem_gb = 1,
       tmp_dir = TMP_DIR
    input:
        fix_mate = "results/02_Mapping/{reference}/{sample}_{mapper}_fix-mate.bam"
    output:
        sorted = temp("results/02_Mapping/{reference}/{sample}_{mapper}_sorted.bam")
    log:
        "results/10_Reports/tools-log/samtools/{reference}/{sample}_{mapper}_sorted.log"
    shell:
        "samtools sort "             # Samtools sort, tools for alignments in the SAM format with command to sort alignment file
        "--threads {resources.cpus} " # -@: Number of additional threads to use (default: 1)
        "-m {resources.mem_gb}G "     # -m: Set maximum memory per thread, suffix K/M/G recognized (default: 768M)
        "-T {resources.tmp_dir} "     # -T: Write temporary files to PREFIX.nnnn.bam
        "--output-fmt BAM "           # -O: Specify output format: SAM, BAM, CRAM (here, BAM format)
        "-o {output.sorted} "         # Sorted bam output
        "{input.fix_mate} "           # Fixmate bam input
        "&> {log}"                    # Log redirection 

###############################################################################
rule samtools_fixmate:
    # Aim: filling in mate coordinates
    # Use: samtools fixmate -@ [THREADS] -m -O BAM [SORT-BY-NAMES.bam] [FIX-MATE.bam] 
    message:
        """
        ~ SamTools ∞ Fil Mate Coordinates ~
        Sample: __________ {wildcards.sample}
        Reference: _______ {wildcards.reference}
        Mapper: _________ {wildcards.mapper}
        """
    conda:
        SAMTOOLS
    resources:
       cpus = 6
    input:
        sort_by_names = "results/02_Mapping/{reference}/{sample}_{mapper}_sort-by-names.bam"
    output:
        fix_mate = temp("results/02_Mapping/{reference}/{sample}_{mapper}_fix-mate.bam")
    log:
        "results/10_Reports/tools-log/samtools/{reference}/{sample}_{mapper}_fix-mate.log"
    shell:
        "samtools fixmate "          # Samtools fixmate, tools for alignments in the SAM format with command to fix mate information
        "--threads {resources.cpus} " # -@: Number of additional threads to use (default: 1)
        "-m "                         # -m: Add mate score tag 
        "--output-fmt BAM "           # -O: Specify output format: SAM, BAM, CRAM (here, BAM format)
        "{input.sort_by_names} "      # Sort_by_names bam input
        "{output.fix_mate} "          # Fix_mate bam output 
        "&> {log}"                    # Log redirection 

###############################################################################
rule samtools_sortbynames:
    # Aim: sorting by names
    # Use: samtools sort -t [THREADS] -m [MEM_GB] -n -O BAM -o [SORT-BY-NAMES.bam] [MAPPED.sam]
    message:
        """
        ~ SamTools ∞ Sort by Names BAM file ~
        Sample: __________ {wildcards.sample}
        Reference: _______ {wildcards.reference}
        Mapper: _________ {wildcards.mapper}
        """
    conda:
        SAMTOOLS
    resources:
       cpus = 6,
       mem_gb = 1
    input:
        mapped = "results/02_Mapping/{reference}/{sample}_{mapper}-mapped.sam"
    output:
        sort_by_names = temp("results/02_Mapping/{reference}/{sample}_{mapper}_sort-by-names.bam")
    log:
        "results/10_Reports/tools-log/samtools/{reference}/{sample}_{mapper}_sort-by-names.log"
    shell:
        "samtools sort "             # Samtools sort, tools for alignments in the SAM format with command to sort alignment file
        "--threads {resources.cpus} " # -@: Number of additional threads to use (default: 1)
        "-m {resources.mem_gb}G "     # -m: Set maximum memory per thread, suffix K/M/G recognized (default: 768M)
        "-n "                         # -n: Sort by read name (not compatible with samtools index command) 
        "--output-fmt BAM "           # -O: Specify output format: SAM, BAM, CRAM (here, BAM format)
        "-o {output.sort_by_names} "  # -o: Write final output to FILE rather than standard output
        "{input.mapped} "             # Mapped reads input
        "&> {log}"                    # Log redirection 

###############################################################################
###############################################################################