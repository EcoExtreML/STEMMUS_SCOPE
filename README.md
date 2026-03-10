# STEMMUS_SCOPE

STEMMUS-SCOPE is a coupled, process-based ecohydrological model that acts as a digital twin for simulating the complex interactions within the soil–plant–atmosphere continuum (SPAC). It integrates soil hydrothermal dynamics (STEMMUS) with plant photosynthesis, fluorescence, and energy fluxes (SCOPE) to advance the understanding of water-energy-carbon interactions, particularly under water-limited conditions.

Key Components and Functionality
STEMMUS (Simultaneous Transfer of Energy, Mass and Momentum in Unsaturated Soil): A two-phase (liquid and gas) heat and mass transfer model that simulates vertical transport in soil.
SCOPE (Soil Canopy Observation of Photosynthesis and Energy fluxes): A canopy model that describes radiative transfer, canopy photosynthesis, and energy balances .
Coupling Mechanism: STEMMUS-SCOPE links these models via a 1D root growth model and a resistance scheme from the soil to the atmosphere. STEMMUS feeds root zone moisture and temperature into the canopy module, while SCOPE returns soil surface temperature as a boundary condition. Advanced versions (STEMMUS-SCOPE-PHS) now include a full plant hydraulics pathway, calculating water potentials in roots, stems, and leaves to better simulate xylem vulnerability .

Main Capabilities and Applications
Drought and Water Stress Monitoring: The model specifically tracks plant hydraulic function and root water uptake to assess ecosystem responses to extreme events like droughts and heatwaves. Validation studies on maize confirm its high accuracy in simulating SIF and GPP under drought stress.

Solar-Induced Chlorophyll Fluorescence (SIF): The model simulates SIF, allowing for direct comparison with satellite-derived SIF to evaluate photosynthetic light responses and water stress effects across different scales.

Improved Flux Estimation: STEMMUS-SCOPE better captures the dynamics of evapotranspiration (ET) and gross primary production (GPP) than traditional models, especially under water-deficit conditions. The plant hydraulics version (PHS) further improves these simulations.

Digital Twin and Data Integration: It is used as a "forward modeling" pillar in creating digital replicas of the soil-plant system, supporting the integration of Earth Observation (EO) data and machine learning for better environmental monitoring. It has been used to generate a consistent global dataset of SPAC fluxes, filling critical gaps in observations.

For more information about the coupling between these two models, please check [this reference](https://gmd.copernicus.org/articles/14/1379/2021/). Before running the model, you need to prepare input data and a configuration file. This can be done using the python package
[PyStemmusScope](https://pystemmusscope.readthedocs.io).

![img](https://raw.githubusercontent.com/EcoExtreML/STEMMUS_SCOPE/main/docs/assets/imgs/coupling_scheme.png)
(by Zeng & Su, 2021)

## Documentation

The documentation of the STEMMUS_SCOPE model can be found [here](https://ecoextreml.github.io/STEMMUS_SCOPE/).

## Contributing

If you want to contribute to the development of `STEMMUS_SCOPE`,
have a look at the [contribution guidelines](https://github.com/EcoExtreML/STEMMUS_SCOPE/blob/main/CONTRIBUTING.md).

## How to cite us

[![RSD](https://img.shields.io/badge/rsd-ecoextreml-00a3e3.svg)](https://research-software-directory.org/projects/ecoextreml)
<!-- [![DOI](https://zenodo.org/badge/DOI/<replace-with-created-DOI>.svg)](https://doi.org/<replace-with-created-DOI>) -->
