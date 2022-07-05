global InputPath SaturatedK SaturatedMC ResidualMC Coefficient_n Coefficient_Alpha porosity FOC FOS FOSL MSOC Coef_Lamda fieldMC fmax theta_s0 Ks0

%% load soil property
if sitename(1:2)==['ID'] % Soil data missing at ID-Pag site, we use anothor location information here.
   latitude=-1;
   longitude=112;
end

% The "soil_parameters.mat" file is generated using "PyStemmusScope" python package, see https://github.com/EcoExtreML/STEMMUS_SCOPE_Processing
soil_global_path = fullfile(InputPath, 'soil_parameters.mat');

%% Explicitly load all variables into the workspace
load(soil_global_path, 'SaturatedK', 'SaturatedMC', 'ResidualMC', 'Coefficient_n', 'Coefficient_Alpha', 'porosity', 'FOC', 'FOS', 'MSOC', 'Coef_Lamda', 'fieldMC', 'fmax', 'theta_s0', 'Ks0')
