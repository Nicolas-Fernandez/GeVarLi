###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ gevarli.smk
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Snakefile with GeVarLi rules
# Date ___________________ 2021.10.12
# Latest modifications ___ 2022.11.07
# Use ____________________ snakemake -s gevarli.smk --use-conda 

###############################################################################
###### CONFIGURATION ######

configfile: "config/config.yaml"

###############################################################################
###### FUNCTIONS ######

def get_memory_per_thread(wildcards):
    memory_per_thread = RAM // CPUS
    return memory_per_thread

def get_bam_input(wildcards):
    if BAMCLIP == "yes":
        markdup = "results/02_Mapping/{sample}_{aligner}_mark-dup.primerclipped.bam"
    elif BAMCLIP == "no":
        markdup = "results/02_Mapping/{sample}_{aligner}_mark-dup.bam"
    else:
        markdup = "error_config_file_yaml"
    return markdup

def get_bai_input(wildcards):
    if BAMCLIP == "yes":
        index = "results/02_Mapping/{sample}_{aligner}_mark-dup.primerclipped.bam.bai"
    elif BAMCLIP == "no":
        index = "results/02_Mapping/{sample}_{aligner}_mark-dup.bam.bai"
    else:
        index = "error_config_file_yaml"
    return index

def get_pangolin_input(wildcards):
    pangolin_list = []
    if "SARS-CoV-2" in REFERENCE:
        pangolin_list = expand("results/06_Lineages/{sample}_{aligner}_{mincov}X_pangolin-report.csv",
                               sample = SAMPLE, aligner = ALIGNER, mincov = MINCOV)
    return pangolin_list

def get_nextclade_input(wildcards):
    nextclade_list = []
    if "SARS-CoV-2" in REFERENCE or "Monkeypox-virus" in REFERENCE:
        nextclade_list = expand("results/06_Lineages/{sample}_{aligner}_{mincov}X_nextclade-report.tsv",
                                sample = SAMPLE, aligner = ALIGNER, mincov = MINCOV)
    return nextclade_list

def get_nextclade_dataset(wildcards):
    if "SARS-CoV-2" in REFERENCE:
        nextclade_dataset = "sars-cov-2"
    elif "Monkeypox-virus" in REFERENCE:
        nextclade_dataset = "MPXV"
    else:
        nextclade_dataset = "error_config_file_yaml"
    return nextclade_dataset


###############################################################################
###### WILDCARDS ######

SAMPLE, = glob_wildcards("resources/reads/{sample}_R1.fastq.gz")

###############################################################################
###### RESOURCES ######

OS = config["os"]                      # Operating system
CPUS = config["resources"]["cpus"]     # Threads (maximum)
RAM = config["resources"]["ram"]       # Memory (RAM) in Gb (maximum)
MEM_GB = get_memory_per_thread         # Memory per thread in GB (maximum)
TMPDIR = config["resources"]["tmpdir"] # Temporary directory

###############################################################################
###### ENVIRONMENTS ######

CUTADAPT = config["conda"][OS]["cutadapt"]        # Cutadapt
SICKLETRIM = config["conda"][OS]["sickle-trim"]   # Sickle-trim
BOWTIE2 = config["conda"][OS]["bowtie2"]          # Bowtie2
BWA = config["conda"][OS]["bwa"]                  # Bwa
SAMTOOLS = config["conda"][OS]["samtools"]        # SamTools
BAMCLIPPER = config["conda"][OS]["bamclipper"]    # BAMClipper
BEDTOOLS = config["conda"][OS]["bedtools"]        # BedTools
BCFTOOLS = config["conda"][OS]["bcftools"]        # BcfTools
GAWK = config["conda"][OS]["gawk"]                # Gawk
LOFREQ = config["conda"][OS]["lofreq"]            # LoFreq
PANGOLIN = config["conda"][OS]["pangolin"]        # Pangolin
NEXTCLADE = config["conda"][OS]["nextclade"]      # Nextclade

###############################################################################
###### PARAMETERS ######

LENGTHc = config["cutadapt"]["length"]          # Cutadapt --minimum-length
TRUSEQ = config["cutadapt"]["kits"]["truseq"]   # Cutadapt --adapter Illumina TruSeq
NEXTERA = config["cutadapt"]["kits"]["nextera"] # Cutadapt --adapter Illumina Nextera
SMALL = config["cutadapt"]["kits"]["small"]     # Cutadapt --adapter Illumina Small

COMMAND = config["sickle-trim"]["command"]      # Sickle-trim command
ENCODING = config["sickle-trim"]["encoding"]    # Sickle-trim --qual-type 
QUALITY = config["sickle-trim"]["quality"]      # Sickle-trim --qual-threshold
LENGTH = config["sickle-trim"]["length"]        # Sickle-trim --length-treshold

ALIGNER = config["aligner"]                     # Aligners ('bwa' or 'bowtie2')

BWAPATH = config["bwa"]["path"]                 # BWA path to indexes
BWAALGO = config["bwa"]["algorithm"]            # BWA indexing algorithm

BT2PATH = config["bowtie2"]["path"]             # Bowtie2 path to indexes
SENSITIVITY = config["bowtie2"]["sensitivity"]  # Bowtie2 sensitivity preset
BT2ALGO = config["bowtie2"]["algorithm"]        # BT2 indexing algorithm

BAMCLIP = config["bamclipper"]["clipping"]      # Bamclipper option on / off
CLIPPATH = config["bamclipper"]["path"]         # Bamclipper path to primers
PRIMERS = config["bamclipper"]["primers"]       # Bamclipper primers bed files
UPSTREAM = config["bamclipper"]["upstream"]     # Bamclipper upstream nucleotides
DOWNSTREAM = config["bamclipper"]["downstream"] # Bamclipper downstream nucleotides

REFPATH = config["consensus"]["path"]           # Path to genomes references
REFERENCE = config["consensus"]["reference"]    # Genome reference sequence, in fasta format
MINCOV = config["consensus"]["mincov"]          # Minimum coverage, mask lower regions with 'N' 
MINAF = config["consensus"]["minaf"]            # Minimum allele frequency allowed
IUPAC = config["consensus"]["iupac"]            # Output variants in the form of IUPAC ambiguity codes

NEXTPATH = config["nextclade"]["path"]          # Path to nextclade dataset
NEXTDATASET = get_nextclade_dataset             # Nextclade dataset

###############################################################################
###### RULES ######

rule all:
    input:
        covstats = expand("results/03_Coverage/{sample}_{aligner}_{mincov}X_coverage-stats.tsv",
                          sample = SAMPLE, aligner = ALIGNER, mincov = MINCOV),
        consensus = expand("results/05_Consensus/{sample}_{aligner}_{mincov}X_consensus.fasta",
                           sample = SAMPLE, aligner = ALIGNER, mincov = MINCOV),
        pangolin = get_pangolin_input,
        nextclade = get_nextclade_input
        #gisaid = get_gisaid_input # soon

###############################################################################
rule nextclade_lineage:
    # Aim: nextclade lineage assignation
    # Use: nextclade [QUERY.fasta] -t [THREADS] --outfile [NAME.csv]
    message:
        "Nextclade lineage assignation for {wildcards.sample} sample consensus ({wildcards.aligner}, @{wildcards.mincov}X)"
    conda:
        NEXTCLADE
    resources:
        cpus = CPUS
    params:
        path = NEXTPATH,
        dataset = NEXTDATASET
    input:
        consensus = "results/05_Consensus/{sample}_{aligner}_{mincov}X_consensus.fasta"
    output:
        lineage = "results/06_Lineages/{sample}_{aligner}_{mincov}X_nextclade-report.tsv",
        alignment = directory("results/06_Lineages/{sample}_{aligner}_{mincov}X_nextclade-all/")
    log:
        "results/10_Reports/tools-log/nextclade/{sample}_{aligner}_{mincov}X_lineage.log"
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
        "Pangolin lineage mapping for {wildcards.sample} sample consensus ({wildcards.aligner}, @{wildcards.mincov}X)"
    conda:
        PANGOLIN
    resources:
        cpus = CPUS
    params:
        tmpdir = TMPDIR
    input:
        consensus = "results/05_Consensus/{sample}_{aligner}_{mincov}X_consensus.fasta"
    output:
        lineage = "results/06_Lineages/{sample}_{aligner}_{mincov}X_pangolin-report.csv"
    log:
        "results/10_Reports/tools-log/pangolin/{sample}_{aligner}_{mincov}X_lineage.log"
    shell:
        "pangolin "                  # Pangolinn, Phylogenetic Assignment of Named Global Outbreak LINeages
        "{input.consensus} "          # Query fasta file of sequences to analyse
        "--threads {resources.cpus} " # -t: Number of threads
        "--tempdir {params.tmpdir} "  # Specify where you want the temp stuff to go (default: $TMPDIR)
        "--outfile {output.lineage} " # Optional output file name (default: lineage_report.csv)
        "&> {log}"                    # Log redirection

###############################################################################
rule sed_rename_headers:
    # Aim: rename all fasta header with sample name
    # Use: sed 's/[OLD]/[NEW]/' [IN] > [OUT]
    message:
        "Sed rename header for {wildcards.sample} sample consensus fasta ({wildcards.aligner}, @{wildcards.mincov}X)"
    input:
        constmp = "results/05_Consensus/{sample}_{aligner}_{mincov}X_consensus.fasta.tmp"
    output:
        consensus = "results/05_Consensus/{sample}_{aligner}_{mincov}X_consensus.fasta"
    log:
        "results/10_Reports/tools-log/sed/{sample}_{aligner}_{mincov}X_fasta-header.log"
    shell:
        "sed " # Sed, a Stream EDitor used to perform basic text transformations on an input stream
        "'s/^>.*$/>{wildcards.sample}_{wildcards.aligner}_{wildcards.mincov}/' "
        "{input.constmp} "       # Input file
        "1> {output.consensus} " # Output file
        "2> {log}"               # Log redirection

###############################################################################
rule bcftools_consensus:
    # Aim: create consensus
    # Use: bcftools consensus -f [REFERENCE] [VARIANTS.vcf.gz] -o [CONSENSUS.fasta] 
    message:
        "BcfTools consensus for {wildcards.sample} sample ({wildcards.aligner}, @{wildcards.mincov}X)"
    conda:
        BCFTOOLS
    params:
        iupac = IUPAC
    input:
        maskedref = "results/04_Variants/{sample}_{aligner}_{mincov}X_masked-ref.fasta",
        archive = "results/04_Variants/{sample}_{aligner}_{mincov}X_variant-filt.vcf.bgz",
        index = "results/04_Variants/{sample}_{aligner}_{mincov}X_variant-filt.bgz.tbi"
    output:
        constmp = temp("results/05_Consensus/{sample}_{aligner}_{mincov}X_consensus.fasta.tmp")
    log:
        "results/10_Reports/tools-log/bcftools/{sample}_{aligner}_{mincov}X_consensus.log"
    shell:
        "bcftools "                      # Bcftools, tools for variant calling and manipulating VCFs and BCFs
        "consensus "                      # Create consensus sequence by applying VCF variants to a reference fasta file
        "--fasta-ref {input.maskedref} "  # -f: reference sequence in fasta format
        "{params.iupac} "                 # -I, --iupac-codes: output variants in the form of IUPAC ambiguity codes
        "{input.archive} "                # SNVs and Indels filtered VCF archive file
        "--output {output.constmp} "      # -o: write output to a file (default: standard output)
        "2> {log}"                        # Log redirection

###############################################################################
rule tabix_tabarch_indexing:
    # Aim: tab archive indexing
    # Use: tabix [OPTIONS] [TAB.bgz]
    message:
        "Tabix tab archive indexing for {wildcards.sample} sample ({wildcards.aligner}, @{wildcards.mincov}X)"
    conda:
        SAMTOOLS
    input:
        archive = "results/04_Variants/{sample}_{aligner}_{mincov}X_variant-filt.vcf.bgz"
    output:
        index = temp("results/04_Variants/{sample}_{aligner}_{mincov}X_variant-filt.bgz.tbi")
    log:
        "results/10_Reports/tools-log/tabix/{sample}_{aligner}_{mincov}X_variant-archive-index.log"
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
        "Bgzip variant block compressing for {wildcards.sample} sample ({wildcards.aligner}, @{wildcards.mincov}X)"
    conda:
        SAMTOOLS
    resources:
        cpus = CPUS
    input:
        variantfilt = "results/04_Variants/{sample}_{aligner}_{mincov}X_variant-filt.vcf"
    output:
        archive = temp("results/04_Variants/{sample}_{aligner}_{mincov}X_variant-filt.vcf.bgz")
    log:
        "results/10_Reports/tools-log/bgzip/{sample}_{aligner}_{mincov}X_variant-archive.log"
    shell:
        "bgzip "                     # Bgzip, block compression/decompression utility
        "--stdout "                   # -c: Write to standard output, keep original files unchanged
        "--threads {resources.cpus} " # -@: Number of threads to use (default: 1)
        "{input.variantfilt} "          # VCF input file, gzip suuported, no streaming supported
        "1> {output.archive} "        # VCF output file, gzip supported (default: standard output)
        "2> {log}"                    # Log redirection 

###############################################################################
rule lofreq_variant_filtering:
    # Aim: SNVs and Indels filtering in VCF file
    # Use: lofreq filter [OPTIONS] -i [INDEL.vcf] -o [INDELFILT.vcf]
    # Note: without --no-defaults LoFreq's predefined filters are on
    message:
        "LoFreq filtering SNVs and Indels for {wildcards.sample} sample ({wildcards.aligner}, @{wildcards.mincov}X)"
    conda:
        LOFREQ
    params:
        minaf = MINAF
    input:
        variantcall = "results/04_Variants/{sample}_{aligner}_{mincov}X_variant-call.vcf"
    output:
        variantfilt = "results/04_Variants/{sample}_{aligner}_{mincov}X_variant-filt.vcf"
    log:
        "results/10_Reports/tools-log/lofreq/{sample}_{aligner}_{mincov}X_variant-filt.log"
    shell:
        "lofreq "                      # LoFreq, fast and sensitive inference of SNVs and indels
        "filter "                       # Filter SNVs and Indels parsed from vcf file
        "--cov-min {wildcards.mincov} " # -v: Minimum coverage allowed (INT)
        "--af-min {params.minaf} "      # -a: Minimum allele freq allowed (FLOAT)
        "--in {input.variantcall} "     # VCF input file, gzip suuported, no streaming supported
        "--out {output.variantfilt} "   # VCF output file, gzip supported (default: standard output)
        "&> {log}"                      # Log redirection 

###############################################################################
rule lofreq_variant_calling:
    # Aim: SNVs and Indels calling
    # Use: lofreq call-parallel --pp-threads [THREADS] --call-indels -f [MASKEDREF.fasta] -o [INDEL.vcf] [INDEL.bam]
    message:
        "LoFreq calling SNVs and Indels for {wildcards.sample} sample ({wildcards.aligner}, @{wildcards.mincov}X)"
    conda:
        LOFREQ
    resources:
        cpus = CPUS
    input:
        maskedref = "results/04_Variants/{sample}_{aligner}_{mincov}X_masked-ref.fasta",
        indelqual = "results/04_Variants/{sample}_{aligner}_{mincov}X_indel-qual.bam",
        index = "results/04_Variants/{sample}_{aligner}_{mincov}X_indel-qual.bai"
    output:
        variantcall = "results/04_Variants/{sample}_{aligner}_{mincov}X_variant-call.vcf"
    log:
        "results/10_Reports/tools-log/lofreq/{sample}_{aligner}_{mincov}X_variant-call.log"
    shell:
        "lofreq "                       # LoFreq, fast and sensitive inference of SNVs and indels
        "call-parallel "                 # Call variants from BAM file
        "--pp-threads {resources.cpus} " # Number of threads (required)
        "--call-indels "                 # Enable indel calls (note: preprocess your file to include indel alignment qualities!)
        "--ref {input.maskedref} "       # -f: Indexed reference fasta file (gzip supported)
        "--out {output.variantcall} "    # -o: SNVs and Indels VCF file output (default: standard output)
        "{input.indelqual} "             # Indel BAM input
        "&> {log}"                       # Log redirection 

###############################################################################
rule samtools_indel_indexing:
    # Aim: indexing indel qualities BAM file
    # Use: samtools index -@ [THREADS] -b [INDELQUAL.bam] [INDEX.bai]
    message:
        "SamTools indexing indel qualities BAM file {wildcards.sample} sample ({wildcards.aligner}, @{wildcards.mincov}X)"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
    input:
        indelqual = "results/04_Variants/{sample}_{aligner}_{mincov}X_indel-qual.bam"
    output:
        index = "results/04_Variants/{sample}_{aligner}_{mincov}X_indel-qual.bai"
    log:
        "results/10_Reports/tools-log/samtools/{sample}_{aligner}_{mincov}X_indel-qual-index.log"
    shell:
        "samtools index "     # Samtools index, tools for alignments in the SAM format with command to index alignment
        "-@ {resources.cpus} " # Number of additional threads to use (default: 0)
        "-b "                  # -b: Generate BAI-format index for BAM files (default)
        "{input.indelqual} "   # Sorted bam input
        "{output.index} "      # Markdup bam output
        "&> {log}"             # Log redirection 

###############################################################################
rule lofreq_indel_qualities:
    # Aim: Indels qualities 
    # Use: lofreq indelqual --dindel -f [MASKEDREF.fasta] -o [INDEL.bam] [MARKDUP.bam]
    # Note: do not realign your BAM file afterwards!
    message:
        "LoFreq insert indels qualities for {wildcards.sample} sample ({wildcards.aligner}, @{wildcards.mincov}X)"
    conda:
        LOFREQ
    input:
        maskedref = "results/04_Variants/{sample}_{aligner}_{mincov}X_masked-ref.fasta",
        markdup = get_bam_input,
        index = get_bai_input
    output:
        indelqual = "results/04_Variants/{sample}_{aligner}_{mincov}X_indel-qual.bam"
    log:
        "results/10_Reports/tools-log/lofreq/{sample}_{aligner}_{mincov}X_indel-qual.log"
    shell:
        "lofreq "                  # LoFreq, fast and sensitive inference of SNVs and Indels 
        "indelqual "                # Insert indel qualities into BAM file (required for indel predictions)
        "--dindel "                 # Add Dindel's indel qualities Illumina specifics (need --ref and clashes with -u)
        "--ref {input.maskedref} "  # -f: Reference (masked) sequence used for mapping (only required for --dindel)
        "--out {output.indelqual} " # -o: Indel BAM file output (default: standard output)
        "{input.markdup} "          # Markdup BAM input
        "&> {log}"                  # Log redirection 

###############################################################################
rule bedtools_masking:
    # Aim: masking low coverage regions
    # Use: bedtools maskfasta [OPTIONS] -fi [REFERENCE.fasta] -bed [RANGE.bed] -fo [MASKEDREF.fasta]
    message:
        "BedTools masking low coverage regions for {wildcards.sample} sample ({wildcards.aligner}, @{wildcards.mincov}X)"
    conda:
        BEDTOOLS
    params:
        path = REFPATH,
        reference = REFERENCE
    input:
        lowcovmask = "results/03_Coverage/{sample}_{aligner}_{mincov}X_low-cov-mask.bed"
    output:
        maskedref = "results/04_Variants/{sample}_{aligner}_{mincov}X_masked-ref.fasta"
    log:
        "results/10_Reports/tools-log/bedtools/{sample}_{aligner}_{mincov}X_masking.log"
    shell:
        "bedtools maskfasta "                       # Bedtools maskfasta, mask a fasta file based on feature coordinates
        "-fi {params.path}{params.reference}.fasta " # Input FASTA file 
        "-bed {input.lowcovmask} "                   # BED/GFF/VCF file of ranges to mask in -fi
        "-fo {output.maskedref} "                    # Output masked FASTA file
        "&> {log}"                                   # Log redirection 

###############################################################################
rule bedtools_merged_mask:
    # Aim: merging overlaps
    # Use: bedtools merge [OPTIONS] -i [FILTERED.bed] -g [GENOME.fasta] 
    message:
        "BedTools merging overlaps for {wildcards.sample} sample ({wildcards.aligner}, @{wildcards.mincov}X)"
    conda:
        BEDTOOLS
    input:
        mincovfilt = "results/03_Coverage/{sample}_{aligner}_{mincov}X_min-cov-filt.bed"
    output:
        lowcovmask = temp("results/03_Coverage/{sample}_{aligner}_{mincov}X_low-cov-mask.bed")
    log:
        "results/10_Reports/tools-log/bedtools/{sample}_{aligner}_{mincov}X_merging.log"
    shell:
        "bedtools merge "        # Bedtools merge, merges overlapping BED/GFF/VCF entries into a single interval
        "-i {input.mincovfilt} "  # -i: BED/GFF/VCF input to merge 
        "1> {output.lowcovmask} " # merged output
        "2> {log}"                # Log redirection

###############################################################################
rule awk_mincovfilt:
    # Aim: minimum coverage filtration
    # Use: awk '$4 < [MINCOV]' [BEDGRAPH.bed] 1> [FILTERED.bed]
    message:
        "Awk minimum coverage filtration for {wildcards.sample} sample ({wildcards.aligner}, @{wildcards.mincov}X)"
    conda:
        GAWK
    input:
        genomecov = "results/03_Coverage/{sample}_{aligner}_genome-cov.bed"
    output:
        mincovfilt = temp("results/03_Coverage/{sample}_{aligner}_{mincov}X_min-cov-filt.bed")
    log:
        "results/10_Reports/tools-log/awk/{sample}_{aligner}_{mincov}X_min-cov-filt.log"
    shell:
        "awk "                      # Awk, a program that you can use to select particular records in a file and perform operations upon them
        "'$4 < {wildcards.mincov}' " # Minimum coverage for masking regions in consensus sequence
        "{input.genomecov} "         # BedGraph coverage input
        "1> {output.mincovfilt} "    # Minimum coverage filtered bed output
        "2> {log} "                  # Log redirection

###############################################################################
rule awk_coverage_statistics:
    # Aim: computing genomme coverage stats
    # Use: awk {FORMULA} END {{print [RESULTS.tsv] [BEDGRAPH.bed]
    message:
        "Awk compute genome coverage statistics BED {wildcards.sample} sample ({wildcards.aligner})"
    conda:
        GAWK
    input:
        genomecov = "results/03_Coverage/{sample}_{aligner}_genome-cov.bed"
    output:
        covstats = "results/03_Coverage/{sample}_{aligner}_{mincov}X_coverage-stats.tsv"
    log:
        "results/10_Reports/tools-log/awk/{sample}_{aligner}_{mincov}X_coverage-stats.log"
    shell:
        "awk ' "                            # Awk, a program to select particular records in a file and perform operations upon them
        "$4 >= {wildcards.mincov} "          # Minimum coverage
        "{{supMinCov+=$3-$2}} ; "            # Genome size >= @ mincov X
        "{{genomeSize+=$3-$2}} ; "           # Genome size
        "{{totalBases+=($3-$2)*$4}} ; "      # Total bases @ 1 X 
        "{{totalBasesSq+=(($3-$2)*$4)**2}} " # Total bases square @ 1 X
        "END "                                # END
        "{{print "                             # Print
        """ "sample_id", "\t", """              # Sample ID header
        """ "mean_depth", "\t", """             # Mean depth header
        """ "standard_deviation", "\t", """     # Standard deviation header
        """ "cov_percent_%" "\t", """           # Coverage percent header
        """ "@_min_cov_X" "\t", """             # @ mincov X header
        """ "aligner" """                       # Aligner header
        "ORS "                                   # \n newline
        """ "{wildcards.sample}", "\t", """       # Sample ID value
        """ int(totalBases/genomeSize), "\t", """ # Mean depth value
        """ int(sqrt((totalBasesSq/genomeSize)-(totalBases/genomeSize)**2)), "\t", """ # Standard deviation value
        """ supMinCov/genomeSize*100 "\t", """     # Coverage percent (@ mincov X) value
        """ "@{wildcards.mincov}X" "\t", """       # @ mincov X value
        """ "{wildcards.aligner}" """              # Aligner value
        "}}' "                                    # Close print
        "{input.genomecov} "                     # BedGraph coverage input
        "1> {output.covstats} "                  # Mean depth output
        "2> {log}"                              # Log redirection

###############################################################################
rule bedtools_genome_coverage:
    # Aim: computing genome coverage sequencing
    # Use: bedtools genomecov [OPTIONS] -ibam [MARKDUP.bam] 1> [BEDGRAPH.bed]
    message:
        "BedTools computing genome coverage for {wildcards.sample} sample against reference genome sequence ({wildcards.aligner})"
    conda:
        BEDTOOLS
    input:
        markdup = get_bam_input,
        index = get_bai_input
    output:
        genomecov = temp("results/03_Coverage/{sample}_{aligner}_genome-cov.bed")
    log:
        "results/10_Reports/tools-log/bedtools/{sample}_{aligner}_genome-cov.log"
    shell:
        "bedtools genomecov "    # Bedtools genomecov, compute the coverage of a feature file among a genome
        "-bga "                   # Report depth in BedGraph format, regions with zero coverage are also reported
        "-ibam {input.markdup} "  # The input file is in BAM format, must be sorted by position
        "1> {output.genomecov} "  # BedGraph output
        "2> {log} "               # Log redirection

###############################################################################
rule bamclipper_amplicon_primers:
    # Aim: soft-clip primer sequences from BAM alignments of PCR amplicons
    # Use: bamclipper.sh -n [THREADS] -b [MARKDUP.bam] -p [PRIMER.bed] -u [UPSTREAM] -d [DOWNSTREAM]
    message:
        "BAMClipper soft-clipping BAM alignments for {wildcards.sample} sample ({wildcards.aligner})"
    conda:
        BAMCLIPPER
    resources:
       cpus = CPUS
    params:
        path = CLIPPATH,
        primers = PRIMERS,
        upstream = UPSTREAM,
        downstream = DOWNSTREAM
    input:
        markdup = "results/02_Mapping/{sample}_{aligner}_mark-dup.bam",
        index = "results/02_Mapping/{sample}_{aligner}_mark-dup.bam.bai"
    output:
        bamclip = "results/02_Mapping/{sample}_{aligner}_mark-dup.primerclipped.bam",
        baiclip = "results/02_Mapping/{sample}_{aligner}_mark-dup.primerclipped.bam.bai"
    log:
        "results/10_Reports/tools-log/bamclipper/{sample}_{aligner}_primers-clip.log"
    shell:
        "bamclipper.sh "                          # BAMClipper, remove primer sequences from BAM alignments of PCR amplicons by soft-clipping
        "-b {input.markdup} "                      # Indexed BAM alignment file
        "-p {params.path}/{params.primers}.bedpe " # BEDPE of primer pair locations
        "-n {resources.cpus} "                     # Number of threads (default: 1)
        "-u {params.upstream} "                    # Number of nuc. upstream for assigning alignments to primers (default: 1)
        "-d {params.downstream} "                  # Number of nuc. downstream for assigning alignments to primers (default: 5)
        #"-o results/02_Mapping/ "                  # Path to write output (BamClipper v.1.1.3)
        "&> {log} "                                # Log redirection
        "&& mv {wildcards.sample}_{wildcards.aligner}_mark-dup.primerclipped.bam {output.bamclip} "
        "&& mv {wildcards.sample}_{wildcards.aligner}_mark-dup.primerclipped.bam.bai {output.baiclip}"

###############################################################################
rule samtools_index_markdup:
    # Aim: indexing marked as duplicate BAM file
    # Use: samtools index -@ [THREADS] -b [MARKDUP.bam] [INDEX.bai]
    message:
        "SamTools indexing marked as duplicate BAM file {wildcards.sample} sample ({wildcards.aligner})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
    input:
        markdup = "results/02_Mapping/{sample}_{aligner}_mark-dup.bam"
    output:
        index = "results/02_Mapping/{sample}_{aligner}_mark-dup.bam.bai"
    log:
        "results/10_Reports/tools-log/samtools/{sample}_{aligner}_mark-dup-index.log"
    shell:
        "samtools index "     # Samtools index, tools for alignments in the SAM format with command to index alignment
        "-@ {resources.cpus} " # --threads: Number of additional threads to use (default: 1)
        "-b "                  # -b: Generate BAI-format index for BAM files (default)
        "{input.markdup} "     # Markdup bam input
        "{output.index} "      # Markdup index output
        "&> {log}"             # Log redirection

###############################################################################
rule samtools_markdup:
    # Aim: marking duplicate alignments
    # Use: samtools markdup -@ [THREADS] -r -s -O BAM [SORTED.bam] [MARKDUP.bam] 
    message:
        "SamTools marking duplicate alignments for {wildcards.sample} sample ({wildcards.aligner})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
    input:
        sorted = "results/02_Mapping/{sample}_{aligner}_sorted.bam"
    output:
        markdup = "results/02_Mapping/{sample}_{aligner}_mark-dup.bam"
    log:
        "results/10_Reports/tools-log/samtools/{sample}_{aligner}_mark-dup.log"
    shell:
        "samtools markdup "          # Samtools markdup, tools for alignments in the SAM format with command mark duplicates
        "--threads {resources.cpus} " # -@: Number of additional threads to use (default: 1)
        "-r "                         # -r: Remove duplicate reads
        "-s "                         # -s: Report stats
        "--output-fmt BAM "           # -O: Specify output format: SAM, BAM, CRAM (here, BAM format)
        "{input.sorted} "             # Sorted bam input
        "{output.markdup} "           # Markdup bam output
        "&> {log}"                    # Log redirection 

###############################################################################
rule samtools_sorting:
    # Aim: sorting
    # Use: samtools sort -@ [THREADS] -m [MEM] -T [TMPDIR] -O BAM -o [SORTED.bam] [FIXMATE.bam] 
    message:
        "SamTools sorting {wildcards.sample} sample reads ({wildcards.aligner})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS,
       mem_gb = MEM_GB
    params:
        tmpdir = TMPDIR
    input:
        fixmate = "results/02_Mapping/{sample}_{aligner}_fix-mate.bam"
    output:
        sorted = temp("results/02_Mapping/{sample}_{aligner}_sorted.bam")
    log:
        "results/10_Reports/tools-log/samtools/{sample}_{aligner}_sorted.log"
    shell:
        "samtools sort "              # Samtools sort, tools for alignments in the SAM format with command to sort alignment file
        "--threads {resources.cpus} "  # -@: Number of additional threads to use (default: 1)
        "-m {resources.mem_gb}G "      # -m: Set maximum memory per thread, suffix K/M/G recognized (default: 768M)
        "-T {params.tmpdir} "          # -T: Write temporary files to PREFIX.nnnn.bam
        "--output-fmt BAM "            # -O: Specify output format: SAM, BAM, CRAM (here, BAM format)
        "-o {output.sorted} "          # Sorted bam output
        "{input.fixmate} "             # Fixmate bam input
        "&> {log}"                     # Log redirection 

###############################################################################
rule samtools_fixmate:
    # Aim: filling in mate coordinates
    # Use: samtools fixmate -@ [THREADS] -m -O BAM [SORTBYNAMES.bam] [FIXMATE.bam] 
    message:
        "SamTools filling in mate coordinates {wildcards.sample} sample reads ({wildcards.aligner})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
    input:
        sortbynames = "results/02_Mapping/{sample}_{aligner}_sort-by-names.bam"
    output:
        fixmate = temp("results/02_Mapping/{sample}_{aligner}_fix-mate.bam")
    log:
        "results/10_Reports/tools-log/samtools/{sample}_{aligner}_fixmate.log"
    shell:
        "samtools fixmate "           # Samtools fixmate, tools for alignments in the SAM format with command to fix mate information
        "--threads {resources.cpus} "  # -@: Number of additional threads to use (default: 1)
        "-m "                          # -m: Add mate score tag 
        "--output-fmt BAM "            # -O: Specify output format: SAM, BAM, CRAM (here, BAM format)
        "{input.sortbynames} "         # Sortbynames bam input
        "{output.fixmate} "            # Fixmate bam output 
        "&> {log}"                     # Log redirection 

###############################################################################
rule samtools_sortbynames:
    # Aim: sorting by names
    # Use: samtools sort -t [THREADS] -n -O BAM -o [SORTBYNAMES.bam] [MAPPED.sam]
    message:
        "SamTools sorting by names {wildcards.sample} sample reads ({wildcards.aligner})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS,
       mem_gb = MEM_GB
    input:
        mapped = "results/02_Mapping/{sample}_{aligner}-mapped.sam"
    output:
        sortbynames = temp("results/02_Mapping/{sample}_{aligner}_sort-by-names.bam")
    log:
        "results/10_Reports/tools-log/samtools/{sample}_{aligner}_sort-by-names.log"
    shell:
        "samtools sort "              # Samtools sort, tools for alignments in the SAM format with command to sort alignment file
        "--threads {resources.cpus} "  # -@: Number of additional threads to use (default: 1)
        "-m {resources.mem_gb}G "      # -m: Set maximum memory per thread, suffix K/M/G recognized (default: 768M)
        "-n "                          # -n: Sort by read name (not compatible with samtools index command) 
        "--output-fmt BAM "            # -O: Specify output format: SAM, BAM, CRAM (here, BAM format)
        "-o {output.sortbynames} "     # -o: Write final output to FILE rather than standard output
        "{input.mapped} "              # Mapped reads input
        "&> {log}"                     # Log redirection 

###############################################################################
rule bwa_mapping:
    # Aim: reads mapping against reference sequence
    # Use: bwa mem -t [THREADS] -x [REFERENCE] [FWD_R1.fq] [REV_R2.fq] 1> [MAPPED.sam]
    message:
        "BWA-MEM mapping {wildcards.sample} sample reads against reference genome sequence"
    conda:
        BWA
    resources:
        cpus = CPUS
    params:
        bwapath = BWAPATH,
        reference = REFERENCE
    input:
        fwdreads = "results/01_Trimming/sickle/{sample}_sickle-trimmed_R1.fastq.gz",
        revreads = "results/01_Trimming/sickle/{sample}_sickle-trimmed_R2.fastq.gz"
    output:
        mapped = temp("results/02_Mapping/{sample}_bwa-mapped.sam")
    log:
        "results/10_Reports/tools-log/bwa/{sample}.log"
    shell:
        "bwa mem "                           # BWA-MEM algorithm, performs local alignment
        "-t {resources.cpus} "                # -t: Number of threads (default: 12)
        "-v 1 "                               # -v: Verbosity level: 1=error, 2=warning, 3=message, 4+=debugging
        "{params.bwapath}{params.reference} " # Reference index filename prefix
        "{input.fwdreads} "                   # Forward input reads
        "{input.revreads} "                   # Reverse input reads
        "1> {output.mapped} "                 # SAM output
        "2> {log}"                            # Log redirection 

###############################################################################
rule bowtie2_mapping:
    # Aim: reads mapping against reference sequence
    # Use: bowtie2 -p [THREADS] -x [REFERENCE] -1 [FWD_R1.fq] -2 [REV_R2.fq] -S [MAPPED.sam]
    message:
        "Bowtie2 mapping {wildcards.sample} sample reads against reference genome sequence"
    conda:
        BOWTIE2
    resources:
        cpus = CPUS
    params:
        bt2path = BT2PATH,
        reference = REFERENCE,
        sensitivity = SENSITIVITY
    input:
        fwdreads = "results/01_Trimming/sickle/{sample}_sickle-trimmed_R1.fastq.gz",
        revreads = "results/01_Trimming/sickle/{sample}_sickle-trimmed_R2.fastq.gz"
    output:
        mapped = temp("results/02_Mapping/{sample}_bowtie2-mapped.sam")
    log:
        "results/10_Reports/tools-log/bowtie2/{sample}.log"
    shell:
        "bowtie2 "                    # Bowtie2, an ultrafast and memory-efficient tool for aligning sequencing reads to long reference sequences
        "--threads {resources.cpus} "  # -p: Number of alignment threads to launch (default: 1)
        "--reorder "                   # Keep the original read order (if multi-processor option -p is used)
        "-x {params.bt2path}{params.reference} " # -x: Reference index filename prefix (minus trailing .X.bt2) [Bowtie-1 indexes are not compatible]
        "{params.sensitivity} "        # Preset (default: "--sensitive", same as [-D 15 -R 2 -N 0 -L 22 -i S,1,1.15]) 
        "-q "                          # -q: Query input files are FASTQ .fq/.fastq (default)
        "-1 {input.fwdreads} "         # Forward input reads
        "-2 {input.revreads} "         # Reverse input reads
        "1> {output.mapped} "          # -S: File for SAM output (default: stdout) 
        "2> {log}"                     # Log redirection 

###############################################################################
rule sickle_trim_quality:
    # Aim: windowed adaptive trimming tool for FASTQ files using quality
    # Use: sickle [COMMAND] [OPTIONS]
    message:
        "Sickle-trim low quality sequences trimming for {wildcards.sample} sample"
    conda:
        SICKLETRIM
    params:
        command = COMMAND,
        encoding = ENCODING,
        quality = QUALITY,
        length = LENGTH
    input:
        fwdreads = "results/01_Trimming/cutadapt/{sample}_cutadapt-removed_R1.fastq.gz",
        revreads = "results/01_Trimming/cutadapt/{sample}_cutadapt-removed_R2.fastq.gz"
    output:
        fwdreads = temp("results/01_Trimming/sickle/{sample}_sickle-trimmed_R1.fastq.gz"),
        revreads = temp("results/01_Trimming/sickle/{sample}_sickle-trimmed_R2.fastq.gz"),
        single = temp("results/01_Trimming/sickle/{sample}_sickle-trimmed_SE.fastq.gz")
    log:
        "results/10_Reports/tools-log/sickle-trim/{sample}.log"
    shell:
       "sickle "                # Sickle, a windowed adaptive trimming tool for FASTQ files using quality
        "{params.command} "      # Paired-end or single-end sequence trimming
        "-t {params.encoding} "  # --qual-type: Type of quality values, solexa ; illumina ; sanger ; CASAVA, < 1.3 ; 1.3 to 1.7 ; >= 1.8
        "-q {params.quality} "   # --qual-threshold: Threshold for trimming based on average quality in a window (default: 20)
        "-l {params.length} "    # --length-threshold: Threshold to keep a read based on length after trimming (default: 20)
        "-f {input.fwdreads} "   # --pe-file1: Input paired-end forward fastq file
        "-r {input.revreads} "   # --pe-file2: Input paired-end reverse fastq file
        "-g "                    # --gzip-output: Output gzipped files
        "-o {output.fwdreads} "  # --output-pe1: Output trimmed forward fastq file
        "-p {output.revreads} "  # --output-pe2: Output trimmed reverse fastq file (must use -s option)
        "-s {output.single} "    # --output-single: Output trimmed singles fastq file
        "&> {log}"               # Log redirection

###############################################################################
rule cutadapt_adapters_removing:
    # Aim: finds and removes adapter sequences, primers, poly-A tails and other types of unwanted sequence from your high-throughput sequencing reads
    # Use: cutadapt [OPTIONS] -a/-A [ADAPTER] -o [OUT-FWD.fastq.gz] -p [OUT-REV.fastq.gz] [IN-FWD.fastq.gz] [IN-REV.fastq.gz]
    # Rmq: multiple adapter sequences can be given using further -a options, but only the best-matching adapter will be removed
    message:
        "Cutadapt adapters removing for {wildcards.sample} sample"
    conda:
        CUTADAPT
    resources:
        cpus = CPUS
    params:
        length = LENGTHc,
        truseq = TRUSEQ,
        nextera = NEXTERA,
        small = SMALL
    input:
        fwdreads = "resources/reads/{sample}_R1.fastq.gz",
        revreads = "resources/reads/{sample}_R2.fastq.gz"
    output:
        fwdreads = temp("results/01_Trimming/cutadapt/{sample}_cutadapt-removed_R1.fastq.gz"),
        revreads = temp("results/01_Trimming/cutadapt/{sample}_cutadapt-removed_R2.fastq.gz")
    log:
        "results/10_Reports/tools-log/cutadapt/{sample}.log"
    shell:
       "cutadapt "                          # Cutadapt, finds and removes unwanted sequence from your HT-seq reads
        "--cores {resources.cpus} "          # -j: Number of CPU cores to use. Use 0 to auto-detect (default: 1)
        "--trim-n "                          # --trim-n: Trim N's on ends of reads
        "--minimum-length {params.length} "  # -m: Discard reads shorter than length
        "--adapter {params.truseq} "         # -a: Sequence of an adapter ligated to the 3' end of the first read
        "-A {params.truseq} "                # -A: 3' adapter to be removed from second read in a pair
        "--adapter {params.nextera} "        # -a: Sequence of an adapter ligated to the 3' end of the first read
        "-A {params.nextera} "               # -A: 3' adapter to be removed from second read in a pair
        "--adapter {params.small} "          # -a: Sequence of an adapter ligated to the 3' end of the first read
        "-A {params.small} "                 # -A: 3' adapter to be removed from second read in a pair
        "--output {output.fwdreads} "        # -o: Write trimmed reads to FILE
        "--paired-output {output.revreads} " # -p: Write second read in a pair to FILE
        "{input.fwdreads} "                  # Input forward reads R1.fastq
        "{input.revreads} "                  # Input reverse reads R2.fastq
        "&> {log}"                           # Log redirection

###############################################################################
