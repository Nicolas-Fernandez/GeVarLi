###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __| ___| \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__|_)\_|____|____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ gevarli.smk
# Version ________________ v.2023.06
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Snakefile with GeVarLi rules
# Date ___________________ 2021.10.12
# Latest modifications ___ 2023.06.21
# Use ____________________ snakemake -s gevarli.smk --use-conda 

###############################################################################
### CONFIGURATION ###
#####################

configfile: "configuration/config.yaml"

###############################################################################
### FUNCTIONS ###
#################

def get_memory_per_thread(wildcards):
    memory_per_thread = int(RAM) // int(CPUS)
    return memory_per_thread

def get_pangolin_input(wildcards):
    pangolin_list = []
    if "yes" in PANGO_RUN:
        pangolin_list = expand("results/06_Lineages/{reference}/{sample}_{aligner}_{min_cov}X_pangolin-report.csv",
                               reference = REFERENCE, sample = SAMPLE, aligner = ALIGNER, min_cov = MIN_COV)
    return pangolin_list

def get_nextclade_input(wildcards):
    nextclade_list = []
    if "yes" in NEXT_RUN:
        nextclade_list = expand("results/06_Lineages/{reference}/{sample}_{aligner}_{min_cov}X_nextclade-report.tsv",
                                reference = REFERENCE, sample = SAMPLE, aligner = ALIGNER, min_cov = MIN_COV)
    return nextclade_list

###############################################################################
### WILDCARDS ###
#################

#SAMPLE, = glob_wildcards("/users/illumina/local/data/run_1/FATSQ/{sample}_R1.fastq.gz")

SAMPLE, = glob_wildcards("resources/reads/{sample}_R1.fastq.gz")

###############################################################################
### RESOURCES ###
#################

OS = config["os"]                        # Operating system
CPUS = config["resources"]["cpus"]       # Threads (maximum)
RAM = config["resources"]["ram"]         # Memory (RAM) in Gb (maximum)
MEM_GB = get_memory_per_thread           # Memory per thread in GB (maximum)
TMP_DIR = config["resources"]["tmp_dir"] # Temporary directory

###############################################################################
### ENVIRONMENTS ###
####################

CUTADAPT = config["conda"][OS]["cutadapt"]       # Cutadapt conda environment
SICKLE_TRIM = config["conda"][OS]["sickle_trim"] # Sickle-Trim conda environment
BWA = config["conda"][OS]["bwa"]                 # BWA conda environment
BOWTIE2 = config["conda"][OS]["bowtie2"]         # Bowtie2 conda environment
SAMTOOLS = config["conda"][OS]["samtools"]       # SamTools conda environment
BEDTOOLS = config["conda"][OS]["bedtools"]       # BedTools conda environment
GAWK = config["conda"][OS]["gawk"]               # Awk (GNU) conda environment
LOFREQ = config["conda"][OS]["lofreq"]           # LoFreq conda environment
BCFTOOLS = config["conda"][OS]["bcftools"]       # BcfTools conda environment
PANGOLIN = config["conda"][OS]["pangolin"]       # Pangolin conda environment
NEXTCLADE = config["conda"][OS]["nextclade"]     # Nextclade conda environment

###############################################################################
### PARAMETERS ###
##################

C_LENGTH = config["cutadapt"]["length"]         # Cutadapt --minimum-length
TRUSEQ = config["cutadapt"]["kits"]["truseq"]   # Cutadapt --adapter Illumina TruSeq
NEXTERA = config["cutadapt"]["kits"]["nextera"] # Cutadapt --adapter Illumina Nextera
SMALL = config["cutadapt"]["kits"]["small"]     # Cutadapt --adapter Illumina Small
CLIPPING = config["cutadapt"]["clipping"]       # Cutadapt --cut

COMMAND = config["sickle_trim"]["command"]      # Sickle-trim command
ENCODING = config["sickle_trim"]["encoding"]    # Sickle-trim --qual-type 
QUALITY = config["sickle_trim"]["quality"]      # Sickle-trim --qual-threshold
S_LENGTH = config["sickle_trim"]["length"]      # Sickle-trim --length-treshold

BWA_PATH = config["bwa"]["path"]                # BWA path to indexes
BWA_ALGO = config["bwa"]["algorithm"]           # BWA indexing algorithm

BT2_PATH = config["bowtie2"]["path"]            # Bowtie2 path to indexes
SENSITIVITY = config["bowtie2"]["sensitivity"]  # Bowtie2 sensitivity preset
BT2_ALGO = config["bowtie2"]["algorithm"]       # BT2 indexing algorithm

ALIGNER = config["consensus"]["aligner"]        # Aligners ('bwa' or 'bowtie2')
REF_PATH = config["consensus"]["path"]          # Path to genomes references
REFERENCE = config["consensus"]["reference"]    # Genome reference sequence, in fasta format
MIN_COV = config["consensus"]["min_cov"]        # Minimum coverage, mask lower regions with 'N' 
MIN_AF = config["consensus"]["min_af"]          # Minimum allele frequency allowed
IUPAC = config["consensus"]["iupac"]            # Output variants in the form of IUPAC ambiguity codes

NEXT_RUN = config["nextclade"]["run"]           # Nextclade run option
NEXT_PATH = config["nextclade"]["path"]         # Path to nextclade dataset
NEXT_DATASET = config["nextclade"]["dataset"]   # Nextclade dataset

PANGO_RUN = config["pangolin"]["run"]           # Pangolin run option

###############################################################################
### RULES ###
#############

rule all:
    input:
        flagstat = expand("results/03_Coverage/{reference}/flagstat/{sample}_{aligner}_flagstat.{ext}",
                          reference = REFERENCE, sample = SAMPLE, aligner = ALIGNER, ext = ["txt", "tsv", "json"]),
        covstats = expand("results/03_Coverage/{reference}/{sample}_{aligner}_{min_cov}X_coverage-stats.tsv",
                          reference = REFERENCE, sample = SAMPLE, aligner = ALIGNER, min_cov = MIN_COV),
        consensus = expand("results/05_Consensus/{reference}/{sample}_{aligner}_{min_cov}X_consensus.fasta",
                           reference = REFERENCE, sample = SAMPLE, aligner = ALIGNER, min_cov = MIN_COV),
        pangolin = get_pangolin_input,
        nextclade = get_nextclade_input
        #gisaid = get_gisaid_input # soon

###############################################################################
rule nextclade_lineage:
    # Aim: nextclade lineage assignation
    # Use: nextclade [QUERY.fasta] -t [THREADS] --outfile [NAME.csv]
    message:
        "Nextclade lineage assignation for [[ {wildcards.sample} ]] sample consensus (for {wildcards.reference} with {wildcards.aligner}, @{wildcards.min_cov}X)"
    conda:
        NEXTCLADE
    resources:
        cpus = CPUS
    params:
        path = NEXT_PATH,
        dataset = NEXT_DATASET
    input:
        consensus = "results/05_Consensus/{reference}/{sample}_{aligner}_{min_cov}X_consensus.fasta"
    output:
        lineage = "results/06_Lineages/{reference}/{sample}_{aligner}_{min_cov}X_nextclade-report.tsv",
        alignment = directory("results/06_Lineages/{reference}/{sample}_{aligner}_{min_cov}X_nextclade-all/")
    log:
        "results/10_Reports/tools-log/nextclade/{reference}/{sample}_{aligner}_{min_cov}X_lineage.log"
    shell:
        "nextclade "                                    # Nextclade, assign queries sequences to clades and reports potential quality issues
        "run "                                           # Run analyzis
        "--jobs {resources.cpus} "                       # -j: Number of CPU threads used by the algorithm (default: all available threads)
        "--input-dataset {params.path}{params.dataset} " # -raq: Path to a directory containing a dataset (root-seq, tree and qc-config required)
        "--output-tsv {output.lineage} "                 # -t: Path to output TSV results file
        "--output-all {output.alignment} "               # -O: Produce all of the output files into this directory, using default basename
        "{input.consensus} "                             # Path to a .fasta file with input sequences
        "&> {log}"                                       # Log redirection

###############################################################################
rule pangolin_lineage:
    # Aim: lineage mapping
    # Use: pangolin [QUERY.fasta] -t [THREADS] --outfile [NAME.csv]
    message:
        "Pangolin lineage mapping for [[ {wildcards.sample} ]] sample consensus (for {wildcards.reference} with {wildcards.aligner}, @{wildcards.min_cov}X)"
    conda:
        PANGOLIN
    resources:
        cpus = CPUS,
        tmp_dir = TMP_DIR
    input:
        consensus = "results/05_Consensus/{reference}/{sample}_{aligner}_{min_cov}X_consensus.fasta"
    output:
        lineage = "results/06_Lineages/{reference}/{sample}_{aligner}_{min_cov}X_pangolin-report.csv"
    log:
        "results/10_Reports/tools-log/pangolin/{reference}/{sample}_{aligner}_{min_cov}X_lineage.log"
    shell:
        "pangolin "                     # Pangolinn, Phylogenetic Assignment of Named Global Outbreak LINeages
        "{input.consensus} "             # Query fasta file of sequences to analyse
        "--threads {resources.cpus} "    # -t: Number of threads
        "--tempdir {resources.tmp_dir} " # Specify where you want the temp stuff to go (default: $TMPDIR)
        "--outfile {output.lineage} "    # Optional output file name (default: lineage_report.csv)
        "&> {log}"                       # Log redirection

###############################################################################
rule sed_rename_headers:
    # Aim: rename all fasta header with sample name
    # Use: sed 's/[OLD]/[NEW]/' [IN] > [OUT]
    message:
        "Sed rename fasta header for [[ {wildcards.sample} ]] sample consensus (for {wildcards.reference} with {wildcards.aligner}, @{wildcards.min_cov}X)"
    conda:
        GAWK
    input:
        cons_tmp = "results/05_Consensus/{reference}/{sample}_{aligner}_{min_cov}X_consensus.fasta.tmp"
    output:
        consensus = "results/05_Consensus/{reference}/{sample}_{aligner}_{min_cov}X_consensus.fasta"
    log:
        "results/10_Reports/tools-log/sed/{reference}/{sample}_{aligner}_{min_cov}X_fasta-header.log"
    shell:
        "sed " # Sed, a Stream EDitor used to perform basic text transformations on an input stream
        "'s/^>.*$/>{wildcards.sample}_{wildcards.aligner}_{wildcards.min_cov}X/' "
        "{input.cons_tmp} "      # Input file
        "1> {output.consensus} " # Output file
        "2> {log}"               # Log redirection
        
###############################################################################
rule bcftools_consensus:
    # Aim: create consensus
    # Use: bcftools consensus -f [REFERENCE] [VARIANTS.vcf.gz] -o [CONSENSUS.fasta] 
    message:
        "BcfTools consensus for [[ {wildcards.sample} ]] sample (for {wildcards.reference} with {wildcards.aligner}, @{wildcards.min_cov}X)"
    conda:
        BCFTOOLS
    params:
        iupac = IUPAC
    input:
        masked_ref = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_masked-ref.fasta",
        archive = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_variant-filt.vcf.bgz",
        index = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_variant-filt.bgz.tbi"
    output:
        cons_tmp = temp("results/05_Consensus/{reference}/{sample}_{aligner}_{min_cov}X_consensus.fasta.tmp")
    log:
        "results/10_Reports/tools-log/bcftools/{reference}/{sample}_{aligner}_{min_cov}X_consensus.log"
    shell:
        "bcftools "                      # Bcftools, tools for variant calling and manipulating VCFs and BCFs
        "consensus "                      # Create consensus sequence by applying VCF variants to a reference fasta file
        "--fasta-ref {input.masked_ref} " # -f: reference sequence in fasta format
        "{params.iupac} "                 # -I, --iupac-codes: output variants in the form of IUPAC ambiguity codes
        "{input.archive} "                # SNVs and Indels filtered VCF archive file
        "--output {output.cons_tmp} "     # -o: write output to a file (default: standard output)
        "2> {log}"                        # Log redirection

###############################################################################
rule tabix_tabarch_indexing:
    # Aim: tab archive indexing
    # Use: tabix [OPTIONS] [TAB.bgz]
    message:
        "Tabix tab archive indexing for [[ {wildcards.sample} ]] sample (for {wildcards.reference} with {wildcards.aligner}, @{wildcards.min_cov}X)"
    conda:
        LOFREQ
    input:
        archive = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_variant-filt.vcf.bgz"
    output:
        index = temp("results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_variant-filt.bgz.tbi")
    log:
        "results/10_Reports/tools-log/tabix/{reference}/{sample}_{aligner}_{min_cov}X_variant-archive-index.log"
    shell:
        "tabix "            # Tabix, indexes a TAB-delimited genome position file in.tab.bgz and creates an index file
        "{input.archive} "   # The input data file must be position sorted and compressed by bgzip
        "1> {output.index} " # Tabix output TBI index formats
        "2> {log}"           # Log redirection 

###############################################################################
rule bgzip_variant_archive:
    # Aim: Variant block compressing
    # Use: bgzip [OPTIONS] -c -@ [THREADS] [INDEL.vcf] 1> [COMPRESS.vcf.bgz]
    message:
        "Bgzip variant block compressing for [[ {wildcards.sample} ]] sample (for {wildcards.reference} with {wildcards.aligner}, @{wildcards.min_cov}X)"
    conda:
        LOFREQ
    resources:
        cpus = CPUS
    input:
        variant_filt = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_variant-filt.vcf"
    output:
        archive = temp("results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_variant-filt.vcf.bgz")
    log:
        "results/10_Reports/tools-log/bgzip/{reference}/{sample}_{aligner}_{min_cov}X_variant-archive.log"
    shell:
        "bgzip "                     # Bgzip, block compression/decompression utility
        "--stdout "                   # -c: Write to standard output, keep original files unchanged
        "--threads {resources.cpus} " # -@: Number of threads to use (default: 1)
        "{input.variant_filt} "       # VCF input file, gzip suuported, no streaming supported
        "1> {output.archive} "        # VCF output file, gzip supported (default: standard output)
        "2> {log}"                    # Log redirection 

###############################################################################
rule lofreq_variant_filtering:
    # Aim: SNVs and Indels filtering in VCF file
    # Use: lofreq filter [OPTIONS] -i [INDEL.vcf] -o [INDEL-FILT.vcf]
    # Note: without --no-defaults LoFreq's predefined filters are on
    message:
        "LoFreq filtering SNVs and Indels for [[ {wildcards.sample} ]] sample (for {wildcards.reference} with {wildcards.aligner}, @{wildcards.min_cov}X)"
    conda:
        LOFREQ
    params:
        min_af = MIN_AF
    input:
        variant_call = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_variant-call.vcf"
    output:
        variant_filt = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_variant-filt.vcf"
    log:
        "results/10_Reports/tools-log/lofreq/{reference}/{sample}_{aligner}_{min_cov}X_variant-filt.log"
    shell:
        "lofreq "                       # LoFreq, fast and sensitive inference of SNVs and indels
        "filter "                        # Filter SNVs and Indels parsed from vcf file
        "--cov-min {wildcards.min_cov} " # -v: Minimum coverage allowed (INT)
        "--af-min {params.min_af} "      # -a: Minimum allele freq allowed (FLOAT)
        "--in {input.variant_call} "     # VCF input file, gzip suuported, no streaming supported
        "--out {output.variant_filt} "   # VCF output file, gzip supported (default: standard output)
        "&> {log}"                       # Log redirection 

###############################################################################
rule lofreq_variant_calling:
    # Aim: SNVs and Indels calling
    # Use: lofreq call-parallel --pp-threads [THREADS] --call-indels -f [MASKED-REF.fasta] -o [INDEL.vcf] [INDEL.bam]
    message:
        "LoFreq calling SNVs and Indels for [[ {wildcards.sample} ]] sample (for {wildcards.reference} with {wildcards.aligner}, @{wildcards.min_cov}X)"
    conda:
        LOFREQ
    resources:
        cpus = CPUS
    input:
        masked_ref = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_masked-ref.fasta",
        indel_qual = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_indel-qual.bam",
        index = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_indel-qual.bai"
    output:
        variant_call = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_variant-call.vcf"
    log:
        "results/10_Reports/tools-log/lofreq/{reference}/{sample}_{aligner}_{min_cov}X_variant-call.log"
    shell:
        "lofreq "                       # LoFreq, fast and sensitive inference of SNVs and indels
        #"call-parallel "                 # Call variants with parallel wrapper, requires --pp-threads
        #"--pp-threads {resources.cpus} " # Number of threads (required) [INT] (default, dactivate because issue).
        "call "                          # Call variants (no parallel)
        "--call-indels "                 # Enable indel calls (note: preprocess your file to include indel alignment qualities!)
        "--ref {input.masked_ref} "      # -f: Indexed reference fasta file (gzip supported)
        "--out {output.variant_call} "   # -o: SNVs and Indels VCF file output (default: standard output)
        "{input.indel_qual} "            # Indel BAM input
        "&> {log}"                       # Log redirection 

###############################################################################
rule samtools_indel_indexing:
    # Aim: indexing indel qualities BAM file
    # Use: samtools index -@ [THREADS] -b [INDEL-QUAL.bam] [INDEX.bai]
    message:
        "SamTools indexing indel qualities BAM file [[ {wildcards.sample} ]] sample (for {wildcards.reference} with {wildcards.aligner}, @{wildcards.min_cov}X)"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
    input:
        indel_qual = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_indel-qual.bam"
    output:
        index = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_indel-qual.bai"
    log:
        "results/10_Reports/tools-log/samtools/{reference}/{sample}_{aligner}_{min_cov}X_indel-qual-index.log"
    shell:
        "samtools index "     # Samtools index, tools for alignments in the SAM format with command to index alignment
        "-@ {resources.cpus} " # Number of additional threads to use (default: 0)
        "-b "                  # -b: Generate BAI-format index for BAM files (default)
        "{input.indel_qual} "  # Sorted bam input
        "{output.index} "      # Markdup bam output
        "&> {log}"             # Log redirection 

###############################################################################
rule lofreq_indel_qualities:
    # Aim: Indels qualities 
    # Use: lofreq indelqual --dindel -f [MASKEDREF.fasta] -o [INDEL.bam] [MARKDUP.bam]
    # Note: do not realign your BAM file afterwards!
    message:
        "LoFreq insert indels qualities for [[ {wildcards.sample} ]] sample (for {wildcards.reference} with {wildcards.aligner}, @{wildcards.min_cov}X)"
    conda:
        LOFREQ
    input:
        masked_ref = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_masked-ref.fasta",
        mark_dup = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.bam",
        index = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.bam.bai"
    output:
        indel_qual = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_indel-qual.bam"
    log:
        "results/10_Reports/tools-log/lofreq/{reference}/{sample}_{aligner}_{min_cov}X_indel-qual.log"
    shell:
        "lofreq "                   # LoFreq, fast and sensitive inference of SNVs and Indels 
        "indelqual "                 # Insert indel qualities into BAM file (required for indel predictions)
        "--dindel "                  # Add Dindel's indel qualities Illumina specifics (need --ref and clashes with -u)
        "--ref {input.masked_ref} "  # -f: Reference (masked) sequence used for mapping (only required for --dindel)
        "--out {output.indel_qual} " # -o: Indel BAM file output (default: standard output)
        "{input.mark_dup} "          # Markdup BAM input
        "&> {log}"                   # Log redirection 

###############################################################################
rule bedtools_masking:
    # Aim: masking low coverage regions
    # Use: bedtools maskfasta [OPTIONS] -fi [REFERENCE.fasta] -bed [RANGE.bed] -fo [MASKEDREF.fasta]
    message:
        "BedTools masking low coverage regions for [[ {wildcards.sample} ]] sample (for {wildcards.reference} with {wildcards.aligner}, @{wildcards.min_cov}X)"
    conda:
        BEDTOOLS
    params:
        path = REF_PATH
    input:
        low_cov_mask = "results/03_Coverage/{reference}/bed/{sample}_{aligner}_{min_cov}X_low-cov-mask.bed"
    output:
        masked_ref = "results/04_Variants/{reference}/{sample}_{aligner}_{min_cov}X_masked-ref.fasta"
    log:
        "results/10_Reports/tools-log/bedtools/{reference}/{sample}_{aligner}_{min_cov}X_masking.log"
    shell:
        "bedtools maskfasta "                       # Bedtools maskfasta, mask a fasta file based on feature coordinates
        "-fi {params.path}{wildcards.reference}.fasta " # Input FASTA file 
        "-bed {input.low_cov_mask} "                 # BED/GFF/VCF file of ranges to mask in -fi
        "-fo {output.masked_ref} "                   # Output masked FASTA file
        "&> {log}"                                   # Log redirection 

###############################################################################
rule bedtools_merged_mask:
    # Aim: merging overlaps
    # Use: bedtools merge [OPTIONS] -i [FILTERED.bed] -g [GENOME.fasta] 
    message:
        "BedTools merging overlaps for [[ {wildcards.sample} ]] sample (for {wildcards.reference} with {wildcards.aligner}, @{wildcards.min_cov}X)"
    conda:
        BEDTOOLS
    input:
        min_cov_filt = "results/03_Coverage/{reference}/bed/{sample}_{aligner}_{min_cov}X_min-cov-filt.bed"
    output:
        low_cov_mask = temp("results/03_Coverage/{reference}/bed/{sample}_{aligner}_{min_cov}X_low-cov-mask.bed")
    log:
        "results/10_Reports/tools-log/bedtools/{reference}/{sample}_{aligner}_{min_cov}X_merging.log"
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
        "Awk minimum coverage filtration for [[ {wildcards.sample} ]] sample (for {wildcards.reference} with {wildcards.aligner}, @{wildcards.min_cov}X)"
    conda:
        GAWK
    input:
        genome_cov = "results/03_Coverage/{reference}/bed/{sample}_{aligner}_genome-cov.bed"
    output:
        min_cov_filt = temp("results/03_Coverage/{reference}/bed/{sample}_{aligner}_{min_cov}X_min-cov-filt.bed")
    log:
        "results/10_Reports/tools-log/awk/{reference}/{sample}_{aligner}_{min_cov}X_min-cov-filt.log"
    shell:
        "awk "                      # Awk, a program that you can use to select particular records in a file and perform operations upon them
        "'$4 < {wildcards.min_cov}' " # Minimum coverage for masking regions in consensus sequence
        "{input.genome_cov} "         # BedGraph coverage input
        "1> {output.min_cov_filt} "   # Minimum coverage filtered bed output
        "2> {log} "                   # Log redirection

###############################################################################
rule awk_coverage_statistics:
    # Aim: computing genomme coverage stats
    # Use: awk {FORMULA} END {{print [RESULTS.tsv] [BEDGRAPH.bed]
    message:
        "Awk compute genome coverage statistics BED [[ {wildcards.sample} ]] sample (for {wildcards.reference} with {wildcards.aligner})"
    conda:
        GAWK
    input:
        cutadapt = "results/10_Reports/tools-log/cutadapt/{sample}.log",
        sickle = "results/10_Reports/tools-log/sickle-trim/{sample}.log",
        samtools = "results/10_Reports/tools-log/samtools/{reference}/{sample}_{aligner}_mark-dup.log",
        flagstat = "results/03_Coverage/{reference}/flagstat/{sample}_{aligner}_flagstat.json",
        histogram = "results/03_Coverage/{reference}/histogram/{sample}_{aligner}_coverage-histogram.txt",
        genome_cov = "results/03_Coverage/{reference}/bed/{sample}_{aligner}_genome-cov.bed"
    output:
        cov_stats = "results/03_Coverage/{reference}/{sample}_{aligner}_{min_cov}X_coverage-stats.tsv"
    log:
        "results/10_Reports/tools-log/awk/{reference}/{sample}_{aligner}_{min_cov}X_coverage-stats.log"
    shell:
        """ rawReads=$(grep -o -E  """                                  # Get raw reads 
        """ 'Total read pairs processed:.+' {input.cutadapt}  """       #
        """ | sed -E 's/Total read pairs processed:\ +//'  """          #
        """ | sed 's/,//g') ; """                                       #
        #
        """ cutadaptPF=$(grep -o -E """                                 # Get cutadapt Passing Filtes reads
        """ 'Pairs written \(passing filters\):.+' {input.cutadapt} """ #
        """ | sed -E 's/Pairs written \(passing filters\):\ +//' """    #
        """ | sed 's/,//g') ; """                                       #
        #
        """ sicklePF=$(grep -o -E """                                   # Get sickle Passing Filtes reads
        """ 'FastQ paired records kept:.+' {input.sickle} """           #
        """ | sed -E 's/FastQ paired records kept:\ +//') ; """         #
        #
        """ totalDuplicate=$(grep -o -E """                             # Get total duplicated reads
        """ 'DUPLICATE TOTAL:.+' {input.samtools} """                   #
        """ | sed -E 's/DUPLICATE TOTAL:\ +//') ; """                   #
        #
        """ estimatedLibrarySize=$(grep -o -E """                       # Get estimated library size
        """ 'ESTIMATED_LIBRARY_SIZE:.+' {input.samtools} """            #
        """ | sed -E 's/ESTIMATED_LIBRARY_SIZE:\ +//') ; """            #
        #
        """ samtoolsPF=$(grep -o -E """                                 # Get samtool Passing Filter reads
        """ 'WRITTEN: .+' {input.samtools} """                          #
        """ | sed -E 's/WRITTEN:\ +//') ; """                           #
        #
        """ mappedReads=$(grep -o -E -m 1 """                           # Get mapped reads
        """ '"mapped": .+' {input.flagstat} """                         #
        """ | sed -E 's/"mapped":\ +//' """                             #
        """ | sed 's/,//g') ; """                                       #
        #
        """ mappedPercentReads=$(grep -o -E -m 1 """                    # Get mapped precent reads
        """ '"mapped %": .+' {input.flagstat} """                       #
        """ | sed -E 's/"mapped %":\ +//' """                           #
        """ | sed 's/,//g') ; """                                       #
        #
        """ covPercentAt1X=$(grep -o -E """                             # Get coverage percent @1X
        """ 'Percent covered:.+' {input.histogram} """                  #
        """ | sed -E 's/Percent covered:\ +//') ; """                   #
        #
        """ awk """                                                   # Awk, a program to select particular records in a file and perform operations upon them
        """ -v rawReads="${{rawReads}}" """                             # Define external variable
        """ -v cutadaptPF="${{cutadaptPF}}" """                         # Define external variable
        """ -v sicklePF="${{sicklePF}}" """                             # Define external variable
        """ -v totalDuplicate="${{totalDuplicate}}" """                 # Define external variable
        """ -v estimatedLibrarySize="${{estimatedLibrarySize}}" """     # Define external variable
        """ -v samtoolsPF="${{samtoolsPF}}" """                         # Define external variable
        """ -v mappedReads="${{mappedReads}}" """                       # Define external variable
        """ -v mappedPercentReads="${{mappedPercentReads}}" """         # Define external variable
        """ -v covPercentAt1X="${{covPercentAt1X}}" """                 # Define external variable
        """ '$4 >= {wildcards.min_cov} {{supMin_Cov+=$3-$2}} ; """      # Genome size (>= min_cov @X)
        """ {{genomeSize+=$3-$2}} ; """                                 # Genome size (total)
        """ {{totalBases+=($3-$2)*$4}} ; """                            # Total bases @1X
        """ {{totalBasesSq+=(($3-$2)*$4)**2}} """                       # Total bases square @1X
        """ END """                                                    # END
        """ {{print """                                                # Print
        """ "sample_id", "\t", """                                      # header: Sample ID
        """ "raw_paired_reads", "\t", """                               # header: Raw paired reads
        """ "cutadapt_pairs_PF", "\t", """                              # header: Cutadapt Passing Filters
        """ "sickle_reads_PF", "\t", """                                # header: Sickle-trim Passing Filters
        """ "duplicated_reads", "\t", """                               # header:
        """ "duplicated_percent_%","\t", """                            # header:
        """ "estimated_library_size*", "\t", """                        # header:
        """ "samtools_pairs_PF", "\t", """                              # header:
        """ "mapped_with", "\t",  """                                   # header: aligner
        """ "mapped_on", "\t",  """                                     # header: reference
        """ "mapped_reads", "\t", """                                   # header:
        """ "mapped_percent_%", "\t", """                               # header:
        """ "mean_depth", "\t", """                                     # header: mean depth
        """ "standard_deviation", "\t", """                             # header: standard deviation
        """ "cov_percent_%_@1X", "\t", """                              # header: coverage percentage @1X
        """ "cov_percent_%" "\t", """                                   # header: coverage percentage
        """ "@_min_cov" """                                             # header: @_[min_cov]_X
        """ ORS """                                                      # \n newline
        """ "{wildcards.sample}", "\t", """                             # value: Sample ID
        """ rawReads, "\t", """                                         # value: Raw sequences
        """ cutadaptPF, "\t", """                                       # value: Cutadapt Passing Filter
        """ sicklePF, "\t", """                                         # value: Sickle Passing Filter
        """ totalDuplicate, "\t", """                                   # value:
        """ int(((totalDuplicate)/(rawReads*2))*100), "%", "\t", """    # value: (divided by 2 to estimated pairs)
        """ estimatedLibrarySize, "\t", """                             # value:
        """ samtoolsPF, "\t", """                                       # value:
        """ "{wildcards.aligner}", "\t",  """                           # value: aligner
        """ "{wildcards.reference}", "\t",  """                         # value: reference
        """ mappedReads, "\t", """                                      # value:
        """ mappedPercentReads, "%", "\t", """                          # value:
        """ int(totalBases/genomeSize), "\t", """                       # value: mean depth
        """ int(sqrt((totalBasesSq/genomeSize)-(totalBases/genomeSize)**2)), "\t", """ # Standard deviation value
        """ covPercentAt1X, "\t", """                                   # value
        """ supMin_Cov/genomeSize*100, "%", "\t", """                   # Coverage percent (@ min_cov X) value
        """ "@{wildcards.min_cov}X" """                                 # @ min_cov X value
        """ }}' """                                                     # Close print
        """ {input.genome_cov} """                                      # BedGraph coverage input
        """ 1> {output.cov_stats} """                                   # Mean depth output
        """ 2> {log}"""                                                 # Log redirection
        
###############################################################################
rule bedtools_genome_coverage:
    # Aim: computing genome coverage sequencing
    # Use: bedtools genomecov [OPTIONS] -ibam [MARK-DUP.bam] 1> [BEDGRAPH.bed]
    message:
        "BedTools computing genome coverage for [[ {wildcards.sample} ]] sample against reference genome sequence (for {wildcards.reference} with {wildcards.aligner})"
    conda:
        BEDTOOLS
    input:
        mark_dup = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.bam",
        index = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.bam.bai"
    output:
        genome_cov = "results/03_Coverage/{reference}/bed/{sample}_{aligner}_genome-cov.bed"
    log:
        "results/10_Reports/tools-log/bedtools/{reference}/{sample}_{aligner}_genome-cov.log"
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
        "SamTools calcul alignment depth and percent coverage @1X from BAM file for [[ {wildcards.sample} ]] sample (for {wildcards.reference} with {wildcards.aligner})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
       #bins = BINS,
       #depth = DEPTH
    input:
        mark_dup = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.bam"
    output:
        histogram = "results/03_Coverage/{reference}/histogram/{sample}_{aligner}_coverage-histogram.txt"
    log:
        "results/10_Reports/tools-log/samtools/{reference}/{sample}_{aligner}_coverage-histogram.log"
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
        "SamTools calcul simple stats from BAM file for [[ {wildcards.sample} ]] sample (for {wildcards.reference} with {wildcards.aligner})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
    input:
        mark_dup = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.bam"
    output:
        flagstat = "results/03_Coverage/{reference}/flagstat/{sample}_{aligner}_flagstat.{ext}"
    log:
        "results/10_Reports/tools-log/samtools/{reference}/{sample}_{aligner}_flagstat-{ext}.log"
    shell:
        "samtools flagstat "           # Samtools flagstat, tools for alignments in the SAM format with command to simple stat
        "--threads {resources.cpus} "   # -@: Number of additional threads to use (default: 1)
        "--verbosity 4 "                # Set level of verbosity [INT] (default: 3)
        "--output-fmt {wildcards.ext} " # -O Specify output format (none, tsv and json)
        "{input.mark_dup} "             # Mark_dup bam input
        "1> {output.flagstat} "        # Mark_dup index output
        "2> {log}"                      # Log redirection

###############################################################################
rule samtools_index_markdup:
    # Aim: indexing marked as duplicate BAM file
    # Use: samtools index -@ [THREADS] -b [MARK-DUP.bam] [INDEX.bai]
    message:
        "SamTools indexing marked as duplicate BAM file for [[ {wildcards.sample} ]] sample (for {wildcards.reference} with {wildcards.aligner})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
    input:
        mark_dup = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.bam"
    output:
        index = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.bam.bai"
    log:
        "results/10_Reports/tools-log/samtools/{reference}/{sample}_{aligner}_mark-dup-index.log"
    shell:
        "samtools index "     # Samtools index, tools for alignments in the SAM format with command to index alignment
        "-@ {resources.cpus} " #--threads: Number of additional threads to use (default: 1)(NB, --threads form dose'nt work)
        "-b "                  # -b: Generate BAI-format index for BAM files (default)
        "{input.mark_dup} "    # Mark_dup bam input
        "{output.index} "      # Mark_dup index output
        "&> {log}"             # Log redirection

###############################################################################
rule samtools_markdup:
    # Aim: marking duplicate alignments
    # Use: samtools markdup -@ [THREADS] -r -s -O BAM [SORTED.bam] [MARK-DUP.bam] 
    message:
        "SamTools marking duplicate alignments for [[ {wildcards.sample} ]] sample (for {wildcards.reference} with {wildcards.aligner})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
    input:
        sorted = "results/02_Mapping/{reference}/{sample}_{aligner}_sorted.bam"
    output:
        mark_dup = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.bam"
    log:
        "results/10_Reports/tools-log/samtools/{reference}/{sample}_{aligner}_mark-dup.log"
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
        "SamTools sorting [[ {wildcards.sample} ]] sample reads (for {wildcards.reference} with {wildcards.aligner})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS,
       mem_gb = MEM_GB,
       tmp_dir = TMP_DIR
    input:
        fix_mate = "results/02_Mapping/{reference}/{sample}_{aligner}_fix-mate.bam"
    output:
        sorted = temp("results/02_Mapping/{reference}/{sample}_{aligner}_sorted.bam")
    log:
        "results/10_Reports/tools-log/samtools/{reference}/{sample}_{aligner}_sorted.log"
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
        "SamTools filling in mate coordinates [[ {wildcards.sample} ]] sample reads (for {wildcards.reference} with {wildcards.aligner})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
    input:
        sort_by_names = "results/02_Mapping/{reference}/{sample}_{aligner}_sort-by-names.bam"
    output:
        fix_mate = temp("results/02_Mapping/{reference}/{sample}_{aligner}_fix-mate.bam")
    log:
        "results/10_Reports/tools-log/samtools/{reference}/{sample}_{aligner}_fix-mate.log"
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
        "SamTools sorting by names [[ {wildcards.sample} ]] sample reads (for {wildcards.reference} with {wildcards.aligner})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS,
       mem_gb = MEM_GB
    input:
        mapped = "results/02_Mapping/{reference}/{sample}_{aligner}-mapped.sam"
    output:
        sort_by_names = temp("results/02_Mapping/{reference}/{sample}_{aligner}_sort-by-names.bam")
    log:
        "results/10_Reports/tools-log/samtools/{reference}/{sample}_{aligner}_sort-by-names.log"
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
rule bwa_mapping:
    # Aim: reads mapping against reference sequence
    # Use: bwa mem -t [THREADS] -x [REFERENCE] [FWD_R1.fq] [REV_R2.fq] 1> [MAPPED.sam]
    message:
        "BWA-MEM mapping [[ {wildcards.sample} ]] sample reads against reference genome sequence (for {wildcards.reference})"
    conda:
        BWA
    resources:
        cpus = CPUS
    params:
        bwa_path = BWA_PATH
    input:
        fwd_reads = "results/01_Trimming/sickle/{sample}_sickle-trimmed_R1.fastq.gz",
        rev_reads = "results/01_Trimming/sickle/{sample}_sickle-trimmed_R2.fastq.gz"
    output:
        mapped = temp("results/02_Mapping/{reference}/{sample}_bwa-mapped.sam")
    log:
        "results/10_Reports/tools-log/bwa/{sample}_{reference}.log"
    shell:
        "bwa mem "                            # BWA-MEM algorithm, performs local alignment
        "-t {resources.cpus} "                 # -t: Number of threads (default: 12)
        "-v 1 "                                # -v: Verbosity level: 1=error, 2=warning, 3=message, 4+=debugging
        "{params.bwa_path}{wildcards.reference} " # Reference index filename prefix
        "{input.fwd_reads} "                   # Forward input reads
        "{input.rev_reads} "                   # Reverse input reads
        "1> {output.mapped} "                  # SAM output
        "2> {log}"                             # Log redirection 

###############################################################################
rule bowtie2_mapping:
    # Aim: reads mapping against reference sequence
    # Use: bowtie2 -p [THREADS] -x [REFERENCE] -1 [FWD_R1.fq] -2 [REV_R2.fq] -S [MAPPED.sam]
    message:
        "Bowtie2 mapping [[ {wildcards.sample} ]] sample reads against reference genome sequence (for {wildcards.reference})"
    conda:
        BOWTIE2
    resources:
        cpus = CPUS
    params:
        bt2_path = BT2_PATH,
        sensitivity = SENSITIVITY
    input:
        fwd_reads = "results/01_Trimming/sickle/{sample}_sickle-trimmed_R1.fastq.gz",
        rev_reads = "results/01_Trimming/sickle/{sample}_sickle-trimmed_R2.fastq.gz"
    output:
        mapped = temp("results/02_Mapping/{reference}/{sample}_bowtie2-mapped.sam")
    log:
        "results/10_Reports/tools-log/bowtie2/{sample}_{reference}.log"
    shell:
        "bowtie2 "                   # Bowtie2, an ultrafast and memory-efficient tool for aligning sequencing reads to long reference sequences
        "--threads {resources.cpus} " # -p: Number of alignment threads to launch (default: 1)
        "--reorder "                  # Keep the original read order (if multi-processor option -p is used)
        "-x {params.bt2_path}{wildcards.reference} " # -x: Reference index filename prefix (minus trailing .X.bt2) [Bowtie-1 indexes are not compatible]
        "{params.sensitivity} "       # Preset (default: "--sensitive", same as [-D 15 -R 2 -N 0 -L 22 -i S,1,1.15]) 
        "-q "                         # -q: Query input files are FASTQ .fq/.fastq (default)
        "-1 {input.fwd_reads} "       # Forward input reads
        "-2 {input.rev_reads} "       # Reverse input reads
        "1> {output.mapped} "         # -S: File for SAM output (default: stdout) 
        "2> {log}"                    # Log redirection 

###############################################################################
rule sickle_trim_quality:
    # Aim: windowed adaptive trimming tool for FASTQ files using quality
    # Use: sickle [COMMAND] [OPTIONS]
    message:
        "Sickle-trim low quality sequences trimming for [[ {wildcards.sample} ]] sample"
    conda:
        SICKLE_TRIM
    params:
        command = COMMAND,
        encoding = ENCODING,
        quality = QUALITY,
        length = S_LENGTH
    input:
        fwd_reads = "results/01_Trimming/cutadapt/{sample}_cutadapt-removed_R1.fastq.gz",
        rev_reads = "results/01_Trimming/cutadapt/{sample}_cutadapt-removed_R2.fastq.gz"
    output:
        fwd_reads = temp("results/01_Trimming/sickle/{sample}_sickle-trimmed_R1.fastq.gz"),
        rev_reads = temp("results/01_Trimming/sickle/{sample}_sickle-trimmed_R2.fastq.gz"),
        single = temp("results/01_Trimming/sickle/{sample}_sickle-trimmed_SE.fastq.gz")
    log:
        "results/10_Reports/tools-log/sickle-trim/{sample}.log"
    shell:
       "sickle "                # Sickle, a windowed adaptive trimming tool for FASTQ files using quality
        "{params.command} "      # Paired-end or single-end sequence trimming
        "-t {params.encoding} "  # --qual-type: Type of quality values, solexa ; illumina ; sanger ; CASAVA, < 1.3 ; 1.3 to 1.7 ; >= 1.8
        "-q {params.quality} "   # --qual-threshold: Threshold for trimming based on average quality in a window (default: 20)
        "-l {params.length} "    # --length-threshold: Threshold to keep a read based on length after trimming (default: 20)
        "-f {input.fwd_reads} "  # --pe-file1: Input paired-end forward fastq file
        "-r {input.rev_reads} "  # --pe-file2: Input paired-end reverse fastq file
        "-g "                    # --gzip-output: Output gzipped files
        "-o {output.fwd_reads} " # --output-pe1: Output trimmed forward fastq file
        "-p {output.rev_reads} " # --output-pe2: Output trimmed reverse fastq file (must use -s option)
        "-s {output.single} "    # --output-single: Output trimmed singles fastq file
        "&> {log} "              # Log redirection
        "&& echo 'keep.dir' > results/01_Trimming/sickle/.keep"

###############################################################################
rule cutadapt_adapters_removing:
    # Aim: finds and removes adapter sequences, primers, poly-A tails and other types of unwanted sequence from your high-throughput sequencing reads
    # Use: cutadapt [OPTIONS] -a/-A [ADAPTER] -o [OUT_FWD.fastq.gz] -p [OUT_REV.fastq.gz] [IN_FWD.fastq.gz] [IN_REV.fastq.gz]
    # Rmq: multiple adapter sequences can be given using further -a options, but only the best-matching adapter will be removed
    message:
        "Cutadapt adapters removing for [[ {wildcards.sample} ]] sample"
    conda:
        CUTADAPT
    resources:
        cpus = CPUS
    params:
        length = C_LENGTH,
        truseq = TRUSEQ,
        nextera = NEXTERA,
        small = SMALL,
        cut = CLIPPING
    input:
        fwd_reads = "resources/reads/{sample}_R1.fastq.gz",
        rev_reads = "resources/reads/{sample}_R2.fastq.gz"
        #fwd_reads = "/users/illumina/local/data/run_1/FATSQ/{sample}_R1.fastq.gz",
        #rev_reads = "/users/illumina/local/data/run_1/FATSQ/{sample}_R2.fastq.gz"
    output:
        fwd_reads = temp("results/01_Trimming/cutadapt/{sample}_cutadapt-removed_R1.fastq.gz"),
        rev_reads = temp("results/01_Trimming/cutadapt/{sample}_cutadapt-removed_R2.fastq.gz")
    log:
        "results/10_Reports/tools-log/cutadapt/{sample}.log"
    shell:
       "cutadapt "                           # Cutadapt, finds and removes unwanted sequence from your HT-seq reads
        "--cores {resources.cpus} "           # -j: Number of CPU cores to use. Use 0 to auto-detect (default: 1)
        "--cut {params.cut} "                 # -u: Remove 'n' first bases (5') from forward R1 (hard-clipping, default: 0)
        "-U {params.cut} "                    # -U: Remove 'n' first bases (5') from reverse R2 (hard-clipping, default: 0)
        "--trim-n "                           # --trim-n: Trim N's on ends (3') of reads
        "--minimum-length {params.length} "   # -m: Discard reads shorter than length
        "--adapter {params.truseq} "          # -a: Sequence of an adapter ligated to the 3' end of the first read
        "-A {params.truseq} "                 # -A: 3' adapter to be removed from second read in a pair
        "--adapter {params.nextera} "         # -a: Sequence of an adapter ligated to the 3' end of the first read
        "-A {params.nextera} "                # -A: 3' adapter to be removed from second read in a pair
        "--adapter {params.small} "           # -a: Sequence of an adapter ligated to the 3' end of the first read
        "-A {params.small} "                  # -A: 3' adapter to be removed from second read in a pair
        "--output {output.fwd_reads} "        # -o: Write trimmed reads to FILE
        "--paired-output {output.rev_reads} " # -p: Write second read in a pair to FILE
        "{input.fwd_reads} "                  # Input forward reads R1.fastq
        "{input.rev_reads} "                  # Input reverse reads R2.fastq
        "&> {log} "                           # Log redirection
        "&& echo 'keep.dir' > results/01_Trimming/cutadapt/.keep"

###############################################################################
