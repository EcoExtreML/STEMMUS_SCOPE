function GroundwaterSettings = readGroundwaterSettings()
    %{ added by Mostafa
    %}	
    % Activate/deactivate Groundwater coupling
    GroundwaterSettings.GroundwaterCoupling = 0; % (value = 0 -> deactivate coupling, or = 1 -> activate coupling); default = 0, if update value to = 1 -> through BMI
	
    % Initialize the head at the bottom layer (start of saturated zone) and the index of the layer that contains that head
    GroundwaterSettings.headBotmLayer = 100.0; % head at bottom layer, received from MODFLOW through BMI
    GroundwaterSettings.indexBotmLayer = 40; % index of bottom layer that contains current headBotmLayer, received from MODFLOW through BMI
	
    % Load model settings
    ModelSettings = io.getModelSettings();
    NN = ModelSettings.NN; % Number of nodes;
    NL = ModelSettings.NL; % Number of layers

    % Calculate soil layer thickness (cumulative layer thickness; e.g. 1, 2, 3, 4, 5, 10, 20 ......., last = total_soil_depth) 
    GroundwaterSettings.soilLayerThickness = zeros(NN, 1); % cumulative soil layer thickness
    GroundwaterSettings.soilLayerThickness(1) = 0;
    TDeltZ = flip(ModelSettings.DeltZ);
    for ML = 2: NL
	GroundwaterSettings.soilLayerThickness(ML) = GroundwaterSettings.soilLayerThickness(ML - 1) + TDeltZ(ML - 1);
    end
    GroundwaterSettings.soilLayerThickness(NN) = ModelSettings.Tot_Depth;
end
