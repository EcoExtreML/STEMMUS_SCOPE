function GroundwaterSettings = readGroundwaterSettings()
    %{
        added by Mostafa,
        The concept followed to couple STEMMUS to MODFLOW can be found at https://doi.org/10.5194/hess-23-637-2019
        and also in (preprint) https://doi.org/10.5194/gmd-2022-221

                                %%%%%%%%%% Important note %%%%%%%%%%
        The index order for the soil layers in STEMMUS is from bottom to top (NN:1), where NN is the number of STEMMUS soil layers,
        which is the opposite of MODFLOW (top to bottom). So, when converting information between STEMMUS and MODFLOW, indices need to be flipped

                                %%%%%%%%%% Variables definitions %%%%%%%%%%

        headBotmLayer       groundwater head (cm) at the bottom layer, received from MODFLOW through BMI
        tempBotm            groundwater temperature (C), received from MODFLOW through BMI
        topLevel            elevation of the top surface aquifer layer, received from MODFLOW through BMI
        % SS                  specific storage of MODFLOW aquifers, default value = 0.05 (unitless)
        % SY                  specific yield of MODFLOW aquifers, default value = 1e-5 (1/m)
        % numAqL              number of MODFLOW aquifer layers, received from MODFLOW through BMI
    %}

    % Activate/deactivate Groundwater coupling
    GroundwaterSettings.GroundwaterCoupling = 0; % (value = 0 -> deactivate coupling, or = 1 -> activate coupling); default = 0, update value to = 1 -> through BMI

    % Initialize the variables (head, temperature, air pressure) at the bottom boundary (start of saturated zone)
    % groundwater head (cm) at bottom layer, received from MODFLOW through BMI
    GroundwaterSettings.headBotmLayer = 1950.0;

    % groundwater temperature (C), received from MODFLOW through BMI
    GroundwaterSettings.tempBotm = 17.0;

    % Call MODFLOW layers information (number of aquifer layers and their elevations, etc)
    % elevation of the top surface aquifer layer
    GroundwaterSettings.topLevel = 2000.0;

    % Define Specific yield (SY) and Specific storage (SS) with default values (otherwise received from MODFLOW through BMI)
    % GroundwaterSettings.SY = [0.05  0.05  0.05  0.05  0.05]; % default SY = 0.05 (unitless)
    % GroundwaterSettings.SS = [1e-7  1e-7  1e-7  1e-7  1e-7]; % default SS = 1e-5 1/m = 1e-7 1/cm
    % GroundwaterSettings.numAqL = 5; % number of MODFLOW aquifer layers, received from MODFLOW through BMI
    % GroundwaterSettings.aqLayers = [2000.0  1900.0  1800.0  1700.0  1600.0  1500.0]; % elevation of top surface level and all bottom levels of aquifer layers, received from MODFLOW through BMI

end
