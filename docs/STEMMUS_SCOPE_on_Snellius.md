## STEMMUS_SCOPE on Snellius

[Snellius](https://servicedesk.surfsara.nl/wiki/display/WIKI/Snellius) is the
Dutch National supercomputer hosted at SURF.

### Dataflow of STEMMUS_SCOPE on Snellius:

1. Data required by the model are in a folder named "data" in the project
    directory `einf2480` on Snellius. This directory includes:

    - forcing/plumber2_data: the forcing/driving data provided by PLUMBER2.
    - model_parameters/soil_property: the soil texture data and soil hydraulic parameters.
    - model_parameters/vegetation_property:
      - directional
      - fluspect_parameters
      - leafangles
      - radiationdata
      - soil_spectra
      - input_data.xlsx

    For the explanation of the directories see 
  [Dataflow of STEMMUS_SCOPE on CRIB](./STEMMUS_SCOPE_on_CRIB.md#dataflow-of-stemmus_scope-on-crib).

2. Config file: it is a text file that sets the paths **required** by the model.
    For example, see [config_file_snellius.txt](../config_file_snellius.txt) in
    this repository. This file includes:

    - SoilPropertyPath: a path to soil texture data and soil hydraulic
      parameters.
    - InputPath: this is the working/running directory of the model and should
      include the data of `directional`, `fluspect_parameters`, `leafangles`,
      `radiationdata`, `soil_spectra`, and `input_data.xlsx`.
    - OutputPath: this is the base path to store outputs of the model. When
    the model runs, it creates `sitename_timestamped` directories under
    this path.
    - ForcingPath: a path to the forcing/driving data.
    - ForcingFileName: name of the forcing file in a netcdf format. Currently,
    the model runs at the site scale. For example, if we put the
    `FI-Hyy_1996-2014_FLUXNET2015_Met.nc` here, the model runs at the `FI-Hyy`
    site.
    - VegetationPropertyPath: path to required data except `Plumber2_data` and `SoilProperty`. 
    - DurationSize: total number of time steps in which model runs. It can be
      `NA` or a number. Example `DurationSize=17520` runs the model for one year a
      half-hour time step i.e. `365*24*2=17520`.

    To edit the config file, open the file with a text editor and change the
    paths. The `InputPath` and `OutputPath` are user-defined directories, make
    sure they exist and you have right permissions. The variable name e.g.
    `SoilPropertyPath` should not be changed. Also, note a `/` is required at
    the end of each line.

As explained above, the "InputPath" directory of the model is considered as
the working/running directory and should include some data required by the
model. As seen in the config file, the "InputPath" is now set to an "input"
folder under "scratch-shared" directory. This means that the "input" folder is
treated as the model's working/running directory. However, it is possible to
create a different working/running directory and set the "InputPath" to it.
Then, you should copy the required data i.e. `directional`,
`fluspect_parameters`, `leafangles`, `radiationdata`, `soil_spectra`, and `
input_data.xlsx` to the working/running directory. For example:
` cp -r
/projects/0/einf2480/model_parameters/vegetation_property/*
/scratch-shared/EcoExtreML/STEMMUS_SCOPE/input/<your_work_dir> `

### Workflow of STEMMUS_SCOPE on Snellius:

This is the same as the workflow of STEMMUS_SCOPE on crib, see section
[Workflow of STEMMUS_SCOPE on CRIB](./STEMMUS_SCOPE_on_CRIB.md#workflow-of-stemmus_scope-on-crib). 

### How to run STEMMUS_SCOPE on Snellius:

1. Log in to Snellius. 
2. Download the source code from this repository or get it using `git clone` in
   a terminal:

    ` git clone https://github.com/EcoExtreML/STEMMUS_SCOPE.git `

    All the codes can be found in the folder `src` whereas the executable file in
    the folder `exe`.

3. Check `config_file_snellius.txt` and change the paths if needed,
   specifically "InputPath" and "OutputPath".
4. Follow one of the instructions below: 

#### Run using MATLAB that requires a license

In order to use MATLAB, you need to send a request to add you to the user pool
on Snellius. Then, open the file
[config_file_snellius.txt](../config_file_snellius.txt) and set the paths. Then,
run the main script `STEMMUS_SCOPE_exe.m` using MATLAB command line in a terminal on
a **compute node**:

```bash
module load 2021
module load MATLAB/2021a-upd3
matlab -nodisplay -nosplash -nodesktop -r "STEMMUS_SCOPE_exe('config_file_snellius.txt');exit;"
```

> To run the codes above on a compute node, you can create a bash script as:

```bash
#!/bin/bash
# SLURM settings
#SBATCH -J stemmus_scope
#SBATCH -t 01:00:00
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH -p thin
#SBATCH --output=./slurm_%j.out
#SBATCH --error=./slurm_%j.out

module load 2021
module load MATLAB/2021a-upd3
matlab -nodisplay -nosplash -nodesktop -r "STEMMUS_SCOPE_exe('config_file_snellius.txt');exit;"
```

#### Run using MATLAB Compiler that does not require a license

If you want to run the model as a standalone application, you need MATLAB
Runtime version `2021a`. This is available on Snellius. You can run the
model by passing the path of the config file in a terminal on a **compute
node**:

```bash
module load 2021
module load MCR/R2021a.3
./STEMMUS_SCOPE/exe/STEMMUS_SCOPE config_file_snellius.txt
```

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