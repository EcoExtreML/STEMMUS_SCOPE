function GroundwaterSettings = readGroundwaterSettings()
    %{
    %}	
    % Activate/deactivate Groundwater coupling
	GroundwaterSettings.GroundwaterCoupling = 1
	
	% Initalize the head at the bottom layer (start of saturated zone) and the index of the layer that contains that head
	GroundwaterSettings.headBotmLayer = 10.0; % head at bottom layer, received from MODFLOW through BMI
	GroundwaterSettings.indexBotmLayer = 40; % index of bottom layer that contains current headBotmLayer, received from MODFLOW through BMI
	
	% Load model settings
    ModelSettings = io.getModelSettings();
    NN = ModelSettings.NN; % Number of nodes;
	NL = ModelSettings.NL; % Number of layers
	
	% next 9 lines -> retreived from Lianyu's STEMMUS_MODFLOW
	GroundwaterSettings.soilLayerThickness = zeros(NN, 1); % layer thickness of STEMMUS soil layers
	GroundwaterSettings.soilLayerThickness(1) = 0;
	TDeltZ = flip(ModelSettings.DeltZ);
	for ML = 2: NL
		GroundwaterSettings.soilLayerThickness(ML) = GroundwaterSettings.soilLayerThickness(ML - 1) + TDeltZ(ML - 1);
	end
	GroundwaterSettings.soilLayerThickness(NN) = ModelSettings.Tot_Depth;
	
	%  To be decided later if needed
	%GroundwaterSettings.NLAY = 3; % number of MODFLOW layers
	%GroundwaterSettings.ADAPTF = 1; % indicator for adaptive lower boundary setting, 1 means moving lower boundary; 0 means fixed lower boundary
	%GroundwaterSettings.nSoilColumns = 1; % number of STEMMUS soil columns for MODFLOW
	%GroundwaterSettings.HPUNIT = 100; % unit conversion from m to cm (MODFLOW values in m)
	%GroundwaterSettings.botmLayerLevel = 100.0 * ModflowConfigs.HPUNIT; % elevation of the bottom layer of MODFLOW
	%GroundwaterSettings.TopLayerLevel = [200.0  180.0  190.0  185.0  170] .* ModflowConfigs.HPUNIT; % elevation at the top surface
end
