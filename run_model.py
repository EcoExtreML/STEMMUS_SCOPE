#!/usr/bin/env python
"""
2022.10.20      : Workflow operator for STEMMUS_SCOPE on Snellius
Author          : Team Beta
Date            : 2022.10.20
Last Update     : 2022.10.21
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


def run_model(ncfile_index):
    """Workflow executer.

    Run StemmusScope model with PyStemmusScope.
    """
    path_to_config_file = "./config_file_snellius.txt"
    path_to_exe_file = "./exe/STEMMUS_SCOPE"

    # create an an instance of the model
    model = StemmusScope(config_file=path_to_config_file, exe_file=path_to_exe_file)
    
    # get the forcing file
    forcing_filenames_list = [file.name for file in Path(model.config["ForcingPath"]).iterdir()]
    # note that index starts from 1 from bash input, so ncfile_index-1
    nc_file = forcing_filenames_list[ncfile_index-1]
    
    # feed model with the correct forcing file 
    _ = model.setup(
        ForcingFileName = nc_file,
        NumberOfTimeSteps="10",
    )

    # run model
    _ = model.run()

    # save output in netcdf format
    required_netcdf_variables = "./required_netcdf_variables.csv"
    _ = save.to_netcdf(model.config, required_netcdf_variables)


if __name__=="__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument('-n', '--ncfile_index', required=True, type=int, default=0,
                        help="index of netCDF file")
    # get arguments
    args = parser.parse_args()

    run_model(args.ncfile_index)
