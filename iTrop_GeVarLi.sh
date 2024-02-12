#!/bin/bash

###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __| ___| \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__|_)\_|____|____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ iTrop_GeVarLi.sh
# Version ________________ v.2024.02
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Slurm script running GeVarLi on iTrop HPC
# Date ___________________ 2022.10.16
# Latest modifications ___ 2024.02.12
# Use ____________________ sbatch iTrop_GeVarLi.sh

###############################################################################
### Slurm Configuration ###
###########################

user="fernandez"

#SBATCH --job-name GeVarLi-SLURM

#SBATCH --mail-user nicolas.fernandez@ird.fr
#SBATCH --mail-type ALL
#SBATCH --verbose

#SBATCH --partition=highmem --cpus-per-task=112 --constraint=512,infiniband

###############################################################################
### Script ###
##############

# CREATE SCRATCH FOLDER
mkdir -p /scratch/${user}-GeVarLi-${SLURM_JOB_ID}/

# TRANSFER DATA
scp -r san-ib://projects/large/GorillaSIVmeta/GeVarLi/ /scratch/${user}-GeVarLi-${SLURM_JOB_ID}/

# MODULE


# ANALYSIS
bash /scratch/${user}-GeVarLi-${SLURM_JOB_ID}/GeVarLi/Start_GeVarLi.sh

# TRANSFER RESULTS
scp -r /scratch/${user}-GeVarLi-${SLURM_JOB_ID}/GeVarLi/ san-ib://projects/large/GorillaSIVmeta/

# DELETE SCRATCH FOLDER
rm -rf /scratch/fernandez-${SLURM_JOB_ID}/
