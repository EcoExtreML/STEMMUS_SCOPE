# STEMMUS_SCOPE

Integrated code of SCOPE and STEMMUS

## STEMMUS_SCOPE on CRIB

### Dataflow of STEMMUS_SCOPE:

1. Data required by the model are in a folder named "input" on crib. This
    folder includes:

    - Plumber2_data: the forcing/driving data provided by PLUMBER2.
    - SoilProperty: the soil texture data and soil hydraulic parameters.
    - directional: [FIXE ME]
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
    - ForcingFileName: name of the forcing file in the netcdf format. Currently,
    the model runs at the site scale. For example, if we put the
    `FI-Hyy_1996-2014_FLUXNET2015_Met.nc` here, the model runs at the FI-Hyy
    site.

  > To edit the config file, open the file with a text editor and change the
  > paths. The variable names e.g. `SoilPropertyPath` should not be changed.
  > Also, note a `/` is required at the end of each line.

  > As explained above, the "InputPath" directory of the model is considered as
  > the working/running directory and should include some data required by the
  > model. As seen in the config file, the "InputPath" is now set as same as the
  > "input" folder on crib. This means that the "input" folder is treated as the
  > model's working/running directory. However, it is possible to create a
  > different working/running directory and set the "InputPath" to it. Then,
  > you should copy the required data i.e. `directional`, `fluspect_parameters`,
  > `leafangles`, `radiationdata`, `soil_spectra`, and `input_data.xlsx` to the
  > working/running directory.

### Workflow of STEMMUS_SCOPE:

1. The model reads the `ForcingFile` e.g. `FI-Hyy_1996-2014_FLUXNET2015_Met.nc`
  from "ForcingPath" and extracts forcing variables in `.dat` format using
  `filesread.m`. The `.dat` files are stored in the "InputPath" directory. In
  addition, the model reads the site information including location and
  vegetation.
2. The model reads the soil parameters from "SoilPropertyPath" with
    `soilpropertyread.m`.
3. Some constants are loaded using `Constant.m`.
4. The model runs step by step until the whole simulation period  is completed
    i.e till the last time step of the forcing data.
5. The results are saved as binary files temporarily. Then, the binary files are
    converted to `.csv` files and stored in a `sitename_timestamped` output
    directory under "OutputPath".

### How to run STEMMUS_SCOPE:

1. Log in CRIB. Open https://crib.utwente.nl/, then click login (with your username and pasword). 
2. Dwonload the source code from this repository or get it using `git clone` in
   a terminal: 
```
git clone https://github.com/EcoExtreML/STEMMUS_SCOPE.git
```
All the codes can be found in the folder `src`. 

3. Check `config_file_crib.txt` and change the paths if it is needed.
4. Follow step 1 or 2 below: 

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

    2. **Using MATLAB Compiler that does not require a license**: If you want to
    run the model as a standalone application, you need MATLAB runtime version
    `2021a`. To download and install the MATLAB Runtime, follow this
    [instruction](https://nl.mathworks.com/products/compiler/matlab-runtime.html).
    The "STEMMUS_SCOPE" aplication is located in `STEMMUS_SCOPE/exe` directory
    in this repository. You can run the model by paasing the path of the config
    file using a command line in a terminal:
    ```bash
    exe/STEMMUS_SCOPE config_file_crib.txt
    ```

## STEMMUS_SCOPE on Snellius

### Dataflow of STEMMUS_SCOPE:

1. Data required by the model are in a folder named "data" in the project dorectory `einf2480` on snellius. This
    directory includes:

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
    - this is the working/running directory of the model and should
      include the data of `directional`, `fluspect_parameters`, `leafangles`,
      `radiationdata`, `soil_spectra`, and `input_data.xlsx`.
    - OutputPath: this is the base path to store outputs of the model. When
    the model is running, it creates `sitename_timestamped` directories under
    this path.
    - ForcingPath: a path to the forcing/driving data.
    - ForcingFileName: name of the forcing file in the netcdf format. Currently,
    the model runs at the site scale. For example, if we put the
    `FI-Hyy_1996-2014_FLUXNET2015_Met.nc` here, the model will be run at the
    FI-Hyy site.
    - VegetationPropertyPath: path to required data except `Plumber2_data` and `SoilProperty`. 

  > To edit the config file, open the file with a text editor and change the
  > paths. The variable name e.g. `SoilPropertyPath` should not be changed.
  > Also, note a `/` is required at the end of each line.

  > As explained above, the "InputPath" directory of the model is considered as
  > the working/running directory and should include some data required by the
  > model. As seen in the config file, the "InputPath" is now set an "input"
  > folder under "scratch" directory. This means that the "input" folder is
  > treated as the model's working/running directory. However, it is possible to
  > create a different working/running directory and set the "InputPath" to it.
  > Then, you should copy the required data i.e. `directional`,
  > `fluspect_parameters`, `leafangles`, `radiationdata`, `soil_spectra`, and `
  > input_data.xlsx` to the working/running directory.

(3) Run STEMMUS_SCOPE v1.0.0 on a different compute node:

Open the file "filesread.m" and set all paths at the top of this file. The rest of the workflow is the same as explained above. 

(4) Converting `.csv` files to NetCDF files:

There is some files in utils directory in this repository. The utils are used to
read `.csv` files and save them in `.nc` format. 

> An example NetCDF file is stored in the project directory to show the desired
  structure of variables in one file.

(5) [Create Standalone Application from MATLAB](https://nl.mathworks.com/help/compiler/mcc.html)

```bash
mcc -m STEMMUS_SCOPE/src/STEMMUS_SCOPE_exe.m -a STEMMUS_SCOPE/src -d STEMMUS_SCOPE/exe -o STEMMUS_SCOPE -R nodisplay
```