function GroundwaterSettings = initializeGroundwaterSettings()
    %{
        added by Mostafa,
        The concept followed to couple STEMMUS to MODFLOW can be found at https://doi.org/10.5194/hess-23-637-2019
        and also in (preprint) https://doi.org/10.5194/gmd-2022-221

                                %%%%%%%%%% Important note %%%%%%%%%%
        The index order for the soil layers in STEMMUS is from bottom to top (NN:1), where NN is the number of STEMMUS soil layers,
        which is the opposite of MODFLOW (top to bottom). So, when converting information between STEMMUS and MODFLOW, indices need to be flipped

                                %%%%%%%%%% Variables definitions %%%%%%%%%%

        headBotmLayer       groundwater head (cm) at the bottom layer, received from MODFLOW through BMI
        tempBotm            groundwater temperature (C) at the bottom layer, received from MODFLOW through BMI
        topLevel            elevation of the top surface aquifer layer, received from MODFLOW through BMI
        % numAqL            number of MODFLOW aquifer layers, received from MODFLOW through BMI
        % aqBotmlevels      elevation of all bottom levels of aquifer layers, received from MODFLOW through BMI
        % aqlevels          elevation of top surface level and all bottom levels of aquifer layers
        % SS                specific storage of MODFLOW aquifers, default value = 0.05 (unitless)
        % SY                specific yield of MODFLOW aquifers, default value = 1e-5 (1/m)
    %}

    % Activate/deactivate Groundwater coupling
    GroundwaterSettings.GroundwaterCoupling = 1; % (value = 0 -> deactivate coupling, or = 1 -> activate coupling); default = 0, update value to = 1 -> through BMI

    % Initialize the variables (head, temperature) at the bottom boundary (start of saturated zone)
    GroundwaterSettings.headBotmLayer = 1750.0; % groundwater head (cm) at bottom layer
    GroundwaterSettings.tempBotm = NaN; % groundwater temperature at bottom layer (C)

    % Call MODFLOW layers information (number of aquifer layers and their elevations, etc)
    % elevation of the top surface aquifer layer
    GroundwaterSettings.topLevel = 2000.0;

    % GroundwaterSettings.numAqL = 5; % number of MODFLOW aquifer layers
    % GroundwaterSettings.aqBotmlevels = [1900.0  1800.0  1700.0  1600.0  1500.0]; % elevation of all bottom levels of aquifer layers
    % GroundwaterSettings.aqlevels = [GroundwaterSettings.topLevel, GroundwaterSettings.aqBotmlevels]; % elevation of top surface level and all bottom levels of aquifer layers

    % Define Specific yield (SY) and Specific storage (SS) with default values (otherwise received from MODFLOW through BMI)
    % GroundwaterSettings.SY = [0.05  0.05  0.05  0.05  0.05]; % default SY = 0.05 (unitless)
    % GroundwaterSettings.SS = [1e-7  1e-7  1e-7  1e-7  1e-7]; % default SS = 1e-5 1/m = 1e-7 1/cm
end
