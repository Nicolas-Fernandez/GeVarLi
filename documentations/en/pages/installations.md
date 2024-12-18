# Installations

## Conda _(Dependency required)_

GeVarLi use the use the free and open-source package manager **Conda**.  

If you don't have Conda, we hihly recommad to installed it with **Miniforge**.
_(read why: [Avoiding the Pitfalls of the Anaconda License: A Practical Guide](https://mivegec.pages.ird.fr/dainat/malbec-fix-conda-licensing-issues/en/))_  

If you need help, you can use the side script: [Install_Conda-with-Miniforge3.sh](https://forge.ird.fr/transvihmi/nfernandez/install_conda-with-miniforge3)  

Or you can just **download** and **install** it for your specific OS here: [Latest Miniforge installer](https://github.com/conda-forge/miniforge/releases) (≥ 24.11)  

We higly recommand to **set channels** and **update** it !
_(read why: [Avoiding the Pitfalls of the Anaconda License](https://mivegec.pages.ird.fr/dainat/malbec-fix-conda-licensing-issues/en/))_  

Example script for **Linux_x86_64-bit** or **Windows Subsystem for Linux (WSL)** *systems:  
```shell
## Download
curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh

## Install
bash ./Miniforge3-Linux-x86_64.sh -b -p ~/miniforge3/

## Clean
rm -f ./Miniforge3-Linux-x86_64.sh

## Configure
~/miniforge3/condabin/conda config --add channels bioconda
/miniforge3/condabin/conda config --add channels conda-forge
~/miniforge3/condabin/conda config --set channel_priority strict
~/miniforge3/condabin/conda config --set auto_activate_base false

## Update
~/miniforge3/condabin/conda update conda --yes

## Check install
~/miniforge3/condabin/conda --version
~/miniforge3/condabin/conda config --show channels

## Init
~/miniforge3/condabin/conda init
```


## GeVarLi _(given that Conda is installed)_

You can just **download** [GeVarLi](https://forge.ird.fr/transvihmi/nfernandez/GeVarLi):

As a zip file:
<img src="./documentations/images/download_button.png" width="436" height="82">  

Exemple script to **download** to your home/ directory:
```shell
curl https://forge.ird.fr/transvihmi/nfernandez/GeVarLi/-/archive/main/GeVarLi-main.tar.gz -o ~/GeVarLi-main.tar.gz
tar -xzvf ~/GeVarLi-main.tar.gz
mv ~/GeVarLi-main/ ~/GeVarLi/
rm -f ~/GeVarLi-main.tar.gz
```

Otherwise, you can **clone** and **update** [GeVarLi](https://forge.ird.fr/transvihmi/nfernandez/GeVarLi)

Exemple script to **clone** to your home/ directory:
```shell
git clone --depth 1 https://forge.ird.fr/transvihmi/nfernandez/GeVarLi.git ~/GeVarLi/
```

Exemple script to **update** through "git pull":
```shell
cd ~/GeVarLi/ && git reset --hard HEAD && git pull --depth 1 --verbose
```
