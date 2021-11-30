# RQCP: Reads Quality Control Pipeline #

## Description ##
RQCP check NGS (illumina) reads quality and clean it if needed, as you set, using: 

- Cutadapts to trim NGS sequencing adapters  
- Sickle-trim to trim reads on base-calling quality score  
- Fastq-join to join mates reads (forward R1 and Reverse R2) when it's possible  
- FastQC to check global quality
- FastqScreen to check putative contamination(s)
- MultiQC to generate HTML reports  

## Badges ##
![Maintener](<https://badgen.net/badge/Maintener/Nicolas Fernandez/blue?scale=0.9>)
![MacOS](<https://badgen.net/badge/icon/Hight Sierra (10.13),Catalina (10.15),Big Sure (11)/cyan?icon=apple&label&list=|&scale=0.9>)
![Issues closed](<https://badgen.net/badge/Issues closed/2/green?scale=0.9>)
![Issues opened](<https://badgen.net/badge/Issues opened/0/yellow?scale=0.9>)
![Maintened](<https://badgen.net/badge/Maintened/Yes/red?scale=0.9>)
![Wiki](<https://badgen.net/badge/icon/Wiki/pink?icon=wiki&label&scale=0.9>)
![Open Source](<https://badgen.net/badge/icon/Open Source/purple?icon=https://upload.wikimedia.org/wikipedia/commons/4/44/Corazón.svg&label&scale=0.9>)
![GNU AGPL v3](<https://badgen.net/badge/Licence/GNU AGPL v3/grey?scale=0.9>)
![Bash](<https://badgen.net/badge/icon/Bash 3.2.57/black?icon=terminal&label&scale=0.9>)
![Python](<https://badgen.net/badge/icon/Python 3.8.7/black?icon=https://upload.wikimedia.org/wikipedia/commons/0/0a/Python.svg&label&scale=0.9>)
![Snakemake](<https://badgen.net/badge/icon/Snakemake 5.11.2/black?icon=https://upload.wikimedia.org/wikipedia/commons/d/d3/Python_icon_%28black_and_white%29.svg&label&scale=0.9>)
![Conda](<https://badgen.net/badge/icon/Conda 4.10.3/black?icon=codacy&label&scale=0.9>)

## Visuals ##
_Good idea to include screenshots or GIFs (see ttygif or Asciinema)_  

## Installation ##

### Conda _(prior!)_ ###
Download and install **Conda**: [Latest Miniconda Installer](https://docs.conda.io/en/latest/miniconda.html#latest-miniconda-installer-links)  
1. Donwload conda installer _(i.e. for Miniconda3 with Python 3.9 on MacOSX-64-bit)_:
```shel
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
```

2. Install conda using installer bash script:
_Follow the prompts on the installer screens_  
```shell
bash Miniconda3-latest-MacOSX-x86_64.sh
```

3. Remove conda installer:
```shell
rm Miniconda3-latest-MacOSX-x86_64.sh
```

4. Restart shell, close and reopen new terminal window

### Snakemake _(prior!)_ ###

Install **Snakemake** using Conda package management system  
_Follow the prompts on the installer screens_  
```shell
conda install -c bioconda -c conda-forge snakemake
```

### RQCP ###

**Download** _OR_ clone the **Reads Quality Control Pipeline** project  

#### Download ####

- Download source code archive (_zip_, **tar.gz**, _tar.bz2_, _tar_): [RQCP on GitLab](https://gitlab.com/ird_transvihmi/Reads_Quality_Control_Pipeline)  
```shel
wget  https://gitlab.com/ird_transvihmi/Reads_Quality_Control_Pipeline/-/archive/main/Reads_Quality_Control_Pipeline-main.tar.gz -O ~/Desktop/ 
```

_alternatively_:
![Image of download button](./visuals/download_button.png)  

- Extract and remove the the archive (i.e. tar.gz):
```shell
tar -xzvf path/to/archive/Reads_Quality_Control_Pipeline-main.tar.gz
rm path/to/archive/Reads_Quality_Control_Pipeline-main.tar.gz 
mv ~/Desktop/Reads_Quality_Control_Pipeline-main ~/Desktop/Reads_Quality_Control_Pipeline
cd ~/Desktop/Reads_Quality_Control_Pipeline
```

#### Clone ####

- Clone with **SSH** when you want to authenticate only one time  
Authenticate with GitLab by following the instructions in the [SSH documentation](https://docs.gitlab.com/ee/ssh/index.html)  
```shell
git clone git@gitlab.com:ird_transvihmi/Reads_Quality_Control_Pipeline.git

cd Reads_Quality_Control_Pipeline
```

Clone with **HTTPS** when you want to authenticate each time you perform an operation between your computer and GitLab  
```shell
git clone https://gitlab.com/ird_transvihmi/Reads_Quality_Control_Pipeline.git
cd Reads_Quality_Control_Pipeline
```

#### Difference between download and clone ####
To create a copy of a remote repository’s files on your computer, you can either download or clone the repository  
If you download it, you cannot sync the repository with the remote repository on GitLab  
Cloning a repository is the same as downloading, except it preserves the Git connection with the remote repository  
You can then modify the files locally and upload the changes to the remote repository on GitLab  

## Usage ##
- Copy your **paired-end** reads in **fastq.gz** format files into: **./resources/reads/** directory  
- Edit **config.yaml** file on **./config/** directory, as you want, if needed  
- Edit **fastq-screen.conf** file on **./config/** directory, as you want, if needed  
- Be sure your bash script is executable, if not, you can run in a Terminal:

```shell
sudo chmod +x path/to/Reads_Quality_Control_Pipeline/RQCP.sh
```

- Run **RQCP.sh** bash script by double-clicking on it  
- Enter project name (option) 

A terminal will open. you can close it at the end.

### Results ###
Yours results are available in results\_Date\_Hour\_Project

- ... TODO ...

###  Configuration ###

#### Resources ####
Edit to match your hardware configuration  

#### Environments ####
Edit if you change some environments (i.e.new version) in ./workflow/envs/tools-version.yaml files

#### Datasets ####
Edit to choose datasets you want an quality control with FastQC et Fastq-Screen 

#### Cutadapt ####
- **length**: Discard reads shorter than length, after trim (default config: '75')
- **kit**: Sequence of an adapter ligated to the 3' end of the first read (default config: truseq / nextera / small)  

#### Sickle-trim ####
- **command**: Pipeline wait for paired-end reads (default config: 'pe') see: rule sickletrim on ./workflow/rules/reads_quality_control_pipeline.smk snake file
- **encoding**: If your data are from recent Illumina run, let 'sanger' (default config: 'sanger')
- **quality**: [Q-phred score](https://en.wikipedia.org/wiki/Phred_quality_score) limit (default config: '30')
- **length**: Read length limit, after trim (default config: '75')

##### Fastq-Join #####
- **percent**: Percent maximum difference (default config: 5) 
- **overlap**: Minimum overlap (default config: 25)

#### Fastq-Screen #####
- **config**: Path to the fastq-screen configuration file (default config: ./config/fastq-screen.conf)
- **subset**: Don't use the whole sequence file, but create a temporary dataset of this specified number of read (default config: '10000', set '0' for all dataset)
- **aligner**: Specify the aligner to use for the mapping. Valid arguments are 'bowtie', bowtie2' or 'bwa' (default config: 'bwa')

##### fastq-screen.conf #####
- **path**: Set this value to tell the program where to find your chosen aligner (default :/usr/local/\<tool\>
- **bismark**: Same for bismark (for bisulfite sequencing only)
- **threads**: Set this value to the number of cores you want for mapping reads (default: 1, but overwrited by Snakemake and config.yaml file)
- **databases**: This section enables you to configure multiple genomes databases (aligner index files) to search against in your screen

##### databases #####
For each genome you need to provide a database name (which **can't** contain spaces) and the location of the aligner index files  

>The path to the index files **should include the basename** of the index, _(e.g: ./resources/databases//Human/Homo\_sapiens\_h38)_  
>Thus, the index files _(Homo\_sapiens\_h38.bt2, Homo\_sapiens\_h38.2.bt2, etc.)_ are found in a folder named **'Homo\_sapiens\_h38'**  
>For example, the Bowtie, Bowtie2 and BWA indices of a given genome reside in the **same folder**  
>A **single** path may be provided to **all** the of indices  

The index used will be the one compatible with the chosen aligner _(as specified using the --aligner option)_  

The entries shown in _./config/fastq-screen.conf_ are only suggested examples,  
- You can add as many **database** sections as required  
- You can **comment** out or **remove** as many of the existing entries as desired

It's suggested including genomes and sequences that:  
- may be sources of contamination either because they where run on your sequencer previously
- may have contaminated your sample during the library preparation step

For IRD_U233_TransVIHMI, cretaed this indexes:

- **Human**: main sources of lab. contaminations _(exepted if Boston Dynamics Atlas robot did the job)_ **¡not included!**
- **Mouse**: main model in biology experimentation, very frequent in NGS facility core **¡not included!**
- **Arabidopsis**: frequent plant model in NGS facility core associated with plants researches (IRD, CIRAD, INRAE, ...) **¡not included!**
- **Ecoli**: frequent bacteria model, also an indicator of human contaminations, also in feces and stool samples
- **PhiX**: usefull control in Illumina sequencing run technology
- **Adapters**: use for libraries generation
- **Vector**: use in general molecular biology
- **Gorilla**: species studied in TransVIHMI **¡not included!**
- **Chimpanzee**: species studied in TransVIHMI **¡not included!**
- **Bat**: species studied in TransVIHMI **¡not included!**
- **HIV**: species studied in TransVIHMI
- **Ebola**: species studied in TransVIHMI
- **SARS-CoV-2**: species studied in TransVIHMI

**Not included indexes:**  
Indexes for large genomes can be heavy (~ 3Gb) and git limit each project to 10Gb. Download all this databases can be also to long.  
Commonly it's share on git only code, but not larger resources _(data input, databases, references, ...).  
This data can always be download somewhere (online servers).   
Databases for below genomes where generated and available at IRD_U233_TransVIHMI lab.  
You can freely ask for sharing (with USB supports or FileSender) to add it to your analyses.  
You can also ask for new databases, for genomes references not yet included, to check putative presence / absence on your dataset.  

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

## License ##
[GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)  

## Project status ##
This project is regularly update and actively maintened  
However, you can be volunteer to step in as a maintainer  

[//]: # (I'm out of time for this project, development has slowed down, close to stopped completely, you can be volunteer to step in as a maintainer, or choose to fork this project allowing this project to keep going!)

For information about main git roles:  
- **Guests** are _not active contributors_ in private projects, they can only see, and leave comments and issues.  
- **Reporters** are _read-only contributors_, they can't write to the repository, but can on issues.  
- **Developers** are _direct contributors_, they have access to everything to go from idea to production,  
unless something has been explicitly restricted.  
- **Maintainers** are _super-developers_, they are able to push to master, deploy to production.  
This role is often held by maintainers and engineering managers.  
- **Owners** are essentially _group-admins_, they can give access to groups and have destructive capabilities.  

