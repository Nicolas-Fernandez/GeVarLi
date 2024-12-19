# **Installations**

## **Conda**
!!! caution
    Dépendance requise!

GeVarLi utilise le gestionnaire de paquets gratuit et open-source **Conda**.  

**Si vous n'avez pas Conda**, nous vous recommandons vivement de l'installer avec **Miniforge**.
!!! note
    Lire pourquoi: [Éviter les Pièges de la Licence Anaconda : Guide Pratique](https://mivegec.pages.ird.fr/dainat/malbec-fix-conda-licensing-issues/fr/)

!!! tip
    Si vous avez besoin d'aide, vous pouvez utiliser le script annexe : [Install_Conda-with-Miniforge3.sh](https://forge.ird.fr/transvihmi/nfernandez/install_conda-with-miniforge3)

Sinon, vous pouvez **télécharger** et **installer** la [dernière version de Miniforge](https://github.com/conda-forge/miniforge/releases) spécifique à votre système d'exploitation.

_Exemple de script pour les systèmes Linux\_x86\_64 bits ou Sous-système Windows pour Linux (WSL)_
```shell
# Download
curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh

# Install
bash ./Miniforge3-Linux-x86_64.sh -b -p ~/miniforge3/

# Clean
rm -f ./Miniforge3-Linux-x86_64.sh

# Configure
~/miniforge3/condabin/conda config --add channels bioconda
/miniforge3/condabin/conda config --add channels conda-forge
~/miniforge3/condabin/conda config --set channel_priority strict
~/miniforge3/condabin/conda config --set auto_activate_base false

# Update
~/miniforge3/condabin/conda update conda --yes

# Check install
~/miniforge3/condabin/conda --version
~/miniforge3/condabin/conda config --show channels

# Init
~/miniforge3/condabin/conda init
```
!!! caution
    Nous vous recommandons fortement de **définir des canaux** et de **mettre à jour** !
!!! note
    Lire pourquoi: [Éviter les Pièges de la Licence Anaconda : Guide Pratique](https://mivegec.pages.ird.fr/dainat/malbec-fix-conda-licensing-issues/fr/)


## **GeVarLi**
!!! important
    Présumant que vous avez Conda installé!

Vous pouvez **télécharger** GeVarLi depuis le [dépôt git sur IRD-Forge](https://forge.ird.fr/transvihmi/nfernandez/GeVarLi), en tant que fichier zip :
<img src="../../../images/download_button.png" width="300" height="60">

_Exemple de script pour télécharger GeVarLi dans votre répertoire home/_
```shell
# Download
curl https://forge.ird.fr/transvihmi/nfernandez/GeVarLi/-/archive/main/GeVarLi-main.tar.gz -o ~/GeVarLi-main.tar.gz

# Untar
tar -xzvf ~/GeVarLi-main.tar.gz

# Clean
rm -f ~/GeVarLi-main.tar.gz

# Rename
mv ~/GeVarLi-main/ ~/GeVarLi/
```

!!! tip
    Sinon, vous pouvez aussi **cloner** et **mettre à jour** à jour GeVarLi :
    
    _Exemple de script pour le cloner et le mettre à jour, dans votre répertoire home/_
    ```shell
    # Clone
    git clone --depth 1 https://forge.ird.fr/transvihmi/nfernandez/GeVarLi.git ~/GeVarLi/
    cd ~/GeVarLi/

    # Update/Pull (présumant que vous êtes dans le répertoire GeVarLi/)
    git reset --hard HEAD && git pull --depth 1 --verbose
    ```
