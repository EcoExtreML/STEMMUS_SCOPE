#!/bin/bash
# This is a batch script for Snellius at Surf
# usage: cd STEMMUS_SCOPE; mkdir -p slurm; sbatch run_stemmus_scope_snellius.sh

# SLURM settings
#SBATCH -J stemmus_scope
#SBATCH -t 01:00:00
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH -p thin
#SBATCH --array=1-2%32
#SBATCH --output=./slurm/slurm_%A_%a.out
#SBATCH --error=./slurm/slurm_%A_%a.out

# Some security: stop script on error and undefined variables
set -euo pipefail

### 1. Load module needed to run the model (no need for license)
module load 2021
module load MCR/R2021a.3

### 2. Get paths from a config file ############
config="config_file_snellius.txt"
source $config

############ Config file should have the variables below ############
echo "SoilPropertyPath is $SoilPropertyPath"
echo "OutputPath is $OutputPath"
echo "ForcingPath is $ForcingPath"
echo "VegetationPropertyPath is $VegetationPropertyPath"

### 3. Run the model ############
### 3.1 loop over forcing file using Array jobs
echo "$SLURM_ARRAY_TASK_ID"

ncfiles=("$(echo "$ForcingPath" | tr -d '\r')"*.nc)
### -1 is needed because ncfiles array starts from 0
file=${ncfiles[$SLURM_ARRAY_TASK_ID-1]}
echo "ForcingFileName is $file"

start_time=$(date +%s)
base_name=$(basename ${file})
station_name="${base_name%%_*}"
timestamp=$(date +"%Y-%m-%d-%H%M")

### 3.2 create input directories, 
WorkDir="$(echo "$InputPath" | tr -d '\r')${station_name}_${timestamp}/"
mkdir $WorkDir

### 3.3 copy files to WorkDir,
vegetation_path="$(echo "$VegetationPropertyPath" | tr -d '\r')"
cp -r $vegetation_path/* $WorkDir
echo "WorkDir is $WorkDir"

### 3.4 update config file for ForcingFileName and InputPath,
### !due to "/" in WorkDir, the sed uses "|" instead of "/"
station_config="${WorkDir}${station_name}_${timestamp}_config.txt"
sed -e "s/ForcingFileName=.*$/ForcingFileName=$base_name/g" \
    -e "s|InputPath=.*$|InputPath=$WorkDir|g" <$config >$station_config

### 3.5 run the model 
exe/STEMMUS_SCOPE $station_config

end_time=$(date +%s)
echo $(expr $end_time - $start_time) s
## TODO 3.6 check if model run is finished
## This can be done later by checking "State" in slurm*.out file
