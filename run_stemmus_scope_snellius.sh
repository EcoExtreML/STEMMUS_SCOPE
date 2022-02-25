#!/bin/bash
# This is a batch script for Snellius at Surf
# usage: cd STEMMUS_SCOPE; sbatch run_stemmus_scope_snellius.sh

# SLURM settings
#SBATCH -J stemmus_scope
#SBATCH -t 01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH -p thin
#SBATCH --output=./slurm/slurm_%j.out
#SBATCH --error=./slurm/slurm_%j.out

### 1. Load module needed to run the model (no need for license)
module load 2021
### This is for Matlab
module load MCR/R2021a.3
### This is for GNU parallel
### First time loading asks for citation agreement
module load parallel/20210622-GCCcore-10.3.0

### 2. To transfer environment vars, functions, ... 
source `which env_parallel.bash`

### 3. Create a function to loop over
loop_func() {

    ### 3.1 Some security: stop script on error and undefined variables
    set -euo pipefail
    
    ### 3.2 Get paths from a config file 
    config="my_config_file.txt"
    source $config

    ### 3.3 loop over forcing file using i that is the function input argument
    i=$1
    ncfiles=("$(echo "$ForcingPath" | tr -d '\r')"*.nc)
    
    file=${ncfiles[$i]}

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
    std_out="./slurm/slurm_${SLURM_JOB_ID}_${i}.out"
    echo "
    SoilPropertyPath is $SoilPropertyPath
    InputPath is $InputPath
    OutputPath is $OutputPath
    ForcingPath is $ForcingPath
    VegetationPropertyPath is $VegetationPropertyPath
    WorkDir is $WorkDir
    ForcingFileName is $base_name" > $std_out

    ### 3.8 run the model and store the time and model log info
    ###TODO check why this creates java.log files in user home dir
    time exe/STEMMUS_SCOPE $station_config >> $std_out

    end_time=$(date +%s)
    run_time=$(expr $end_time - $start_time)

    ## 3.9 Add some information to slurm*.out file later will be used.
    echo "Run is COMPLETED. Model run time is $run_time s." >> $std_out
}

### 4. Create a log file for GNU parallel
log_file="./slurm/parallel_${SLURM_JOB_ID}.log"

### 5. Run env_parallel instead of parallel to have our environment
env_parallel -n1 -j32 --joblog $log_file loop_func ::: {1..170}
