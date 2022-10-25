#!/usr/bin/env python
"""
2022.10.20      : Workflow operator for STEMMUS_SCOPE on Snellius
Author          : Team Beta
Date            : 2022.10.20
Last Update     : 2022.10.25
Description     : This script is used in the job submission file to run 
                  StemmusScope model with PyStemmusScope on a HPC cluster
                  using slurm workload manager.
Dependancy      : PyStemmusScope
Caveat          : In order to launch the model, users need to install
                  PyStemmusScope from STEMMUS_SCOPE_Processing.
"""

import argparse
from pathlib import Path
from PyStemmusScope import StemmusScope
from PyStemmusScope import save


def run_model(ncfile_index, job_id):
    """Workflow executer.

    Run StemmusScope model with PyStemmusScope.
    """
    path_to_config_file = "./config_file_snellius.txt"
    path_to_exe_file = "./exe/STEMMUS_SCOPE"

    # create an instance of the model
    model = StemmusScope(config_file=path_to_config_file, exe_file=path_to_exe_file)
    
    # get the forcing file
    forcing_filenames_list = [file.name for file in Path(model.config["ForcingPath"]).iterdir()]
    # note that index starts from 1 from bash input, so ncfile_index-1
    nc_file = forcing_filenames_list[ncfile_index-1]
    station_name = nc_file.split("_")[0]

    # create slurm log
    slurm_log(ncfile_index, job_id, model.config, station_name)
    
    # feed model with the correct forcing file 
    config_path = model.setup(
        ForcingFileName = nc_file,
        NumberOfTimeSteps="10",
    )

    # run model
    config_path = model.run()

    # save output in netcdf format
    required_netcdf_variables = "../utils/csv_to_nc/required_netcdf_variables.csv"
    _ = save.to_netcdf(config_path, required_netcdf_variables)


def slurm_log(ncfile_index, job_id, config, station_name):
    # list all paths for display
    SoilPropertyPath = config["SoilPropertyPath"]
    InputPath = config["InputPath"]
    OutputPath = config["OutputPath"]
    ForcingPath = config["ForcingPath"]
    # get vegetation path from leafangles path
    VegetationPropertyPath = config["leafangles"].split("/leafangles")[0]
    WorkDir = config["WorkDir"]
    ForcingFileName = config["ForcingFileName"]

    with open(f"../slurm/slurm_{job_id}_{ncfile_index}_{station_name}.out",'w+',encoding = 'utf-8') as f:
        f.write(f"SoilPropertyPath is {SoilPropertyPath}\n")
        f.write(f"InputPath is {InputPath}\n")
        f.write(f"OutputPath is {OutputPath}\n")
        f.write(f"ForcingPath is {ForcingPath}\n")
        f.write(f"VegetationPropertyPath is {VegetationPropertyPath}\n")
        f.write(f"WorkDir is {WorkDir}\n")
        f.write(f"ForcingFileName is {ForcingFileName}\n")


if __name__=="__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument('-n', '--ncfile_index', required=True, type=int, default=0,
                        help="index of netCDF file")
    parser.add_argument('-j', '--job_id', required=True, type=int, default=0,
                        help="slurm job id from snellius")    
    # get arguments
    args = parser.parse_args()

    run_model(args.ncfile_index, args.job_id)
