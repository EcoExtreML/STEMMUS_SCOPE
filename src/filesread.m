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

% The "forcing_globals.mat" file is generated using "PyStemmusScope" python package, see https://github.com/EcoExtreML/STEMMUS_SCOPE_Processing
forcing_global_path = fullfile(InputPath, 'forcing_globals.mat');

%% Explicitly load all variables into the workspace
load(forcing_global_path, 'DELT', 'Dur_tot', 'IGBP_veg_long', 'latitude', 'longitude', 'reference_height', 'canopy_height', 'sitename')

% Convert the int vectors back to strings
sitename = char(sitename);
IGBP_veg_long = char(IGBP_veg_long);

% The model expects the char vector to be transposed:
IGBP_veg_long = transpose(IGBP_veg_long);

%% Clear unnescessary variables from workspace
clearvars -except SoilPropertyPath InputPath OutputPath InitialConditionPath DELT Dur_tot IGBP_veg_long latitude longitude reference_height canopy_height sitename
