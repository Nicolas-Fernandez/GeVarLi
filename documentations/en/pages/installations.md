# ~ INSTALLATIONS ~

## Conda
_(Dependency required)_

GeVarLi use the use the free and open-source package manager **Conda**.  
If you don't have Conda, it can be installed with **Miniforge**.

You can **download** and **install** it for your specific OS here: [Latest Miniforge installer](https://github.com/conda-forge/miniforge/releases) (≥ 24.9.2)  

Example script for **MacOSX_INTEL-chips_x86_64-bit** or **MacOSX_M1/M2-chips_arm_64-bit (with Rosetta)** systems:  
```shell
curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh
bash ./Miniforge3-MacOSX-x86_64.sh -b -p ~/miniforge3/
rm -f ./Miniforge3-MacOSX-x86_64.sh

~/miniforge3/condabin/conda init
shell=$(~/miniforge3/condabin/conda init 2> /dev/null | grep "modified" | sed 's/modified      //')
source ${shell}
```

Example script for **Linux_x86_64-bit** or **Windows Subsystem for Linux (WSL)** *systems:  
```shell
curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash ./Miniforge3-Linux-x86_64.sh -b -p ~/miniforge3/
rm -f ./Miniforge3-Linux-x86_64.sh

~/miniforge3/condabin/conda init
shell=$(~/miniforge3/condabin/conda init 2> /dev/null | grep "modified" | sed 's/modified      //')
source ${shell}
```

We also higly recommand to **set channels** and **update** it !
Read: [Avoiding the Pitfalls of the Anaconda License](https://mivegec.pages.ird.fr/dainat/malbec-fix-conda-licensing-issues/en/)

Example script:
```shell  
~/miniforge3/condabin/conda config --add channels bioconda
~/miniforge3/condabin/conda config --add channels conda-forge
~/miniforge3/condabin/conda config --set channel_priority strict
~/miniforge3/condabin/conda config --set auto_activate_base false

~/miniforge3/condabin/conda update conda --yes

~/miniforge3/condabin/conda --version
~/miniforge3/condabin/conda config --show channels
```


## GeVarLi
_(Given that Conda is installed)_

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
