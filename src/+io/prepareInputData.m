function [SiteProperties, SoilProperties, TimeProperties] = prepareInputData(InputPath)
    %{
    This function is used to read forcing data and site properties.

    Input:
        InputPath: path of input data.

    Output:
        SiteProperties: A structure containing site properties variables.
        SoilProperties: A structure containing soil variables.
        TimeProperties: A structure containing time variables like time interval in seconds, normal is 1800 s in STEMMUS-SCOPE
            and the total number of time steps.
    %}

    % The "forcing_globals.mat" and "soil_parameters.mat" files are generated using "PyStemmusScope"
    %    python package, see https://github.com/EcoExtreML/STEMMUS_SCOPE_Processing
    forcing_global_path = fullfile(InputPath, 'forcing_globals.mat');
    soil_global_path = fullfile(InputPath, 'soil_parameters.mat');

    %% Explicitly load all variables into the workspace
    TimeProperties = load(forcing_global_path, 'DELT', 'Dur_tot');
    SiteProperties = load(forcing_global_path, 'latitude', 'longitude', 'reference_height', 'canopy_height', 'sitename');


    SoilProperties = load(soil_global_path, 'SaturatedK', 'SaturatedMC', 'ResidualMC', 'Coefficient_n', 'Coefficient_Alpha', ...
                          'porosity', 'FOC', 'FOS', 'MSOC', 'Coef_Lamda', 'fieldMC', 'fmax', 'theta_s0', 'Ks0');

    % Convert the int vectors back to strings
    SiteProperties.sitename = char(SiteProperties.sitename);

    % Convert the 1-D int vector into a vector of strings;
    landcoverClass = load(forcing_global_path, 'landcoverClass');
    SiteProperties.landcoverClass = cellstr(char(...
        reshape(...
            landcoverClass, ...
            [size(landcoverClass)/Dur_tot, Dur_tot] ...
        )' ...
    ));

end
