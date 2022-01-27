
# GeVarLi: GEnome assembly, VARiant calling and LIneage assignment #

## Description ##

GeVarLi	is a bioinformatic pipeline used for SARS-CoV-2	genomes assembly from Illumina short reads with tiled libraries sequencing.  

- First, control reads qualities and clean it, if needed.  
- Intermediates usefull files are also provided, like alignement bam files (use IGV), variants vcf files and genome coverage statistics.  
- Last, submit obtained consensus sequences to Nextclade and Pangolin classifications.  

This is the **macOSX** version (specific conda environements).


## Badges ##

![Maintener](<https://badgen.net/badge/Maintener/Nicolas Fernandez/blue?scale=0.9>)
![MacOSX](<https://badgen.net/badge/icon/Hight Sierra (10.13) | Catalina (10.15) | Big Sure (11)/E6055C?icon=apple&label&list=|&scale=0.9>)
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

### Conda _(¡prior!)_ ###

- Install **Conda** (_i.e. Miniconda3 with Python 3.9 on MacOSX-64-bit_): [Latest Miniconda Installer](https://docs.conda.io/en/latest/miniconda.html#latest-miniconda-installer-links)  
_Follow the screen prompt instructions_  
```shell
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
bash ./Miniconda3-latest-MacOSX-x86_64.sh
rm -f ./Miniconda3-latest-MacOSX-x86_64.sh
```
_Restart shell (close and reopen the terminal window)_


### Snakemake _(¡prior!)_ ###

- Install **Snakemake** (_i.e. v.6.12.1_) using Conda  
_Follow the screen prompt instructions_  
```shell
conda install -c conda-forge mamba --yes
mamba install -c bioconda rename --yes
mamba install -c conda-forge -c bioconda snakemake=6.12.1 --yes
```


### GeVarLi ###

- Clone the [GeVarLi_Pipeline_macOSX](https://gitlab.com/ird_transvihmi/GeVarLi_Pipeline_macOSX) repository on GitLab (_ID: 31729804_)

#### HTTPS ####
_If you want to authenticate each time you perform an operation between your computer and GitLab_
```shell
git clone https://gitlab.com/ird_transvihmi/GeVarLi_Pipeline_macOSX.git
```
```shell
mv ./GeVarLi_Pipeline_macOSX/ ~/Desktop/GeVarLi_Pipeline_macOSX/
cd ~/Desktop/GeVarli_Pipeline_macOSX/
```

#### SSH ####
_If you want to authenticate only one time (follow instructions: [SSH documentation](https://docs.gitlab.com/ee/ssh/index.html))_
```shell
git clone git@gitlab.com:ird_transvihmi/GeVarLi_Pipeline_macOSX.git
```
```shell
mv GeVarLi_Pipeline_macOSX/ ~/Desktop/GeVarLi_Pipeline_macOSX/
cd ~/Desktop/GeVarli_Pipeline_macOSX/
```

Difference between **Download** and **Clone**:  
- To create a copy of a remote repository’s files on your computer, you can either **Download** or **Clone** the repository  
- If you download it, you cannot sync the repository with the remote repository on GitLab  
- Cloning a repository is the same as downloading, except it preserves the Git connection with the remote repository  
- You can then modify the files locally and upload the changes to the remote repository on GitLab  
- You can then **update** the files locally and download the changes from the remote repository on GitLab  
```shell
git pull
```


## Usage ##

- Copy your **paired-end** reads in **.fastq.gz** format files into: **./resources/reads/** directory
- Double-click on **GeVarLi.sh** bash script to run the GeVarLi pipeline
_A new terminal window will open and yours analyzes will start)_

- _Option: Edit **config.yaml** file in **./config/** directory
- _Option: Edit **fastq-screen.conf** file in **./config/** directory


### Results ###

Yours results are available in **./results** directory, as follow:

#### root ####

- *All_consensus_sequences.fasta*: all consensus assembled genomes in fasta format
- *All_genome_coverages.tsv*: all genome coverage in tsv format
- *All_pangolin_lineages.tsv*: all pangolin lineages in tsv format
- *All_nextclade_lineages.tsv*: _comming soon_ all nextclade lineages in tsv format

#### 00_Quality_Control ####

- *fastq-screen*: raw reads putative contaminations reports for each samples in html, png and txt formats 
- *fastqc*: raw reads quality reports for each samples in html and zip format
- *multiqc*: fastq-screen and fastqc results agrgation report for all samples in html format

#### 01_Trimming ####

- *sickle*: paired reads, without adapters and quality trimmed
- _cutadapt: paired reads, without adapters (default: tempdir, removed, save disk usage)_

#### 02_Mapping ####

- _mapped.sam_: (default: tempdir, removed, save disk usage)_
- _sortbynames.bam_: (default: tempdir, removed, save disk usage)_
- _fixmate.bam_: (default: tempdir, removed, save disk usage)_
- _sorted.bam_: (default: tempdir, removed, save disk usage)_
- *markdup.bam*:
- *markdup.bai*:

#### 03_Coverage ####
#### 04_Variants ####
#### 05_Consensus ####
#### 06_Lineages ####
#### 10_graphs ####
#### 11_Reports ####



###  Configuration ###

#### Resources ####

Edit to match your hardware configuration  
- **cpus**:
- **mem_gb**:
- **tmpdir**:

#### Environments ####

Edit if you change some environments (i.e.new version) in ./workflow/envs/tools-version.yaml files


#### Aligner ####

#### Consensus ####

#### InDel ####

#### BWA ####

#### Bowtie2 ####

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


### Directories paths ###

  GeVarLi.sh  
  README.md  
  **config**/  
 ├──  config.yaml  
 └──  fastq-screen.conf  
  **resources/**  
 ├──  **genomes/**  
 │  ├──  Adapters.fasta  
 │  ├──  Ebola_ZEBOV.fasta  
 │  ├──  Echerichia_coli_U00096.fasta  
 │  ├──  HIV_HXB2.fasta  
 │  ├──  Phi-X174.fasta  
 │  ├──  SARS-CoV-2_Wuhan-WIV04_2019.fasta  
 │  └──  UniVec_wo_phi-X174.fasta  
 ├──  **indexes/**  
 │  ├──  **bowtie2/**  
 │  │  ├──  SARS-CoV-2_Wuhan-WIV04_2019  
 │  └──  **bwa/**  
 │     ├──  SARS-CoV-2_Wuhan-WIV04_2019  
 │     ├──  Adapters  
 │     ├──  Ebola_ZEBOV  
 │     ├──  Echerichia_coli_U00096  
 │     ├──  HIV_HXB2  
 │     ├──  Phi-X174  
 │     ├──  UniVec_wo_phi-X174  
 ├──  **nextclade/**  
 │  ├──  genemap.gff  
 │  ├──  primers.csv  
 │  ├──  qc.json  
 │  ├──  reference.fasta  
 │  ├──  sequences.fasta  
 │  ├──  tag.json  
 │  └──  tree.json  
 └──  **reads/**  
    └──  .gitkeep  
  **visuals/**  
 ├──  download_button.png  
 └──  rulegraph.png  
  **workflow/**  
 ├──  **envs/**  
 │  ├──  bcftools-1.14.yaml  
 │  ├──  bedtools-2.30.0.yaml  
 │  ├──  bowtie2-2.4.4.yaml  
 │  ├──  bwa-0.7.17.yaml  
 │  ├──  cutadapt-3.5.yaml  
 │  ├──  fastq-screen-0.14.0.yaml  
 │  ├──  fastqc-0.11.9.yaml  
 │  ├──  lofreq-2.1.5.yaml  
 │  ├──  multiqc-1.11.yaml  
 │  ├──  nextclade-1.9.0.yaml  
 │  ├──  pangolin-3.1.17.yaml  
 │  ├──  samtools-1.14.yaml  
 │  └──  sickle-trim-1.33.yaml  
 └──  **rules/**  
    └──  gevarli.smk  


## Support ##

1. RTFM! (Read The Fabulous Manual! ^^.)
2. Read de awsome wiki ;)
3. Create a new issue: Issues > New issue > Describe your issue
4. Send an email to [nicolas.fernandez@ird.fr](url)
5. Call me to `+33.(0)4.67.41.55.xx` (No don't please _O\_o_!)


## Roadmap ##

Add a wiki !  
Finish documentation about "terminal" and "results"
Add new features  


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

