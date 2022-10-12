# STEMMUS_SCOPE

Integrated code of SCOPE and STEMMUS.

<!-- TO DO: Briefly introduce STEMMUS_SCOPE -->
<img width="500" alt="Logo" src=./docs/assets/imgs/coupling_scheme.png>

## Running STEMMUS_SCOPE

```mermaid
flowchart LR
    A[Data] -->|set paths| B[Config file]
    B --> C(Choose platform)
    C -->D(Snellius)
    C -->E(CRIB)
    click D "./docs/STEMMUS_SCOPE_on_Snellius.md" "Run STEMMUS_SCOPE on Snellius" _blank
    click E "./docs/STEMMUS_SCOPE_on_CRIB.md" "Run STEMMUS_SCOPE on CRIB" _blank
```

## Create an executable file of STEMMUS_SCOPE

See the [exe readme](./exe/README.md).

## Preparing the outputs of the model in NetCDF:

There is some files in utils directory in this repository. The utils are used to
read `.csv` files and save them in `.nc` format. See [utils
readme](./utils/csv_to_nc/README.md).

> An example NetCDF file is stored in the project directory to show the desired
  structure of variables in one file.

## Documentation

More information will follow soon.

## Contributing

If you want to contribute to the development of `STEMMUS_SCOPE`,
have a look at the [contribution guidelines](CONTRIBUTING.md).

## How to cite us
[![RSD](https://img.shields.io/badge/rsd-ecoextreml-00a3e3.svg)](https://research-software-directory.org/projects/ecoextreml)
<!-- [![DOI](https://zenodo.org/badge/DOI/<replace-with-created-DOI>.svg)](https://doi.org/<replace-with-created-DOI>) -->

<!--TODO: add links to zenodo. -->
More information will follow soon.