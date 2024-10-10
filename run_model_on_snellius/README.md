## Run STEMMUS_SCOPE on Snellius

This folder contains files that are needed for running `STEMMUS_SCOPE` on Snellius:

- `run_stemmus_scope_snellius.sh` is the batch script for job submission
- `run_model.py` is the python script for executing the workflow
- `config_file_snellius.txt` is the model config file

Before submitting the job via `sbatch run_stemmus_scope_snellius.sh`, make sure that conda environment `pystemmusscope` is created, see the [environment file](https://github.com/EcoExtreML/STEMMUS_SCOPE_Processing/blob/main/environment.yml). Also, set the `WorkDir` and `NumberOfTimeSteps` in the model config file e.g. `config_file_snellius.txt`.

The bash script `run_stemmus_scope_snellius.sh` in this repository, runs the
model at 170 sites (default) on a **compute node**. The scripts loops over
forcing files in the "ForcingPath", creates `sitename_timestamped` working
directories under "InputPath" directory and copies required data to those
working dirs. To change the number of sites, open the script and on the last
line change the parameter `{1..170}`. For example `env_parallel -n1 -j32
--joblog $log_file loop_func ::: {1..170}` will run the model at 32 sites
simultaneously. For testing purposes, the time of the bash script is set to
`00:10:00`. Note that the model run can take long for some of the sites. As the
maxium time wall is 5 days on a partition thin, time can be set to`5-00:00:00`
for a complete run of the model.

You can run the script in a terminal:

```shell
cd STEMMUS_SCOPE
mkdir -p slurm
sbatch run_stemmus_scope_snellius.sh
```

This creates a log file per each forcing file in the folder `slurm`.
