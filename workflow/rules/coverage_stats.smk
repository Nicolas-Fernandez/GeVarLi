###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ coverage_stats.smk
# Version ________________ v.2025.06
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Compute Genome Coverage Statistics from BED file
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.06.10
# Use ____________________ snakemake --use-conda -s <SNAKEFILE>
###############################################################################

###############################################################################
rule awk_coverage_statistics:
    # Aim: computing genomme coverage stats
    # Use: awk {FORMULA} END {{print [RESULTS.tsv] [BEDGRAPH.bed]
    message:
        """
        ~ Awk ∞ Compute Genome Coverage Statistics from BED file ~
        Sample: _______ {wildcards.sample}
        Reference: ____ {wildcards.reference}
        Mapper: _______ {wildcards.mapper}
        Min. depth: ___ {wildcards.min_depth}x
        """
    conda:
        GAWK
    input:
        cutadapt = "results/10_Reports/tools-log/cutadapt/{sample}.log",
        sickle = "results/10_Reports/tools-log/sickle-trim/{sample}.log",
        samtools = "results/10_Reports/tools-log/samtools/{sample}_{reference}_{mapper}_markdup.log",
        flagstat = "results/03_Coverage/flagstat/{sample}_{reference}_{mapper}_flagstat.json",
        histogram = "results/03_Coverage/histogram/{sample}_{reference}_{mapper}_coverage-histogram.txt",
        genome_cov = "results/02_Mapping/{sample}_{reference}_{mapper}_genome-cov.bed"
    output:
        cov_stats = "results/03_Coverage/{sample}_{reference}_{mapper}_{min_depth}x_coverage-stats.tsv"
    log:
        "results/10_Reports/tools-log/awk/{sample}_{reference}_{mapper}_{min_depth}x_coverage-stats.log"
    shell:
        r""" rawReads=$(grep -o -E  """                                  # Get raw reads 
        r""" 'Total read pairs processed:.+' {input.cutadapt}  """       #
        r""" | sed -E 's/Total read pairs processed:\ +//'  """          #
        r""" | sed 's/,//g') ; """                                       #
        #
        r""" cutadaptPF=$(grep -o -E """                                 # Get cutadapt Passing Filtes reads
        r""" 'Pairs written \(passing filters\):.+' {input.cutadapt} """ #
        r""" | sed -E 's/Pairs written \(passing filters\):\ +//' """    #
        r""" | sed 's/,//g') ; """                                       #
        #
        r""" sicklePF=$(grep -o -E """                                   # Get sickle Passing Filtes reads
        r""" 'FastQ paired records kept:.+' {input.sickle} """           #
        r""" | sed -E 's/FastQ paired records kept:\ +//') ; """         #
        #
        r""" totalDuplicate=$(grep -o -E """                             # Get total duplicated reads
        r""" 'DUPLICATE TOTAL:.+' {input.samtools} """                   #
        r""" | sed -E 's/DUPLICATE TOTAL:\ +//') ; """                   #
        #
        r""" estimatedLibrarySize=$(grep -o -E """                       # Get estimated library size
        r""" 'ESTIMATED_LIBRARY_SIZE:.+' {input.samtools} """            #
        r""" | sed -E 's/ESTIMATED_LIBRARY_SIZE:\ +//') ; """            #
        #
        r""" samtoolsPF=$(grep -o -E """                                 # Get samtool Passing Filter reads
        r""" 'WRITTEN: .+' {input.samtools} """                          #
        r""" | sed -E 's/WRITTEN:\ +//') ; """                           #
        #
        r""" mappedReads=$(grep -o -E -m 1 """                           # Get mapped reads
        r""" '"mapped": .+' {input.flagstat} """                         #
        r""" | sed -E 's/"mapped":\ +//' """                             #
        r""" | sed 's/,//g') ; """                                       #
        #
        r""" mappedPercentReads=$(grep -o -E -m 1 """                    # Get mapped precent reads
        r""" '"mapped %": .+' {input.flagstat} """                       #
        r""" | sed -E 's/"mapped %":\ +//' """                           #
        r""" | sed 's/,//g') ; """                                       #
        #
        r""" covPercentAt1X=$(grep -o -E """                             # Get coverage percent @1X
        r""" 'Percent covered:.+' {input.histogram} """                  #
        r""" | sed -E 's/Percent covered:\ +//') ; """                   #
        #
        r""" awk """                                                   # Awk, a program to select particular records in a file and perform operations upon them
        r""" -v rawReads="${{rawReads}}" """                             # Define external variable
        r""" -v cutadaptPF="${{cutadaptPF}}" """                         # Define external variable
        r""" -v sicklePF="${{sicklePF}}" """                             # Define external variable
        r""" -v totalDuplicate="${{totalDuplicate}}" """                 # Define external variable
        r""" -v estimatedLibrarySize="${{estimatedLibrarySize}}" """     # Define external variable
        r""" -v samtoolsPF="${{samtoolsPF}}" """                         # Define external variable
        r""" -v mappedReads="${{mappedReads}}" """                       # Define external variable
        r""" -v mappedPercentReads="${{mappedPercentReads}}" """         # Define external variable
        r""" -v covPercentAt1X="${{covPercentAt1X}}" """                 # Define external variable
        r""" '$4 >= {wildcards.min_depth} {{supMin_Cov+=$3-$2}} ; """      # Genome size (>= min_depth @X)
        r""" {{genomeSize+=$3-$2}} ; """                                 # Genome size (total)
        r""" {{totalBases+=($3-$2)*$4}} ; """                            # Total bases @1X
        r""" {{totalBasesSq+=(($3-$2)*$4)**2}} """                       # Total bases square @1X
        r""" END """                                                    # END
        r""" {{print """                                                # Print
        r""" "sample_id", "\t", """                                      # header: Sample ID
        r""" "raw_paired_reads", "\t", """                               # header: Raw paired reads
        r""" "cutadapt_pairs_PF", "\t", """                              # header: Cutadapt Passing Filters
        r""" "sickle_reads_PF", "\t", """                                # header: Sickle-trim Passing Filters
        r""" "duplicated_reads", "\t", """                               # header:
        r""" "duplicated_percent_%","\t", """                            # header:
        r""" "estimated_library_size*", "\t", """                        # header:
        r""" "samtools_pairs_PF", "\t", """                              # header:
        r""" "mapped_with", "\t",  """                                   # header: mapper
        r""" "mapped_on", "\t",  """                                     # header: reference
        r""" "mapped_reads", "\t", """                                   # header:
        r""" "mapped_percent_%", "\t", """                               # header:
        r""" "mean_depth", "\t", """                                     # header: mean depth
        r""" "standard_deviation", "\t", """                             # header: standard deviation
        r""" "cov_percent_%_@1X", "\t", """                              # header: coverage percentage @1X
        r""" "cov_percent_%" "\t", """                                   # header: coverage percentage
        r""" "@_min_depth" """                                             # header: @_[min_depth]_X
        r""" ORS """                                                      # \n newline
        r""" "{wildcards.sample}", "\t", """                             # value: Sample ID
        r""" rawReads, "\t", """                                         # value: Raw sequences
        r""" cutadaptPF, "\t", """                                       # value: Cutadapt Passing Filter
        r""" sicklePF, "\t", """                                         # value: Sickle Passing Filter
        r""" totalDuplicate, "\t", """                                   # value:
        r""" int(((totalDuplicate)/(rawReads*2))*100), "%", "\t", """    # value: (divided by 2 to estimated pairs)
        r""" estimatedLibrarySize, "\t", """                             # value:
        r""" samtoolsPF, "\t", """                                       # value:
        r""" "{wildcards.mapper}", "\t",  """                           # value: mapper
        r""" "{wildcards.reference}", "\t",  """                         # value: reference
        r""" mappedReads, "\t", """                                      # value:
        r""" mappedPercentReads, "%", "\t", """                          # value:
        r""" int(totalBases/genomeSize), "\t", """                       # value: mean depth
        r""" int(sqrt((totalBasesSq/genomeSize)-(totalBases/genomeSize)**2)), "\t", """ # Standard deviation value
        r""" covPercentAt1X, "\t", """                                   # value
        r""" supMin_Cov/genomeSize*100, "%", "\t", """                   # Coverage percent (@ min_depth X) value
        r""" "@{wildcards.min_depth}X" """                                 # @ min_depth X value
        r""" }}' """                                                     # Close print
        r""" {input.genome_cov} """                                      # BedGraph coverage input
        r""" 1> {output.cov_stats} """                                   # Mean depth output
        r""" 2> {log}"""                                                 # Log redirection

###############################################################################
rule bedtools_genome_coverage:
    # Aim: computing genome coverage sequencing
    # Use: bedtools genomecov [OPTIONS] -ibam [MARK-DUP.bam] 1> [BEDGRAPH.bed]
    message:
        """
        ~ BedTools ∞ Compute Genome Coverage ~
        Sample: _______ {wildcards.sample}
        Reference: ____ {wildcards.reference}
        Mapper: _______ {wildcards.mapper}
        """
    conda:
        BEDTOOLS
    input:
        mark_dup = get_bam_input,
        index = get_bai_input
    output:
        genome_cov = "results/02_Mapping/{sample}_{reference}_{mapper}_genome-cov.bed"
    log:
        "results/10_Reports/tools-log/bedtools/{sample}_{reference}_{mapper}_genome-cov.log"
    shell:
        "bedtools genomecov "    # Bedtools genomecov, compute the coverage of a feature file among a genome
        "-bga "                   # Report depth in BedGraph format, regions with zero coverage are also reported
        "-ibam {input.mark_dup} " # The input file is in BAM format, must be sorted by position
        "1> {output.genome_cov} " # BedGraph output
        "2> {log} "               # Log redirection

###############################################################################
rule samtools_coverage_histogram:
    # Aim: alignment depth and percent coverage histogram
    # Use: samtools coverage --histogram [INPUT.bam]
    message:
        """
        ~ SamTools ∞ Calcul Depth and Coverage from BAM file ~
        Sample: ________ {wildcards.sample}
        Reference: _____ {wildcards.reference}
        Mapper: ________ {wildcards.mapper}
        """
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
       #bins = BINS,
       #depth = DEPTH
    input:
        mark_dup = get_bam_input
    output:
        histogram = "results/03_Coverage/histogram/{sample}_{reference}_{mapper}_coverage-histogram.txt"
    log:
        "results/10_Reports/tools-log/samtools/{sample}_{reference}_{mapper}_coverage-histogram.log"
    shell:
        "samtools coverage "          # Samtools coverage, tools for alignments in the SAM format with command to alignment depth and percent coverage
        "--histogram "                 # -m: show histogram instead of tabular output
        "--verbosity 4 "               # Set level of verbosity [INT] (default: 3)
        "--n-bins 149 "                # -w: number of bins in histogram (default: terminal width - 40) (todo: {params.bins}) 
        "--depth 0 "                   # -d maximum allowed coverage depth [INT] (default: 1000000 ; 0 removing any depth limit) (todo: {params.depth}) 
        "--output {output.histogram} " # write output to FILE (default: stdout)
        "{input.mark_dup} ; "          # Mark_dup bam input
        "echo >> {output.histogram} ; " # Newline
        "samtools coverage "    # Samtools coverage, tools for alignments in the SAM format with command to alignment depth and percent coverage
        "--verbosity 4 "         # Set level of verbosity [INT] (default: 3)
        "{input.mark_dup} "      # Mark_dup bam input
        ">> {output.histogram} " # write output to FILE (default: stdout)
        "2> {log}"               # Log redirection

###############################################################################
rule samtools_flagstat_ext:
    # Aim: simple stats
    # Use: samtools flagstat -@ [THREADS] [INPUT.bam]
    message:
        """
        ~ SamTools ∞ Calcul simple Stats from BAM file ~
        Sample: ________ {wildcards.sample}
        Reference: _____ {wildcards.reference}
        Mapper: ________ {wildcards.mapper}
        """
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
    input:
        mark_dup = get_bam_input
    output:
        flagstat = "results/03_Coverage/flagstat/{sample}_{reference}_{mapper}_flagstat.{ext}"
    log:
        "results/10_Reports/tools-log/samtools/{sample}_{reference}_{mapper}_flagstat-{ext}.log"
    shell:
        "samtools flagstat "           # Samtools flagstat, tools for alignments in the SAM format with command to simple stat
        "--threads {resources.cpus} "   # -@: Number of additional threads to use (default: 1)
        "--verbosity 4 "                # Set level of verbosity [INT] (default: 3)
        "--output-fmt {wildcards.ext} " # -O Specify output format (none, tsv and json)
        "{input.mark_dup} "             # Mark_dup bam input
        "1> {output.flagstat} "         # Mark_dup index output
        "2> {log}"                      # Log redirection

###############################################################################
###############################################################################