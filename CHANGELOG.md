# Unreleased

**Changed:**

- Added changes to support groundwater coupling via BMI in
  [#221](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/221) and
  [#234](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/234)
- Save water stress factor and water potential into csv files.
  [#229](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/229)

**Fixed:**

- Calculations of surface runoff discussed in
  [#232](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/232) and fixed in
  [#234](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/234)
- The bug in the QVT calculations discussed in
  [#230](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/230) and fixed in
  [#234](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/234)
- The bug in activating the dry air calculations discussed in
  [#227](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/230) and fixed in
  [#234](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/227)
- Defining the indices of the first four layers discussed in
  [#237](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/237) and fixed in
  [#238](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/238)
- Add an option to define soil layer settings through a csv file discussed in
  [#237](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/237) and
  [#241](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/241) and fixed in
  [#243](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/243)
- Remove unnecessary function discussed in
  [#244](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/244) and fixed in
  [#243](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/243)
  
<a name="1.5.0"></a>
# [1.5.0](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.5.0) - 3 Jan 2024

This version of STEMMUS_SCOPE is only compatible with [PyStemmusScope 0.3.0.](https://github.com/EcoExtreML/STEMMUS_SCOPE_Processing/releases/tag/v0.3.0)

**Changed:**

- The STEMMUS_SCOPE Matlab Runtime executable now needs version `R2023a` ([#208](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/208)).

**Added:**

- STEMMUS_SCOPE 'BMI'-like mode ([#208](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/208)):
  - The executable can be run in an "interactive" mode.
    In this mode the model's initialization, time update, and finalization can be called upon separately.
  - The model now will write away BMI-required variables to a state file, which can be used for the Python BMI.
- A dockerfile for the BMI-enabled STEMMUS_SCOPE model, to make the setup easier.

**Fixed:**

- use `any()` function in `solveTridiagonalMatrixEquations.m` in
  [#203](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/203)


<a name="1.4.0"></a>
# [1.4.0](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.4.0) - 17 Oct 2023

This version of STEMMUS_SCOPE is only compatible with [PyStemmusScope 0.3.0.](https://github.com/EcoExtreML/STEMMUS_SCOPE_Processing/releases/tag/v0.3.0)

**Changed:**

- All `cond*_` functions are refcatored and moved to `+conductivity` folder in
  [#189](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/189)
- All `h_*` functions are refcatored and moved to `+soilmoisture` folder in
  [#193](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/193)
- All `Air_*` functions are refcatored and moved to `+dryair` folder in
  [194](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/194)
- All `Engry_*` functions are refcatored and moved to `+energy` folder in
[197](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/197)
- Remove `ObservationPoints` script
[200](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/200)
- Remove all global variables from `STEMMUS_SCOPE` script
[201](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/201)

**Fixed:**

- issue [#181](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/181)
- issue [#98](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/98)
- issue [#99](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/99)
- issue [#100](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/100)
- issue [#101](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/101)
- issue [#195](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/195)

<a name="1.3.0"></a>
# [1.3.0](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.3.0) - 22 Jun 2023

This version of STEMMUS_SCOPE is only compatible with [PyStemmusScope 0.3.0.](https://github.com/EcoExtreML/STEMMUS_SCOPE_Processing/releases/tag/v0.3.0)

**Added:**

- A license file, indicating that the code is under the GNU GPL-3.0 license ([#153](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/153))
- A notebook to (more) easily compare the results of different STEMMUS_SCOPE git branches ([#177](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/177))
- Changes in the land cover over time are now supported by the model ([#182](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/182)).

**Changed:**

- All code has been formatted with [MISS_HIT](https://misshit.org/), to improve readability ([#147](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/147)). All new or modified code should follow this style as well.
- The `Constants.m` file has been refactored ([#158](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/158)):
  - Removed unused script `src/CnvrgnCHK.m`
  - Removed unused global variables
  - Replaced `Constants.m` with `io.loadModelSettings` and `init.defineInitialValues`
 - The files `calcLambda.m` and `calcPhi_s.m` have been moved to the `+equations` module ([#171](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/171))
 - The scripts `SOIL1.m` and `SOIL2.m` have been refactored. The code is now in the files `UpdateSoilWaterContent.m` and `updateWettingHistory.m`([#180](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/180))

**Fixed:**

- An error in the sign of NEE has been corrected ([#151](https://github.com/EcoExtreML/STEMMUS_SCOPE/pull/151)).

[Changes][1.3.0]

<a name="1.2.0"></a>
# [1.2.0](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.2.0) - 21 Feb 2023

This version of STEMMUS_SCOPE is only compatible with [PyStemmusScope 0.2.0.](https://github.com/EcoExtreML/STEMMUS_SCOPE_Processing/releases/tag/v0.2.0)

### Changed:
- The StartInit file has been refactored to improve the code quality, and to remove global variables ([#113](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/113)). This also lead to various bugfixes ([#144](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/144))
- Soil initial conditions are now read from a .mat file generated by [PyStemmusScope](https://github.com/EcoExtreML/STEMMUS_SCOPE_Processing/), see the [release there](https://github.com/EcoExtreML/STEMMUS_SCOPE_Processing/releases/tag/v0.2.0).
- The STEMMUS_SCOPE configuration file has been modified. PLUMBER2 sites are now defined as, e.g. `Location=AU-DaS`, and the time range for the model is defined as `StartTime=2001-01-01T00:00`, `EndTime=2001-01-02T00:00`. See [PyStemmusScope](https://github.com/EcoExtreML/STEMMUS_SCOPE_Processing/) for more information.

[Changes][1.2.0]


<a name="1.1.11"></a>
# [1.1.11](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.1.11) - 15 Nov 2022

STEMMUS_SCOPE model that is Octave compatible. The input data and config file can be prepared using PyStemmusScope python package, see [readme](https://github.com/EcoExtreML/STEMMUS_SCOPE/tree/main#stemmus_scope). Changes are introduced in [#128](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/128)

[Changes][1.1.11]


<a name="1.1.10"></a>
# [1.1.10](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.1.10) - 15 Nov 2022

STEMMUS_SCOPE model.

**Added:**
- `pull_request_template.md` in [#116](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/116)

**Removed:**
- `src/filesread.m` in [#107](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/107)
- `src/set_parameter_filenames.m` in [#109](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/109)

**Fixed:**
- the function `bin_to_csv` for storing the values of `sim_temp` and `sim_theta` in [#103](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/103).

**Changed:**
- the function `filesread` is replaced with `prepareForcingData` in [#107](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/107)
- a more user-friendly readme in [#117](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/117)

[Changes][1.1.10]


<a name="1.1.9"></a>
# [1.1.9](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.1.9) - 28 Jul 2022

STEMMUS_SCOPE model.

**Fixed**:

- function `es_fun` [#81](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/81)

**Changed**:

- era5cli notebook checks sites against land sea mask [#79](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/79)
- Number of canopy layers in [#85](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/85)
- Convergence criteria in ebal `abs(PSI-PSI1)` and stemmus scope `max(CHK)` in [#85](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/85)
- Module parallel replaced with for loop in snellius bash script in [#91](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/91)

**Removed**:

- Variables for boundary condition settings from Constants.m in [#85](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/85)

[Changes][1.1.9]


<a name="1.1.8"></a>
# [1.1.8](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.1.8) - 08 Jul 2022

STEMMUS_SCOPE model.

**Fixed:**
- maximum fractional saturated area in [#78](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/78)

**Changed:**
- the parameter of evergreen broadleaf forests in [#78](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/78)

[Changes][1.1.8]


<a name="1.1.7"></a>
# [1.1.7](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.1.7) - 30 Jun 2022

STEMMUS_SCOPE model.

**Fixed:**

- Fix vegetation type and T min in [#72](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/72)

[Changes][1.1.7]


<a name="1.1.6"></a>
# [1.1.6](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.1.6) - 29 Jun 2022

STEMMUS_SCOPE model.

**Fixed:**

- Fix bugs in DoY and vegetation type processing [#67](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/67)
- Re-generate the exe file in [#70](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/70)

[Changes][1.1.6]


<a name="1.1.5"></a>
# [1.1.5](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.1.5) - 10 Jun 2022

STEMMUS_SCOPE model updating the scripts `StartInit.m` and `Constants.m` to use soil era5 land data in [#58](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/58)

**Changed:**

- `src/StartInit.m`, `src/Constants.m` and `src/filesread.m` in [#58](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/58)

**Fixed:**
- fix warning message in [#57](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/57)

**Added:**
- add `InitialConditionPath` to config files in [#58](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/58) and [#59](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/59)
- add the notebook `download_era5_data.ipynb` to `utils/notebooks` in [#54](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/54)


[Changes][1.1.5]


<a name="1.1.4b"></a>
# [1.1.4 (1.1.4b)](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.1.4b) - 11 May 2022

STEMMUS_SCOPE model updating the scripts `StartInit.m` and `Constants.m` to modify initial soil moisture in [#49](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/49)

**Changed:**

- `src/StartInit.m` and `src/Constants.m` in [#49](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/49)
-  use warning off in `src/STEMMUS_SCOPE_exe.m` in [#45](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/45)


**Fixed:**

- Use warning instead of fprintf [#45](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/45)
- Fix `var_t_length` so it matches `DurationSize` in `utils/csv_to_nc` in [#47](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/47)

**Removed:**

- unused scripts in [#48](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/48)

[Changes][1.1.4b]


<a name="1.1.3"></a>
# [1.1.3](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.1.3) - 19 Apr 2022

STEMMUS_SCOPE model updating the equation `calc_rssrbs.m` and refactoring the script `soilpropertyread.m` to use a high-resolution global soil property datasets in [#39](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/39)

**Changed:**

- `src/+equations/calc_rssrbs.m`, `src/Constants.m`, `src/Initial_root_biomass.m`, `src/soilpropertyread.m` in [#39](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/39)

**Fixed:**

- fix the input/output paths in crib config file, see [#34](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/34)
- replacing the `keyboard` command with a `fprintf` statement, see [#40](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/40)



[Changes][1.1.3]


<a name="1.1.2"></a>
# [1.1.2](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.1.2) - 12 Apr 2022

STEMMUS_SCOPE model updating `ebal` script in [#24](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/24) and [#37](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/37).

**Added**

- output of NEE in [#37](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/37)
- documentation in [#32](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/32) and [#33](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/33)
- variable `DurationSize` to config file in [#36](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/36)
- documentation of how to convert the model output to netcdf files in `utils/csv_to_nc/README.md` [#27](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/27)
- python utility for converting the model output to netcdf files in [#27](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/27)

**Removed**
- utils/csv_to_nc/write.py and utils/csv_to_nc/read.py in [#27](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/27)

**Changed**

- `src/ebal.m` in [#24](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/24) and [#37](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/37)
- `src/+io/bin_to_csv.m`, `src/+io/output_data_binary.m`, and
- `src/filesread.m` in [#24](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/24) and [#36](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/36)
- update `utils/csv_to_nc/Variables_will_be_in_NetCDF_file.csv` in [#27](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/27)
- replace `mean` with `nanmean` in [#37](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/37)
- readme in [#36](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/36)

**Fixed**

- the bash script of the running model on Snellius in [#25](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/25)

[Changes][1.1.2]


<a name="1.1.1"></a>
# [1.1.1](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.1.1) - 02 Feb 2022

STEMMUS_SCOPE model including the simplification of freeze/thaw in subroutines introduced in [#14](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/14).

**Added**

- Python scripts in Utils to convert the output in csv format to netcdf format, see [#11](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/11)
- The script `soilpropertyread.m` requires the data of `surfdata.nc`, see [#14](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/14).

**Removed**

- Files `src/+io/create_output_files.m` , `src/+io/output_data.m`, `src/SCOPE.exe`, in [#14](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/14).
- Files `src/PHENOLOGY_STATE.m`, `src/Root_Fraction_General.m`, `src/VEGETATION_DYNAMIC.m`, `src/calc_root_growth.m` in [#14](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/14).

**Changed**

- `src/+equations/Soil_Inertia1.m`, `src/soilpropertyread.m`, `src/filesread.m`, `src/ebal.m`, `src/StartInit.m` , `src/STEMMUS_SCOPE.m`, `src/Initial_root_biomass.m`, `src/Evap_Cal.m, src/Enrgy_sub.m`, `src/Constants.m`, `src/+plot/plots.m`, `src/+io/select_input.m`, `src/+io/output_data_binary.m`, `src/+io/bin_to_csv.m` , in [#14](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/14).

**Fixed**

- Output path and forcing path in [#10](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/10)

[Changes][1.1.1]


<a name="1.1.0"></a>
# [1.1.0](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.1.0) - 25 Jan 2022

STEMMUS_SCOPE model including changes from pull requests [#4](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/4) and [#9](https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/9). The changes are summarized below:

**Added**
- Add subfunction and module for "Root Properties"
- Add modules `HT_frez`, `Initial_root_biomass`
- Add module `filesread` to get input/output paths and prepare input data
- Add module `soilpropertyread` to prepare soil property input data
- Add module `soltir_tp7` to read MODTRAN tp7 file and applies a new MIT algorithm
- Add functions to convert the outputs format from binary to csv
- Add the function `output_verfication` from SCOPE code
- Add a function to convert timestamp to datetime array  from SCOPE code


**Changed**
- Modify equation of `rssrbs`
- Modify the equation of "soil respiration"
- Modify modules `AirPARM`, `Air_sub`, `CnvrgCHK`, `CondL_Tdisp`, `CondL_h`, `CondT_coeff`, `CondV_DE`, `CondV_DVg`, `Cond_k_g`, `Constants`, `Density_V`, `Dtrmn_Z`, `EfeCapCond`, `EnrgyPARM`, `Enrgy_BC`, `Enrgy_Solve`, `Enrgy_sub`, `Evap_Cal`, `Forcing_PARM`, `Max_Rootdepth`, `ObservationPoints`, `SOIL2`, `StartInit`, `TimestepCHK`, `biochemical`, `calc_rsoil`, `calc_sfactor`, `ebal`, `hPARM`, `h_BC`, `h_sub`, `hh_Solve`
- Modify `STEMMUS_SCOPE`
- Refactor function `PlotResults1`
- Remove some of the print statements related to outputs in module IO
- Refactor function plot in module plot to read csv format instead dat format
- Update readme


[Changes][1.1.0]


<a name="1.0.0"></a>
# [1.0.0](https://github.com/EcoExtreML/STEMMUS_SCOPE/releases/tag/1.0.0) - 17 Dec 2021

Snapshots of codes used for the paper [Integrated modeling of canopy photosynthesis, fluorescence, and the transfer of energy, mass, and momentum in the soil–plant–atmosphere continuum (STEMMUS–SCOPE v1.0.0)](https://doi.org/10.5194/gmd-14-1379-2021).

[Changes][1.0.0]

[1.3.0]: https://github.com/EcoExtreML/STEMMUS_SCOPE/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/EcoExtreML/STEMMUS_SCOPE/compare/1.1.11...1.2.0
[1.1.11]: https://github.com/EcoExtreML/STEMMUS_SCOPE/compare/1.1.10...1.1.11
[1.1.10]: https://github.com/EcoExtreML/STEMMUS_SCOPE/compare/1.1.9...1.1.10
[1.1.9]: https://github.com/EcoExtreML/STEMMUS_SCOPE/compare/1.1.8...1.1.9
[1.1.8]: https://github.com/EcoExtreML/STEMMUS_SCOPE/compare/1.1.7...1.1.8
[1.1.7]: https://github.com/EcoExtreML/STEMMUS_SCOPE/compare/1.1.6...1.1.7
[1.1.6]: https://github.com/EcoExtreML/STEMMUS_SCOPE/compare/1.1.5...1.1.6
[1.1.5]: https://github.com/EcoExtreML/STEMMUS_SCOPE/compare/1.1.4b...1.1.5
[1.1.4b]: https://github.com/EcoExtreML/STEMMUS_SCOPE/compare/1.1.3...1.1.4b
[1.1.3]: https://github.com/EcoExtreML/STEMMUS_SCOPE/compare/1.1.2...1.1.3
[1.1.2]: https://github.com/EcoExtreML/STEMMUS_SCOPE/compare/1.1.1...1.1.2
[1.1.1]: https://github.com/EcoExtreML/STEMMUS_SCOPE/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/EcoExtreML/STEMMUS_SCOPE/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/EcoExtreML/STEMMUS_SCOPE/tree/1.0.0
