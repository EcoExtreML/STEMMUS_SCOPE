## STEMMUS_SCOPE on CRIB

[CRIB](https://crib.utwente.nl/) is the ITC Geospatial Computing Platform.

### Dataflow of STEMMUS_SCOPE on CRIB:

1. Data required by the model are in a folder named "input" under project
    directory on CRIB. This folder includes:

    - Plumber2_data: the forcing/driving data provided by PLUMBER2.
    - SoilProperty: the soil texture data and soil hydraulic parameters. 
    
    Below the directory explanations are from [SCOPE
    documentation](https://scope-model.readthedocs.io/en/latest/directories.html):

    - directional: the observer’s zenith and azimuth angles.(only used for
      multi-angle simulations (if the option ‘directional’ is switched on in
      parameters).
    - fluspect_parameters: absorption spectra of different leaf components are
      provided, according to PROSPECT 3.1, as well as Fluspect input: standard
      spectra for PSI and PSII.
    - leafangles: example leaf inclination distribution data are provided.
    - radiationdata: RTMo.m calculates spectra based on MODTRAN5 outputs (T-18
      system).Note that in the input data (files as well as the spreadsheet),
      the broadband input radiation may be provided. SCOPE linearly scales the
      input spectra of the optical and the thermal domain in such a way that
      the spectrally integrated input shortwave and long-wave radiation matches
      with the measured values.
    - soil_spectra: the soil spectrum is provided. Note that it is also possible
      to simulate a soil reflectance spectrum with the BSM model. In that case,
      the values for the BSM model parameters are taken from the input data, and
      the archived spectra in this folder are not used.
    - input_data.xlsx: the input to SCOPE model is provided. It
      provides parameter inputs for PROSPECT, leaf_biochemical, fluorescence,
      soil, canopy, aerodynamic, angles, photosynthetic temperature dependence
      functional parameters, etc.

2. Config file: it is a text file that sets the paths **required** by the
    model. For example, see [config_file_crib.txt](../config_file_crib.txt) in this repository. This file
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
    - DurationSize: total number of time steps in which model runs. It can be
      `NA` or a number. Example `DurationSize=17520` runs the model for one year a
      half-hour time step i.e. `365*24*2=17520`.

    To edit the config file, open the file with a text editor and change the
    paths. The variable names e.g. `SoilPropertyPath` should not be changed.
    Also, note a `/` is required at the end of each line.

As explained above, the "InputPath" directory of the model is considered as
the working/running directory and should include some data required by the
model. As seen in the config file, the "InputPath" is now set as same as the
"input" folder. This means that the "input" folder is treated as the
model's working/running directory. However, it is possible to create a
different working/running directory and set the "InputPath" to it. Then,
you should copy the required data i.e. `directional`, `fluspect_parameters`,
`leafangles`, `radiationdata`, `soil_spectra`, and `input_data.xlsx` to the
working/running directory.

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
4. Follow the instructions below:

#### Run using MATLAB that requires a license

If you want to use MATLAB desktop,

1. click on the `Remote Desktop` in the
Launcher. Click on the `Applications`. You will find the 'MATLAB' software under
the `Research`. 
2. After clicking on 'MATLAB', it asks for your account information that is
connected to a MATLAB license.
3. Open the file `filesread.m` and set the
variable `CFG` to the path of the config file e.g. `CFG =
'/data/shared/EcoExtreML/STEMMUS_SCOPEv1.0.0/STEMMUS_SCOPE/config_file_crib.txt';`.
4. Then, run the main script `STEMMUS_SCOPE.m`.

As an alternative, you can run the
main script using MATLAB command line in a terminal:

```bash
matlab -nodisplay -nosplash -nodesktop -r "run('STEMMUS_SCOPE.m');exit;"
```