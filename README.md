# GeVarLi: GEnome assembly, VARiant calling and LIneage assignation #

![Maintener](<https://badgen.net/badge/Maintener/Nicolas Fernandez/blue?scale=0.9>)
![MacOSX Intel/M1/M2](<https://badgen.net/badge/icon/Hight Sierra (10.13.6) | Catalina (10.15.7) | Big Sure (11.6.3) | Monterey (12.6.0) | Ventura (13.0.1)/E6055C?icon=apple&label&list=|&scale=0.9>)
![GNU-Linux Ubuntu](<https://badgen.net/badge/icon/Bionic Beaver (18.04) | Focal Fossa (20.04) | Jammy Jellyfish (22.04)/772953?icon=https://www.svgrepo.com/show/25424/ubuntu-logo.svg&label&list=|&scale=0.9>)
![WSL/WSL2](<https://badgen.net/badge/icon/Bionic Beaver (18.04) | Focal Fossa (20.04) | Jammy Jellyfish (22.04)/00BCF2?icon=windows&label&list=|&scale=0.9>)
![Issues closed](<https://badgen.net/badge/Issues closed/0/green?scale=0.9>)
![Issues opened](<https://badgen.net/badge/Issues opened/0/yellow?scale=0.9>)
![Maintened](<https://badgen.net/badge/Maintened/Yes/red?scale=0.9>)
![Wiki](<https://badgen.net/badge/icon/Wiki/pink?icon=wiki&label&scale=0.9>)
![Open Source](<https://badgen.net/badge/icon/Open Source/purple?icon=https://upload.wikimedia.org/wikipedia/commons/4/44/Corazón.svg&label&scale=0.9>)
![GNU AGPL v3](<https://badgen.net/badge/Licence/GNU AGPL v3/grey?scale=0.9>)
![Gitlab](<https://badgen.net/badge/icon/Gitlab/orange?icon=gitlab&label&scale=0.9>)
![Bash](<https://badgen.net/badge/icon/Bash 3.2.57/black?icon=terminal&label&scale=0.9>)
![Python](<https://badgen.net/badge/icon/Python 3.9.5/black?icon=https://upload.wikimedia.org/wikipedia/commons/0/0a/Python.svg&label&scale=0.9>)
![Snakemake](<https://badgen.net/badge/icon/Snakemake 6.12.1/black?icon=https://upload.wikimedia.org/wikipedia/commons/d/d3/Python_icon_%28black_and_white%29.svg&label&scale=0.9>)
![Conda](<https://badgen.net/badge/icon/Conda 4.10.3/black?icon=codacy&label&scale=0.9>)


## ~ ABOUT ~ ##

GeVarLi	is a bioinformatic pipeline used for SARS-CoV-2	genome assembly with Illumina Inc. short reads COVIDSeq&trade; libraries sequencing.  
Developed for **[AFROSCREEN](https://www.afroscreen.org/)** project. 

### Genomic sequencing, a public health tool ###
The establishment of a surveillance and sequencing network is an essential public health tool for detecting and containing pathogens with epidemic potential. Genomic sequencing makes it possible to identify pathogens, monitor the emergence and impact of variants, and adapt public health policies accordingly.

The Covid-19 epidemic has highlighted the disparities that remain between continents in terms of surveillance and sequencing systems. At the end of October 2021, of the 4,600,000 sequences shared on the public and free GISAID tool worldwide, only 49,000 came from the African continent, i.e. less than 1% of the cases of Covid-19 diagnosed on this continent.

### Features ###
- Control reads quality (_multiQC html report_) and clean it  
- Align reads (_bam files_), variants calling (_vcf files_) and genome coverage statistics  
- Consensus sequences (_fasta file_)  
- Nextclade and Pangolin classifications  

### Version ###
*V.2022.11*  


### Citation ###
_(soon)_


### Rulegraph ###
<img src="./resources/visuals/gevarli_rulegraph.png" width="300" height="1200">  
<img src="./resources/visuals/quality_control_rulegraph.png" width="250" height="150">  
<img src="./resources/visuals/indexing_genomes_rulegraph.png" width="200" height="100">  


## ~ INSTALLATIONS ~ ##

# Conda _(mandatory)_ #
GeVarLi _(with Snakemake)_ use the usefull **Conda** environment manager  
So, if and only if, it's required _(Conda not already installed)_, please, first install **Conda**!  
 
Download and install your OS adapted version of [Latest Miniconda Installer](https://docs.conda.io/en/latest/miniconda.html#latest-miniconda-installer-links)  

e.g. for **MacOSX-64-bit** systems:  
```shell
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -o ~/Miniconda3-latest-MacOSX-x86_64.sh && \
bash ~/Miniconda3-latest-MacOSX-x86_64.sh -b -p ~/miniconda3/ && \
rm -f ~/Miniconda3-latest-MacOSX-x86_64.sh && \
~/miniconda3/condabin/conda update conda --yes && \
~/miniconda3/condabin/conda init && \
exit
```

e.g. for **Linux-64-bit** systems:  
```shell
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/Miniconda3-latest-Linux-x86_64.sh && \
bash ~/Miniconda3-latest-Linux-x86_64.sh -b -p ~/miniconda3/ && \
rm -f ~/Miniconda3-latest-Linux-x86_64.sh && \
~/miniconda3/condabin/conda update conda --yes && \
~/miniconda3/condabin/conda init && \
exit
```


# GeVarLi #
Clone _(with HTTPS)_ the [GeVarLi](https://forge.ird.fr/transvihmi/GeVarLi) repository on GitLab _(ID: 399)_:
```shell
git clone https://forge.ird.fr/transvihmi/GeVarLi.git ~/GeVarLi/ && \
cd ~/GeVarLi/
```

Difference between **Download** and **Clone**:  
- To create a copy of a remote repository’s files on your computer, you can either **Download** or **Clone** the repository  
- If you download it, you **cannot sync** the repository with the remote repository on GitLab  
- Cloning a repository is the same as downloading, except it preserves the Git connection with the remote repository  
- You can then modify the files locally and upload the changes to the remote repository on GitLab  
- You can then **update** the files locally and download the changes from the remote repository on GitLab  
```shell
git reset --hard HEAD && \
git pull --verbose
```

## ~ USAGE ~ ##

1. Copy your **paired-end** reads in **.fastq.gz** format files into: **./resources/reads/** directory
_SARS-CoV-2 sample reads are available for test into ./resources/test\_data/ directory_

2. Execute **Start_GeVarLi.sh** bash script to run GeVarLi pipeline _(according to your choice)_:
    - or with a **Double-click** on it _(if you make .sh files executable files with Terminal.app)_
	- or with a **Right-click** > **Open with** > **Terminal.app**
	- or with **CLI** from a terminal:
```shell
bash Start_GeVarLi.sh
```
3. Yours analyzes will start, with default configuration settings  

_Option-1: Edit **config.yaml** file in **./config/** directory_  
_Option-2: Edit **fastq-screen.conf** file in **./config/** directory_  

First run will auto-created _(only once)_:
	- Gevarli-Base conda environment _(Snakemake, Mamba, Rename, GraphViz)_
	- Snakemake-conda environments _(for each tools used by GeVarLi)_
	- Indexes for BWA and BOWTIE2 aligners _(for each fasta genomes in resources)_
	
_This may take some time, depending on your internet connection and your computer_
	

## ~ RESULTS ~ ##

Yours results are available in **./results/** directory, as follow:  
_Some [temp] tagged files are removed by default, to save disk usage_

```shell
 🧩 GeVarLi/
  └── 📂 results/
       ├── 🧬 All_consensus_sequences.fasta
       ├── 📊 All_genome_coverages.tsv
       ├── 📊 All_nextclade_lineages.tsv
       ├── 📊 All_pangolin_lineages.tsv
       ├── 🌐 All_readsQC_reports.html
       ├── 📂 00_Quality_Control/
       │    ├── 📂 fastq-screen/
       │    │    ├── 🌐 {SAMPLE}_R{1/2}_screen.html
       │    │    ├── 📈 {SAMPLE}_R{1/2}_screen.png
       │    │    └── 📄 {SAMPLE}_R{1/2}_screen.txt
       │    ├── 📂 fastqc/
       │    │    ├── 🌐 {SAMPLE}_R{1/2}_fastqc.html
       │    │    └── 📦 {SAMPLE}_R{1/2}_fastqc.zip
       │    └── 📂 multiqc/
       │         ├── 🌐 multiqc_report.html
       │         └──📂 multiqc_data/
       │             ├── 📝 multiqc.log
       │             ├── 📄 multiqc_citations.txt
       │             ├── 🌀 multiqc_data.json
       │             ├── 📄 multiqc_fastq_screen.txt
       │             ├── 📄 multiqc_fastqc.txt
       │             ├── 📄 multiqc_general_stats.txt
       |             └── 📄 multiqc_sources.txt
       ├── 📂 01_Trimming/
       │    ├── 📂 cutadapt/
       │    │    └── 📦 {SAMPLE}_cutadapt-removed_R{1/2}.fastq.gz       # [temp]
       │    └── 📂 sickle/
       │         ├── 📦 {SAMPLE}_sickle-trimmed_R{1/2}.fastq.gz         # [temp]
       │         └── 📦 {SAMPLE}_sickle-trimmed_SE.fastq.gz             # [temp]
       ├── 📂 02_Mapping/
       │    ├── 🧭 {SAMPLE}_{ALIGNER}_mark-dup.bam
       │    ├── 🗂️  {SAMPLE}_{ALIGNER}_mark-dup.bam.bai
       │    ├── 🧭 {SAMPLE}_{ALIGNER}_mark-dup.primerclipped.bam
       │    ├── 🗂️  {SAMPLE}_{ALIGNER}_mark-dup.primerclipped.bam.bai
       │    ├── 🧭 {SAMPLE}_{ALIGNER}-mapped.sam                        # [temp]
       │    ├── 🧭 {SAMPLE}_{ALIGNER}_sorted-by-names.bam               # [temp]
       │    ├── 🧭 {SAMPLE}_{ALIGNER}_fixed-mate.bam                    # [temp]
       │    └── 🧭 {SAMPLE}_{ALIGNER}_sorted.bam                        # [temp]
       ├── 📂 03_Coverage/
       │    ├── 📊 {SAMPLE}_{ALIGNER}_{MINCOV}_coverage-stats.tsv
       │    ├── 🛏️  {SAMPLE}_{ALIGNER}_genome-cov.bed                    # [temp]
       │    ├── 🛏️  {SAMPLE}_{ALIGNER}_{MINCOV}_min-cov-filt.bed         # [temp]
       │    └── 🛏️  {SAMPLE}_{ALIGNER}_{MINCOV}_low-cov-mask.bed         # [temp]
       ├── 📂 04_Variants/
       │    ├── 🧬 {SAMPLE}_{ALIGNER}_{MINCOV}_masked-ref.fasta
       │    ├── 🗂️  {SAMPLE}_{ALIGNER}_{MINCOV}_masked-ref.fasta.fai
       │    ├── 🧭 {SAMPLE}_{ALIGNER}_{MINCOV}_indel-qual.bam
       │    ├── 🗂️  {SAMPLE}_{ALIGNER}_{MINCOV}_indel-qual.bai
       │    ├── 🧮️  {SAMPLE}_{ALIGNER}_{MINCOV}_variant-call.vcf
       │    ├── 🧮️  {SAMPLE}_{ALIGNER}_{MINCOV}_variant-filt.vcf
       │    ├── 📦 {SAMPLE}_{ALIGNER}_{MINCOV}_variant-filt.vcf.bgz     # [temp]
       │    └── 🗂️  {SAMPLE}_{ALIGNER}_{MINCOV}_variant-filt.vcf.bgz.tbi # [temp]
       ├── 📂 05_Consensus/
       │    └── 🧬 {SAMPLE}_{ALIGNER}_{MINCOV}_consensus.fasta
       ├── 📂 06_Lineages/
       │    ├── 📊 {SAMPLE}_{ALIGNER}_{MINCOV}_nextclade-report.tsv
       │    ├── 📊 {SAMPLE}_{ALIGNER}_{MINCOV}_pangolin-report.csv
       │    └── 📂 {SAMPLE}_{ALIGNER}_{MINCOV}_nextclade-all/
       │         ├── 🧬 nextclade.aligned.fasta
       │         ├── 📊 nextclade.csv
       │         ├── 📊 nextclade.errors.csv
       │         ├── 📊 nextclade.insertions.csv
       │         ├── 🌀 nextclade.json
       │         ├── 🌀 nextclade.ndjson
       │         ├── 🌀 nextclade.auspice.json
       │         └── 🧬 nextclade_{GENE}.translation.fasta
       └── 📂 10_Reports/
            ├── ⚙️  config.log
            ├── 📝 settings.log
            ├── 🍜 gevarli_v.2022.11.yaml
            ├── 📂 files-summaries
            │    └── 📄 {PIPELINE}_files-summary.txt
            ├── 📂 graphs/
            │    ├── 📈 {PIPELINE}_dag.{PNG/PDF}
            │    ├── 📈 {PIPELINE}_filegraph.{PNG/PDF}
            │    └── 📈 {PIPELINE}_rulegraph.{PNG/PDF}
            └── 📂 tools-log/
                 ├── 📂 awk/
                 ├── 📂 bcftools/
                 ├── 📂 bedtools/
                 ├── 📂 bgzip/
                 ├── 📂 bwa/
                 ├── 📂 cutadapt/
                 ├── 📂 lofreq/
                 ├── 📂 nextclade/
                 ├── 📂 pangolin/
                 ├── 📂 samtools/
                 ├── 📂 sed/
                 ├── 📂 sickle-trim/
                 ├── 📂 tabix/
                 ├── 📝 fastq-screen.log
                 ├── 📝 fastqc.log
                 └── 📝 multiqc.log
```

## ~ CONFIGURATION ~ ##

You can edit default settings in **config.yaml** file into **./config/** directory:  

### Resources ###
Edit to match your hardware configuration  
- **cpus**: for tools that can _(i.e. bwa)_, could be use at most n cpus to run in parallel _(default config: '8')_  
_**Note**: snakemake (with default Start bash script) will always use all cpus to parallelize jobs_
- **ram**: for tools that can _(i.e. samtools)_, limit memory usage to max n Gb _(default config: '16' Gb)_
- **tmpdir**: for tools that can _(i.e. pangolin)_, specify where you want the temp stuff _(default config: '$TMPDIR')_

### Environments ###
Edit if you want change some environments _(e.g. test a new version)_ in ./workflow/envs/{tools}_v.{version}.yaml files

### Aligner ###
Edit to choose align your reads using either **BWA** or **Bowtie2**  
- **bwa**: faster _(default)_
- **bowtie2**: slower, 'sensitivity' is requiried and could be set _(see below "Bowtie2" options)_

### Consensus ###
- **reference**: reference sequence path used for genome assmbling _(default config: 'SARS-CoV-2\_Wuhan-WIV04\_2019')_
- **mincov**: minimum coverage for masking to low covered regions in final consensus sequence _(default config: '10')_

### Variant ###
- **covmin**: minimum coverage allowed for SNVs and InDels filtering, if < 1 = off _(default config: '10' (INT))_
- **afmin**: minimum allele frequency allowed for SNVs and InDels filtering, if < 1 = off _(default config: '0.2' (FLOAT))_

### BWA ###
- **index**: reference index path for bwa _(default config: 'SARS-CoV-2_Wuhan-WIV04_2019')_

### Bowtie2 ###
- **index**: reference index path for bowtie2 _(default config: 'SARS-CoV-2\_Wuhan-WIV04\_2019')_
- **sensitivity**: preset for bowtie2 sensitivity _(default config: '--sensitive')_

### Sickle-trim ###
- **command**: Pipeline wait for paired-end reads _(default config: 'pe')_
- **encoding**: If your data are from recent Illumina run, let 'sanger' _(default config: 'sanger')_
- **quality**: [Q-phred score](https://en.wikipedia.org/wiki/Phred_quality_score) limit _(default config: '30')_
- **length**: read length limit, after trim _(default config: '25')_

### Cutadapt ###
- **length**: discard reads shorter than length, after trim _(default config: '25')_
- **kits**: sequence of an adapter ligated to the 3' end of the first read _(default config: 'truseq', 'nextera' and 'small' Illumina kits)  

### Fastq-Screen ###
- **config**: path to the fastq-screen configuration file _(default config: ./config/fastq-screen.conf)_
- **subset**: do not use the whole sequence file, but create a temporary dataset of this specified number of read _(default config: '1000')_
- **aligner**: specify the aligner to use for the mapping. Valid arguments are 'bowtie', bowtie2' or 'bwa' _(default config: 'bwa')_

#### fastq-screen.conf ####
- **databases**: enables you to configure multiple genomes databases _(aligner index files)_ to search against

### Glossary ###
- **BAM**: Binary Alignment Map
- **BAI**: BAM Indexes
- **FASTA**: Fast-All
- **FASTQ**: FASTA with Quality
- **FAI**: FASTA Indexes
- **SAM**: Sequence Alignment Map

## ~ SUPPORT ~ ##
1. Read The Fabulous Manual!
2. Read de Awsome Wiki! (todo...)
3. Create a new issue: Issues > New issue > Describe your issue
4. Send an email to [nicolas.fernandez@ird.fr](url)

## ~ ROADMAP ~ ##
- Add GisAid submission files generation

## ~ AUTHORS & ACKNOWLEDGMENTS ~ ##
- Nicolas Fernandez - IRD _(Developer and Maintener)_  
- Christelle Butel - IRD _(Reporter, User-addict, Features inspiration source)_  
- Eddy Kinganda-Lusamaki - INRB _(looking for open source unix and biologiist friendly pipeline)_  

## ~ CONTRIBUTING ~ ##
Open to contributions!  
Testing code, finding issues, asking for update, proposing new features...  
Use Git tools to share!  

## ~ PROJECT STATUS ~ ##
This project is **regularly update** and **actively maintened**  
However, you can be volunteer to step in as **developer** or **maintainer**  

For information about main git roles:  
- **Guests** are _not active contributors_ in private projects, they can only see, and leave comments and issues  
- **Reporters** are _read-only contributors_, they can't write to the repository, but can on issues  
- **Developers** are _direct contributors_, they have access to everything to go from idea to production  
_Unless something has been explicitly restricted_  
- **Maintainers** are _super-developers_, they are able to push to master, deploy to production  
_This role is often held by maintainers and engineering managers_  
- **Owners** are essentially _group-admins_, they can give access to groups and have destructive capabilities  


## ~ LICENSE ~ ##
Licencied under [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)  

Intellectual property belongs to [IRD](https://www.ird.fr/) and authors.


### GeVarLi map ###
```shell
 🧩 GeVarLi/
 ├── 🖥️️  Start_GeVarLi.sh
 ├── 📚 README.md
 ├── 🪪 LICENSE
 ├── 🛑 .gitignore
 ├── 📂 .git/
 ├── 📂 .snakemake/
 ├── 📂 config/
 │    ├── ⚙️  config.yaml
 │    └── ⚙️  fastq-screen.conf
 ├── 📂 resources/
 │    ├── 📂 genomes/
 │    │    ├── 🧬 SARS-CoV-2_Wuhan_MN908947-3.fasta
 │    │    ├── 🧬 Monkeypox-virus_Zaire_AF380138-1.fasta
 │    │    ├── 🧬 Monkeypox-virus_UK_MT903345-1.fasta
 │    │    ├── 🧬 Swinepox-virus_India_MW036632-1.fasta
 │    │    ├── 🧬 Ebola-virus_Zaire_AF272001-1.fasta
 │    │    ├── 🧬 Nipah-virus_Malaysia_AJ564622-1.fasta
 │    │    ├── 🧬 HIV-1_HXB2_K03455-1.fasta.fasta
 │    │    ├── 🧬 (your_favorite_genome_reference}.fasta
 │    │    ├── 🧬 QC_Echerichia-coli_CP060121-1.fasta
 │    │    ├── 🧬 QC_Kanamycin-Resistance-Gene.fasta
 │    │    ├── 🧬 QC_NGS-adapters.fasta
 │    │    ├── 🧬 QC_phi-X174_Coliphage_NC-001422-1.fasta
 │    │    ├── 🧬 QC_UniVec_wo_phiX_and_kanamycin.fasta
 │    │    └── 🧬 {your_favorite_qc_reference}.fasta
 │    ├── 📂 indexes/
 │    │    ├── 📂 bwa/
 │    │    │    ├── 🗂️  {GENOME}.amb
 │    │    │    ├── 🗂️  {GENOME}.ann
 │    │    │    ├── 🗂️  {GENOME}.bwt
 │    │    │    ├── 🗂️  {GENOME}.pac
 │    │    │    └── 🗂️  {GENOME}.sa
 │    │    └── 📂 bowtie2/
 │    │         ├── 🗂️  {GENOME}.1.bt2
 │    │         ├── 🗂️  {GENOME}.2.bt2
 │    │         ├── 🗂️  {GENOME}.3.bt2
 │    │         ├── 🗂️  {GENOME}.4.bt2
 │    │         ├── 🗂️  {GENOME}.rev.1.bt2
 │    │         └── 🗂️  {GENOME}.rev.2.bt2
 │    ├── 📂 nextclade/
 │    │    ├── 📂 sars-cov-2/
 │    │    │    ├── 🌍 genemap.gff
 │    │    │    ├── 🧪 primers.csv
 │    │    │    ├── ✅ qc.json
 │    │    │    ├── 🦠 reference.fasta
 │    │    │    ├── 🧬 sequences.fasta
 │    │    │    ├── 🏷️  tag.json
 │    │    │    └── 🌳 tree.json
 │    │    ├── 📂 MPXV/
 │    │    │    ├── 🌍 genemap.gff
 │    │    │    ├── 🧪 primers.csv
 │    │    │    ├── ✅ qc.json
 │    │    │    ├── 🦠 reference.fasta
 │    │    │    ├── 🧬 sequences.fasta
 │    │    │    ├── 🏷️  tag.json
 │    │    │    └── 🌳 tree.json
 │    │    ├── 📂 hMPWV/
 │    │    │    ├── 🌍 genemap.gff
 │    │    │    ├── 🧪 primers.csv
 │    │    │    ├── ✅ qc.json
 │    │    │    ├── 🦠 reference.fasta
 │    │    │    ├── 🧬 sequences.fasta
 │    │    │    ├── 🏷️  tag.json
 │    │    │    └── 🌳 tree.json
 │    │    └── 📂 hMPXV_B1/
 │    │         ├── 🌍 genemap.gff
 │    │         ├── 🧪 primers.csv
 │    │         ├── ✅ qc.json
 │    │         ├── 🦠 reference.fasta
 │    │         ├── 🧬 sequences.fasta
 │    │         ├── 🏷️  tag.json
 │    │         └── 🌳 tree.json
 │    ├── 📂 primers/
 │    │    ├── 📂 bedpe/
 │    │    │    ├── 🛡️  .gitkeep
 │    │    │    ├── 🛌️  SARS-CoV-2_Wuhan_MN908947-3_artic-primers-V1.bedpe
 │    │    │    ├── 🛌️  SARS-CoV-2_Wuhan_MN908947-3_artic-primers-V2.bedpe
 │    │    │    ├── 🛌️  SARS-CoV-2_Wuhan_MN908947-3_artic-primers-V3.bedpe
 │    │    │    ├── 🛌️  SARS-CoV-2_Wuhan_MN908947-3_artic-primers-V4.bedpe
 │    │    │    ├── 🛌️  SARS-CoV-2_Wuhan_MN908947-3_artic-primers-V4-1.bedpe
 │    │    │    ├── 🛌️  Ebola-virus_Zaire_KR063671-1_artic-primers-V1.bedpe
 │    │    │    ├── 🛌️  Ebola-virus_Zaire_AF272001-1_artic-primers-V2.bedpe
 │    │    │    ├── 🛌️  Ebola-virus_Zaire_KR063671-1_artic-primers-V3.bedpe
 │    │    │    ├── 🛌️  Nipah-virus_Malaysia_AJ564622-1_artic-primers-V1.bedpe
 │    │    │    └── 🛌️  {your_favorite_kit_primers}.bedpe
 │    │    ├── 📂 bed/
 │    │    │    ├── 🛡️  .gitkeep
 │    │    │    ├── 🛏️  SARS-CoV-2_Wuhan_MN908947-3_artic-primers-V1.bed
 │    │    │    ├── 🛏️  SARS-CoV-2_Wuhan_MN908947-3_artic-primers-V2.bed
 │    │    │    ├── 🛏️  SARS-CoV-2_Wuhan_MN908947-3_artic-primers-V3.bed
 │    │    │    ├── 🛏️  SARS-CoV-2_Wuhan_MN908947-3_artic-primers-V4.bed
 │    │    │    ├── 🛏️  SARS-CoV-2_Wuhan_MN908947-3_artic-primers-V4-1.bed
 │    │    │    ├── 🛏️  Ebola-virus_Zaire_KR063671-1_artic-primers-V1.bed
 │    │    │    ├── 🛏️  Ebola-virus_Zaire_AF272001-1_artic-primers-V2.bed
 │    │    │    ├── 🛏️  Ebola-virus_Zaire_KR063671-1_artic-primers-V3.bed
 │    │    │    ├── 🛏️  Nipah-virus_Malaysia_AJ564622-1_artic-primers-V1.bed
 │    │    │    └── 🛏️  {your_favorite_kit_primers}.bed
 │    │    └── 📂 fasta/
 │    │         ├── 🛡️  .gitkeep
 │    │         ├── 🧬 Monkeypox-virus_UK_MT903345-1_custom-VGCARE-primers-V1.fasta
 │    │         └── 🧬 {your_favorite_kit_primers}.fasta
 │    ├── 📂 reads/
 │    │    ├── 🛡️  .gitkeep
 │    │    ├── 📦 {SAMPLE}_R1.fastq.gz
 │    │    └── 📦 {SAMPLE}_R2.fastq.gz
 │    ├── 📂 test_data/
 │    │    ├── 🛡️  .gitkeep
 │    │    ├── 📦 SARS-CoV-2_Omicron-BA.1.1_Covid-Seq-Lib-on-MiSeq_250000-reads_R1.fastq.gz
 │    │    └── 📦 SARS-CoV-2_Omicron-BA.1.1_Covid-Seq-Lib-on-MiSeq_250000-reads_R2.fastq.gz
 │    └── 📂 visuals/
 │         ├── 📈 gevarli_rulegraph.png
 │         ├── 📈 indexing_genomes_rulegraph.png
 │         └── 📈 quality_control_rulegraph.png
 └── 📂 workflow/
      ├── 📂 envs/
	  │    ├── 📂 linux/
      │    │    ├── 🍜 bamclipper_v.1.0.yaml
      │    │    ├── 🍜 bcftools_v.1.15.1.yaml
      │    │    ├── 🍜 bedtools_v.2.30.0.yaml
      │    │    ├── 🍜 bowtie2_v.2.4.5.yaml
      │    │    ├── 🍜 bwa_v.0.7.17.yaml
      │    │    ├── 🍜 cutadapt_v.4.1.yaml
      │    │    ├── 🍜 fastq-screen_v.0.15.2.yaml
      │    │    ├── 🍜 fastqc_v.0.11.9.yaml
      │    │    ├── 🍜 gawk_v.5.1.0.yaml
      │    │    ├── 🍜 gevarli-base_v.2022.11.yaml
      │    │    ├── 🍜 lofreq_v.2.1.5.yaml
      │    │    ├── 🍜 multiqc_v.1.12.yaml
      │    │    ├── 🍜 nextclade_v.2.8.0.yaml
      │    │    ├── 🍜 pangolin_v.4.0.6.yaml
      │    │    ├── 🍜 samtools_v.1.15.1.yaml
      │    │    └── 🍜 sickle-trim_v.1.33.yaml
      │    └── 📂 osx/
      │    │    ├── 🍜 bamclipper_v.1.0.yaml
      │    │    ├── 🍜 bcftools_v.1.15.1.yaml
      │    │    ├── 🍜 bedtools_v.2.30.0.yaml
      │    │    ├── 🍜 bowtie2_v.2.4.5.yaml
      │    │    ├── 🍜 bwa_v.0.7.17.yaml
      │    │    ├── 🍜 cutadapt_v.4.1.yaml
      │    │    ├── 🍜 fastq-screen_v.0.15.2.yaml
      │    │    ├── 🍜 fastqc_v.0.11.9.yaml
      │    │    ├── 🍜 gawk_v.5.1.0.yaml
      │    │    ├── 🍜 gevarli-base_v.2022.11.yaml
      │    │    ├── 🍜 lofreq_v.2.1.5.yaml
      │    │    ├── 🍜 multiqc_v.1.12.yaml
      │    │    ├── 🍜 nextclade_v.2.8.0.yaml
      │    │    ├── 🍜 pangolin_v.4.0.6.yaml
      │    │    ├── 🍜 samtools_v.1.15.1.yaml
      │    │    └── 🍜 sickle-trim_v.1.33.yaml
      └── 📂 rules/
	       ├── 📜 gevarli.smk
	       ├── 📜 indexing_genomes.smk
           └── 📜 quality_control.smk
```


## ~ REFERENCES ~ ##
**Sustainable data analysis with Snakemake**  
Felix Mölder, Kim Philipp Jablonski, Brice Letcher, Michael B. Hall, Christopher H. Tomkins-Tinch, Vanessa Sochat, Jan Forster, Soohyun Lee, Sven O. Twardziok, Alexander Kanitz, Andreas Wilm, Manuel Holtgrewe, Sven Rahmann, Sven Nahnsen, Johannes Köster  
_F1000Research (2021)_  
**DOI**: [https://doi.org/10.12688/f1000research.29032.2](https://doi.org/10.12688/f1000research.29032.2)  
**Publication**: [https://f1000research.com/articles/10-33/v1](https://f1000research.com/articles/10-33/v1)  
**Source code**: [https://github.com/snakemake/snakemake](https://github.com/snakemake/snakemake)  
**Documentation**: [https://snakemake.readthedocs.io/en/stable/index.html](https://snakemake.readthedocs.io/en/stable/index.html)  

**Anaconda Software Distribution**  
Team  
_Computer software (2016)_  
**DOI**: []()  
**Publication**: [https://www.anaconda.com](https://www.anaconda.com)  
**Source code**: [https://github.com/snakemake/snakemake](https://github.com/snakemake/snakemake) (conda)  
**Documentation**: [https://snakemake.readthedocs.io/en/stable/index.html](https://snakemake.readthedocs.io/en/stable/index.html) (conda)  
**Source code**: [https://github.com/mamba-org/mamba](https://github.com/mamba-org/mamba) (mamba) 
**Documentation**: [https://mamba.readthedocs.io/en/latest/index.html](https://mamba.readthedocs.io/en/latest/index.html) (mamba)  

**HAVoC, a bioinformatic pipeline for reference-based consensus assembly and lineage assignment for SARS-CoV-2 sequences**  
Phuoc Thien Truong Nguyen, Ilya Plyusnin, Tarja Sironen, Olli Vapalahti, Ravi Kant & Teemu Smura  
_BMC Bioinformatics volume 22, Article number: 373 (2021)_  
**DOI**: [https://doi.org/10.1186/s12859-021-04294-2](https://doi.org/10.1186/s12859-021-04294-2)  
**Publication**: [https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-021-04294-2#Bib1](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-021-04294-2#Bib1)  
**Source code**: [https://bitbucket.org/auto_cov_pipeline/havoc](https://bitbucket.org/auto_cov_pipeline/havoc)  
**Documentation**: [https://www2.helsinki.fi/en/projects/havoc](https://www2.helsinki.fi/en/projects/havoc)  

**Nextclade: clade assignment, mutation calling and quality control for viral genomes**  
Ivan Aksamentov, Cornelius Roemer, Emma B. Hodcroft and Richard A. Neher  
_The Journal of Open Source Software_  
**DOI**: [https://doi.org/10.21105/joss.03773](https://doi.org/10.21105/joss.03773)  
**Publication**: [https://joss.theoj.org/papers/10.21105/joss.03773)(https://joss.theoj.org/papers/10.21105/joss.03773)  
**Source code**: [https://github.com/nextstrain/nextclade](https://github.com/nextstrain/nextclade)  
**Documentation**: [https://clades.nextstrain.org](https://clades.nextstrain.org)  

**Assignment of epidemiological lineages in an emerging pandemic using the pangolin tool**  
Áine O’Toole, Emily Scher, Anthony Underwood, Ben Jackson, Verity Hill, John T McCrone, Rachel Colquhoun, Chris Ruis, Khalil Abu-Dahab, Ben Taylor, Corin Yeats, Louis du Plessis, Daniel Maloney, Nathan Medd, Stephen W Attwood, David M Aanensen, Edward C Holmes, Oliver G Pybus and Andrew Rambaut  
_Virus Evolution, Volume 7, Issue 2 (2021)_  
**DOI**: [https://doi.org/10.1093/ve/veab064](https://doi.org/10.1093/ve/veab064)  
**Publication**: [https://academic.oup.com/ve/article/7/2/veab064/6315289](https://academic.oup.com/ve/article/7/2/veab064/6315289)  
**Source code**: [https://github.com/cov-lineages/pangolin](https://github.com/cov-lineages/pangolin) _(pangolin)_  
**Source code**: [https://github.com/cov-lineages/scorpio](https://github.com/cov-lineages/scorpio) _(scorpio)_  
**Documentation**: [https://cov-lineages.org/index.html](https://cov-lineages.org/index.html)  

**Tabix: fast retrieval of sequence features from generic TAB-delimited files**  
Heng Li  
_Bioinformatics, Volume 27, Issue 5 (2011)_  
**DOI**: [https://doi.org/10.1093/bioinformatics/btq671](https://doi.org/10.1093/bioinformatics/btq671)  
**Publication**: [https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3042176/](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3042176/)  
**Source code**: [https://github.com/samtools/samtools](https://github.com/samtools/samtools)  
**Documentation**: [http://samtools.sourceforge.net](http://samtools.sourceforge.net)  

**LoFreq: a sequence-quality aware, ultra-sensitive variant caller for uncovering cell-population heterogeneity from high-throughput sequencing datasets**  
Andreas Wilm, Pauline Poh Kim Aw, Denis Bertrand, Grace Hui Ting Yeo, Swee Hoe Ong, Chang Hua Wong, Chiea Chuen Khor, Rosemary Petric, Martin Lloyd Hibberd and Niranjan Nagarajan  
_Nucleic Acids Research, Volume 40, Issue 22 (2012)_  
**DOI**: [https://doi.org/10.1093/nar/gks918](https://doi.org/10.1093/nar/gks918)  
**Publication**: [https://pubmed.ncbi.nlm.nih.gov/23066108/](https://pubmed.ncbi.nlm.nih.gov/23066108/)  
**Source code**: [https://gitlab.com/treangenlab/lofreq](https://gitlab.com/treangenlab/lofreq) _(v2 used)_  
**Source code**: [https://github.com/andreas-wilm/lofreq3](https://github.com/andreas-wilm/lofreq3) _(see also v3 in Nim)_  
**Documentation**: [https://csb5.github.io/lofreq](https://csb5.github.io/lofreq)  

**The AWK Programming Language**  
Al Aho, Brian Kernighan and Peter Weinberger  
_Addison-Wesley (1988)_  
**ISBN**: [https://www.biblio.com/9780201079814](https://www.biblio.com/9780201079814)  
**Publication**: []()  
**Source code**: [https://github.com/onetrueawk/awk](https://github.com/onetrueawk/awk)  
**Documentation**: [https://www.gnu.org/software/gawk/manual/gawk.html](https://www.gnu.org/software/gawk/manual/gawk.html)  

**BEDTools: a flexible suite of utilities for comparing genomic features**  
Aaron R. Quinlan and Ira M. Hall  
_Bioinformatics, Volume 26, Issue 6 (2010)_  
**DOI**: [https://doi.org/10.1093/bioinformatics/btq033](https://doi.org/10.1093/bioinformatics/btq033)  
**Publication**: [https://academic.oup.com/bioinformatics/article/26/6/841/244688](https://academic.oup.com/bioinformatics/article/26/6/841/244688)  
**Source code**: [https://github.com/arq5x/bedtools2](https://github.com/arq5x/bedtools2)  
**Documentation**: [https://bedtools.readthedocs.io/en/latest/](https://bedtools.readthedocs.io/en/latest/)  

**ARTIC Network**  
Authors
Journal (year)  
**DOI**: []()  
**Publication**: []()  
**Source code**: [https://github.com/artic-network/primer-schemes](https://github.com/artic-network/primer-schemes)
**Documentation**:

**BAMClipper: removing primers from alignments to minimize false-negative mutations in amplicon next-generation sequencing**  
Chun Hang Au, Dona N. Ho, Ava Kwong, Tsun Leung Chan and Edmond S. K. Ma 
Scientific Reports 7:1567 (2017)  
**DOI**: [https://doi.org/10.1038/s41598-017-01703-6](https://doi.org/10.1038/s41598-017-01703-6)
**Publication**: [https://www.nature.com/articles/s41598-017-01703-6](https://www.nature.com/articles/s41598-017-01703-6)
**Source code**: [https://github.com/tommyau/bamclipper](https://github.com/tommyau/bamclipper)
**Documentation**:

**Twelve years of SAMtools and BCFtools**  
Petr Danecek, James K Bonfield, Jennifer Liddle, John Marshall, Valeriu Ohan, Martin O Pollard, Andrew Whitwham, Thomas Keane, Shane A McCarthy, Robert M Davies and Heng Li  
_GigaScience, Volume 10, Issue 2 (2021)_  
**DOI**: [https://doi.org/10.1093/gigascience/giab008](https://doi.org/10.1093/gigascience/giab008)  
**Publication**: [https://academic.oup.com/gigascience/article/10/2/giab008/6137722](https://academic.oup.com/gigascience/article/10/2/giab008/6137722)  
**Source code**: [https://github.com/samtools/samtools](https://github.com/samtools/samtools)  
**Documentation**: [http://samtools.sourceforge.net](http://samtools.sourceforge.net)  

**Fast and accurate short read alignment with Burrows-Wheeler Transform**  
Heng Li and Richard Durbin  
_Bioinformatics, Volume 25, Aricle 1754-60 (2009)_  
**DOI**: [https://doi.org/10.1093/bioinformatics/btp324](https://doi.org/10.1093/bioinformatics/btp324)  
**Publication**: [https://pubmed.ncbi.nlm.nih.gov/19451168@](https://pubmed.ncbi.nlm.nih.gov/19451168)  
**Source code**: [https://github.com/lh3/bwa](https://github.com/lh3/bwa)  
**Documentation**: [http://bio-bwa.sourceforge.net](http://bio-bwa.sourceforge.net)  

**Sickle: A sliding-window, adaptive, quality-based trimming tool for FastQ files**  
Joshi NA and Fass JN  
_(2011)  
**DOI**: [https://doi.org/](https://doi.org/)  
**Publication**: []()  
**Source code**: [https://github.com/najoshi/sickle](https://github.com/najoshi/sickle)  
**Documentation**: []()  

**Cutadapt Removes Adapter Sequences From High-Throughput Sequencing Reads**  
Marcel Martin  
_EMBnet Journal, Volume 17, Article 1 (2011)  
**DOI**: [https://doi.org/10.14806/ej.17.1.200](https://doi.org/10.14806/ej.17.1.200)  
**Publication**: [http://journal.embnet.org/index.php/embnetjournal/article/view/200](http://journal.embnet.org/index.php/embnetjournal/article/view/200)  
**Source code**: [https://github.com/marcelm/cutadapt](https://github.com/marcelm/cutadapt)  
**Documentation**: [https://cutadapt.readthedocs.io/en/stable/](https://cutadapt.readthedocs.io/en/stable)  

**MultiQC: summarize analysis results for multiple tools and samples in a single report**  
Philip Ewels, Måns Magnusson, Sverker Lundin and Max Käller  
_Bioinformatics, Volume 32, Issue 19 (2016)_  
**DOI**: [https://doi.org/10.1093/bioinformatics/btw354](https://doi.org/10.1093/bioinformatics/btw354)  
**Publication**: [https://academic.oup.com/bioinformatics/article/32/19/3047/2196507](https://academic.oup.com/bioinformatics/article/32/19/3047/2196507)  
**Source code**: [https://github.com/ewels/MultiQC](https://github.com/ewels/MultiQC)  
**Documentation**: [https://multiqc.info](https://multiqc.info)  

**FastQ Screen: A tool for multi-genome mapping and quality control**  
Wingett SW and Andrews S  
_F1000Research (2018)_  
**DOI**: [https://doi.org/10.12688/f1000research.15931.2](https://doi.org/10.12688/f1000research.15931.2)  
**Publication**: [https://f1000research.com/articles/7-1338/v2](https://f1000research.com/articles/7-1338/v2)  
**Source code**: [https://github.com/StevenWingett/FastQ-Screen](https://github.com/StevenWingett/FastQ-Screen)  
**Documentation**: [https://www.bioinformatics.babraham.ac.uk/projects/fastq_screen](https://www.bioinformatics.babraham.ac.uk/projects/fastq_screen)  

**FastQC: A quality control tool for high throughput sequence data**  
Simon Andrews  
_Online (2010)_  
**DOI**: [https://doi.org/](https://doi.org/)  
**Publication**: []()  
**Source code**: [https://github.com/s-andrews/FastQC](https://github.com/s-andrews/FastQC)  
**Documentation**: [https://www.bioinformatics.babraham.ac.uk/projects/fastqc](https://www.bioinformatics.babraham.ac.uk/projects/fastqc)  

**Seqtk: A fast and lightweight tool for processing sequences in the FASTA or FASTQ format**  
Heng Li  
_Online (2014)_  
**DOI**: [https://doi.org/](https://doi.org/)  
**Publication**: []()  
**Source code**: [https://github.com/lh3/seqtk](https://github.com/lh3/seqtk)  
**Documentation**: [https://bioweb.pasteur.fr/packages/pack@seqtk@1.3](https://bioweb.pasteur.fr/packages/pack@seqtk@1.3)  

###############################################################################
