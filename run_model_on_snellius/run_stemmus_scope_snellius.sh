#!/bin/bash
# This is a batch script for Snellius at Surf
# usage: cd STEMMUS_SCOPE/run_model_on_snellius; sbatch run_stemmus_scope_snellius.sh

# SLURM settings
#SBATCH -J stemmus_scope
#SBATCH -t 00:10:00
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH -p thin
#SBATCH --output=./slurm_%j.out
#SBATCH --error=./slurm_%j.out

### 1. Load module needed to run the model (no need for license)
module load 2021

### This is for Matlab
module load MCR/R2021a.3

### python environment pystemmusscope is needed
### see https://pystemmusscope.readthedocs.io
. ~/mamba/bin/activate pystemmusscope

### 2. Some security: stop script on error and undefined variables
set -euo pipefail

### 3. Run parallel loop
# number of cores on a shared node
ncores=32 

# number of forcing files
nfiles=170

# some indices for loop
k=0
i=0

for k in `seq 0 5`; do
  for j in `seq 1 $ncores` ; do
  (
    i=$(( ncores * k + j ))
    if [[ $i -le $nfiles ]]; then
      python run_model.py -n $i -j ${SLURM_JOB_ID}
    fi
  )&
  done
  wait
done