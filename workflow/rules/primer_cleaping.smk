###############################################################################
############################## PRIMER CLEAPING  ###############################
###############################################################################

###############################################################################
rule bamclipper_amplicon_primers:
    # Aim: soft-clip amplicon PCR primers from BAM alignments
    # Use: bamclipper.sh -n [THREADS] -b [MARKDUP.bam] -p [PRIMER.bed] -u [UPSTREAM] -d [DOWNSTREAM]
    message:
        """
        ~ BAMClipper ∞ soft-clipping amplicon PCR primers from BAM alignments ~
        Sample: __________ {wildcards.sample}
        Reference: _______ {wildcards.reference}
        Aligner: _________ {wildcards.aligner}
        """
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
        markdup = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.bam",
        index = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.bam.bai"
    output:
        bamclip = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.primerclipped.bam",
        baiclip = "results/02_Mapping/{reference}/{sample}_{aligner}_mark-dup.primerclipped.bam.bai"
    log:
        "results/10_Reports/tools-log/bamclipper/{reference}/{sample}_{aligner}_primers-clip.log"
    shell:
        "bamclipper.sh "                         # BAMClipper, remove primer sequences from BAM alignments of PCR amplicons by soft-clipping
        "-b {input.markdup} "                     # Indexed BAM alignment file
        "-p {params.path}{params.primers}.bedpe " # BEDPE of primer pair locations
        "-n {resources.cpus} "                    # Number of threads (default: 1)
        "-u {params.upstream} "                   # Number of nuc. upstream for assigning alignments to primers (default: 5)
        "-d {params.downstream} "                 # Number of nuc. downstream for assigning alignments to primers (default: 5)
        #"-o results/02_Mapping/ "                 # Path to write output (if BamClipper v.1.1.2) (todo)
        "&> {log} "                               # Log redirection
        "&& mv {wildcards.sample}_{wildcards.aligner}_mark-dup.primerclipped.bam {output.bamclip} "    # because BamClipper v.1 default output system...
        "&& mv {wildcards.sample}_{wildcards.aligner}_mark-dup.primerclipped.bam.bai {output.baiclip}" # because BamClipper v.1 default output system...

###############################################################################
