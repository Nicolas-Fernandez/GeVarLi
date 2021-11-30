###############################################################################
# Name: GeVarLi pipeline
# Author: Nicolas Fernandez
# Affiliation: IRD_U233_TransVIHMI
# Aim: SARS-CoV-2 Genome assembling, Variant and Lineage (pangolin) calling
# Date: 2021.10.12
# Run: snakemake --use-conda -s gevarli.smk --cores 
# Latest modification: 2021.11.26
# Todo: ...

###############################################################################
# PUBLICATIONS #



###############################################################################
# CONFIGURATION #
configfile: "config/config.yaml"

# FUNCTIONS #

# WILDCARDS #
SAMPLE, = glob_wildcards("resources/reads/{sample}_R1.fastq.gz")

# ENVIRONMENTS #
CUTADAPT = config["conda"]["cutadapt"]      # Cutadapt
SICKLETRIM = config["conda"]["sickle-trim"] # Sickle-trim

FASTQC = config["conda"]["fastqc"]            # FastQC
FASTQSCREEN = config["conda"]["fastq-screen"] # Fastq-Screen
MULTIQC = config["conda"]["multiqc"]          # MultiQC

BOWTIE2 = config["conda"]["bowtie2"]  # Bowtie2
BWA = config["conda"]["bwa"]          # Bwa

SAMTOOLS = config["conda"]["samtools"] # SamTools
BEDTOOLS = config["conda"]["bedtools"] # BedYools
BCFTOOLS = config["conda"]["bcftools"] # BcfTools

LOFREQ = config["conda"]["lofreq"] # LoFreq

PANGOLIN = config["conda"]["pangolin"] # Pangolin

# RESOURCES #
CPUS = config["resources"]["cpus"]     # resources thread
MEM_GB = config["resources"]["mem_gb"] # resources mem in Gb
TMPDIR = config["resources"]["tmpdir"] # resources temporary directory

# PATRAMETERS #
LENGTHC = config["cutadapt"]["length"]          # Cutadapt --minimum-length
TRUSEQ = config["cutadapt"]["kits"]["truseq"]   # Cutadapt --adapter Illumina TruSeq
NEXTERA = config["cutadapt"]["kits"]["nextera"] # Cutadapt --adapter Illumina Nextera
SMALL = config["cutadapt"]["kits"]["small"]     # Cutadapt --adapter Illumina Small

COMMAND = config["sickle-trim"]["command"]   # Sickle-trim command
ENCODING = config["sickle-trim"]["encoding"] # Sickle-trim --qual-type 
QUALITY = config["sickle-trim"]["quality"]   # Sickle-trim --qual-threshold
LENGTHS = config["sickle-trim"]["length"]    # Sickle-trim --length-treshold

CONFIG = config["fastq-screen"]["config"]   # Fastq-screen --conf
ALIGNER = config["fastq-screen"]["aligner"] # Fastq-screen --aligner
SUBSET = config["fastq-screen"]["subset"]   # Fastq-screen --subset

MAPPER = config["mapper"] # Mappers (bowtie2 and/or bwa)

INDEXBT2 = config["bowtie2"]["index"]          # bowtie2 path to indexed genome reference
SENSITIVITY = config["bowtie2"]["sensitivity"] # bowtie2 sensitivity preset
INDEXBWA = config["bwa"]["index"]              # bwa path to indexed genome reference

REFERENCE = config["consensus"]["reference"] # Genome reference fasta sequence
MINCOV = config["consensus"]["mincov"]       # Minimum coverage for masking regions in consensus sequence

COVMIN = config["indel"]["covmin"] # Minimum coverage allowed
AFMIN = config["indel"]["afmin"]   # Minimum allele freq allowed

###############################################################################
rule all:
    input:
        lineage = expand("results/pangolin/{sample}_{mapper}_{mincov}_lineage_report.csv",
                         mincov = MINCOV, sample = SAMPLE, mapper = MAPPER),
        multiqc = "results/quality/multiqc/"
        
###############################################################################
rule pangolin_lineage:
    # Aim: lineage mapping
    # Use: pangolin [QUERY.fasta] -t [THREADS] --outfile [NAME.csv]
    message:
        "Pangolin lineage mapping for {wildcards.sample} sample consensus ({wildcards.mapper})"
    conda:
        PANGOLIN
    resources:
        cpus = CPUS
    params:
        tmpdir = TMPDIR
    input:
        consensus = "results/bcftools/{sample}_{mapper}_{mincov}_consensus.fasta"
    output:
        lineage = "results/pangolin/{sample}_{mapper}_{mincov}_lineage_report.csv"
    log:
        "results/reports/pangolin/{sample}_{mapper}_{mincov}_lineage.log"
    shell:
        "pangolin "                   # Pangolinn Phylogenetic Assignment of Named Global Outbreak LINeages
        "{input.consensus} "          # Query fasta file of sequences to analyse
        "--threads {resources.cpus} " # -t: Number of threads
        "--tempdir {params.tmpdir} "  # Specify where you want the temp stuff to go (Default: $TMPDIR)
        "--outfile {output.lineage} " # Optional output file name (default: lineage_report.csv)
        "&> {log}"                    # Add redirection for log

###############################################################################
rule bcftools_consensus:
    # Aim: create consensus
    # Use: bcftools consensus -f [REFERENCE] [.vcf.gz] -o [CONSENSUS.fasta] 
    message:
        "BcfTools consensus for {wildcards.sample} sample ({wildcards.mapper})"
    conda:
        BCFTOOLS
    params:
        reference = REFERENCE
    input:
        indelfilt = "results/{mincov}/indel/{sample}_{mapper}_indelfilt.vcf.bgz",
        index = "results/{mincov}/indel/{sample}_{mapper}_indelfilt.tbi"
    output:
        consensus = "results/bcftools/{sample}_{mapper}_{mincov}_consensus.fasta"
    log:
        "results/reports/bcftools/{sample}_{mapper}_{mincov}_consensus.log"
    shell:
        "bcftools "                       # Bcftools, tools for variant calling and manipulating VCFs and BCFs
        "consensus "                      # Create consensus sequence by applying VCF variants to a reference fasta file
        "--fasta-ref {params.reference} " # -f: reference sequence in fasta format
        "{input.indelfilt} "              # VCF variants file
        "--output {output.consensus} "    # -o: write output to a file (default: standard output)
        "2> {log}"                        # Add redirection for log

###############################################################################
rule tabix_tabarch_indexing:
    # Aim: tab archive indexing
    # Use: tabix [OPTIONS] [TAB.bgz]
    message:
        "Tabix tab archive indexing for {wildcards.sample} sample ({wildcards.mapper})"
    conda:
        SAMTOOLS
    input:
        bgzip = "results/{mincov}/indel/{sample}_{mapper}_indelfilt.vcf.bgz"
    output:
        index = "results/{mincov}/indel/{sample}_{mapper}_indelfilt.tbi"
    log:
        "results/{mincov}/reports/tabix/{sample}_{mapper}_indelarch-index.log"
    shell:
        "tabix "             # Tabix, indexes a TAB-delimited genome position file in.tab.bgz and creates an index file
        "{input.bgzip} "     # The input data file must be position sorted and compressed by bgzip
        "1> {output.index} " # Tabix output TBI index formats
        "2> {log}"           # Add redirection for log 

###############################################################################
rule bgzip_indel_compressing:
    # Aim: indel block compressing
    # Use: bgzip [OPTIONS] -c -@ [THREADS] [INDEL.vcf] 1> [COMPRESS.vcf.bgz]
    message:
        "Bgzip indel block compressing for {wildcards.sample} sample ({wildcards.mapper})"
    conda:
        SAMTOOLS
    resources:
        cpus = CPUS
    input:
        indelfilt = "results/{mincov}/indel/{sample}_{mapper}_indelfilt.vcf"
    output:
        bgzip = "results/{mincov}/indel/{sample}_{mapper}_indelfilt.vcf.bgz"
    log:
        "results/{mincov}/reports/bgzip/{sample}_{mapper}_indel-bgz.log"
    shell:
        "bgzip "                      # Bgzip, block compression/decompression utility
        "--stdout "                   # -c: Write to standard output, keep original files unchanged
        "--threads {resources.cpus} " # -@: Number of threads to use (default: 1)
        "{input.indelfilt} "          # VCF input file, gzip suuported, no streaming supported
        "1> {output.bgzip} "          # VCF output file, gzip supported (default: standard output)
        "2> {log}"                    # Add redirection for log 

###############################################################################
rule lofreq_indel_filtering:
    # Aim: variants filtering in VCF file
    # Use: lofreq filter [OPTIONS] -i [INDEL.vcf] -o [INDELFILT.vcf]
    # Note: without --no-defaults LoFreq's predefined filters are on
    message:
        "LoFreq filtering variants for {wildcards.sample} sample ({wildcards.mapper})"
    conda:
        LOFREQ
    params:
        covmin = COVMIN,
        afmin = AFMIN
    input:
        indelcall = "results/{mincov}/indel/{sample}_{mapper}_indelcall.vcf"
    output:
        indelfilt = "results/{mincov}/indel/{sample}_{mapper}_indelfilt.vcf"
    log:
        "results/{mincov}/reports/lofreq/{sample}_{mapper}_indelfilt.log"
    shell:
        "lofreq "                    # LoFreq, fast and sensitive inference of SNVs and indels
        "filter "                    # Filter variant parsed from vcf file
        "--cov-min {params.covmin} " # -v: Minimum coverage allowed (<1=off) (INT)
        "--af-min {params.afmin} "   # -a: Minimum allele freq allowed (<1=off) (FLOAT)
        "--in {input.indelcall} "    # VCF input file, gzip suuported, no streaming supported
        "--out {output.indelfilt} "  # VCF output file, gzip supported (default: standard output)
        "&> {log}"                   # Add redirection for log 

###############################################################################
rule lofreq_indel_calling:
    # Aim: variants calling
    # Use: lofreq call-parallel --pp-threads [THREADS] --call-indels -f [REFERENCE.fasta] -o [INDEL.vcf] [INDEL.bam]
    message:
        "LoFreq calling variants for {wildcards.sample} sample ({wildcards.mapper})"
    conda:
        LOFREQ
    resources:
        cpus = CPUS
    input:
        maskedref = "results/{mincov}/bedtools/{sample}_{mapper}_maskedref.fasta",
        indelqual = "results/{mincov}/indel/{sample}_{mapper}_indelqual.bam",
        index = "results/{mincov}/indel/{sample}_{mapper}_indelqual.bai"
    output:
        indelcall = "results/{mincov}/indel/{sample}_{mapper}_indelcall.vcf"
    log:
        "results/{mincov}/reports/lofreq/{sample}_{mapper}_indelcall.log"
    shell:
        "lofreq "                        # LoFreq, fast and sensitive inference of SNVs and indels
        "call-parallel "                 # Call variants from BAM file
        "--pp-threads {resources.cpus} " # Number of threads (required)
        "--call-indels "                 # Enable indel calls (note: preprocess your file to include indel alignment qualities!)
        "--ref {input.maskedref} "       # -f: Indexed reference fasta file (gzip supported)
        "--out {output.indelcall} "      # -o: Indel VCF file output (default: standard output)
        "{input.indelqual} "             # Indel BAM input
        "&> {log}"                       # Add redirection for log 

###############################################################################
rule samtools_indel_indexing: 
    # Aim: indexing insertion/deletion qualities BAM file
    # Use: samtools index -@ [THREADS] -b [INDELQUAL.bam] [INDEX.bai]
    message:
        "SamTools indexing insertion/deletion qualities BAM file {wildcards.sample} sample ({wildcards.mapper})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
    input:
        indelqual = "results/{mincov}/indel/{sample}_{mapper}_indelqual.bam"
    output:
        index = "results/{mincov}/indel/{sample}_{mapper}_indelqual.bai"
    log:
        "results/reports/{mincov}/samtools/{sample}_{mapper}_indelqual-index.log"
    shell:
        "samtools index "             # Samtools index, tools for alignments in the SAM format with command to index alignment
        "-@ {resources.cpus} "        # --threads: Number of additional threads to use (default: 0)
        "-b "                         # -b: Generate BAI-format index for BAM files (default)
        "{input.indelqual} "          # Sorted bam input
        "{output.index} "             # Markdup bam output
        "&> {log}"                    # Add redirection for log 

###############################################################################
rule lofreq_indel_qualities:
    # Aim: insertion/deletion qualities 
    # Use: lofreq indelqual --dindel -f [REFERENCE.fasta] -o [INDEL.bam] [MARKDUP.bam]
    # Note: do not realign your BAM file afterwards!
    message:
        "LoFreq insertion/deletion qualities for {wildcards.sample} sample ({wildcards.mapper})"
    conda:
        LOFREQ
    input:
        maskedref = "results/{mincov}/bedtools/{sample}_{mapper}_maskedref.fasta",
        markdup = "results/samtools/{sample}_{mapper}_markdup.bam"
    output:
        indelqual = "results/{mincov}/indel/{sample}_{mapper}_indelqual.bam"
    log:
        "results/reports/{mincov}/lofreq/{sample}_{mapper}_indelqual.log"
    shell:
        "lofreq "                     # LoFreq, fast and sensitive inference of SNVs and indels 
        "indelqual "                  # Insert indel qualities into BAM file (required for indel predictions)
        "--dindel "                   # Add Dindel's indel qualities Illumina specifics (need --ref and clashes with -u)
        "--ref {input.maskedref} "    # -f: Reference (masked) sequence used for mapping (only required for --dindel)
        "--out {output.indelqual} "   # -o: Indel BAM file output (default: standard output)
        "{input.markdup} "            # Markdup BAM input
        "&> {log}"                    # Add redirection for log 

###############################################################################
rule bedtools_masking:
    # Aim: masking low coverage regions
    # Use: bedtools maskfasta [OPTIONS] -fi [REFERENCE.fasta] -bed [RANGE.bed] -fo [MASKED.fasta] 
    message:
        "BedTools masking low coverage regions for {wildcards.sample} sample ({wildcards.mapper})"
    conda:
        BEDTOOLS
    params:
        reference = REFERENCE
    input:
        lowcovmask = "results/{mincov}/bedtools/{sample}_{mapper}_lowcovmask.bed"
    output:
        maskedref = "results/{mincov}/bedtools/{sample}_{mapper}_maskedref.fasta"
    log:
        "results/{mincov}/reports/bedtools/{sample}_{mapper}_masking.log"
    shell:
        "bedtools maskfasta "      # Bedtools maskfasta, mask a fasta file based on feature coordinates
        "-fi {params.reference} "  # Input FASTA file 
        "-bed {input.lowcovmask} " # BED/GFF/VCF file of ranges to mask in -fi
        "-fo {output.maskedref} "  # Output masked FATSA file
        "&> {log}"                 # Add redirection for log 

###############################################################################
rule bedtools_merge:
    # Aim: merging overlaps
    # Use: bedtools merge [OPTIONS] -i [FILTERED.bed] -g [GENOME.fasta] 
    message:
        "BedTools merging overlaps for {wildcards.sample} sample ({wildcards.mapper})"
    conda:
        BEDTOOLS
    input:
        mincovfilt = "results/{mincov}/bedtools/{sample}_{mapper}_mincovfilt.bed"
    output:
        lowcovmask = "results/{mincov}/bedtools/{sample}_{mapper}_lowcovmask.bed"
    log:
        "results/{mincov}/reports/bedtools/{sample}_{mapper}_merging.log"
    shell:
        "bedtools merge "         # Bedtools merge, merges overlapping BED/GFF/VCF entries into a single interval
        "-i {input.mincovfilt} "  # -i: BED/GFF/VCF input to merge 
        "1> {output.lowcovmask} " # merged output
        "2> {log}"                # Add redirection for log

###############################################################################
rule awk_mincovfilt:
    # Aim: minimum coverage filtration
    # Use: awk '$4 < [MINCOV]' [BED] 1> [FILTERED]
    message:
        "Awk minimum coverage filtration for {wildcards.sample} sample ({wildcards.mapper})"
    params:
        #mincov = MINCOV
    input:
        genomecov = "results/bedtools/{sample}_{mapper}_genomecov.bed"
    output:
        mincovfilt = "results/{mincov}/bedtools/{sample}_{mapper}_mincovfilt.bed"
    log:
        "results/{mincov}/reports/bedtools/{sample}_{mapper}_mincovfilt.log"
    shell:
        "awk "                       # Awk, a program that you can use to select particular records in a file and perform operations upon them
        "'$4 < {wildcards.mincov}' " # Minimum coverage for masking regions in consensus sequence (default: 10)
        "{input.genomecov} "         # BedGraph coverage input
        "1> {output.mincovfilt} "    # Minimum coverage filtered bed output
        "2> {log} "                  # Add redirection for log

###############################################################################
rule bedtools_genomecov:
    # Aim: computing genome coverage
    # Use: bedtools genomecov [OPTIONS] -ibam [MARKDUP.bam]
    message:
        "BedTools computing genome coverage for {wildcards.sample} sample against reference genome sequence ({wildcards.mapper})"
    conda:
        BEDTOOLS
    input:
        markdup = "results/samtools/{sample}_{mapper}_markdup.bam",
        index = "results/samtools/{sample}_{mapper}_markdup.bai"
    output:
        genomecov = "results/bedtools/{sample}_{mapper}_genomecov.bed"
    log:
        "results/reports/bedtools/{sample}_{mapper}_genomecov.log"
    shell:
        "bedtools genomecov "     # Bedtools genomecov, compute the coverage of a feature file among a genome
        "-ibam {input.markdup} "  # The input file is in BAM format, must be sorted by position
        "-bga {output.genomecov}" # Report depth in BedGraph format, regions with zero coverage are also reported
        "&> {log} "               # Add redirection for log

###############################################################################
rule samtools_index_markdup: 
    # Aim: indexing marked as duplicate BAM file
    # Use: samtools index -@ [THREADS] -b [MARKDUP.bam] [INDEX.bai]
    message:
        "SamTools indexing marked as duplicate BAM file {wildcards.sample} sample ({wildcards.mapper})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
    input:
        markdup = "results/samtools/{sample}_{mapper}_markdup.bam"
    output:
        index = "results/samtools/{sample}_{mapper}_markdup.bai"
    log:
        "results/reports/samtools/{sample}_{mapper}_markdup-index.log"
    shell:
        "samtools index "             # Samtools index, tools for alignments in the SAM format with command to index alignment
        "-@ {resources.cpus} "        # --threads: Number of additional threads to use (default: 1)
        "-b "                         # -b: Generate BAI-format index for BAM files (default)
        "{input.markdup} "            # Sorted bam input
        "{output.index} "             # Markdup bam output
        "&> {log}"                    # Add redirection for log 

###############################################################################
rule samtools_markdup: 
    # Aim: marking duplicate alignments
    # Use: samtools markdup -@ [THREADS] -r -s -O BAM [SORTED.bam] [MARKDUP.bam] 
    message:
        "SamTools marking duplicate alignments for {wildcards.sample} sample ({wildcards.mapper})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
    input:
        sorted = "results/samtools/{sample}_{mapper}_sorted.bam"
    output:
        markdup = "results/samtools/{sample}_{mapper}_markdup.bam"
    log:
        "results/reports/samtools/{sample}_{mapper}_markdup.log"
    shell:
        "samtools markdup "           # Samtools markdup, tools for alignments in the SAM format with command mark duplicates
        "--threads {resources.cpus} " # -@: Number of additional threads to use (default: 1)
        "-r "                         # -r: Remove duplicate reads
        "-s "                         # -s: Report stats
        "--output-fmt BAM "           # -O: Specify output format: SAM, BAM, CRAM (here, BAM format)
        "{input.sorted} "             # Sorted bam input
        "{output.markdup} "           # Markdup bam output
        "&> {log}"                    # Add redirection for log 

###############################################################################
rule samtools_sorting: 
    # Aim: sorting
    # Use: samtools sort -@ [THREADS] -m [MEM] -T [TMPDIR] -O BAM -o [SORTED.bam] [FIXMATE.bam] 
    message:
        "SamTools sorting {wildcards.sample} sample reads ({wildcards.mapper})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS,
       mem_gb = MEM_GB
    params:
        tmpdir = TMPDIR
    input:
        fixmate = "results/samtools/{sample}_{mapper}_fixmate.bam"
    output:
        sorted = "results/samtools/{sample}_{mapper}_sorted.bam"
    log:
        "results/reports/samtools/{sample}_{mapper}_sorting.log"
    shell:
        "samtools sort "               # Samtools sort, tools for alignments in the SAM format with command to sort alignment file
        "--threads {resources.cpus} "  # -@: Number of additional threads to use (default: 1)
        "-m {resources.mem_gb}G "      # -m: Set maximum memory per thread, suffix K/M/G recognized (default: 768M)
        "-T {params.tmpdir} "          # -T: Write temporary files to PREFIX.nnnn.bam
        "--output-fmt BAM "            # -O: Specify output format: SAM, BAM, CRAM (here, BAM format)
        "-o {output.sorted} "          # Sorted bam output
        "{input.fixmate} "             # Fixmate bam input
        "&> {log}"                     # Add redirection for log 

###############################################################################
rule samtools_fixmate: 
    # Aim: filling in mate coordinates
    # Use: samtools fixmate -@ [THREADS] -m -O BAM [SORTBYNAMES.bam] [FIXMATE.bam] 
    message:
        "SamTools filling in mate coordinates {wildcards.sample} sample reads ({wildcards.mapper})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS
    input:
        sortbynames = "results/samtools/{sample}_{mapper}_sortbynames.bam"
    output:
        fixmate = "results/samtools/{sample}_{mapper}_fixmate.bam"
    log:
        "results/reports/samtools/{sample}_{mapper}_fixmate.log"
    shell:
        "samtools fixmate "            # Samtools fixmate, tools for alignments in the SAM format with command to fix mate information
        "--threads {resources.cpus} "  # -@: Number of additional threads to use (default: 1)
        "-m "                          # -m: Add mate score tag 
        "--output-fmt BAM "            # -O: Specify output format: SAM, BAM, CRAM (here, BAM format)
        "{input.sortbynames} "         # Sortbynames bam input
        "{output.fixmate} "            # Fixmate bam output 
        "&> {log}"                     # Add redirection for log 

###############################################################################
rule samtools_sortbynames: 
    # Aim: sorting by names
    # Use: samtools sort -t [THREADS] -n -O BAM -o [SORTBYNAMES.bam] [MAPPED.sam]
    message:
        "SamTools sorting by names {wildcards.sample} sample reads ({wildcards.mapper})"
    conda:
        SAMTOOLS
    resources:
       cpus = CPUS,
       mem_gb = MEM_GB
    input:
        mapped = "results/{mapper}/{sample}_mapped.sam"
    output:
        sortbynames = "results/samtools/{sample}_{mapper}_sortbynames.bam"
    log:
        "results/reports/samtools/{sample}_{mapper}_names-sorting.log"
    shell:
        "samtools sort "               # Samtools sort, tools for alignments in the SAM format with command to sort alignment file
        "--threads {resources.cpus} "  # -@: Number of additional threads to use (default: 1)
        "-m {resources.mem_gb}G "      # -m: Set maximum memory per thread, suffix K/M/G recognized (default: 768M)
        "-n "                          # -n: Sort by read name (not compatible with samtools index command) 
        "--output-fmt BAM "            # -O: Specify output format: SAM, BAM, CRAM (here, BAM format)
        "-o {output.sortbynames} "     # -o: Write final output to FILE rather than standard output
        "{input.mapped} "              # Mapped reads input
        "&> {log}"                     # Add redirection for log 

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
        indexbwa = INDEXBWA
    input:
        forward = "results/reads/sickle/{sample}_quality-trimmed_R1.fastq.gz",
        reverse = "results/reads/sickle/{sample}_quality-trimmed_R2.fastq.gz"
    output:
        mapped = "results/bwa/{sample}_mapped.sam"
    log:
        "results/reports/bwa/{sample}_mapping.log"
    shell:
        "bwa mem "            # BWA-MEM algorithm, performs local alignment.
        "-t {resources.cpus} " # -t: Number of threads (default: 12)
        "-v 1 "                # -v: Verbosity level: 1=error, 2=warning, 3=message, 4+=debugging
        "{params.indexbwa} "   # Reference index filename prefix
        "{input.forward} "     # Forward input reads
        "{input.reverse} "     # Reverse input reads
        "1> {output.mapped} "  # SAM output
        "2> {log}"             # Add redirection for log 

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
        sensitivity = SENSITIVITY
    input:
        forward = "results/reads/sickle/{sample}_quality-trimmed_R1.fastq.gz",
        reverse = "results/reads/sickle/{sample}_quality-trimmed_R2.fastq.gz"
    output:
        mapped = "results/bowtie2/{sample}_mapped.sam"
    log:
        "results/reports/bowtie2/{sample}_mapping.log"
    shell:
        "bowtie2 "                   # Bowtie2, an ultrafast and memory-efficient tool for aligning sequencing reads to long reference sequences.
        "--threads {resources.cpus} " # -p: Number of alignment threads to launch (default: 1)
        "--reorder "                  # Keep the original read order (if multi-processor option -p is used)
        "-x {params.indexbt2} "       # -x: Reference index filename prefix (minus trailing .X.bt2) [Bowtie-1 indexes are not compatible]
        "{params.sensitivity} "       # Preset (default: "--sensitive", same as [-D 15 -R 2 -N 0 -L 22 -i S,1,1.15]) 
        "-q "                         # -q: Query input files are FASTQ .fq/.fastq (default)
        "-1 {input.forward} "         # Forward input reads
        "-2 {input.reverse} "         # Reverse input reads
        "1> {output.mapped} "         # -S: File for SAM output (default: stdout) 
        "2> {log}"                    # Add redirection for log 

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
        length = LENGTHS
    input:
        forward = "results/reads/cutadapt/{sample}_adapt-removed_R1.fastq.gz",
        reverse = "results/reads/cutadapt/{sample}_adapt-removed_R2.fastq.gz"
    output:
        forward = "results/reads/sickle/{sample}_quality-trimmed_R1.fastq.gz",
        reverse = "results/reads/sickle/{sample}_quality-trimmed_R2.fastq.gz",
        single = temp("results/reads/sickle/{sample}_quality-trimmed_SE.fastq.gz")
    log:
        "results/reports/sickle-trim/{sample}.log"
    shell:
       "sickle "               # Sickle, a windowed adaptive trimming tool for FASTQ files using quality
        "{params.command} "     # Paired-end or single-end sequence trimming
        "-t {params.encoding} " # --qual-type: Type of quality values, solexa ; illumina ; sanger ; CASAVA, < 1.3 ; 1.3 to 1.7 ; >= 1.8
        "-q {params.quality} "  # --qual-threshold: Threshold for trimming based on average quality in a window (default: 20)
        "-l {params.length} "   # --length-threshold: Threshold to keep a read based on length after trimming (default: 20)
        "-f {input.forward} "   # --pe-file1: Input paired-end forward fastq file
        "-r {input.reverse} "   # --pe-file2: Input paired-end reverse fastq file
        "-g "                   # --gzip-output: Output gzipped files
        "-o {output.forward} "  # --output-pe1: Output trimmed forward fastq file
        "-p {output.reverse} "  # --output-pe2: Output trimmed reverse fastq file (must use -s option)
        "-s {output.single} "   # --output-single: Output trimmed singles fastq file
        "&> {log}"              # Add redirection for log

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
        length = LENGTHC,
        truseq = TRUSEQ,
        nextera = NEXTERA,
        small = SMALL
    input:
        forward = "resources/reads/{sample}_R1.fastq.gz",
        reverse = "resources/reads/{sample}_R2.fastq.gz"
    output:
        forward = temp("results/reads/cutadapt/{sample}_adapt-removed_R1.fastq.gz"),
        reverse = temp("results/reads/cutadapt/{sample}_adapt-removed_R2.fastq.gz")
    log:
        "results/reports/cutadapt/{sample}.log"
    shell:
       "cutadapt "                         # Cutadapt, finds and removes unwanted sequence from your HT-seq reads
        "--cores {resources.cpus} "         # -j: Number of CPU cores to use. Use 0 to auto-detect (default: 1)
        "--trim-n "                         # --trim-n: Trim N's on ends of reads
        "--minimum-length {params.length} " # -m: Discard reads shorter than length
        "--adapter {params.truseq} "        # -a: Sequence of an adapter ligated to the 3' end of the first read
        "-A {params.truseq} "               # -A: 3' adapter to be removed from second read in a pair
        "--adapter {params.nextera} "       # -a: Sequence of an adapter ligated to the 3' end of the first read
        "-A {params.nextera} "              # -A: 3' adapter to be removed from second read in a pair
        "--adapter {params.small} "         # -a: Sequence of an adapter ligated to the 3' end of the first read
        "-A {params.small} "                # -A: 3' adapter to be removed from second read in a pair
        "--output {output.forward} "        # -o: Write trimmed reads to FILE
        "--paired-output {output.reverse} " # -p: Write second read in a pair to FILE
        "{input.forward} "                  # Input forward reads R1.fastq
        "{input.reverse} "                  # Input reverse reads R2.fastq
        "&> {log}"                          # Add redirection for log

###############################################################################
rule multiqc_reports_aggregation:
    # Aim: aggregates bioinformatics analyses results into a single report
    # Use: multiqc [OPTIONS] --output [MULTIQC/] [FASTQC/] [MULTIQC/]
    priority:1
    message:
        "MultiQC reports aggregating"
    conda:
        MULTIQC
    input:
        fastqc = "results/quality/fastqc/",
        fastqscreen = "results/quality/fastq-screen/"
    output:
        multiqc = directory("results/quality/multiqc/")
    log:
        "results/reports/multiqc/aggregation.log"
    shell:
        "multiqc "                  # Multiqc, searches in given directories for analysis & compiles a HTML report
        "--quiet "                   # -q: Only show log warning
        "--outdir {output.multiqc} " # -o: Create report in the specified output directory
        "{input.fastqc} "            # Input FastQC files
        "{input.fastqscreen} "       # Input Fastq-Screen
        "--no-ansi "                 # Disable coloured log
        "&> {log}"                   # Add redirection for log

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
        aligner = ALIGNER,
        subset = SUBSET
    input:
        fastq = "resources/reads/"
    output:
        fastqscreen = directory("results/quality/fastq-screen/")
    log:
        "results/reports/fastq-screen/reads-contamination.log"
    shell:
        "fastq_screen "                 # FastqScreen, what did you expect ?
        "-q "                            # --quiet: Only show log warning
        "--threads {resources.cpus} "    # --threads: Specifies across how many threads bowtie will be allowed to run
        "--conf {params.config} "        # path to configuration file
        "--aligner {params.aligner} "    # -a: choose aligner 'bowtie', 'bowtie2', 'bwa'
        "--subset {params.subset} "      # Don't use the whole sequence file, but create a subset of specified size
        "--outdir {output.fastqscreen} " # Output directory
        "{input.fastq}/*.fastq.gz "      # Input file.fastq
        "&> {log}"                       # Add redirection for log

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
        fastqc = directory("results/quality/fastqc/")
    log:
        "results/reports/fastqc/reads-qualities.log"
    shell:
        "fastqc "                    # FastQC, a high throughput sequence QC analysis tool
        "--quiet "                    # -q: Supress all progress messages on stdout and only report errors
        "--threads {resources.cpus} " # -t: Specifies files number which can be processed simultaneously
        "--outdir {output.fastqc} "   # -o: Create all output files in the specified output directory
        "{input.fastq}/*.fastq.gz "   # Input file.fastq
        "&> {log}"                    # Add redirection for log

###############################################################################
