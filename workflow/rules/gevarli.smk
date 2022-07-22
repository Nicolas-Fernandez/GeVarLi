#######T######R#####A#####N######S######V######I######H#######M######I#########
# Name: gevarli.smk
# Author: Nicolas Fernandez
# Affiliation: IRD_U233_TransVIHMI
# Aim: Snakefile for GEnome assembling, VARiant calling and LIneage assignation 
# Date: 2021.10.12
# Run: snakemake --snakefile gevarli.smk --cores --use-conda 
# Latest modification: 2022.06.22
# Done: Nextclade and Pangolin conditioned by reference setting (SARS-CoV-2)

###############################################################################
# PUBLICATIONS #

###############################################################################
# CONFIGURATION #
configfile: "config/config.yaml"

###############################################################################
# FUNCTIONS #
def get_pangolin(wildcards):
    pangolin_list = []
    if REFERENCE == "SARS-CoV-2_Wuhan-WIV04_2019":
        pangolin_list = expand("results/06_Lineages/{sample}_{aligner}_{mincov}X_pangolin-report.csv",
                               sample = SAMPLE, aligner = ALIGNER, mincov = MINCOV)
    return pangolin_list

def get_nextclade(wildcards):
    nextclade_list = []
    if REFERENCE == "SARS-CoV-2_Wuhan-WIV04_2019":
        nextclade_list = expand("results/06_Lineages/{sample}_{aligner}_{mincov}X_nextclade-report.tsv",
                                sample = SAMPLE, aligner = ALIGNER, mincov = MINCOV)
    return nextclade_list

###############################################################################
# WILDCARDS #
SAMPLE, = glob_wildcards("resources/reads/{sample}_R1.fastq.gz")

###############################################################################
# ENVIRONMENTS #
FASTQC = config["conda"]["fastqc"]            # FastQC
FASTQSCREEN = config["conda"]["fastq-screen"] # Fastq-Screen
MULTIQC = config["conda"]["multiqc"]          # MultiQC
CUTADAPT = config["conda"]["cutadapt"]        # Cutadapt
SICKLETRIM = config["conda"]["sickle-trim"]   # Sickle-trim
BOWTIE2 = config["conda"]["bowtie2"]          # Bowtie2
BWA = config["conda"]["bwa"]                  # Bwa
SAMTOOLS = config["conda"]["samtools"]        # SamTools
BEDTOOLS = config["conda"]["bedtools"]        # BedTools
BCFTOOLS = config["conda"]["bcftools"]        # BcfTools
GAWK = config["conda"]["gawk"]                # Gawk
LOFREQ = config["conda"]["lofreq"]            # LoFreq
PANGOLIN = config["conda"]["pangolin"]        # Pangolin
NEXTCLADE = config["conda"]["nextclade"]      # Nextclade

###############################################################################
# RESOURCES #
CPUS = config["resources"]["cpus"]     # resources thread
MEM_GB = config["resources"]["mem_gb"] # resources mem in Gb
TMPDIR = config["resources"]["tmpdir"] # resources temporary directory

###############################################################################
# PARAMETERS #
LENGTHc = config["cutadapt"]["length"]          # Cutadapt --minimum-length
TRUSEQ = config["cutadapt"]["kits"]["truseq"]   # Cutadapt --adapter Illumina TruSeq
NEXTERA = config["cutadapt"]["kits"]["nextera"] # Cutadapt --adapter Illumina Nextera
SMALL = config["cutadapt"]["kits"]["small"]     # Cutadapt --adapter Illumina Small

COMMAND = config["sickle-trim"]["command"]   # Sickle-trim command
ENCODING = config["sickle-trim"]["encoding"] # Sickle-trim --qual-type 
QUALITY = config["sickle-trim"]["quality"]   # Sickle-trim --qual-threshold
LENGTH = config["sickle-trim"]["length"]     # Sickle-trim --length-treshold

CONFIG = config["fastq-screen"]["config"]  # Fastq-screen --conf
MAPPER = config["fastq-screen"]["aligner"] # Fastq-screen --aligner
SUBSET = config["fastq-screen"]["subset"]  # Fastq-screen --subset

ALIGNER = config["aligner"] # Aligners ('bwa' or 'bowtie2')

INDEXBWA = config["bwa"]["indexes"]            # BWA path to indexes
INDEXBT2 = config["bowtie2"]["indexes"]        # Bowtie2 path to indexes
SENSITIVITY = config["bowtie2"]["sensitivity"] # Bowtie2 sensitivity preset

GENOMES = config["consensus"]["genomes"]     # Path to genomes references
REFERENCE = config["consensus"]["reference"] # Genome reference sequence, in fasta format
MINCOV = config["consensus"]["mincov"]       # Minimum coverage, mask lower regions with 'N' 
MINAF = config["consensus"]["minaf"]         # Minimum allele frequency allowed
IUPAC = config["consensus"]["iupac"]         # Output variants in the form of IUPAC ambiguity codes

DATASET = config["nextclade"]["dataset"] # Nextclade dataset

###############################################################################
rule all:
    input:
        multiqc = "results/00_Quality_Control/multiqc/",
        covstats = expand("results/03_Coverage/{sample}_{aligner}_{mincov}X_coverage-stats.tsv",
                          sample = SAMPLE, aligner = ALIGNER, mincov = MINCOV),
        consensus = expand("results/05_Consensus/{sample}_{aligner}_{mincov}X_consensus.fasta",
                           sample = SAMPLE, aligner = ALIGNER, mincov = MINCOV),
        pangolin = get_pangolin,
        nextclade = get_nextclade

###############################################################################
rule nextclade_lineage:
    # Aim: nextclade lineage assignation
    # Use: nextclade [QUERY.fasta] -t [THREADS] --outfile [NAME.csv]
    message:
        "Nextclade lineage assignation for {wildcards.sample} sample consensus ({wildcards.aligner}-{wildcards.mincov})"
    conda:
        NEXTCLADE
    resources:
        cpus = CPUS
    params:
        dataset = DATASET
    input:
        consensus = "results/05_Consensus/{sample}_{aligner}_{mincov}X_consensus.fasta"
    output:
        lineage = "results/06_Lineages/{sample}_{aligner}_{mincov}X_nextclade-report.tsv",
        alignment = directory("results/06_Lineages/{sample}_{aligner}_{mincov}X_nextclade-alignment/")
    log:
        "results/11_Reports/nextclade/{sample}_{aligner}_{mincov}X_lineage.log"
    shell:
        "nextclade "                       # Nextclade, assign queries sequences to clades and reports potential quality issues
        "run "                              # Run analyzis
        "--jobs {resources.cpus} "          # -j: Number of CPU threads used by the algorithm (default: the algorithm will use all the available threads)
        "--input-dataset {params.dataset} " # -raq: Path to a directory containing a dataset (root-seq, tree and qc-config required)
        "--output-tsv {output.lineage} "    # -t: Path to output TSV results file
        "--output-all {output.alignment} "  # -O: Produce all of the output files into this directory, using default basename
        "{input.consensus} "                # Path to a .fasta file with input sequences
        "&> {log}"                          # Log redirection

###############################################################################
rule pangolin_lineage:
    # Aim: lineage mapping
    # Use: pangolin [QUERY.fasta] -t [THREADS] --outfile [NAME.csv]
    message:
        "Pangolin lineage mapping for {wildcards.sample} sample consensus ({wildcards.aligner}-{wildcards.mincov})"
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
        "results/11_Reports/pangolin/{sample}_{aligner}_{mincov}X_lineage.log"
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
        "Sed rename header for {wildcards.sample} sample consensus fasta ({wildcards.aligner}-{wildcards.mincov})"
    input:
        constmp = "results/05_Consensus/{sample}_{aligner}_{mincov}X_consensus.fasta.tmp"
    output:
        consensus = "results/05_Consensus/{sample}_{aligner}_{mincov}X_consensus.fasta"
    log:
        "results/11_Reports/sed/{sample}_{aligner}_{mincov}X_fasta-header.log"
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
        "BcfTools consensus for {wildcards.sample} sample ({wildcards.aligner}-{wildcards.mincov})"
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
        "results/11_Reports/bcftools/{sample}_{aligner}_{mincov}X_consensus.log"
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
        "Tabix tab archive indexing for {wildcards.sample} sample ({wildcards.aligner}-{wildcards.mincov})"
    conda:
        SAMTOOLS
    input:
        archive = "results/04_Variants/{sample}_{aligner}_{mincov}X_variant-filt.vcf.bgz"
    output:
        index = temp("results/04_Variants/{sample}_{aligner}_{mincov}X_variant-filt.bgz.tbi")
    log:
        "results/11_Reports/tabix/{sample}_{aligner}_{mincov}X_variant-archive-index.log"
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
        "Bgzip variant block compressing for {wildcards.sample} sample ({wildcards.aligner}-{wildcards.mincov})"
    conda:
        SAMTOOLS
    resources:
        cpus = CPUS
    input:
        variantfilt = "results/04_Variants/{sample}_{aligner}_{mincov}X_variant-filt.vcf"
    output:
        archive = temp("results/04_Variants/{sample}_{aligner}_{mincov}X_variant-filt.vcf.bgz")
    log:
        "results/11_Reports/bgzip/{sample}_{aligner}_{mincov}X_variant-archive.log"
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
        "LoFreq filtering SNVs and Indels for {wildcards.sample} sample ({wildcards.aligner}-{wildcards.mincov})"
    conda:
        LOFREQ
    params:
        mincov = MINCOV,
        minaf = MINAF
    input:
        variantcall = "results/04_Variants/{sample}_{aligner}_{mincov}X_variant-call.vcf"
    output:
        variantfilt = "results/04_Variants/{sample}_{aligner}_{mincov}X_variant-filt.vcf"
    log:
        "results/11_Reports/lofreq/{sample}_{aligner}_{mincov}X_variant-filt.log"
    shell:
        "lofreq "                    # LoFreq, fast and sensitive inference of SNVs and indels
        "filter "                     # Filter SNVs and Indels parsed from vcf file
        "--cov-min {params.mincov} "  # -v: Minimum coverage allowed (INT)
        "--af-min {params.minaf} "    # -a: Minimum allele freq allowed (FLOAT)
        "--in {input.variantcall} "   # VCF input file, gzip suuported, no streaming supported
        "--out {output.variantfilt} " # VCF output file, gzip supported (default: standard output)
        "&> {log}"                    # Log redirection 

###############################################################################
rule lofreq_variant_calling:
    # Aim: SNVs and Indels calling
    # Use: lofreq call-parallel --pp-threads [THREADS] --call-indels -f [MASKEDREF.fasta] -o [INDEL.vcf] [INDEL.bam]
    message:
        "LoFreq calling SNVs and Indels for {wildcards.sample} sample ({wildcards.aligner}-{wildcards.mincov})"
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
        "results/11_Reports/lofreq/{sample}_{aligner}_{mincov}X_variant-call.log"
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
        "SamTools indexing indel qualities BAM file {wildcards.sample} sample ({wildcards.aligner}-{wildcards.mincov})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
    input:
        indelqual = "results/04_Variants/{sample}_{aligner}_{mincov}X_indel-qual.bam"
    output:
        index = "results/04_Variants/{sample}_{aligner}_{mincov}X_indel-qual.bai"
    log:
        "results/11_Reports/samtools/{sample}_{aligner}_{mincov}X_indel-qual-index.log"
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
        "LoFreq insert indels qualities for {wildcards.sample} sample ({wildcards.aligner}-{wildcards.mincov})"
    conda:
        LOFREQ
    input:
        maskedref = "results/04_Variants/{sample}_{aligner}_{mincov}X_masked-ref.fasta",
        markdup = "results/02_Mapping/{sample}_{aligner}_mark-dup.bam"
    output:
        indelqual = "results/04_Variants/{sample}_{aligner}_{mincov}X_indel-qual.bam"
    log:
        "results/11_Reports/lofreq/{sample}_{aligner}_{mincov}X_indel-qual.log"
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
        "BedTools masking low coverage regions for {wildcards.sample} sample ({wildcards.aligner}-{wildcards.mincov})"
    conda:
        BEDTOOLS
    params:
        genomes = GENOMES,
        reference = REFERENCE
    input:
        lowcovmask = "results/03_Coverage/{sample}_{aligner}_{mincov}X_low-cov-mask.bed"
    output:
        maskedref = "results/04_Variants/{sample}_{aligner}_{mincov}X_masked-ref.fasta"
    log:
        "results/11_Reports/bedtools/{sample}_{aligner}_{mincov}X_masking.log"
    shell:
        "bedtools maskfasta "                          # Bedtools maskfasta, mask a fasta file based on feature coordinates
        "-fi {params.genomes}{params.reference}.fasta " # Input FASTA file 
        "-bed {input.lowcovmask} "                      # BED/GFF/VCF file of ranges to mask in -fi
        "-fo {output.maskedref} "                       # Output masked FASTA file
        "&> {log}"                                      # Log redirection 

###############################################################################
rule bedtools_merged_mask:
    # Aim: merging overlaps
    # Use: bedtools merge [OPTIONS] -i [FILTERED.bed] -g [GENOME.fasta] 
    message:
        "BedTools merging overlaps for {wildcards.sample} sample ({wildcards.aligner}-{wildcards.mincov})"
    conda:
        BEDTOOLS
    input:
        mincovfilt = "results/03_Coverage/{sample}_{aligner}_{mincov}X_min-cov-filt.bed"
    output:
        lowcovmask = temp("results/03_Coverage/{sample}_{aligner}_{mincov}X_low-cov-mask.bed")
    log:
        "results/11_Reports/bedtools/{sample}_{aligner}_{mincov}X_merging.log"
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
        "Awk minimum coverage filtration for {wildcards.sample} sample ({wildcards.aligner}-{wildcards.mincov})"
    conda:
        GAWK
    params:
        mincov = MINCOV
    input:
        genomecov = "results/03_Coverage/{sample}_{aligner}_genome-cov.bed"
    output:
        mincovfilt = temp("results/03_Coverage/{sample}_{aligner}_{mincov}X_min-cov-filt.bed")
    log:
        "results/11_Reports/awk/{sample}_{aligner}_{mincov}X_min-cov-filt.log"
    shell:
        "awk "                      # Awk, a program that you can use to select particular records in a file and perform operations upon them
        "'$4 < {params.mincov}' "    # Minimum coverage for masking regions in consensus sequence
        "{input.genomecov} "         # BedGraph coverage input
        "1> {output.mincovfilt} "    # Minimum coverage filtered bed output
        "2> {log} "                  # Log redirection

###############################################################################
rule awk_coverage_statistics:
    # Aim: computing genomme coverage stats
    # Use: awk {FORMULA} END {{print [RESULTS.tsv] [BEDGRAPH.bed]
    message:
        "Awk compute genome coverage statistics BED {wildcards.sample} sample ({wildcards.aligner}-{wildcards.mincov})"
    conda:
        GAWK
    params:
        mincov = MINCOV
    input:
        genomecov = "results/03_Coverage/{sample}_{aligner}_genome-cov.bed"
    output:
        covstats = "results/03_Coverage/{sample}_{aligner}_{mincov}X_coverage-stats.tsv"
    log:
        "results/11_Reports/awk/{sample}_{aligner}_{mincov}X_coverage-stats.log"
    shell:
        "awk ' "                                  # Awk, a program that you can use to select particular records in a file and perform operations upon them
        "$4 >= {params.mincov} "                   # Minimum coverage
        "{{supMinCov+=$3-$2}} ; "                  # Genome size >= @ mincov X
        "{{genomeSize+=$3-$2}} ; "                 # Genome size
        "{{totalBases+=($3-$2)*$4}} ; "            # Total bases @ 1 X 
        "{{totalBasesSq+=(($3-$2)*$4)**2}} "       # Total bases square @ 1 X
        "END "                                     # End
        "{{print "                                 # Print
        """ "sample_id", "\t", """                 # Sample ID header
        """ "mean_depth", "\t", """                # Mean depth header
        """ "standard_deviation", "\t", """        # Standard deviation header
        """ "cov_percent_@{wildcards.mincov}X" """ # Coverage percent @ mincov X header
        "ORS "                                     # \n newline
        """ "{wildcards.sample}", "\t", """        # Sample ID value
        """ int(totalBases/genomeSize), "\t", """  # Mean depth value
        """ int(sqrt((totalBasesSq/genomeSize)-(totalBases/genomeSize)**2)), "\t", """ # Standard deviation value
        """ supMinCov/genomeSize*100 """           # Coverage percent @ mincov X value
        "}}' "                                     #
        "{input.genomecov} "                       # BedGraph coverage input
        "1> {output.covstats} "                    # Mean depth output
        "2> {log}"                                 # Log redirection

###############################################################################
rule bedtools_genome_coverage:
    # Aim: computing genome coverage sequencing
    # Use: bedtools genomecov [OPTIONS] -ibam [MARKDUP.bam] 1> [BEDGRAPH.bed]
    message:
        "BedTools computing genome coverage for {wildcards.sample} sample against reference genome sequence ({wildcards.aligner})"
    conda:
        BEDTOOLS
    input:
        markdup = "results/02_Mapping/{sample}_{aligner}_mark-dup.bam",
        index = "results/02_Mapping/{sample}_{aligner}_mark-dup.bai"
    output:
        genomecov = temp("results/03_Coverage/{sample}_{aligner}_genome-cov.bed")
    log:
        "results/11_Reports/bedtools/{sample}_{aligner}_genome-cov.log"
    shell:
        "bedtools genomecov "    # Bedtools genomecov, compute the coverage of a feature file among a genome
        "-bga "                   # Report depth in BedGraph format, regions with zero coverage are also reported
        "-ibam {input.markdup} "  # The input file is in BAM format, must be sorted by position
        "1> {output.genomecov} "  # BedGraph output
        "2> {log} "               # Log redirection

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
        index = "results/02_Mapping/{sample}_{aligner}_mark-dup.bai"
    log:
        "results/11_Reports/samtools/{sample}_{aligner}_mark-dup-index.log"
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
        "results/11_Reports/samtools/{sample}_{aligner}_mark-dup.log"
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
        "results/11_Reports/samtools/{sample}_{aligner}_sorted.log"
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
        "results/11_Reports/samtools/{sample}_{aligner}_fixmate.log"
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
        "results/11_Reports/samtools/{sample}_{aligner}_sort-by-names.log"
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
        indexbwa = INDEXBWA,
        reference = REFERENCE
    input:
        fwdreads = "results/01_Trimming/sickle/{sample}_sickle-trimmed_R1.fastq.gz",
        revreads = "results/01_Trimming/sickle/{sample}_sickle-trimmed_R2.fastq.gz"
    output:
        mapped = temp("results/02_Mapping/{sample}_bwa-mapped.sam")
    log:
        "results/11_Reports/bwa/{sample}.log"
    shell:
        "bwa mem "                            # BWA-MEM algorithm, performs local alignment.
        "-t {resources.cpus} "                 # -t: Number of threads (default: 12)
        "-v 1 "                                # -v: Verbosity level: 1=error, 2=warning, 3=message, 4+=debugging
        "{params.indexbwa}{params.reference} " # Reference index filename prefix
        "{input.fwdreads} "                    # Forward input reads
        "{input.revreads} "                    # Reverse input reads
        "1> {output.mapped} "                  # SAM output
        "2> {log}"                             # Log redirection 

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
        indexbt2 = INDEXBT2,
        reference = REFERENCE,
        sensitivity = SENSITIVITY
    input:
        fwdreads = "results/01_Trimming/sickle/{sample}_sickle-trimmed_R1.fastq.gz",
        revreads = "results/01_Trimming/sickle/{sample}_sickle-trimmed_R2.fastq.gz"
    output:
        mapped = temp("results/02_Mapping/{sample}_bowtie2-mapped.sam")
    log:
        "results/11_Reports/bowtie2/{sample}.log"
    shell:
        "bowtie2 "                    # Bowtie2, an ultrafast and memory-efficient tool for aligning sequencing reads to long reference sequences.
        "--threads {resources.cpus} "  # -p: Number of alignment threads to launch (default: 1)
        "--reorder "                   # Keep the original read order (if multi-processor option -p is used)
        "-x {params.indexbt2}{params.reference} " # -x: Reference index filename prefix (minus trailing .X.bt2) [Bowtie-1 indexes are not compatible]
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
        fwdreads = "results/01_Trimming/sickle/{sample}_sickle-trimmed_R1.fastq.gz",
        revreads = "results/01_Trimming/sickle/{sample}_sickle-trimmed_R2.fastq.gz",
        single = temp("results/01_Trimming/sickle/{sample}_sickle-trimmed_SE.fastq.gz")
    log:
        "results/11_Reports/sickle-trim/{sample}.log"
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
        "results/11_Reports/cutadapt/{sample}.log"
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
rule multiqc_reports_aggregation:
    # Aim: aggregates bioinformatics analyses results into a single report
    # Use: multiqc [OPTIONS] --output [MULTIQC/] [FASTQC/] [MULTIQC/]
    priority: 42
    message:
        "MultiQC reports aggregating"
    conda:
        MULTIQC
    input:
        fastqc = "results/00_Quality_Control/fastqc/",
        fastqscreen = "results/00_Quality_Control/fastq-screen/"
    output:
        multiqc = directory("results/00_Quality_Control/multiqc/")
    log:
        "results/11_Reports/quality/multiqc.log"
    shell:
        "multiqc "                  # Multiqc, searches in given directories for analysis & compiles a HTML report
        "--quiet "                   # -q: Only show log warning
        "--outdir {output.multiqc} " # -o: Create report in the specified output directory
        "{input.fastqc} "            # Input FastQC files
        "{input.fastqscreen} "       # Input Fastq-Screen
        "--no-ansi "                 # Disable coloured log
        "&> {log}"                   # Log redirection

###############################################################################
rule fastqscreen_contamination_checking:
    # Aim: screen if the composition of the library matches with  what you expect
    # Use fastq_screen [OPTIONS] --outdir [DIR/] [SAMPLE_1.fastq] ... [SAMPLE_n.fastq]
    message:
        "Fastq-Screen reads contamination checking"
    conda:
        FASTQSCREEN
    resources:
        cpus = CPUS
    params:
        config = CONFIG,
        mapper = MAPPER,
        subset = SUBSET
    input:
        fastq = "resources/reads/"
    output:
        fastqscreen = directory("results/00_Quality_Control/fastq-screen/")
    log:
        "results/11_Reports/quality/fastq-screen.log"
    shell:
        "fastq_screen "                 # FastqScreen, what did you expect ?
        "-q "                            # --quiet: Only show log warning
        "--threads {resources.cpus} "    # --threads: Specifies across how many threads bowtie will be allowed to run
        "--conf {params.config} "        # path to configuration file
        "--aligner {params.mapper} "     # -a: choose aligner 'bowtie', 'bowtie2', 'bwa'
        "--subset {params.subset} "      # Don't use the whole sequence file, but create a subset of specified size
        "--outdir {output.fastqscreen} " # Output directory
        "{input.fastq}/*.fastq.gz "      # Input file.fastq
        "&> {log}"                       # Log redirection

###############################################################################
rule fastqc_quality_control:
    # Aim: reads sequence files and produces a quality control report
    # Use: fastqc [OPTIONS] --output [DIR/] [SAMPLE_1.fastq] ... [SAMPLE_n.fastq]
    message:
        "FastQC reads quality controling"
    conda:
        FASTQC
    resources:
        cpus = CPUS
    input:
        fastq = "resources/reads/"
    output:
        fastqc = directory("results/00_Quality_Control/fastqc/")
    log:
        "results/11_Reports/quality/fastqc.log"
    shell:
        "mkdir -p {output.fastqc} " # (*) this directory must exist as the program will not create it
        "2> /dev/null && "          # in silence and then... 
        "fastqc "                    # FastQC, a high throughput sequence QC analysis tool
        "--quiet "                    # -q: Supress all progress messages on stdout and only report errors
        "--threads {resources.cpus} " # -t: Specifies files number which can be processed simultaneously
        "--outdir {output.fastqc} "   # -o: Create all output files in the specified output directory (*)
        "{input.fastq}/*.fastq.gz "   # Input file.fastq
        "&> {log}"                    # Log redirection

###############################################################################
