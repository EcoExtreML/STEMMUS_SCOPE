# STEMMUS_SCOPE

Integrated code of SCOPE and STEMMUS.

## Run the model

You need the python package
[PyStemmusScope](https://pystemmusscope.readthedocs.io/en/latest/index.html).
See the relevant instructions for `Users` or `Developers` on how to run the
model.

### Users

As a user, you don't need to have a MATLAB license to run the STEMMUS-SCOPE
model. The workflow is executed using python and MATLAB Runtime on a Unix-like
system. Follow this
[instruction](https://pystemmusscope.readthedocs.io/en/latest/readme_link.html#users).

### Developers

If you want to contribute to the development of STEMMUS_SCOPE,
have a look at the [contribution guidelines](CONTRIBUTING.md).

### Dataflow of STEMMUS_SCOPE on CRIB:

[CRIB](https://crib.utwente.nl/) is the ITC Geospatial Computing Platform.

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
    - NumberOfTimeSteps: total number of time steps which model runs for. It can be
      `NA` or a number. Example `NumberOfTimeSteps=17520` runs the model for one year a
      half-hour time step i.e. `365*24*2=17520`.

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
    directory under "OutputPath". A netcdf file is also created in the same
    directory, see [csv_to_nc/README](./utils/csv_to_nc/README.md).

### Dataflow of STEMMUS_SCOPE on Snellius:

[Snellius](https://servicedesk.surfsara.nl/wiki/display/WIKI/Snellius) is the
Dutch National supercomputer hosted at SURF.

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
  [Dataflow of STEMMUS_SCOPE on CRIB](#dataflow-of-stemmus_scope-on-crib).

2. Config file: it is a text file that sets the paths **required** by the model.
    For example, see [config_file_snellius.txt](config_file_snellius.txt) in
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
    - NumberOfTimeSteps: total number of time steps in which model runs. It can be
      `NA` or a number. Example `NumberOfTimeSteps=17520` runs the model for one year a
      half-hour time step i.e. `365*24*2=17520`.

### Workflow of STEMMUS_SCOPE on Snellius:

This is the same as the workflow of STEMMUS_SCOPE on crib, see section
[Workflow of STEMMUS_SCOPE on CRIB](#workflow-of-stemmus_scope-on-crib).
