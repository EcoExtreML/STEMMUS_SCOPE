"""Run STEMMUS_SCOPE on Snellius.
This script is used in a job submission file to loop over forcing files and run
StemmusScope model on a HPC cluster using slurm workload manager. In order to
run the model, PyStemmusScope should be installed, see
https://pystemmusscope.readthedocs.io/.
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
    model = StemmusScope(config_file=path_to_config_file, model_src_path=path_to_exe_file)

    # get the forcing file
    forcing_filenames_list = [
        file.name for file in Path(model.config["ForcingPath"]).iterdir()
    ]
    # note that index starts from 1 from bash input, so ncfile_index-1
    nc_file = forcing_filenames_list[ncfile_index - 1]
    station_name = nc_file.split("_")[0]

    # feed model with the correct forcing file
    config_path = model.setup(Location=station_name)

    # run model
    model_log = model.run()

    # save output in netcdf format
    required_netcdf_variables = "../utils/csv_to_nc/required_netcdf_variables.csv"
    netcdf_file_name = save.to_netcdf(config_path, required_netcdf_variables)

    slurm_log_msg = [
        f"Input path is {model.config['InputPath']}",
        f"Output path is {model.config['OutputPath']}",
        f"model log is {model_log}",
        f"model outputs are in {netcdf_file_name}",
    ]

    slurm_file_name = (
        Path(model.config["OutputPath"])
        / f"slurm_{job_id}_{ncfile_index}_{station_name}.out"
    )

    # create slurm log
    slurm_log(slurm_file_name, slurm_log_msg)


def slurm_log(slurm_file_name, slurm_log_msg):
    """Create slurm log file for the submitted job."""
    with open(slurm_file_name, "w+", encoding="utf-8") as file:
        for line in slurm_log_msg:
            file.write(line)
            file.write("\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-n",
        "--ncfile_index",
        required=True,
        type=int,
        default=0,
        help="index of netCDF file",
    )
    parser.add_argument(
        "-j",
        "--job_id",
        required=True,
        type=int,
        default=0,
        help="slurm job id from snellius",
    )
    # get arguments
    args = parser.parse_args()

    run_model(args.ncfile_index, args.job_id)
