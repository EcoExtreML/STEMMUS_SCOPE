%%% Set paths %%%
global CFG

%% CFG is a path to a config file
if isempty(CFG)
    CFG = '../config_file_crib.txt';
end

%% Read the CFG file. Due to using MATLAB compiler, we cannot use run(CFG)
disp (['Reading config from ',CFG])
[SoilPropertyPath, InputPath, OutputPath, ForcingPath, ForcingFileName, DurationSize, InitialConditionPath] = io.read_config(CFG);

%%% Prepare global input variables. %%%
global DELT IGBP_veg_long latitude longitude reference_height canopy_height sitename
global InputPath SaturatedK SaturatedMC ResidualMC Coefficient_n Coefficient_Alpha
global porosity FOC FOS FOSL MSOC Coef_Lamda fieldMC fmax theta_s0 Ks0

% The "forcing_globals.mat" and "soil_parameters.mat" files are generated using "PyStemmusScope"
%    python package, see https://github.com/EcoExtreML/STEMMUS_SCOPE_Processing
forcing_global_path = fullfile(InputPath, 'forcing_globals.mat');
soil_global_path = fullfile(InputPath, 'soil_parameters.mat');

%% Explicitly load all variables into the workspace
load(forcing_global_path, 'DELT', 'Dur_tot', 'IGBP_veg_long', 'latitude', 'longitude', 'reference_height', 'canopy_height', 'sitename')

load(soil_global_path, 'SaturatedK', 'SaturatedMC', 'ResidualMC', 'Coefficient_n', 'Coefficient_Alpha')
load(soil_global_path, 'porosity', 'FOC', 'FOS', 'MSOC', 'Coef_Lamda', 'fieldMC', 'fmax', 'theta_s0', 'Ks0')

% Convert the int vectors back to strings
sitename = char(sitename);
IGBP_veg_long = char(IGBP_veg_long);

% The model expects the char vector to be transposed:
IGBP_veg_long = transpose(IGBP_veg_long);

%% Clear unnescessary variables from workspace
clearvars -except SoilPropertyPath InputPath OutputPath InitialConditionPath DELT Dur_tot IGBP_veg_long latitude longitude reference_height canopy_height sitename
