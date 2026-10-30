# **Features and tools**

## **Workflow and infrastructure**
  - Workflow orchestrator: Snakemake (version 9.27+)
  - Environment management: Miniforge / Conda (`workflow-core` unified orchestrator)
  - HPC execution: Native Slurm integration for high-performance computing clusters (e.g. IRD i-Trop)
  - Continuous integration: Automated pipeline dry-runs and strict documentation validation

## **Genomic references management**
  - Automated viral reference download: NCBI Entrez efetch (retrieves viral reference genomes dynamically by accession number)
  - Automated lineage dataset download: Nextclade CLI (`nextclade dataset get`)
  - Custom genomes support: Seamless integration of user-supplied FASTA files in `resources/genomes/`

## **Reads quality control**
  - Contamination checking: Fastq-Screen
  - Reads quality metrics: FastQC
  - Aggregated HTML reporting: MultiQC
  
## **Reads cleaning and trimming**
  - Illumina adapter trimming: Cutadapt
  - Amplicon primer trimming: Cutadapt _('hard-clipping')_
  - Low-quality read trimming: Sickle-trim
  
## **Reads mapping and alignment**
  - Genome indexing: BWA _(or Bowtie2, or Minimap2)_
  - Reads mapping: BWA _(or Bowtie2, or Minimap2)_
  - Amplicon primer trimming: Bamclipper _('soft-clipping')_
  - Genome coverage reports: Bedtools _(TSV tabular file)_
  - Visualization: BAM, BAI, and BED files ready for IGV
  
## **Variants calling**
  - Variants calling: iVar
  - Variants filtering: iVar (allele frequency and minimum coverage thresholds)
  - Format conversion: TSV to standard VCF
  
## **Consensus sequences**
  - Consensus calling: iVar _(FASTA file with quality-based ambiguity/N-masking)_
  
## **Genomic classification and lineages**
  - Genome quality assessment: Nextclade
  - Lineage and clade assignment: Nextclade _(and Pangolin when applicable)_

## **Workflow Graphs**

### Rulegraph
<img src="../../../images/gevarli_rulegraph.png" width="2043" height="3216">

### Filegraph 
<img src="../../../images/gevarli_filegraph.png" width="2043" height="3882">
