## STEMMUS_SCOPE on CRIB

[CRIB](https://crib.utwente.nl/) is the ITC Geospatial Computing Platform.

### Dataflow of STEMMUS_SCOPE on CRIB:

Data required by the model are in a folder named "input" under project directory
on CRIB. This folder includes:

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
- input_soilLayThick.csv (optional): A file to change the discretization of
  the soil layers of the STEMMUS model. An example of this file is in
  [example_data folder](../example_data). This file (if needed) should be copied into the
  `InputPath` folder. If this file is used, it will override the default settings of
  the soil layers. The file has three columns: 1) layer number, 2) layer thickness,
  and 3) maximum root depth. The user is free to change the values of the three columns.
  Also, the number of rows determines the number of the soil layers and the total
  thickness of the soil column (sum of soil layer thickness).

### Configuration file:

Config file: it is a text file that sets the paths **required** by the
  model. For example, see [config_file_crib.txt](../config_file_crib.txt) in this
  repository. This file includes:

  - SoilPropertyPath: a path to soil texture data and soil hydraulic
    parameters.
  - InputPath: this is the working/running directory of the model and should
    include the data of `directional`, `fluspect_parameters`, `leafangles`,
    `radiationdata`, `soil_spectra`, and `input_data.xlsx`.
  - OutputPath: this is the base path to store outputs of the model. When the
  model runs, it creates `sitename_timestamped` directories under this
  path.
  - ForcingPath: a path to the forcing/driving data. I.e. the Plumber2 dataset.
  - Location: Location where the model should be run. Currently,
  the model runs at the site scale. For example, if we put `FI-Hyy` here, the model
  runs at the `FI-Hyy` site.
  - StartTime: The start time of the model, in the ISO 8601 format. For example:
  `2001-01-01T00:00`. Note that the time can only be defined in half hour increments.
  If you want the start time to be the first available data point of the forcing data,
  you can set StartTime to `NA`.
  - EndTime: The end time of the model. Formatted the same way as the StartTime.
  For example: `2001-12-31T23:30`. If you want the end time to be the last available
  data point of the forcing data, you can set EndTime to `NA`.

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
