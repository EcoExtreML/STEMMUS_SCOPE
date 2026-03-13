# STEMMUS_SCOPE

STEMMUS-SCOPE is a coupled, process-based ecohydrological model that acts as a digital twin for simulating the complex interactions within the soil–plant–atmosphere continuum (SPAC). It integrates soil hydrothermal dynamics (STEMMUS) with plant photosynthesis, fluorescence, and energy fluxes (SCOPE) to advance the understanding of water-energy-carbon interactions, particularly under water-limited conditions.

Key Components and Functionality:
STEMMUS (Simultaneous Transfer of Energy, Mass and Momentum in Unsaturated Soil): A two-phase (liquid and gas) heat and mass transfer model that simulates vertical transport in soil.
SCOPE (Soil Canopy Observation of Photosynthesis and Energy fluxes): A canopy model that describes radiative transfer, canopy photosynthesis, and energy balances .
Coupling Mechanism: STEMMUS-SCOPE links these models via a 1D root growth model and a resistance scheme from the soil to the atmosphere. STEMMUS feeds root zone moisture and temperature into the canopy module, while SCOPE returns soil surface temperature as a boundary condition. Advanced versions (STEMMUS-SCOPE-PHS) now include a full plant hydraulics pathway, calculating water potentials in roots, stems, and leaves to better simulate xylem vulnerability .

Main Capabilities and Applications:
Drought and Water Stress Monitoring: The model specifically tracks plant hydraulic function and root water uptake to assess ecosystem responses to extreme events like droughts and heatwaves. Validation studies confirm its high accuracy in simulating SIF and GPP under drought stress.

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

If you want to contribute to the development of `STEMMUS_SCOPE`, have a look at the [contribution guidelines](https://github.com/EcoExtreML/STEMMUS_SCOPE/blob/main/CONTRIBUTING.md).
And contact Prof. Bob Su (z.su@utwente.nl), and Dr. Yijian Zeng (y.zeng@utwente.nl)

## How to cite us

[![RSD](https://img.shields.io/badge/rsd-ecoextreml-00a3e3.svg)](https://research-software-directory.org/projects/ecoextreml)
<!-- [![DOI](https://zenodo.org/badge/DOI/<replace-with-created-DOI>.svg)](https://doi.org/<replace-with-created-DOI>) -->

## References:
Wang, Y., Zeng, Y., Yu, L., Yang, P., Van Der Tol, C., Yu, Q., Lü, X., Cai, H., & Su, Z. (2021). Integrated modeling of canopy photosynthesis, fluorescence, and the transfer of energy, mass, and momentum in the soil–plant–atmosphere continuum (STEMMUS–SCOPE v1.0.0). Geoscientific Model Development, 14(3), 1379–1407. [10.5194/gmd-14-1379-202](https://doi.org/10.5194/gmd-14-1379-2021)

Zeng, Y., Alidoost, F., Schilperoort, B., Liu, Y., Verhoeven, S., Grootes, M. W., Wang, Y., Song, Z., Yu, D., Tang, E., Han, Q., Yu, L., Daoud, M. G., Khanal, P., Chen, Y., van der Tol, C., Zurita-Milla, R., Girgin, S., Retsios, B., … Su, Z. (2025). Towards an open soil-plant digital twin based on STEMMUS-SCOPE model following open science. Computers & Geosciences, 205, 106013. [10.1016/j.cageo.2025.10601](https://doi.org/10.1016/j.cageo.2025.106013) 

Song, Z., Zeng, Y., Wang, Y., Tang, E., Yu, D., Alidoost, F., Ma, M., Han, X., Tang, X., Zhu, Z., Xiao, Y., Kong, D., & Su, Z. (2024). Investigating Plant Responses to Water Stress via Plant Hydraulics Pathway. [10.5194/EGUSPHERE-2024-2940](https://doi.org/10.5194/EGUSPHERE-2024-2940)

Tang, E., Zeng, Y., Wang, Y., Song, Z., Yu, D., Wu, H., Qiao, C., Van Der Tol, C., Du, L., & Su, Z. (2024). Understanding the effects of revegetated shrubs on fluxes of energy, water, and gross primary productivity in a desert steppe ecosystem using the STEMMUS-SCOPE model. Biogeosciences, 21(4), 893–909. [10.5194/bg-21-893-2024](https://doi.org/10.5194/bg-21-893-2024)

Wang, Y., Zeng, Y., Alidoost, F., Schilperoort, B., Song, Z., Yu, D., Tang, E., Han, Q., Liu, Z., Peng, X., Zhang, C., Retsios, B., Girgin, S., Lü, X., Zuo, Q., Cai, H., Yu, Q., van der Tol, C., & Su, Z. (2025). A physically consistent dataset of water-energy-carbon fluxes across the Soil-Plant-Atmosphere Continuum. Scientific Data, 12(1), 1146. [10.1038/s41597-025-05386-x](https://doi.org/10.1038/s41597-025-05386-x)

Han, Q., Zeng, Y., Wang, Y., Alidoost, F., Nattino, F., Liu, Y., & Su, B. (2025). FluxHourly: Global long-term hourly 9&thinsp;km terrestrial water-energy-carbon fluxes. Earth System Science Data, 17(12), 7101–7117. [10.5194/essd-17-7101-2025](https://doi.org/10.5194/essd-17-7101-2025)

Su, Z., & Zeng, Y. (2025). Photosynthesis and water potential: A new perspective for coupling water, energy, and carbon cycles. The Innovation Geoscience, 3(3), [10.59717/j.xinn-geo.2025.100156](https://doi.org/10.59717/j.xinn-geo.2025.100156)



