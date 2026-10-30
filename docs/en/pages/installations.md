# **Installation**

## **Conda (Prerequisite)**

!!! warning
    **Dependency required**

GeVarLi relies on the free, open-source package manager **Conda** to manage isolated tool environments automatically.

**If you do not have Conda installed**, we strongly recommend installing it via **Miniforge**:
Download the installer for your operating system from the official [Miniforge repository](https://github.com/conda-forge/miniforge/releases).

!!! shell
    _Example script for Linux x86_64 or Windows Subsystem for Linux (WSL):_
    ```shell
    # Download installer
    curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
    
    # Install Miniforge
    bash ./Miniforge3-Linux-x86_64.sh -b -p ~/miniforge3/
    rm -f ./Miniforge3-Linux-x86_64.sh
    
    # Configure community channels
    ~/miniforge3/condabin/conda config --add channels bioconda
    ~/miniforge3/condabin/conda config --add channels conda-forge
    ~/miniforge3/condabin/conda config --set channel_priority strict
    ~/miniforge3/condabin/conda config --set auto_activate_base false
    
    # Initialize shell
    ~/miniforge3/condabin/conda init
    ```

---

## **GeVarLi**

Thanks to repository optimization, GeVarLi is ultra-lightweight (**~9 MB**) and **no longer requires Git LFS**!

### **Recommended Method: Git Clone**

Cloning the Git repository gives you full version control, automated updates, and branch management:

```shell
# Clone the repository
git clone https://forge.ird.fr/transvihmi/nfernandez/GeVarLi.git ~/GeVarLi

# Navigate to GeVarLi
cd ~/GeVarLi
```

To update an existing installation to the latest version:
```shell
cd ~/GeVarLi
git pull
```

---

### **Alternative: Download Archive (No Git)**

If you prefer downloading a standalone archive without Git:

```shell
# Download tarball archive
curl -L https://forge.ird.fr/transvihmi/nfernandez/GeVarLi/-/archive/main/GeVarLi-main.tar.gz -o ~/GeVarLi-main.tar.gz

# Extract and enter directory
tar -xzvf ~/GeVarLi-main.tar.gz
rm -f ~/GeVarLi-main.tar.gz
mv ~/GeVarLi-main ~/GeVarLi
cd ~/GeVarLi
```

---

## **HPC Clusters (Slurm)**

If you are running on a Slurm-managed HPC cluster (such as the IRD i-Trop cluster), ensure passwordless SSH keys are configured and launch jobs using our dedicated launcher:
```shell
bash run_gevarli_itrop-slurm-hpc.sh
```
