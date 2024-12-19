# Installations

## Conda
_(Dependency required)_

GeVarLi use the use the free and open-source package manager **Conda**.  

If you don't have Conda, we hihly recommad to installed it with **Miniforge**.  
_(read why: [Avoiding the Pitfalls of the Anaconda License: A Practical Guide](https://mivegec.pages.ird.fr/dainat/malbec-fix-conda-licensing-issues/en/))_  

If you need help, you can use the side script: [Install_Conda-with-Miniforge3.sh](https://forge.ird.fr/transvihmi/nfernandez/install_conda-with-miniforge3)  

Otherwise, you can **download** and **install** the [latest version of Miniforge](https://github.com/conda-forge/miniforge/releases) for your specific OS.

!!! warning
    We higly recommand to **set channels** and **update** it !

!!! note
    Read why: [Avoiding the Pitfalls of the Anaconda License](https://mivegec.pages.ird.fr/dainat/malbec-fix-conda-licensing-issues/en/)

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


## GeVarLi
_(given that Conda is installed)_

You can **download** GeVarLi from this its [IRD-Forge git repository](https://forge.ird.fr/transvihmi/nfernandez/GeVarLi), as zip file:
<img src="../../../images/download_button.png" width="436" height="82">

_Exemple script to download** GeVarLi to your home/ directory_
```shell
## Download
curl https://forge.ird.fr/transvihmi/nfernandez/GeVarLi/-/archive/main/GeVarLi-main.tar.gz -o ~/GeVarLi-main.tar.gz

## Untar
tar -xzvf ~/GeVarLi-main.tar.gz

## Clear
rm -f ~/GeVarLi-main.tar.gz

## Rename
mv ~/GeVarLi-main/ ~/GeVarLi/
```

> [!Note]
> Otherwise, you can also **clone** and **update** GeVarLi:

_Exemple script to clone and update it, to your home/ directory_
```shell
## Clone
git clone --depth 1 https://forge.ird.fr/transvihmi/nfernandez/GeVarLi.git ~/GeVarLi/
cd ~/GeVarLi/

## Update/Pull (given you are into GeVarLi/ repository)
git reset --hard HEAD && git pull --depth 1 --verbose
```
