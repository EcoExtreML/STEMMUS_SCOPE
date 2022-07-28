#!/bin/bash
# This is a batch script for Snellius at Surf
# usage: cd STEMMUS_SCOPE; mkdir -p slurm; sbatch run_stemmus_scope_snellius.sh

# SLURM settings
#SBATCH -J stemmus_scope
#SBATCH -t 00:10:00
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH -p thin
#SBATCH --output=./slurm/slurm_%j.out
#SBATCH --error=./slurm/slurm_%j.out

### 1. Load module needed to run the model (no need for license)
module load 2021

### This is for Matlab
module load MCR/R2021a.3

### python environment stemmus is needed to convert csv files to nc files
### see utils/csv_to_nc/README.md
. ~/mamba/bin/activate stemmus

### 2. Some security: stop script on error and undefined variables
set -euo pipefail

### 3. Create a function to loop over
loop_func() {
    
    ### 3.2 Get paths from a config file 
    config="config_file_snellius.txt"
    source $config

    ### 3.3 loop over forcing file using i that is the function input argument
    i=$1
    ncfiles=("$(echo "$ForcingPath" | tr -d '\r')"*.nc)
    
    ### -1 is needed because ncfiles array starts from 0
    file=${ncfiles[$i-1]}

    start_time=$(date +%s)
    base_name=$(basename ${file})
    station_name="${base_name%%_*}"
    timestamp=$(date +"%Y-%m-%d-%H%M")

    ### 3.4 create input directories, 
    work_dir="$(echo "$InputPath" | tr -d '\r')${station_name}_${timestamp}/"
    mkdir -p $work_dir

    ### 3.5 copy files to work_dir,
    vegetation_path="$(echo "$VegetationPropertyPath" | tr -d '\r')"
    cp -r $vegetation_path/* $work_dir

    ### 3.6 update config file for ForcingFileName and InputPath,
    ### !due to "/" in work_dir, the sed uses "|" instead of "/"
    station_config="${work_dir}${station_name}_${timestamp}_config.txt"
    sed -e "s/ForcingFileName=.*$/ForcingFileName=$base_name/g" \
        -e "s|InputPath=.*$|InputPath=$work_dir|g" <$config >$station_config

    ### 3.7 Add info to a std_out file
    std_out="./slurm/slurm_${SLURM_JOB_ID}_${i}_${station_name}.out"
    echo "
    SoilPropertyPath is $SoilPropertyPath
    InputPath is $InputPath
    OutputPath is $OutputPath
    ForcingPath is $ForcingPath
    VegetationPropertyPath is $VegetationPropertyPath
    WorkDir is $work_dir
    ForcingFileName is $base_name" > $std_out

    ### 3.8 run the model and store the time and model log info
    ### set matlab log dir to slurm, otherwise java.log files are created in user home dir
    export MATLAB_LOG_DIR=./slurm
    exe/STEMMUS_SCOPE $station_config >> $std_out

    end_time=$(date +%s)
    run_time=$(expr $end_time - $start_time)

    ## 3.9 Add some information to slurm*.out file later will be used.
    completed="COMPLETED"
    echo "Run is $completed. Model run time is $run_time s." >> $std_out

    ## 3.10 Convert csv files to a nc file, if run is completed
    if [[ -v completed ]];
    then
        python utils/csv_to_nc/generate_netcdf_files.py --config_file $station_config --variable_file utils/csv_to_nc/Variables_will_be_in_NetCDF_file.csv
    fi
}

### 5. Run parallel loop
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
      loop_func $i
    fi
  )&
  done
  wait
done