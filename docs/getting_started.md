# Requiremnets

## Computig resource

To run the STEMMUS-SCOPE model, you can use one of the following computing resources:

- [CRIB](https://crib.utwente.nl/) is the ITC Geospatial Computing Platform.
- [Snellius](https://servicedesk.surfsara.nl/wiki/display/WIKI/Snellius) is the
Dutch National supercomputer hosted at SURF.

Otherwise, you can run the model on your local device if you have the correct
set of software and data.

## Software

To run the STEMMUS-SCOPE model, you need **one** of the following:

- [MATLAB](https://nl.mathworks.com/products/matlab.html)
- [MATLAB Runtime](https://nl.mathworks.com/products/compiler/matlab-runtime.html) on a Unix-like system
- [Octave](https://octave.org/)
- [Docker](https://www.docker.com/)

## Model source code

The source code of STEMMUS_SCOPE can be found in the GitHub repository
[https://github.com/EcoExtreML/STEMMUS_SCOPE](https://github.com/EcoExtreML/STEMMUS_SCOPE)
under the folder `src`. Download the [latest version of the
model](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases) from the repository
or get it using `git clone` in a terminal:

` git clone https://github.com/EcoExtreML/STEMMUS_SCOPE.git `


## Data

To run the STEMMUS-SCOPE model, you need to have input data either from in-situ
measurements or from remote sensing. Before running the model, you need to
prepare input data and a configuration file for **one site/location**. This can be done using
[setup()](https://pystemmusscope.readthedocs.io/en/latest/reference/#PyStemmusScope.stemmus_scope.StemmusScope.setup) function
in the python package [PyStemmusScope](https://pystemmusscope.readthedocs.io/en/latest/). See example datasets below:

=== "Example dataset on Zenodo"
    A pre-processed example dataset for one site can be found on Zenodo
    [here](https://zenodo.org/records/10566827).

=== "Data on CRIB"
    [CRIB](https://crib.utwente.nl/) is the ITC Geospatial Computing Platform.

    {% include-markdown "./STEMMUS_SCOPE_on_CRIB.md" start="### Dataflow of STEMMUS_SCOPE on CRIB" end="### Configuration file" heading-offset=2%}

=== "Data on Snellius"
    [Snellius](https://servicedesk.surfsara.nl/wiki/display/WIKI/Snellius) is the
    Dutch National supercomputer hosted at SURF.

    {% include-markdown "./STEMMUS_SCOPE_on_Snellius.md" start="### Dataflow of STEMMUS_SCOPE on Snellius" end="### Configuration file" heading-offset=2%}

## Configuration file

The configuration file is a text file that sets the paths required by the model.
The configuration file should contain the following information:

```text
WorkDir=/path_to_working_directory/
SoilPropertyPath=/path_to_soil_property_data/
ForcingPath=/path_to_forcing_data/
Location=AU-DaS
directional=/path_to_directional_data/
fluspect_parameters=/path_to_fluspect_parameters_data/
leafangles=/path_to_leafangles_data/
radiationdata=/path_to_radiation_data/
soil_spectrum=/path_to_soil_spectra_data/
InitialConditionPath=/path_to_soil_initial_condition_data/
input_data=/path_to_input_data.xlsx_file/
StartTime=2001-01-01T00:00
EndTime=2001-01-02T00:00
InputPath=/path_to_model_input_folder/
OutputPath=/path_to_model_output_folder/
```
The configuration file could contain the following optional information:
```text
soil_layers_thickness=/path_to_input_soilLayThick.csv_file/
SleepDuration=30
FullCSVfiles=1
```

See example configuration files below:

=== "Example configuration file"
    An example configuration file can be found
    [here](https://github.com/EcoExtreML/STEMMUS_SCOPE/blob/main/config_file_template.txt). If
    [setup()](https://pystemmusscope.readthedocs.io/en/latest/reference/#PyStemmusScope.stemmus_scope.StemmusScope.setup)
    function in the python package
    [PyStemmusScope](https://pystemmusscope.readthedocs.io/en/latest/) is used
    to prepare data, the model configuration file including `InputPath` and
    `OutputPath` and the data of **one site/location** will be generated
    automatically.

=== "Example configuration file on CRIB"
    {% include-markdown "./STEMMUS_SCOPE_on_CRIB.md" start="### Configuration file" heading-offset=2%}

=== "Example configuration file on Snellius"
    {% include-markdown "./STEMMUS_SCOPE_on_Snellius.md" start="### Configuration file" heading-offset=2%}
