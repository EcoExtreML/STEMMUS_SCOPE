# STEMMUS_SCOPE

`STEMMUS_SCOPE` serves as an integrated code of SCOPE and STEMMUS.

SCOPE is a radiative transfer and energy balance model, and STEMMUS model is a two-phase mass and heat transfer model. For more information about the coupling between these two models, please check [this reference](https://gmd.copernicus.org/articles/14/1379/2021/).

<img width="500" alt="Logo" src=./docs/assets/imgs/coupling_scheme.png>
(by Zeng & Su, 2021)

## Running STEMMUS_SCOPE

```mermaid
flowchart LR
  subgraph Platform
    direction RL
    b[Snellius]
    c[CRIB]
    d[Your own machine]
  end
  A(Data)
  Platform --> A
  B(Config file)
  A --> B
  C{{Run model}}
  B --> C
  click b "https://github.com/EcoExtreML/STEMMUS_SCOPE/tree/main/docs/STEMMUS_SCOPE_on_Snellius.md" "Run STEMMUS_SCOPE on Snellius" _blank
  click c "https://github.com/EcoExtreML/STEMMUS_SCOPE/tree/main/docs/STEMMUS_SCOPE_on_CRIB.md" "Run STEMMUS_SCOPE on CRIB" _blank
  click d "https://github.com/EcoExtreML/STEMMUS_SCOPE/tree/main/docs/STEMMUS_SCOPE_on_local_device.md" "Run STEMMUS_SCOPE on your own machine" _blank
```
About how to run `STEMMUS_SCOPE` on Snellius, check [this document](./docs/STEMMUS_SCOPE_on_Snellius.md).

If you want to run `STEMMUS_SCOPE` on CRIB, check [this document](./docs/STEMMUS_SCOPE_on_CRIB.md).

If you want to run `STEMMUS_SCOPE` on your own machine, check [this document](./docs/STEMMUS_SCOPE_on_local_device.md).

## Contributing

If you want to contribute to the development of `STEMMUS_SCOPE`,
have a look at the [contribution guidelines](CONTRIBUTING.md).

## How to cite us
[![RSD](https://img.shields.io/badge/rsd-ecoextreml-00a3e3.svg)](https://research-software-directory.org/projects/ecoextreml)
<!-- [![DOI](https://zenodo.org/badge/DOI/<replace-with-created-DOI>.svg)](https://doi.org/<replace-with-created-DOI>) -->

<!--TODO: add links to zenodo. -->
More information will follow soon.
