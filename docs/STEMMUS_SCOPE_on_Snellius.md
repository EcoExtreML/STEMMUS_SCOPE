## STEMMUS_SCOPE on Snellius

[Snellius](https://servicedesk.surfsara.nl/wiki/display/WIKI/Snellius) is the
Dutch National supercomputer hosted at SURF.

### Dataflow of STEMMUS_SCOPE on Snellius:

Data required by the model are in a folder named "data" in the project
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
  - input_soilThick.csv (optional)

For the explanation of the directories see
[Dataflow of STEMMUS_SCOPE on CRIB](./STEMMUS_SCOPE_on_CRIB.md#dataflow-of-stemmus_scope-on-crib).

### Configuration file:

Config file: it is a text file that sets the paths **required** by the model.
  For example, see [config_file_snellius.txt](../config_file_snellius.txt) in
  this repository. This file includes:

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
