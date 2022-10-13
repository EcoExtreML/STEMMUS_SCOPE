# STEMMUS_SCOPE

`STEMMUS_SCOPE` serves as an integrated code of SCOPE and STEMMUS.

SCOPE is a radiative transfer and energy balance model, and STEMMUS model is a two-phase mass and heat transfer model. For more information about the coupling between these two models, please check [this reference](https://gmd.copernicus.org/articles/14/1379/2021/).

<img width="500" alt="Logo" src=./docs/assets/imgs/coupling_scheme.png>

## Running STEMMUS_SCOPE

```mermaid
flowchart LR
  subgraph Platform
    direction RL
    Snellius
    CRIB
    Your own machine
  end
  A(Data)
  Platform --> A
  B(Config file)
  A --> B
  C{{Run model}}
  B --> C
  click Snellius "https://github.com/EcoExtreML/STEMMUS_SCOPE/tree/main/docs/STEMMUS_SCOPE_on_Snellius.md" "Run STEMMUS_SCOPE on Snellius" _blank
  click CRIB "https://github.com/EcoExtreML/STEMMUS_SCOPE/tree/main/docs/STEMMUS_SCOPE_on_CRIB.md" "Run STEMMUS_SCOPE on CRIB" _blank
```
About how to run `STEMMUS_SCOPE` on Snellius, check [this document](./docs/STEMMUS_SCOPE_on_Snellius.md).

If you want to run `STEMMUS_SCOPE` on CRIB, check [this document](./docs/STEMMUS_SCOPE_on_CRIB.md).

## Create an executable file of STEMMUS_SCOPE

See the [exe readme](./exe/README.md).

## Preparing the outputs of the model in NetCDF:

There is some files in utils directory in this repository. The utils are used to
read `.csv` files and save them in `.nc` format. See [utils
readme](./utils/csv_to_nc/README.md).

> An example NetCDF file is stored in the project directory to show the desired
  structure of variables in one file.

## Contributing

If you want to contribute to the development of `STEMMUS_SCOPE`,
have a look at the [contribution guidelines](CONTRIBUTING.md).

## How to cite us
[![RSD](https://img.shields.io/badge/rsd-ecoextreml-00a3e3.svg)](https://research-software-directory.org/projects/ecoextreml)
<!-- [![DOI](https://zenodo.org/badge/DOI/<replace-with-created-DOI>.svg)](https://doi.org/<replace-with-created-DOI>) -->

<!--TODO: add links to zenodo. -->
More information will follow soon.