# Requiremnets:

## Data

To run the STEMMUS-SCOPE model, you need to have input data either from in-situ
measurements or from remote sensing. Before running the model, you need to
prepare input data and a configuration file. This can be done using the python
package [PyStemmusScope](https://pystemmusscope.readthedocs.io).

### Data on CRIB

[CRIB](https://crib.utwente.nl/) is the ITC Geospatial Computing Platform.

{% include-markdown "./STEMMUS_SCOPE_on_CRIB.md" start="### Dataflow of STEMMUS_SCOPE on CRIB:" end="### Configuration file:" heading-offset=2%}

### Data on Snellius

[Snellius](https://servicedesk.surfsara.nl/wiki/display/WIKI/Snellius) is the
Dutch National supercomputer hosted at SURF.

{% include-markdown "./STEMMUS_SCOPE_on_Snellius.md" start="### Dataflow of STEMMUS_SCOPE on Snellius:" end="### Configuration file:" heading-offset=2%}

### Example dataset on Zenodo

A pre-processed example dataset can be found on Zenodo
[here](https://zenodo.org/records/10566827).

## Configuration file

The configuration file is a text file that sets the paths required by the model.
For example, see
[config_file_template.txt](https://github.com/EcoExtreML/STEMMUS_SCOPE/blob/main/config_file_template.txt).

### Configuration file on CRIB

{% include-markdown "./STEMMUS_SCOPE_on_CRIB.md" start="### Configuration file:" end="### Workflow of STEMMUS_SCOPE on CRIB:" heading-offset=2%}

### Configuration file on Snellius

{% include-markdown "./STEMMUS_SCOPE_on_Snellius.md" start="### Configuration file:" end="### Workflow of STEMMUS_SCOPE on Snellius:" heading-offset=2%}

### Example configuration file

An example configuration file can be found [here]((https://github.com/EcoExtreML/STEMMUS_SCOPE/blob/main/config_file_template.txt)).

## Software

To run the STEMMUS-SCOPE model, you need **one** of the following:

- [MATLAB](https://nl.mathworks.com/products/matlab.html)
- [MATLAB Runtime](https://nl.mathworks.com/products/compiler/matlab-runtime.html) on a Unix-like system
- [Octave](https://octave.org/)
- [Docker](https://www.docker.com/)