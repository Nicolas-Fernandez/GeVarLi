# **Résultats**

Les résultats sont disponible dans le répertoire **./results/** .




!!! tip
    Les fichiers étiqueté comme **[TEMP]** sont supprimés par défaut, afin de préserver l'espace disque.  
	Si vous souhaiter les conserver, veuiller éditer le fichier de **configuration**.

## **Arborescence des fichiers**
```shell
🧩 GeVarLi/
│
└── 📂 results/
    │
    ├── 🌐 All_readsQC_reports.html
    ├── 🧬 All_{REFERENCE}_consensus_sequences.fasta
    ├── 📊 All_{REFERENCE}_genome_coverages.tsv
    ├── 📊 All_{REFERENCE}_nextclade_lineages.tsv
    ├── 📊 All_{REFERENCE}_pangolin_lineages.tsv
    │
    ├── 📂 00_Quality_Control/
    │   │
    │   ├── 📂 fastq-screen/
    │   │   │
    │   │   ├── 🌐 {SAMPLE}_R{1|2}_screen.html
    │   │   ├── 📈 {SAMPLE}_R{1|2}_screen.png
    │   │   └── 📄 {SAMPLE}_R{1|2}_screen.txt
    │   │
    │   ├── 📂 fastqc/
    │   │   │
    │   │   ├── 🌐 {SAMPLE}_R{1|2}_fastqc.html
    │   │   └── 📦 {SAMPLE}_R{1|2}_fastqc.zip
    │   │
    │   └── 📂 multiqc/
    │       │
    │       ├── 🌐 multiqc_report.html
    │       │
    │       └──📂 multiqc_data/
    │          │
    │          ├── 📝 multiqc.log
    │          ├── 📄 multiqc_citations.txt
    │          ├── 🌀 multiqc_data.json
    │          ├── 📄 multiqc_fastq_screen.txt
    │          ├── 📄 multiqc_fastqc.txt
    │          ├── 📄 multiqc_general_stats.txt
    │          └── 📄 multiqc_sources.txt
    │
    ├── 📂 01_Trimming
    │   │
    │   ├── 📂 cutadapt/
    │   │   │
    │   │   └── 📦 {SAMPLE}_cutadapt-removed_R{1|2}.fastq.gz #[TEMP]
    │   │
    │   └── 📂 sickle/
    │       │
    │       ├── 📦 {SAMPLE}_sickle-trimmed_R{1|2}.fastq.gz   #[TEMP]
    │       └── 📦 {SAMPLE}_sickle-trimmed_SE.fastq.gz       #[TEMP]
    │
    ├── 📂 02_Mapping/
    │   │
    │   ├── 🧭 {SAMPLE}_{REFERENCE}_{ALIGNER}_mark-dup.bam
    │   ├── 🗂️ {SAMPLE}_{REFERENCE}_{ALIGNER}_mark-dup.bam.bai
    │   ├── 🧭 {SAMPLE}_{REFERENCE}_{ALIGNER}_mark-dup.primerclipped.bam
    │   ├── 🗂️ {SAMPLE}_{REFERENCE}_{ALIGNER}_mark-dup.primerclipped.bam.bai
    │   ├── 🧭 {SAMPLE}_{REFERENCE}_{ALIGNER}_mapped.sam                     #[TEMP]
    │   ├── 🧭 {SAMPLE}_{REFERENCE}_{ALIGNER}_sorted-by-names.bam            #[TEMP]
    │   ├── 🧭 {SAMPLE}_{REFERENCE}_{ALIGNER}_fixed-mate.bam                 #[TEMP]
    │   └── 🧭 {SAMPLE}_{REFERENCE}_{ALIGNER}_sorted.bam                     #[TEMP]
    │
    ├── 📂 03_Coverage/
    │   │
    │   ├── 📊 {SAMPLE}_{REFERENCE}_{ALIGNER}_{MINCOV}_coverage-stats.tsv
    │   ├── 🛏️ {SAMPLE}_{REFERENCE}_{ALIGNER}_genome-cov.bed              #[TEMP]
    │   ├── 🛏️ {SAMPLE}_{REFERENCE}_{ALIGNER}_{MINCOV}_min-cov-filt.bed   #[TEMP]
    │   └── 🛏️ {SAMPLE}_{REFERENCE}_{ALIGNER}_{MINCOV}_low-cov-mask.bed   #[TEMP]
    │
    ├── 📂 04_Variants/
    │   │
    │   ├── 🧬 {SAMPLE}_{REFERENCE}_{ALIGNER}_{MINCOV}_masked-ref.fasta
    │   ├── 🗂️ {SAMPLE}_{REFERENCE}_{ALIGNER}_{MINCOV}_masked-ref.fasta.fai
    │   ├── 🧭 {SAMPLE}_{REFERENCE}_{ALIGNER}_{MINCOV}_indel-qual.bam
    │   ├── 🗂️ {SAMPLE}_{REFERENCE}_{ALIGNER}_{MINCOV}_indel-qual.bai
    │   ├── 🧮️ {SAMPLE}_{REFERENCE}_{ALIGNER}_{MINCOV}_variant-call.vcf
    │   ├── 🧮️ {SAMPLE}_{REFERENCE}_{ALIGNER}_{MINCOV}_variant-filt.vcf
    │   ├── 📦 {SAMPLE}_{REFERENCE}_{ALIGNER}_{MINCOV}_variant-filt.vcf.bgz     #[TEMP]
    │   └── 🗂️ {SAMPLE}_{REFERENCE}_{ALIGNER}_{MINCOV}_variant-filt.vcf.bgz.tbi #[TEMP]
    │
    ├── 📂 05_Consensus/
    │   │
    │   ├── 🧬 {SAMPLE}_{REFERENCE}_{ALIGNER}_{MINCOV}_consensus.fasta
    │   │
    │   └── 📂 ivar_consensus-quality/
    │       │
    │       └── 🌐 {SAMPLE}_{REFERENCE}_{ALIGNER}_{MINCOV}_ivar_consensus.qual
    │
    ├── 📂 06_Lineages/
    │   │
    │   ├── 📊 {SAMPLE}_{REFERENCE}_{ALIGNER}_{MINCOV}_nextclade-report.tsv
    │   ├── 📊 {SAMPLE}_{REFERENCE}_{ALIGNER}_{MINCOV}_pangolin-report.csv
    │   │
    │   └── 📂 {SAMPLE}_{REFERENCE}_{ALIGNER}_{MINCOV}_nextclade-all/
    │       │
    │       ├── 🧬 nextclade.aligned.fasta
    │       ├── 📊 nextclade.csv
    │       ├── 📊 nextclade.errors.csv
    │       ├── 📊 nextclade.insertions.csv
    │       ├── 🌀 nextclade.json
    │       ├── 🌀 nextclade.ndjson
    │       ├── 🌀 nextclade.auspice.json
    │       └── 🧬 nextclade_{GENE}.translation.fasta
    │
    └── 📂 10_Reports/
        │
        ├── ⚙️ config.log
        ├── 📝 settings.log
        ├── 🍜 gevarli-base_v.{VERSION}.yaml
        │
        ├── 📂 conda_env/
        │   │
        │   └── 📄 {TOOLS}_v.{version}.yaml
        │
        ├── 📂 files-summaries
        │   │
        │   └── 📄 {PIPELINE}_files-summary.txt
        │
        ├── 📂 graphs/
        │   │
        │   ├── 📈 {PIPELINE}_dag.{PNG/PDF}
        │   ├── 📈 {PIPELINE}_filegraph.{PNG/PDF}
        │   └── 📈 {PIPELINE}_rulegraph.{PNG/PDF}
        │
        └── 📂 tools-log/
            │
            └── 📂 {TOOL}/
                │
                └── 📝 {SAMPLE}_{REFERENCE}_{ALIGNER}.log
```
