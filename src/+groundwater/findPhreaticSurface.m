function [soilThickUpGWL, indxGWLay] = findPhreaticSurface(SoilVariables, GroundwaterSettings)
    %{
        added by Mostafa, modified after Lianyu
		This function finds the soil layer that include the phreatic surface (saturated zone)
		This function is needed for the groundwater recharge calculations

								%%%%%%%%%% Important note %%%%%%%%%%
		The index order for the soil layers in STEMMUS is from bottom to top (NN:1), where NN is the number of STEMMUS soil layers,
		which is opposite of MODFLOW (top to bottom). So, when converting information between STEMMUS and MODFLOW, indecies need to be fliped
		
								%%%%%%%%%% Variables definations %%%%%%%%%%
		soilThickUpGWL		soil layer thickness from the top of the soil up to the phreatic surface (saturated zone)
		indxBotmLayer_R   	index of bottom layer that contains current headBotmLayer (top to bottom)
        indxBotmLayer		index of bottom layer that contains current headBotmLayer (bottom to top)
		indxGWLay			index of the soil layer that includes the phreatic surface, so the recharge is .... 
							extracted from that layer (index order is from top layer to bottom)
							Note: indxGWLay must equal to indxBotmLayer_R 
		Shh					soil matric potential (from top layer to bottom; opposite of hh)
		cumLayThick			cumulative soil layers thickness (from top to bottom)
    %}
    
	% Load model settings
    ModelSettings = io.getModelSettings();
    NN = ModelSettings.NN; % Number of nodes;
    NL = ModelSettings.NL; % Number of layers
	
	% Load Groundwater settings	
	if GroundwaterSettings.GroundwaterCoupling == 1 % Groundwater coupling is enabled	
		cumLayThick = GroundwaterSettings.cumLayThick;
		indxBotmLayer = GroundwaterSettings.indxBotmLayer;
		indxBotmLayer_R = GroundwaterSettings.indxBotmLayer_R;

		% Call the matric potential		
		Shh(1:1:NN) = SoilVariables.hh(NN:-1:1);
		soilThickUpGWL = 0; % a starting value to prevent a nan value, but its calcualted below
		indxGWLay = NN - 2; % a starting value to prevent a nan value, but its calcualted below
		
		% Find the phreatic surface (saturated zone)		
		for i = NN:-1:2
			hh_lay = Shh(i);
			soilThick_lay = cumLayThick(i);
			hh_nextlay = Shh(i-1);
			soilThick_nextlay = cumLayThick(i-1);
			% apply a condition to differentiate between the first layer with positive or zero head value and the last layer with negative head value  
			if(hh_lay > -1e-5 && hh_nextlay <= -1e-5) 
				soilThickUpGWL = (hh_lay * soilThick_nextlay - hh_nextlay * soilThick_lay) / (hh_lay - hh_nextlay);
				midCumThick = (cumLayThick(i) + cumLayThick(i-1)) / 2;
				if(soilThickUpGWL >= midCumThick)
					indxGWLay = i;
				elseif(soilThickUpGWL < midCumThick)
					indxGWLay = i - 1;	
				end
				break
			end
		end
        		
		if(soilThickUpGWL <= 0)
			disp('NO GROUNDWATER TABLE FOUND IN MODFLOW!');
		end	

		% check
		if(indxGWLay - 1 == indxBotmLayer_R)
			disp('Problem, index of bottom layer calculated using MODFLOW groundwater head ~= index of the STEMMUS layer that has zero matric potential!');
			return
		end
	end
end