function GroundwaterSettings = readGroundwaterSettings()
    %{
        added by Mostafa,
		The concept followed to couple STEMMUS to MODFLOW can be found in https://doi.org/10.5194/hess-23-637-2019
		and also in (preprint) https://doi.org/10.5194/gmd-2022-221
		
										%%%%%%%%%% Variables definations %%%%%%%%%%
		headBotmLayer: head at bottom layer, received from MODFLOW through BMI
        indexBotmLayer: index of bottom layer that contains current headBotmLayer, received from MODFLOW through BMI
    %}

    % Activate/deactivate Groundwater coupling
    GroundwaterSettings.GroundwaterCoupling = 1; % (value = 0 -> deactivate coupling, or = 1 -> activate coupling); default = 0, if update value to = 1 -> through BMI

    % Initialize the head at the bottom layer (start of saturated zone) and the index of the layer that contains that head
    GroundwaterSettings.headBotmLayer = 100.0; % head at bottom layer, received from MODFLOW through BMI
    GroundwaterSettings.indexBotmLayer = 40; % index of bottom layer that contains current headBotmLayer, received from MODFLOW through BMI

    % Load model settings
    ModelSettings = io.getModelSettings();
    NN = ModelSettings.NN; % Number of nodes;
    NL = ModelSettings.NL; % Number of layers

    % Calculate soil layers thickness (cumulative layers thickness; e.g. 1, 2, 3,
    % 4, 5, 10, 20 ......., last = total_soil_depth)
    GroundwaterSettings.soilLayerThickness = zeros(NN, 1); % cumulative soil layers thickness
    GroundwaterSettings.soilLayerThickness(1) = 0;
    TDeltZ = flip(ModelSettings.DeltZ);

    for ML = 2:NL
        GroundwaterSettings.soilLayerThickness(ML) = GroundwaterSettings.soilLayerThickness(ML - 1) + TDeltZ(ML - 1);
    end

    GroundwaterSettings.soilLayerThickness(NN) = ModelSettings.Tot_Depth;
	
	% To be decided later if needed
	%GroundwaterSettings.NLAY = 3; % number of MODFLOW layers
	%GroundwaterSettings.ADAPTF = 1; % indicator for adaptive lower boundary setting, 1 means moving lower boundary; 0 means fixed lower boundary
	%GroundwaterSettings.nSoilColumns = 1; % number of STEMMUS soil columns for MODFLOW
	%GroundwaterSettings.HPUNIT = 100; % unit conversion from m to cm (MODFLOW values in m)
	%GroundwaterSettings.botmLayerLevel = 100.0 * ModflowConfigs.HPUNIT; % elevation of the bottom layer of MODFLOW
	%GroundwaterSettings.TopLayerLevel = [200.0  180.0  190.0  185.0  170] .* ModflowConfigs.HPUNIT; % elevation at the top surface

end
