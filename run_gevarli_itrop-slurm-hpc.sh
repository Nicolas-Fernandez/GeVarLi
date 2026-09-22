#!/bin/bash

#SBATCH --job-name=gevarli
#SBATCH --partition=normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4GB
#SBATCH --time=7-00:00:00
#SBATCH --constraint=infiniband
#SBATCH --output=gevarli_%j.out
#SBATCH --error=gevarli_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=nicolas.fernandez@ird.fr

################################################################################
# GeVarLi - SLURM Launcher for iTrop Cluster
################################################################################
#
# This script launches the workflow GeVarLi on iTrop cluster.
#
# IMPORTANT: Always run sbatch from the pipeline directory!
#
# Basic usage:
#   cd /projects/xxl/gevarli/
#   rsync -ravhz --progress gevarli /scratch-ib/${USER}/
#   rsync -ravhz --progress runs/*fastq.gz /scratch-ib/${USER}/gevarli/resources/reads/
#   cd /scratch-ib/${USER}/gevarli/
#
#   # First time setup (from login node master1 to download conda packages):
#   # snakemake --use-conda --conda-create-envs-only --cores 4
#
#   # Submit master job:
#   sbatch run_gevarli_itrop-slurm-hpc.sh
#
################################################################################

set -euo pipefail

################################################################################
# Configuration
################################################################################

# Setup temporary directory on scratch-ib (avoid node local /tmp saturation)
export TMPDIR="/scratch-ib/${USER}/tmp"
mkdir -p "$TMPDIR"

# Active conda workflow env
if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
    source "$HOME/miniforge3/etc/profile.d/conda.sh"
    conda activate workflow-core
elif [ -f "/home/fernandez/miniforge3/etc/profile.d/conda.sh" ]; then
    source "/home/fernandez/miniforge3/etc/profile.d/conda.sh"
    conda activate workflow-core
else
    source activate workflow-core
fi

# Unlock the directory in case of previous crash
if [ -f "config/profiles/slurm/config.yaml" ]; then
    snakemake --profile config/profiles/slurm/config.yaml --unlock || true
    # Run the workflow with Slurm profile
    snakemake --profile config/profiles/slurm/config.yaml
else
    snakemake --directory . --snakefile workflow/Snakefile --rerun-incomplete --unlock || true
    # Fallback to local execution within the master allocation
    snakemake \
        --directory . \
        --snakefile workflow/Snakefile \
        --rerun-incomplete \
        --keep-going \
        --use-conda \
        --jobs 50 \
        --latency-wait 60
fi

################################################################################
