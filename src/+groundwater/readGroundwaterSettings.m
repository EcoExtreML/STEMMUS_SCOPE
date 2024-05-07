function GroundwaterSettings = readGroundwaterSettings()
    %{
        added by Mostafa,
		The concept followed to couple STEMMUS to MODFLOW can be found in https://doi.org/10.5194/hess-23-637-2019
		and also in (preprint) https://doi.org/10.5194/gmd-2022-221
		
								%%%%%%%%%% Important note %%%%%%%%%%
		The index order for the soil layers in STEMMUS is from bottom to top (NN:1), where NN is the number of STEMMUS soil layers,
		which is opposite of MODFLOW (top to bottom). So, when converting information between STEMMUS and MODFLOW, indecies need to be fliped
		
								%%%%%%%%%% Variables definations %%%%%%%%%%
		
		headBotmLayer		groundwater head (cm) at bottom layer, received from MODFLOW through BMI
		indxBotmLayer_R   	index of bottom layer that contains current headBotmLayer (top to bottom)
        indxBotmLayer		index of bottom layer that contains current headBotmLayer (bottom to top)
		tempBotm			groundwater temperature (C), received from MODFLOW through BMI
		airPg				atmospheric pressure at the bottom (Pa)
		BtmPg				groundwater pressure (Pa)
		numAqL				number of MODFLOW aquifer layers, received from MODFLOW through BMI
		numAqN				number of MODFLOW aquifer nodes (numAqL + 1)
		aqLayers			elevation of top surface level and all bottom levels of aquifer layers, received from MODFLOW through BMI
		topLevel			elevation of the top surface aquifer layer
		aqBotms				elevation of the bottom layer of all MODFLOW aquifers
		botmSoilLevel		elevation of the bottom layer of the last STEMMUS soil layer
		SS					specific storage of MODFLOW aquifers, default value = 0.05 (unitless)
		SY					specific yield of MODFLOW aquifers, default value = 1e-5 (1/m)
		cumLayThick			cumulative soil layers thickness (from top to bottom) 
		depToGWT			depth from top layer to groundwater level
		WatCol				groundwater column (from groundwater level to bottom aquifer level)
		indxAqLay			index of the MODFLOW aquifer that corresponds to each STEMMUS soil layer	
    %}

	% Load model settings
    ModelSettings = io.getModelSettings();
    NN = ModelSettings.NN; % Number of nodes;
    NL = ModelSettings.NL; % Number of layers 

	% Activate/deactivate Groundwater coupling
    GroundwaterSettings.GroundwaterCoupling = 1; % (value = 0 -> deactivate coupling, or = 1 -> activate coupling); default = 0, if update value to = 1 -> through BMI

    % Initialize the variables (head, temperature, air pressure) at the bottom boundary (start of saturated zone)
    GroundwaterSettings.headBotmLayer = 1750.0; % groundwater head (cm) at bottom layer, received from MODFLOW through BMI
    GroundwaterSettings.tempBotm = 20.0; % groundwater temperature (C), received from MODFLOW through BMI
	airPg = 95197.850; % atmospheric pressure at the bottom (Pa)
	
	% Call MODFLOW layers information (number of aquifer layers and their elevations, etc)
	GroundwaterSettings.numAqL = 5; % number of MODFLOW aquifer layers, received from MODFLOW through BMI
	numAqN = GroundwaterSettings.numAqL + 1; % number of MODFLOW aquifer nodes
    GroundwaterSettings.aqLayers = [2000.0  1900.0  1800.0  1700.0  1600.0  1500.0]; % elevation of top surface level and all bottom levels of aquifer layers, received from MODFLOW through BMI
	GroundwaterSettings.topLevel = GroundwaterSettings.aqLayers(1); % elevation of the top surface aquifer layer
	GroundwaterSettings.aqBotms = GroundwaterSettings.aqLayers(2: end); % elevation of the bottom layer of all MODFLOW aquifers, received from MODFLOW through BMI
    depToGWT = GroundwaterSettings.topLevel - GroundwaterSettings.headBotmLayer; % depth from top layer to groundwater level
	WatCol = GroundwaterSettings.headBotmLayer - GroundwaterSettings.aqBotms(end); % groundwater column
	BtmPg = airPg + WatCol; % groundwater pressure
	
	for i = GroundwaterSettings.aqBotms
		if i <= GroundwaterSettings.headBotmLayer
			GroundwaterSettings.botmSoilLevel = i; % bottom layer level of the last STEMMUS soil layer
			break
		end
	end	
	
	% Define Specific yeild (SY) and Specific storage (SS) with default values (otherwise received from MODFLOW through BMI)
	GroundwaterSettings.SY = [0.05  10.05  0.05  0.05  0.05]; % default SY = 0.05 (unitless)
	GroundwaterSettings.SS = [1e-7  1e-7  1e-7  1e-7  1e-7]; % default SS = 1e-5 1/m = 1e-7 1/cm	
	
    % Calculate soil layers thickness (cumulative layers thickness; e.g. 1, 2, 3,
    % 4, 5, 10, 20 ......., last = total_soil_depth)
    cumLayThick = zeros(NN, 1); % cumulative soil layers thickness
    cumLayThick(1) = 0;
    DeltZ = ModelSettings.DeltZ;
	DeltZ_R = ModelSettings.DeltZ_R;

    for i = 2:NL
        cumLayThick(i) = cumLayThick(i - 1) + DeltZ_R(i - 1);
    end

    cumLayThick(NN) = ModelSettings.Tot_Depth;
	
	% Calculate the index of the bottom layer level using MODFLOW data 
	indxBotmLayer_R = [];

    for i = 1:NL
        midCumThick = (cumLayThick(i) + cumLayThick(i + 1)) / 2;    
        if(depToGWT >= cumLayThick(i) && depToGWT < cumLayThick(i + 1))
            if(depToGWT < midCumThick)
                indxBotmLayer_R = i;
            elseif(depToGWT >= midCumThick)
                 indxBotmLayer_R = i + 1;
            end
            break;
        elseif(depToGWT >= cumLayThick(i + 1))
            continue
        end
        disp('NO GROUNDWATER TABLE FOUND FOR MOVING LOWER BOUNDARY')
    end
	
	indxBotmLayer_R = indxBotmLayer_R; % index of bottom layer that contains current headBotmLayer (top to bottom), opposite of STEMMUS (bottom to top)
	indxBotmLayer = NN - indxBotmLayer_R + 1; % index of bottom boundary layer (bottom to top)
	
	% Assign the index of the MODFLOW aquifer that correspond to each STEMMUS soil layer
	indxAqLay = zeros(NN,1);
	indxAqLay(1) = 1;
	for i = 2:NN
        for K = 2:numAqN
            Z1 = GroundwaterSettings.aqLayers(K-1);
            Z0 = GroundwaterSettings.aqLayers(K);
            ZZ = GroundwaterSettings.aqLayers(1) - cumLayThick(i);
            if(ZZ <= Z1 && ZZ > Z0)
                indxAqLay(i) = K - 1;
                break
            elseif(ZZ == Z0 && K == numAqN)
                indxAqLay(i) = K - 1;
                break
            end
        end
    end
	
	% outputs (will be called by other functions)
	GroundwaterSettings.BtmPg = BtmPg;
	GroundwaterSettings.indxBotmLayer_R = indxBotmLayer_R;
	GroundwaterSettings.indxBotmLayer = indxBotmLayer;	
	GroundwaterSettings.depToGWT = depToGWT;
	GroundwaterSettings.WatCol = WatCol;
	GroundwaterSettings.cumLayThick = cumLayThick;
	GroundwaterSettings.indxAqLay = indxAqLay;
end
