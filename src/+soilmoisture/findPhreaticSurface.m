function [zGWT, indxGWLay] = findPhreaticSurface(Sh, soilLayerThickness, GroundwaterSettings)
    %{
        added by Mostafa, modified after Lianyu
	This function finds the soil layer that include the phreatic surface (saturated zone)
	This function is needed for the groundwater recharge calculations
	This functions needs to be run for each MODFLOW time step (not for each STEMMUS time step)
		
				%%%%%%%%%% Variables definations %%%%%%%%%%
	zGWT: soil layer thickness from the top of the soil up to the phreatic surface
	indxGWLay: index of the soil layer that include the phreatic surface (saturated zone)
	Sh: soil matric potential (from bottom layer to top; opposite of hh)
	soilLayerThickness: cumulative soil layers thickness (from top to bottom)
    %}
    
    % Load model settings
    ModelSettings = io.getModelSettings();
    NN = ModelSettings.NN; % Number of nodes;
    NL = ModelSettings.NL; % Number of layers
    TDeltZ = flip(ModelSettings.DeltZ);
	
    % Load Groundwater settings	
    GroundwaterSettings = io.readGroundwaterSettings();
    soilLayerThickness = GroundwaterSettings.soilLayerThickness; % cumulative soil layer thickness (from top to bottom) 
	
    % Find the phreatic surface (saturated zone)		
    if GroundwaterSettings.GroundwaterCoupling == 1  % Groundwater coupling is enabled
        zGWT = 0; % Prevent the nan value of zGWT
	indxGWLay = NN - 2; % Prevent the nan value of indxGWLay
	for I = NN:-1:2
	    HEAD1 = Sh(I);
	    X1 = soilLayerThickness(I);
	    HEAD0 = Sh(I-1);
	    X0 = soilLayerThickness(I-1);
	    if(HEAD1 > -1e-5 && HEAD0 <= -1E-5)
		zGWT = (HEAD1 * X0 - HEAD0 * X1) / (HEAD1 - HEAD0);
		XMID =(soilLayerThickness(I) + soilLayerThickness(I-1)) / 2;
		if(zGWT >= XMID)
		    indxGWLay = I;
		elseif(zGWT < XMID)
		    indxGWLay = I-1;
		end
		break
	    end
	end	
	if(zGWT <= 0)
	    disp('NO GROUNDWATER TABLE FOUND IN MODFLOW!');
	end
    end
end
