## Run STEMMUS_SCOPE on Snellius

This folder contains files that are needed for running `STEMMUS_SCOPE` on Snellius:

- `run_stemmus_scope_snellius.sh` is the batch script for job submission
- `run_model.py` is the python script for executing the workflow
- `config_file_snellius.txt` is the model config file

Before submitting the job via `sbatch run_stemmus_scope_snellius.sh`, make sure that conda environment `pystemmusscope` is created, see the [environment file](https://github.com/EcoExtreML/STEMMUS_SCOPE_Processing/blob/main/environment.yml). Also, set the `WorkDir` and `NumberOfTimeSteps` in the model config file e.g. `config_file_snellius.txt`.
