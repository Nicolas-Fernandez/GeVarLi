
# GeVarLi: Genome assembly, Variant calling and Lineage assignment (Pangolin) #

## Description ##

GeVarLi check NGS (illumina) reads quality and clean it if needed, using: 

- FastQC to check global quality
- FastqScreen to check putative contamination(s)
- MultiQC to generate HTML reports  
- Cutadapts to trim NGS sequencing adapters  
- Sickle-trim to trim reads on base-calling quality score  

GeVarLi ...


## Badges ##

![Maintener](<https://badgen.net/badge/Maintener/Nicolas Fernandez/blue?scale=0.9>)
![MacOS](<https://badgen.net/badge/icon/Hight Sierra (10.13),Catalina (10.15),Big Sure (11)/cyan?icon=apple&label&list=|&scale=0.9>)
![Issues closed](<https://badgen.net/badge/Issues closed/0/green?scale=0.9>)
![Issues opened](<https://badgen.net/badge/Issues opened/0/yellow?scale=0.9>)
![Maintened](<https://badgen.net/badge/Maintened/Yes/red?scale=0.9>)
![Wiki](<https://badgen.net/badge/icon/Wiki/pink?icon=wiki&label&scale=0.9>)
![Open Source](<https://badgen.net/badge/icon/Open Source/purple?icon=https://upload.wikimedia.org/wikipedia/commons/4/44/Corazón.svg&label&scale=0.9>)
![GNU AGPL v3](<https://badgen.net/badge/Licence/GNU AGPL v3/grey?scale=0.9>)
![Bash](<https://badgen.net/badge/icon/Bash 3.2.57/black?icon=terminal&label&scale=0.9>)
![Python](<https://badgen.net/badge/icon/Python 3.9.5/black?icon=https://upload.wikimedia.org/wikipedia/commons/0/0a/Python.svg&label&scale=0.9>)
![Snakemake](<https://badgen.net/badge/icon/Snakemake 6.12.1/black?icon=https://upload.wikimedia.org/wikipedia/commons/d/d3/Python_icon_%28black_and_white%29.svg&label&scale=0.9>)
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

4. Restart shell (close and reopen new terminal window)


### Snakemake _(prior!)_ ###

Install **Snakemake** (_i.e. v.5.11.2_) using Conda package management system  
_Follow the prompts on the installer screens_  
```shell
conda install -c bioconda -c conda-forge snakemake
```


### GeVarLi ###

**Download** _OR_ clone the **Reads Quality Control Pipeline** project  


#### Download ####

- Download source code archive (_zip_, **tar.gz**, _tar.bz2_, _tar_): [GeVarLi on GitLab](https://gitlab.com/ird_transvihmi/GeVarLi_Pipeline_macOSX)  
```shel
wget  https://gitlab.com/ird_transvihmi/GeVarLi_Pipeline_macOSX/-/archive/main/GeVarLi_Pipeline_macOSX-main.tar.gz -O ~/Desktop/ 
```

_alternatively_:
![Image of download button](./visuals/download_button.png)  

- Extract and remove the the archive (i.e. tar.gz):
```shell
tar -xzvf path/to/archive/GeVarLi_Pipeline_macOSX-main.tar.gz
rm path/to/archive/GeVarLi_Pipeline_macOSX-main.tar.gz 
mv ~/Desktop/GeVarLi_Pipeline_macOSX-main ~/Desktop/GeVarLi_Pipeline
cd ~/Desktop/GeVarLi_Pipeline
```

#### Clone ####

- Clone with **SSH** when you want to authenticate only one time  
Authenticate with GitLab by following the instructions in the [SSH documentation](https://docs.gitlab.com/ee/ssh/index.html)  
```shell
git clone git@gitlab.com:ird_transvihmi/GeVarLi_Pipeline_macOSX.git
mv GeVarLi_Pipeline GeVarLi_Pipeline
cd GeVarLi_Pipeline
```

Clone with **HTTPS** when you want to authenticate each time you perform an operation between your computer and GitLab  
```shell
git clone https://gitlab.com/ird_transvihmi/GeVarLi_Pipeline_macOSX.git
mv GeVarLi_Pipeline GeVarLi_Pipeline
cd GeVarLi_Pipeline
```


#### Difference between download and clone ####

To create a copy of a remote repository’s files on your computer, you can either download or clone the repository  
If you download it, you cannot sync the repository with the remote repository on GitLab  
Cloning a repository is the same as downloading, except it preserves the Git connection with the remote repository  
You can then modify the files locally and upload the changes to the remote repository on GitLab  


## Usage ##

- Copy your **paired-end** reads in **fastq.gz** format files into: **./resources/reads/** directory  
- (_option_) Edit **config.yaml** file on **./config/** directory, as you want, if needed  
- (_option_) Edit **fastq-screen.conf** file on **./config/** directory, as you want, if needed  
- Be sure your bash script is executable, if not, you can run in a Terminal:

```shell
sudo chmod +x path/to/GeVarLi_Pipeline/GeVarLi.sh
```

- Run **GeVarLi.sh** bash script by double-clicking on it  

A terminal will open. you can close it at the end.


### Results ###

Yours results are available in results directory:

- ... TODO ...


###  Configuration ###

#### Resources ####

Edit to match your hardware configuration  


#### Environments ####

Edit if you change some environments (i.e.new version) in ./workflow/envs/tools-version.yaml files


#### Cutadapt ####

- **length**: Discard reads shorter than length, after trim (default config: '75')
- **kit**: Sequence of an adapter ligated to the 3' end of the first read (default config: truseq,  nextera and small)  

#### Sickle-trim ####

- **command**: Pipeline wait for paired-end reads (default config: 'pe') see: rule sickletrim on ./workflow/rules/reads_quality_control_pipeline.smk snake file
- **encoding**: If your data are from recent Illumina run, let 'sanger' (default config: 'sanger')
- **quality**: [Q-phred score](https://en.wikipedia.org/wiki/Phred_quality_score) limit (default config: '30')
- **length**: Read length limit, after trim (default config: '75')


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

For information about main git roles:  
- **Guests** are _not active contributors_ in private projects, they can only see, and leave comments and issues.  
- **Reporters** are _read-only contributors_, they can't write to the repository, but can on issues.  
- **Developers** are _direct contributors_, they have access to everything to go from idea to production,  
unless something has been explicitly restricted.  
- **Maintainers** are _super-developers_, they are able to push to master, deploy to production.  
This role is often held by maintainers and engineering managers.  
- **Owners** are essentially _group-admins_, they can give access to groups and have destructive capabilities.  

