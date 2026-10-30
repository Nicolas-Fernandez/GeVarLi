# **Installation**

## **Conda (Prérequis)**

!!! warning
    **Dépendance requise**

GeVarLi s'appuie sur le gestionnaire de paquets open-source **Conda** pour créer et gérer automatiquement des environnements bioinformatiques isolés et reproductibles.

**Si vous n'avez pas Conda installé**, nous vous recommandons vivement de l'installer via **Miniforge** :
Téléchargez l'installateur adapté à votre système depuis le [dépôt officiel Miniforge](https://github.com/conda-forge/miniforge/releases).

!!! shell
    _Exemple d'installation pour Linux x86_64 ou Sous-système Windows pour Linux (WSL) :_
    ```shell
    # Télécharger l'installateur
    curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
    
    # Installer Miniforge
    bash ./Miniforge3-Linux-x86_64.sh -b -p ~/miniforge3/
    rm -f ./Miniforge3-Linux-x86_64.sh
    
    # Configurer les canaux communautaires stricts
    ~/miniforge3/condabin/conda config --add channels bioconda
    ~/miniforge3/condabin/conda config --add channels conda-forge
    ~/miniforge3/condabin/conda config --set channel_priority strict
    ~/miniforge3/condabin/conda config --set auto_activate_base false
    
    # Initialiser le shell
    ~/miniforge3/condabin/conda init
    ```

---

## **GeVarLi**

Grâce à l'optimisation complète du dépôt, GeVarLi est ultra-léger (**~9 Mo**) et **ne nécessite plus Git LFS** !

### **Méthode recommandée : Cloner avec Git**

Cloner le dépôt Git permet de bénéficier du contrôle de version complet et des mises à jour directes :

```shell
# Cloner le dépôt
git clone https://forge.ird.fr/transvihmi/nfernandez/GeVarLi.git ~/GeVarLi

# Accéder au dossier
cd ~/GeVarLi
```

Pour mettre à jour une installation existante vers la dernière version :
```shell
cd ~/GeVarLi
git pull
```

---

### **Méthode alternative : Téléchargement d'archive (Sans Git)**

Si vous préférez télécharger une archive autonome sans utiliser Git :

```shell
# Télécharger l'archive tarball
curl -L https://forge.ird.fr/transvihmi/nfernandez/GeVarLi/-/archive/main/GeVarLi-main.tar.gz -o ~/GeVarLi-main.tar.gz

# Extraire et entrer dans le dossier
tar -xzvf ~/GeVarLi-main.tar.gz
rm -f ~/GeVarLi-main.tar.gz
mv ~/GeVarLi-main ~/GeVarLi
cd ~/GeVarLi
```

---

## **Clusters de calcul HPC (Slurm)**

Si vous travaillez sur un cluster géré par Slurm (comme le cluster i-Trop de l'IRD), assurez-vous que vos clés SSH sont configurées et lancez l'exécution via notre script dédié :
```shell
bash run_gevarli_itrop-slurm-hpc.sh
```
