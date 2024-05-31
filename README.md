# STEMMUS_SCOPE

Integrated code of SCOPE and STEMMUS.

SCOPE is a radiative transfer and energy balance model, and STEMMUS model is a two-phase mass and heat transfer model. For more information about the coupling between these two models, please check [this reference](https://gmd.copernicus.org/articles/14/1379/2021/). Before running the model, you need to prepare input data and a configuration file. This can be done using the python package
[PyStemmusScope](https://pystemmusscope.readthedocs.io).  

![img](https://raw.githubusercontent.com/EcoExtreML/STEMMUS_SCOPE/main/docs/assets/imgs/coupling_scheme.png)
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
About how to run `STEMMUS_SCOPE` on Snellius, check [./docs/STEMMUS_SCOPE_on_Snellius.md](https://github.com/EcoExtreML/STEMMUS_SCOPE/blob/main/docs/STEMMUS_SCOPE_on_Snellius.md).

If you want to run `STEMMUS_SCOPE` on CRIB, check [./docs/STEMMUS_SCOPE_on_CRIB.md](https://github.com/EcoExtreML/STEMMUS_SCOPE/blob/main/docs/STEMMUS_SCOPE_on_CRIB.md).

If you want to run `STEMMUS_SCOPE` on your own machine, check [./docs/STEMMUS_SCOPE_on_local_device.md](https://github.com/EcoExtreML/STEMMUS_SCOPE/blob/main/docs/STEMMUS_SCOPE_on_local_device.md).

`STEMMUS_SCOPE` scope also has a Basic Model Interface (BMI) mode implemented. The full BMI is implemented in Python in [PyStemmusScope](https://github.com/EcoExtreML/STEMMUS_SCOPE_Processing/). For more information, check [./docs/STEMMUS_SCOPE_BMI.md](https://github.com/EcoExtreML/STEMMUS_SCOPE/blob/main/docs/STEMMUS_SCOPE_BMI.md).

## Contributing

If you want to contribute to the development of `STEMMUS_SCOPE`,
have a look at the [contribution guidelines](https://github.com/EcoExtreML/STEMMUS_SCOPE/blob/main/CONTRIBUTING.md).

## How to cite us
[![RSD](https://img.shields.io/badge/rsd-ecoextreml-00a3e3.svg)](https://research-software-directory.org/projects/ecoextreml)
<!-- [![DOI](https://zenodo.org/badge/DOI/<replace-with-created-DOI>.svg)](https://doi.org/<replace-with-created-DOI>) -->
