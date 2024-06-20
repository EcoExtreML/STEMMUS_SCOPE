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
        indxBotmLayer_R     index of the bottom layer that contains the current headBotmLayer (top to bottom)
        indxBotmLayer       index of the bottom layer that contains the current headBotmLayer (bottom to top)
        tempBotm            groundwater temperature (C), received from MODFLOW through BMI
        numAqL              number of MODFLOW aquifer layers, received from MODFLOW through BMI
        numAqN              number of MODFLOW aquifer nodes (numAqL + 1)
        aqLayers            elevation of top surface level and all bottom levels of aquifer layers, received from MODFLOW through BMI
        topLevel            elevation of the top surface aquifer layer
        aqBotms             elevation of the bottom layer of all MODFLOW aquifers
        botmSoilLevel       elevation of the bottom layer of the last STEMMUS soil layer
        SS                  specific storage of MODFLOW aquifers, default value = 0.05 (unitless)
        SY                  specific yield of MODFLOW aquifers, default value = 1e-5 (1/m)
        soilThick           cumulative soil layers thickness (from top to bottom)
        gw_Dep              water table depth: depth from top soil layer to groundwater level, calculated from MODFLOW inputs
        indxAqLay           index of the MODFLOW aquifer that corresponds to each STEMMUS soil layer
    %}

    % Load model settings
    ModelSettings = io.getModelSettings();
    NN = ModelSettings.NN; % Number of nodes
    NL = ModelSettings.NL; % Number of layers

    % Activate/deactivate Groundwater coupling
    GroundwaterSettings.GroundwaterCoupling = 0; % (value = 0 -> deactivate coupling, or = 1 -> activate coupling); default = 0, update value to = 1 -> through BMI

    % Initialize the variables (head, temperature, air pressure) at the bottom boundary (start of saturated zone)
    GroundwaterSettings.headBotmLayer = 1950.0; % groundwater head (cm) at bottom layer, received from MODFLOW through BMI
    GroundwaterSettings.tempBotm = 17.0; % groundwater temperature (C), received from MODFLOW through BMI

    % Call MODFLOW layers information (number of aquifer layers and their elevations, etc)
    GroundwaterSettings.numAqL = 5; % number of MODFLOW aquifer layers, received from MODFLOW through BMI
    numAqN = GroundwaterSettings.numAqL + 1; % number of MODFLOW aquifer nodes
    GroundwaterSettings.aqLayers = [2000.0  1900.0  1800.0  1700.0  1600.0  1500.0]; % elevation of top surface level and all bottom levels of aquifer layers, received from MODFLOW through BMI
    GroundwaterSettings.topLevel = GroundwaterSettings.aqLayers(1); % elevation of the top surface aquifer layer
    GroundwaterSettings.aqBotms = GroundwaterSettings.aqLayers(2:end); % elevation of the bottom layer of all MODFLOW aquifers, received from MODFLOW through BMI
    gw_Dep = GroundwaterSettings.topLevel - GroundwaterSettings.headBotmLayer; % depth from top layer to groundwater level

    % Check that the position of the water table is within the soil column
    if gw_Dep <= 0
        warning('The soil is fully saturated up to the land surface level!');
    elseif gw_Dep > ModelSettings.Tot_Depth
        warning('Groundwater table is below the end of the soil column!');
    end

    for i = GroundwaterSettings.aqBotms
        if i <= GroundwaterSettings.headBotmLayer
            GroundwaterSettings.botmSoilLevel = i; % bottom layer level of the last STEMMUS soil layer
            break
        end
    end

    % Define Specific yield (SY) and Specific storage (SS) with default values (otherwise received from MODFLOW through BMI)
    GroundwaterSettings.SY = [0.05  0.05  0.05  0.05  0.05]; % default SY = 0.05 (unitless)
    GroundwaterSettings.SS = [1e-7  1e-7  1e-7  1e-7  1e-7]; % default SS = 1e-5 1/m = 1e-7 1/cm

    % Calculate soil layers thickness (cumulative layers thickness; e.g. 1, 2, 3, 5, 10, ......., 480, total soil depth)
    soilThick = zeros(NN, 1); % cumulative soil layers thickness
    soilThick(1) = 0;
    DeltZ = ModelSettings.DeltZ;
    DeltZ_R = ModelSettings.DeltZ_R;

    for i = 2:NL
        soilThick(i) = soilThick(i - 1) + DeltZ_R(i - 1);
    end
    soilThick(NN) = ModelSettings.Tot_Depth; % total soil depth

    % Calculate the index of the bottom layer level using MODFLOW data
    indxBotmLayer_R = [];

    for i = 1:NL
        midThick = (soilThick(i) + soilThick(i + 1)) / 2;
        if gw_Dep >= soilThick(i) && gw_Dep < soilThick(i + 1)
            if gw_Dep < midThick
                indxBotmLayer_R = i;
            elseif gw_Dep >= midThick
                indxBotmLayer_R = i + 1;
            end
            break
        elseif gw_Dep >= soilThick(i + 1)
            continue
        end
    end

    indxBotmLayer_R = indxBotmLayer_R; % index of bottom layer that contains current headBotmLayer
    % Note: indxBotmLayer_R starts from top to bottom, opposite of STEMMUS (bottom to top)
    indxBotmLayer = NN - indxBotmLayer_R + 1; % index of bottom layer (from bottom to top)

    % Assign the index of the MODFLOW aquifer that corresponds to each STEMMUS soil layer
    indxAqLay = zeros(NN, 1);
    indxAqLay(1) = 1;
    for i = 2:NN
        for K = 2:numAqN
            Z1 = GroundwaterSettings.aqLayers(K - 1);
            Z0 = GroundwaterSettings.aqLayers(K);
            ZZ = GroundwaterSettings.aqLayers(1) - soilThick(i);
            if ZZ <= Z1 && ZZ > Z0
                indxAqLay(i) = K - 1;
                break
            elseif ZZ == Z0 && K == numAqN
                indxAqLay(i) = K - 1;
                break
            end
        end
    end

    % outputs (will be called by other functions)
    GroundwaterSettings.indxBotmLayer_R = indxBotmLayer_R;
    GroundwaterSettings.indxBotmLayer = indxBotmLayer;
    GroundwaterSettings.gw_Dep = gw_Dep;
    GroundwaterSettings.soilThick = soilThick;
    GroundwaterSettings.indxAqLay = indxAqLay;
end
