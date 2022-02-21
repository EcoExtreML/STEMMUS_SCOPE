# STEMMUS_SCOPE

Integrated code of SCOPE and STEMMUS.

## STEMMUS_SCOPE on CRIB

[CRIB](https://crib.utwente.nl/) is the ITC Geospatial Computing Platform.

### Dataflow of STEMMUS_SCOPE on CRIB:

1. Data required by the model are in a folder named "input" under project
    directory on CRIB. This folder includes:

    - Plumber2_data: the forcing/driving data provided by PLUMBER2.
    - SoilProperty: the soil texture data and soil hydraulic parameters.
    Below directory explanations are from SCOPE documentation (https://scope-model.readthedocs.io/en/latest/directories.html):
    - directional: the observer’s zenith and azimuth angles.(only used for multi-angle simulations (if the option ‘directional’ is switched on in parameters).
    - fluspect_parameters: [FIXE ME]
    - leafangles: [FIXE ME]
    - radiationdata: [FIXE ME]
    - soil_spectra: [FIXE ME]
    - input_data.xlsx: [FIXE ME]

2. Config file: it is a text file that sets the paths **required** by the
    model. For example, see `config_file_crib.txt` in this repository. This file
    includes:

    - SoilPropertyPath: a path to soil texture data and soil hydraulic
      parameters.
    - InputPath: this is the working/running directory of the model and should
      include the data of `directional`, `fluspect_parameters`, `leafangles`,
      `radiationdata`, `soil_spectra`, and `input_data.xlsx`.
    - OutputPath: this is the base path to store outputs of the model. When the
    model runs, it creates `sitename_timestamped` directories under this
    path.
    - ForcingPath: a path to the forcing/driving data.
    - ForcingFileName: name of the forcing file in a netcdf format. Currently,
    the model runs at the site scale. For example, if we put the
    `FI-Hyy_1996-2014_FLUXNET2015_Met.nc` here, the model runs at the `FI-Hyy`
    site.

    > To edit the config file, open the file with a text editor and change the
    > paths. The variable names e.g. `SoilPropertyPath` should not be changed.
    > Also, note a `/` is required at the end of each line.

> As explained above, the "InputPath" directory of the model is considered as
> the working/running directory and should include some data required by the
> model. As seen in the config file, the "InputPath" is now set as same as the
> "input" folder. This means that the "input" folder is treated as the
> model's working/running directory. However, it is possible to create a
> different working/running directory and set the "InputPath" to it. Then,
> you should copy the required data i.e. `directional`, `fluspect_parameters`,
> `leafangles`, `radiationdata`, `soil_spectra`, and `input_data.xlsx` to the
> working/running directory.

### Workflow of STEMMUS_SCOPE on CRIB:

1. The model reads the `ForcingFile` e.g. `FI-Hyy_1996-2014_FLUXNET2015_Met.nc`
  from "ForcingPath" and extracts forcing variables in `.dat` format using
  `filesread.m`. The `.dat` files are stored in the "InputPath" directory. In
  addition, the model reads the site information i.e. the location and
  vegetation parameters.
2. The model reads the soil parameters from "SoilPropertyPath" using
    `soilpropertyread.m`.
3. Some constants are loaded using `Constant.m`.
4. The model runs step by step until the whole simulation period  is completed
    i.e till the last time step of the forcing data.
5. The results are saved as binary files temporarily. Then, the binary files are
    converted to `.csv` files and stored in a `sitename_timestamped` output
    directory under "OutputPath".

### How to run STEMMUS_SCOPE on CRIB:

1. Log in CRIB with your username and password and select a proper compute unit.
2. Download the source code from this repository or get it using `git clone` in
  a terminal:
  
    ` git clone https://github.com/EcoExtreML/STEMMUS_SCOPE.git `
    
    All the codes can be found in the folder `src` whereas the executable file in
    the folder `exe`.

3. Check `config_file_crib.txt` and change the paths if needed, specifically
   "InputPath" and "OutputPath".
4. Follow instruction 1 OR 2 below:

    1. **Using MATLAB that requires a license**:
    If you want to use MATLAB desktop, click on the `Remote Desktop` in the
    Launcher. Click on the `Applications`. You will find the 'MATLAB' software under
    the `Research`. After clicking on 'MATLAB', it asks for your account information
    that is connected to a MATLAB license. Open the file `filesread.m` and set the
    variable `CFG` to the path of the config file e.g. `CFG =
    '/data/shared/EcoExtreML/STEMMUS_SCOPEv1.0.0/STEMMUS_SCOPE/config_file_crib.txt';`.
    Then, run the main script `STEMMUS_SCOPE.m`. As an alternative, you can run the
    main script using MATLAB command line in a terminal:

        ```bash
        matlab -nodisplay -nosplash -nodesktop -r "run('STEMMUS_SCOPE.m');exit;"
        ```

    2. **Using MATLAB Compiler that does not require a license**:
    If you want to run the model as a standalone application, you need MATLAB
    Runtime version `2021a`. To download and install the MATLAB Runtime, follow
    this
    [instruction](https://nl.mathworks.com/products/compiler/matlab-runtime.html).
    The "STEMMUS_SCOPE" executable file is in `STEMMUS_SCOPE/exe` directory
    in this repository. You can run the model by passing the path of the config
    file in a terminal:

        ```bash
        exe/STEMMUS_SCOPE config_file_crib.txt
        ```

## STEMMUS_SCOPE on Snellius

[Snellius](https://servicedesk.surfsara.nl/wiki/display/WIKI/Snellius) is the
Dutch National supercomputer hosted at SURF.

### Dataflow of STEMMUS_SCOPE on Snellius:

1. Data required by the model are in a folder named "data" in the project
    directory `einf2480` on Snellius. This directory includes:

    - forcing/plumber2_data: the forcing/driving data provided by PLUMBER2.
    - model_parameters/soil_property: the soil texture data and soil hydraulic parameters.
    - model_parameters/vegetation_property:
      - directional: [FIXE ME]
      - fluspect_parameters: [FIXE ME]
      - leafangles: [FIXE ME]
      - radiationdata: [FIXE ME]
      - soil_spectra: [FIXE ME]
      - input_data.xlsx: [FIXE ME]

2. Config file: it is a text file that sets the paths **required** by the
    model. For example, see `config_file_snellius.txt` in this repository. This file
    includes:

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

    > To edit the config file, open the file with a text editor and change the
    > paths. The variable name e.g. `SoilPropertyPath` should not be changed.
    > Also, note a `/` is required at the end of each line.

> As explained above, the "InputPath" directory of the model is considered as
> the working/running directory and should include some data required by the
> model. As seen in the config file, the "InputPath" is now set to an "input"
> folder under "scratch-shared" directory. This means that the "input" folder is
> treated as the model's working/running directory. However, it is possible to
> create a different working/running directory and set the "InputPath" to it.
> Then, you should copy the required data i.e. `directional`,
> `fluspect_parameters`, `leafangles`, `radiationdata`, `soil_spectra`, and `
> input_data.xlsx` to the working/running directory. For example:
>
> ` cp -r
> /projects/0/einf2480/model_parameters/vegetation_property/*
> /scratch-shared/EcoExtreML/STEMMUS_SCOPE/input/<your_work_dir> `

### Workflow of STEMMUS_SCOPE on Snellius:

This is the same as the workflow of STEMMUS_SCOPE on crib, see section
[Workflow of STEMMUS_SCOPE on CRIB](#workflow-of-stemmus_scope-on-crib). 

### How to run STEMMUS_SCOPE on Snellius:

1. Log in to Snellius. 
2. Download the source code from this repository or get it using `git clone` in
   a terminal:

    ` git clone https://github.com/EcoExtreML/STEMMUS_SCOPE.git `

    All the codes can be found in the folder `src` whereas the executable file in
    the folder `exe`.

3. Check `config_file_snellius.txt` and change the paths if needed,
   specifically "InputPath" and "OutputPath".
4. Follow instruction 1 OR 2 below: 

    1. **Using MATLAB that requires a license**: 
    In order to use MATLAB, you need to send a request to add you to the user
    pool on Snellius. Then, open the file `filesread.m` and set the variable
    `CFG` to the path of the config file e.g. `CFG =
    './STEMMUS_SCOPE/config_file_snellius.txt';`. Then, run the main script
    `STEMMUS_SCOPE.m` using MATLAB command line in a terminal on a **comupute
    node**:

        ```bash
        module load 2021
        module load MATLAB/2021a-upd3
        matlab -nodisplay -nosplash -nodesktop -r "run('STEMMUS_SCOPE.m');exit;"
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
        matlab -nodisplay -nosplash -nodesktop -r "run('STEMMUS_SCOPE.m');exit;"
        ```

    2. **Using MATLAB Compiler that does not require a license**:
    If you want to run the model as a standalone application, you need MATLAB
    Runtime version `2021a`. This is avialbale on Snellius. You can run the
    model by passing the path of the config file in a terminal on a **comupute
    node**:

        ```bash
        module load 2021
        module load MCR/R2021a.3
        ./STEMMUS_SCOPE/exe/STEMMUS_SCOPE config_file_snellius.txt
        ```
    
        > The bash script `run_stemmus_scope_snellius.sh` in this repository,
        > runs the model at two sites (default) on a **comupute node**. The
        > scripts loops over forcing files in the "ForcingPath", creates
        > `sitename_timestamped` working directories under "InputPath" directory
        > and copies required data to those working drs. To change the number of
        > sites, open the script and change the parameter `1-2` in line `#SBATCH
        > --array=1-2`. A maximum number of simultaneously running tasks from
        > the job array may be specified using a "%" separator. For example
        > "--array=1-10%4" will limit the number of simultaneously running tasks
        > from this job array to 4, see [Slurm Job
        > Array](https://slurm.schedmd.com/job_array.html). Note that the model
        > run can take long for some of the sites. You can run the script in a
        > terminal: `cd STEMMUS_SCOPE; mkdir -p slurm; sbatch
        > run_stemmus_scope_snellius.sh`. This creates a log file per each
        > forcing file in a folder `slurm`.

## Create an executable file of STEMMUS_SCOPE

See the [exe readme](./exe/README.md).

## Preparing the outputs of the model in NetCDF:

There are some files in `utils` directory in this repository. The utils are used
to read `.csv` files and save them in `.nc` format. 

> An example NetCDF file is stored in the project directory to show the desired
  structure of variables in one file.
