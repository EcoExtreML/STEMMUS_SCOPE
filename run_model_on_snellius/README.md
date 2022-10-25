## Run STEMMUS_SCOPE on Snellius

This folder contains files that are needed for running `STEMMUS_SCOPE` on Snellius:

- `run_stemmus_scope_snellius.sh` is the batch script for job submission
- `run_model.py` is the python script for executing the workflow
- `config_file_snellius.txt` is the config file for paths

To use the scripts, make sure that `PyStemmusScope` is installed from the repositary `STEMMUS_SCOPE_Processing`.

Before submitting the job via `sbatch run_stemmus_scope_snellius.sh`, remember to config the `NumberOfTimeSteps` in the python script `run_model.py`.
