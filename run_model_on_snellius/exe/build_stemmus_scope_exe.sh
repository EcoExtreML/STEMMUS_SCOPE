#!/bin/bash
# This is a batch script for Snellius at Surf
# usage: cd STEMMUS_SCOPE; sbatch exe/build_stemmus_scope_exe.sh

# SLURM settings
#SBATCH -J stemmus_scope
#SBATCH -t 00:05:00
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH -p thin
#SBATCH --output=./slurm_%j.out
#SBATCH --error=./slurm_%j.out

# Some security: stop script on error and undefined variables
set -euo pipefail

############ Use module MATLAB/2021a-upd3 to either run the source code or build the executable file ############
############ This needs a matlab license, make sure yuor account is added to the license pool ############
# Load matlab module
# On Snellius Try: "module spider MATLAB" to see how to load the module(s).
module load 2021
module load MATLAB/2021a-upd3

# Create executable file
mcc -m ./src/STEMMUS_SCOPE_exe.m -a ./src -d ./exe -o STEMMUS_SCOPE -R nodisplay -R singleCompThread
