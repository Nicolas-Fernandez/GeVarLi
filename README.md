
# GeVarLi: GEnome assembly, VARiant calling and LIneage assignation #

## Description ##

GeVarLi	is a bioinformatic pipeline used for SARS-CoV-2	genomes assembly from Illumina short reads with tiled libraries sequencing.  

- First, control reads quality and clean it, if needed.  
- Intermediates usefull files are also provided, like alignement bam files (use IGV), variants vcf files and genome coverage statistics.  
- Last, submit obtained consensus sequences to Nextclade and Pangolin classifications.  

_This is the **macOSX** version (specific conda environements)._


## Badges ##

![Maintener](<https://badgen.net/badge/Maintener/Nicolas Fernandez/blue?scale=0.9>)
![MacOSX](<https://badgen.net/badge/icon/Hight Sierra (10.13.6) | Catalina (10.15.7) | Big Sure (11.6.3) | Monterey (12.2.0)/E6055C?icon=apple&label&list=|&scale=0.9>)
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


## Visuals ##

<img src="./visuals/rulegraph.png" width="150" height="300">  


## Installations ##

### Conda _(required)_ ###

Install **Conda** (_i.e. Miniconda3 with Python 3.9 on MacOSX-64-bit_): [Latest Miniconda Installer](https://docs.conda.io/en/latest/miniconda.html#latest-miniconda-installer-links)  
_Follow the screen prompt instructions_  
```shell
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
bash ./Miniconda3-latest-MacOSX-x86_64.sh
rm -f ./Miniconda3-latest-MacOSX-x86_64.sh
```
_Restart shell (close and reopen the terminal window_


### Snakemake _(required)_ ###

Install **Snakemake** (_i.e. v.6.12.1_) using Conda  
_Follow the screen prompt instructions_  
```shell
conda install -c conda-forge mamba --yes
mamba install -c bioconda rename --yes
mamba install -c conda-forge -c bioconda snakemake=6.12.1 --yes
```


### GeVarLi ###

Clone the [GeVarLi_Pipeline_macOSX](https://gitlab.com/ird_transvihmi/GeVarLi_Pipeline_macOSX) repository on GitLab (_ID: 31729804_):

#### HTTPS ####
If you want to authenticate each time you perform an operation between your computer and GitLab
```shell
git clone https://gitlab.com/ird_transvihmi/GeVarLi_Pipeline_macOSX.git
cd ./GeVarLi_Pipeline_macOSX/
```

**OR**

#### SSH ####
If you want to authenticate only one time (_follow instructions: [SSH documentation](https://docs.gitlab.com/ee/ssh/index.html)_)
```shell
git clone git@gitlab.com:ird_transvihmi/GeVarLi_Pipeline_macOSX.git
cd ./GeVarLi_Pipeline_macOSX/
```

Difference between **Download** and **Clone**:  
- To create a copy of a remote repository’s files on your computer, you can either **Download** or **Clone** the repository  
- If you download it, you **cannot sync** the repository with the remote repository on GitLab  
- Cloning a repository is the same as downloading, except it preserves the Git connection with the remote repository  
- You can then modify the files locally and upload the changes to the remote repository on GitLab  
- You can then **update** the files locally and download the changes from the remote repository on GitLab  
```shell
git pull --verbose
```


## Usage ##

1. Copy your **paired-end** reads in **.fastq.gz** format files into: **./resources/reads/** directory
2. Double-click on **GeVarLi.sh** bash script to run the GeVarLi pipeline  
_A new terminal window will open and yours analyzes will start)_  

_Option: Edit **config.yaml** file in **./config/** directory_  
_Option: Edit **fastq-screen.conf** file in **./config/** directory_  


### Results ###

Yours results are available in **./results** directory, as follow:

#### root ####

- **All_consensus_sequences.fasta**: all consensus sequences, in _fasta_ format
- **All_genome_coverages.tsv**: all genome coverages, in _tsv_ format
- **All_nextclade_lineages.tsv**: all nextclade lineage reports, in _tsv_ format
- **All_pangolin_lineages.tsv**: all pangolin lineage reports, in _tsv_ format
- **All_readsQC_reports.html**: all reads quality reports from MultiQC, in _html_ format

#### 00_Quality_Control ####

- **fastq-screen**: raw reads putative contaminations reports for each samples, in _html_, _png_ and _txt_ formats 
- **fastqc**: raw reads quality reports for each samples, in _html_ and _zip_ formats
- **multiqc**: fastq-screen and fastqc results agregation report for all samples, in _html_ format

#### 01_Trimming ####

- **sickle/**: paired reads, without adapters and quality trimmed, in _fastq.gz_ format
- _cutadapt/: paired reads, without adapters (default: tempdir, removed, save disk usage)_

#### 02_Mapping ####

- **/<sample/>/_/<aligner/>/_markdup.bam**: 
- **/<sample/>/_/<aligner/>/_markdup.bai**:
- _/<sample/>/_/<aligner/>/_mapped.sam_: (default: tempdir, removed, save disk usage)_
- _/<sample/>/_/<aligner/>/_sortbynames.bam_: (default: tempdir, removed, save disk usage)_
- _/<sample/>/_/<aligner/>/_fixmate.bam_: (default: tempdir, removed, save disk usage)_
- _/<sample/>/_/<aligner/>/_sorted.bam_: (default: tempdir, removed, save disk usage)_

#### 03_Coverage ####

- **/<sample/>/_/<aligner/>/_/<mincov/>/_coverage-stats.tsv**:

#### 04_Variants ####

- **/<sample/>/_/<aligner/>/_/<mincov/>/_maskedref.fasta**: reference sequence, masked for low coverage regions, in _fasta_ format
- **/<sample/>/_/<aligner/>/_/<mincov/>/_maskedref.fasta.fai**: reference sequence indexes, masked for low coverages regions, in _fai_ format
- **/<sample/>/_/<aligner/>/_/<mincov/>/_indelqual.bam**: 
- **/<sample/>/_/<aligner/>/_/<mincov/>/_indelqual.bai**:
- **/<sample/>/_/<aligner/>/_/<mincov/>/_variantcall.vcf**: SNVs and Indels calling in _vcf_ format
- **/<sample/>/_/<aligner/>/_/<mincov/>/_variantfilt.vcf**: SNVs and Indels passing filters, in _vcf_ format
- _/<sample/>/_/<aligner/>/_/<mincov/>/_indelfilt.vcf.bgz: (default: tempdir, removed, save disk usage)_
- _/<sample/>/_/<aligner/>/_/<mincov/>/_indelfilt.vcf.bgz.tbi: (default: tempdir, removed, save disk usage)_

#### 05_Consensus ####

- **/<sample/>/_/<aligner/>/_/<mincov/>/_consensus.fasta**: consensus sequence, without low coverage regions, in _fasta_ format

#### 06_Lineages ####

- **/<sample/>/_/<aligner/>/_/<mincov/>/_pangolin-report.csv**: pangolin and scorpio lineage assignation and quality report, in _csv_ format
- **/<sample/>/_/<aligner/>/_/<mincov/>/_nextclade-report.tsv**: nextclade lineage assignation and quality report, in _tsv_ format
- **/<sample/>/_/<aligner/>/_/<mincov/>/_nextclade-alignement/**: nextclade directory containing:
    - **/<sample/>/_/<aligner/>/_/<mincov/>/_consensus.aligned.fasta**:
    - **/<sample/>/_/<aligner/>/_/<mincov/>/_consensus.insertions.csv**:
    - **/<sample/>/_/<aligner/>/_/<mincov/>/_consensus.errors.csv**:
    - **/<sample/>/_/<aligner/>/_/<mincov/>/_consensus.gene./<gene/>.fasta**: for genes E, M, N, S and ORFs 1a, 1b, 3a, 6, 7a, 7b, 8, 9b

#### 10_graphs ####

- **dag**: , in _pdf_ and _png_ formats
- **filegraph**: , in _pdf_ and _png_ formats
- **rulegraph**: , in _pdf_ and _png_ formats

#### 11_Reports ####

- All _non-empty_ **log** for each tool and each sample
- files_summary.txt: , in _txt_ format 

###  Configuration ###

If you want see or edit default settings in **config.yaml** file in **./config/** directory  

#### Resources ####

Edit to match your hardware configuration  
- **cpus**:
- **mem_gb**:
- **tmpdir**:

#### Environments ####

Edit if you change some environments (i.e.new version) in ./workflow/envs/tools-version.yaml files


#### Aligner ####

- TODO

#### Consensus ####

- TODO

#### InDel ####

- TODO

#### BWA ####

- TODO

#### Bowtie2 ####

- TODO

#### Sickle-trim ####

- **command**: Pipeline wait for paired-end reads (default config: 'pe') see: rule sickletrim on ./workflow/rules/reads_quality_control_pipeline.smk snake file
- **encoding**: If your data are from recent Illumina run, let 'sanger' (default config: 'sanger')
- **quality**: [Q-phred score](https://en.wikipedia.org/wiki/Phred_quality_score) limit (default config: '30')
- **length**: Read length limit, after trim (default config: '75')

#### Cutadapt ####

- **length**: Discard reads shorter than length, after trim (default config: '25')
- **kit**: Sequence of an adapter ligated to the 3' end of the first read (default config: Truseq, Nextera and Small Illumina kits)  

#### Fastq-Screen #####

- **config**: Path to the fastq-screen configuration file (default config: ./config/fastq-screen.conf)
- **subset**: Don't use the whole sequence file, but create a temporary dataset of this specified number of read (default config: '10000', set '0' for all dataset)
- **aligner**: Specify the aligner to use for the mapping. Valid arguments are 'bowtie', bowtie2' or 'bwa' (default config: 'bwa')

##### fastq-screen.conf #####

- **path**: Set this value to tell the program where to find your chosen aligner (default :/usr/local/\<tool\>
- **bismark**: Same for bismark (for bisulfite sequencing only)
- **threads**: Set this value to the number of cores you want for mapping reads (default: 1, but overwrited by Snakemake and config.yaml file)
- **databases**: This section enables you to configure multiple genomes databases (aligner index files) to search against in your screen


## Support ##

1. RTFM! (Read The Fabulous Manual! ^^.)
2. Read de awsome wiki ;)
3. Create a new issue: Issues > New issue > Describe your issue
4. Send an email to [nicolas.fernandez@ird.fr](url)
5. Call me to +33.(0)4.67.41.55... No don't please _O\_o_!


## Roadmap ##

Add a wiki ! And move may sections from README.md to the wiki !  
End documentation about "results" and "configuration"...  
Add new features ? (i.e. adding pangolin lineage)  


## Contributing ##

Open to contributions :)  
Testing code, finding issues, asking for update, proposing new features ...  
Use Git tools to share!  


## Authors and acknowledgment ##

- Nicolas Fernandez (Developer and Maintener)  
- Christelle Butel (Reporter, User-addict, Fetaures inspiration source)  
- Eddy Kinganda-Lusamaki (who ask me to find a free open source unix friendly pipeline, now we have Eddy)  


## License ##

[GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)  


## Project status ##

This project is regularly update and actively maintened  
However, you can be volunteer to step in as a maintainer  

For information about main git roles:  
- **Guests** are _not active contributors_ in private projects, they can only see, and leave comments and issues.  
- **Reporters** are _read-only contributors_, they can't write to the repository, but can on issues.  
- **Developers** are _direct contributors_, they have access to everything to go from idea to production,  
unless something has been explicitly restricted.  
- **Maintainers** are _super-developers_, they are able to push to master, deploy to production.  
This role is often held by maintainers and engineering managers.  
- **Owners** are essentially _group-admins_, they can give access to groups and have destructive capabilities.  

### Directories tree structure ###

  GeVarLi.sh  
  README.md  
  **config**/  
 ├──  config.yaml  
 └──  fastq-screen.conf  
  **resources/**  
 ├──  **genomes/**  
/ │   ├──  Adapters.fasta  
 │   ├──  Ebola_ZEBOV.fasta  
 │   ├──  Echerichia_coli_U00096.fasta  
 │   ├──  HIV_HXB2.fasta  
 │   ├──  Phi-X174.fasta  
 │   ├──  SARS-CoV-2_Wuhan-WIV04_2019.fasta  
 │   └──  UniVec_wo_phi-X174.fasta  
 ├──  **indexes/**  
 │   ├──  **bowtie2/**  
 │   │  └──  SARS-CoV-2_Wuhan-WIV04_2019  
 │   └──  **bwa/**  
 │       ├──  SARS-CoV-2_Wuhan-WIV04_2019  
 │       ├──  Adapters  
 │       ├──  Ebola_ZEBOV  
 │       ├──  Echerichia_coli_U00096  
 │       ├──  HIV_HXB2  
 │       ├──  Phi-X174  
 │       └──  UniVec_wo_phi-X174  
 ├──  **nextclade/**  
 │   ├──  genemap.gff  
 │   ├──  primers.csv  
 │   ├──  qc.json  
 │   ├──  reference.fasta  
 │   ├──  sequences.fasta  
 │   ├──  tag.json  
 │   └──  tree.json  
 └──  **reads/**  
     └──  .gitkeep  
  **visuals/**  
 └──  rulegraph.png  
  **workflow/**  
 ├──  **envs/**  
 │   ├──  bcftools-1.14.yaml  
 │   ├──  bedtools-2.30.0.yaml  
 │   ├──  bowtie2-2.4.4.yaml  
 │   ├──  bwa-0.7.17.yaml  
 │   ├──  cutadapt-3.5.yaml  
 │   ├──  fastq-screen-0.14.0.yaml  
 │   ├──  fastqc-0.11.9.yaml  
 │   ├──  lofreq-2.1.5.yaml  
 │   ├──  multiqc-1.11.yaml  
 │   ├──  nextclade-1.10.1.yaml  
 │   ├──  pangolin-3.1.17.yaml  
 │   ├──  samtools-1.14.yaml  
 │   └──  sickle-trim-1.33.yaml  
 └──  **rules/**  
     └──  gevarli.smk  

### References ###

**HAVoC, a bioinformatic pipeline for reference-based consensus assembly and lineage assignment for SARS-CoV-2 sequences**  
Phuoc Thien Truong Nguyen, Ilya Plyusnin, Tarja Sironen, Olli Vapalahti, Ravi Kant & Teemu Smura  
_BMC Bioinformatics volume 22, Article number: 373 (2021)_  
**DOI**:[https://doi.org/10.1186/s12859-021-04294-2](https://doi.org/10.1186/s12859-021-04294-2)  
**Publication**:[https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-021-04294-2#Bib1](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-021-04294-2#Bib1)  
**Source code**:[https://bitbucket.org/auto_cov_pipeline/havoc/src/master/](https://bitbucket.org/auto_cov_pipeline/havoc/src/master/)  
**Documentation**:[https://www2.helsinki.fi/en/projects/havoc](https://www2.helsinki.fi/en/projects/havoc)  

**Sustainable data analysis with Snakemake**  
Felix Mölder, Kim Philipp Jablonski, Brice Letcher, Michael B. Hall, Christopher H. Tomkins-Tinch, Vanessa Sochat, Jan Forster, Soohyun Lee, Sven O. Twardziok, Alexander Kanitz, Andreas Wilm, Manuel Holtgrewe, Sven Rahmann, Sven Nahnsen, Johannes Köster  
_F1000Research (2021)_  
**DOI**:[](https://doi.org/10.12688/f1000research.29032.2)  
**Publication**:[](https://f1000research.com/articles/10-33/v1)  
**Source code**:[](https://github.com/snakemake/snakemake)  
**Documentation**:[](https://snakemake.readthedocs.io/en/stable/index.html)  

**Nextclade: clade assignment, mutation calling and quality control for viral genomes**  
Ivan Aksamentov, Cornelius Roemer, Emma B. Hodcroft and Richard A. Neher  
_The Journal of Open Source Software_  
**DOI**:[](https://doi.org/10.21105/joss.03773)  
**Publication**:[](https://joss.theoj.org/papers/10.21105/joss.03773)  
**Source code**:[](https://github.com/nextstrain/nextclade)  
**Documentation**:[](https://clades.nextstrain.org/)  

**Assignment of epidemiological lineages in an emerging pandemic using the pangolin tool**  
Áine O’Toole, Emily Scher, Anthony Underwood, Ben Jackson, Verity Hill, John T McCrone, Rachel Colquhoun, Chris Ruis, Khalil Abu-Dahab, Ben Taylor, Corin Yeats, Louis du Plessis, Daniel Maloney, Nathan Medd, Stephen W Attwood, David M Aanensen, Edward C Holmes, Oliver G Pybus and Andrew Rambaut  
_Virus Evolution, Volume 7, Issue 2 (2021)_  
**DOI**:[](https://doi.org/10.1093/ve/veab064)  
**Publication**:[](https://academic.oup.com/ve/article/7/2/veab064/6315289)  
**Source code**:[](https://github.com/cov-lineages/pangolin) _(pangolin)_  
**Source code**:[](https://github.com/cov-lineages/scorpio) _(scorpio)_  
**Documentation**:[](https://cov-lineages.org/index.html)  

**Tabix: fast retrieval of sequence features from generic TAB-delimited files**  
Heng Li  
_Bioinformatics, Volume 27, Issue 5 (2011)_  
**DOI**:[](https://doi.org/10.1093/bioinformatics/btq671)  
**Publication**:[](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3042176/)  
**Source code**:[](https://github.com/samtools/samtools)  
**Documentation**:[](http://samtools.sourceforge.net/)  

**LoFreq: a sequence-quality aware, ultra-sensitive variant caller for uncovering cell-population heterogeneity from high-throughput sequencing datasets**  
Andreas Wilm, Pauline Poh Kim Aw, Denis Bertrand, Grace Hui Ting Yeo, Swee Hoe Ong, Chang Hua Wong, Chiea Chuen Khor, Rosemary Petric, Martin Lloyd Hibberd and Niranjan Nagarajan  
_Nucleic Acids Research, Volume 40, Issue 22 (2012)_  
**DOI**:[](https://doi.org/10.1093/nar/gks918)  
**Publication**:[](https://pubmed.ncbi.nlm.nih.gov/23066108/)  
**Source code**:[](https://gitlab.com/treangenlab/lofreq) _(v2 used)_  
**Source code**:[](https://github.com/andreas-wilm/lofreq3) _(see also v3 in Nim)_  
**Documentation**:[](https://csb5.github.io/lofreq/)  

**The AWK Programming Language**  
Al Aho, Brian Kernighan and Peter Weinberger  
_Addison-Wesley (1988)_  
**ISBN**:[](https://www.biblio.com/9780201079814)  
**Publication**:[]()  
**Source code**:[](https://github.com/onetrueawk/awk)  
**Documentation**:[](https://www.gnu.org/software/gawk/manual/gawk.html)  

**BEDTools: a flexible suite of utilities for comparing genomic features**  
Aaron R. Quinlan and Ira M. Hall  
_Bioinformatics, Volume 26, Issue 6 (2010)_  
**DOI**:[](https://doi.org/10.1093/bioinformatics/btq033)  
**Publication**:[](https://academic.oup.com/bioinformatics/article/26/6/841/244688)  
**Source code**:[](https://github.com/arq5x/bedtools2)  
**Documentation**:[](https://bedtools.readthedocs.io/en/latest/)  

**Twelve years of SAMtools and BCFtools**  
Petr Danecek, James K Bonfield, Jennifer Liddle, John Marshall, Valeriu Ohan, Martin O Pollard, Andrew Whitwham, Thomas Keane, Shane A McCarthy, Robert M Davies and Heng Li  
_GigaScience, Volume 10, Issue 2 (2021)_  
**DOI**:[](https://doi.org/10.1093/gigascience/giab008)  
**Publication**:[](https://academic.oup.com/gigascience/article/10/2/giab008/6137722)  
**Source code**:[](https://github.com/samtools/samtools)  
**Documentation**:[](http://samtools.sourceforge.net/)  

**Fast and accurate short read alignment with Burrows-Wheeler Transform**  
Heng Li and Richard Durbin  
_Bioinformatics, Volume 25, Aricle 1754-60 (2009)_  
**DOI**:[](https://doi.org/10.1093/bioinformatics/btp324)  
**Publication**:[](https://pubmed.ncbi.nlm.nih.gov/19451168/)  
**Source code**:[](https://github.com/lh3/bwa)  
**Documentation**:[](http://bio-bwa.sourceforge.net/)  

**Sickle: A sliding-window, adaptive, quality-based trimming tool for FastQ files**  
Joshi NA and Fass JN  
_(2011)  
**DOI**:[](https://doi.org/)  
**Publication**:[]()  
**Source code**:[](https://github.com/najoshi/sickle)  
**Documentation**:[]()  

**Cutadapt Removes Adapter Sequences From High-Throughput Sequencing Reads**  
Marcel Martin  
_EMBnet Journal, Volume 17, Article 1 (2011)  
**DOI**:[](https://doi.org/10.14806/ej.17.1.200)  
**Publication**:[](http://journal.embnet.org/index.php/embnetjournal/article/view/200)  
**Source code**:[](https://github.com/marcelm/cutadapt/)  
**Documentation**:[](https://cutadapt.readthedocs.io/en/stable/)  

**MultiQC: summarize analysis results for multiple tools and samples in a single report**  
Philip Ewels, Måns Magnusson, Sverker Lundin and Max Käller  
_Bioinformatics, Volume 32, Issue 19 (2016)_  
**DOI**:[](https://doi.org/10.1093/bioinformatics/btw354)  
**Publication**:[](https://academic.oup.com/bioinformatics/article/32/19/3047/2196507)  
**Source code**:[](https://github.com/ewels/MultiQC)  
**Documentation**:[](https://multiqc.info/)  

**FastQ Screen: A tool for multi-genome mapping and quality control**  
Wingett SW and Andrews S  
_F1000Research (2018)_  
**DOI**:[](https://doi.org/10.12688/f1000research.15931.2)  
**Publication**:[](https://f1000research.com/articles/7-1338/v2)  
**Source code**:[](https://github.com/StevenWingett/FastQ-Screen)  
**Documentation**:[](https://www.bioinformatics.babraham.ac.uk/projects/fastq_screen/)  

**FastQC: A quality control tool for high throughput sequence data**  
Simon Andrews  
_Online (2010)_  
**DOI**:[](https://doi.org/)  
**Publication**:[]()  
**Source code**:[](https://github.com/s-andrews/FastQC)  
**Documentation**:[](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)  


### Glossary ###

- **BAM**: Binary Alignment Map
- **BAI**: BAM Indexes
- **FASTA**: Fast-All
- **FASTQ**: FASTA with Quality data
- **FAI**: FASTA Indexes
- **SAM**: Sequence Alignment Map
