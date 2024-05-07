function [recharge, soilThickUpGWL_end, indxGWLay_end] = calculateGroundwaterRecharge(EnergyVariables, HBoundaryFlux, SoilVariables, soilThickUpGWL_start, indxGWLay_start, GroundwaterSettings)
    %{
        Added by Mostafa, modified after Lianyu
		The concept followed to calculate groundwater recharge can be found in:
		(a) HYDRUS-MODFLOW paper https://doi.org/10.5194/hess-23-637-2019
		(b) and also in STEMMUS-MODFLOW preprint https://doi.org/10.5194/gmd-2022-221
		To calculate groundwater recharge, a water balance analysis is prepared at the moving balancing domain
		The water balance analysis is described in section 2.5 and Figure 2.b (balancing domain) of HYDRUS-MODFLOW paper
		
								%%%%%%%%%% Important note %%%%%%%%%%
		The index order for the soil layers in STEMMUS is from bottom to top (NN:1), where NN is the number of STEMMUS soil layers,
		which is opposite of MODFLOW (top to bottom). So, when converting information between STEMMUS and MODFLOW, indecies need to be fliped
		
					%%%%%%%%%% Variables definitions %%%%%%%%%%		
		Equations of the water balance are implemented in this function (Equations 8-13 of HYDRUS-MODFLOW paper) as follows:
		recharge = botmFlux + (SY - sy) * DeltZ, where:
		
		recharge				groundwater recharge, which is the upper boundary flux of the top layer of the phreatic aquifer (after the correction of the specific yeild)
		botmFlux				upper boundary flux into the moving balancing domain (before the correction of the specific yeild)
		SS						specific storage of MODFLOW aquifers
		SY						large-scale specific yield of the phreatic aquifer
		sy						small-scale specific yield (dynamically changing water yield) caused by fluctuation of the water table
		soilThickUpGWL_start	soil layer thickness from the top of the soil up to the phreatic surface at the start of current time step
		indxGWLay_start			index of the soil layer that includes the phreatic surface at the start of current time step
    	soilThickUpGWL_end		soil layer thickness from the top of the soil up to the phreatic surface at the end of current time step
		indxGWLay_end			index of the soil layer that includes the phreatic surface at the end of current time step
		Theta_L					soil moisture at the start of current time step (bottom to top)
		Theta_LL				soil moisture at the end of current time step (bottom to top)
		STheta_L				soil moisture at the start of current time step (top to bottom)
		STheta_LL				soil moisture at the end of current time step (top to bottom)		
		cumLayThick				cumulative soil layers thickness (from top to bottom)
		indxAqLay				index of the MODFLOW aquifer that corresponds to each STEMMUS soil layer		
		aqLayers				elevation of top surface level and all bottom levels of aquifer layers, received from MODFLOW through BMI		
	%}
    
	% Load model settings
    ModelSettings = io.getModelSettings();
    NN = ModelSettings.NN; % Number of nodes
    NL = ModelSettings.NL; % Number of layers
	
	% Start Recharge calculations		
	if GroundwaterSettings.GroundwaterCoupling == 1 % Groundwater coupling is enabled
		% Load needed variables	
		cumLayThick = GroundwaterSettings.cumLayThick; % cumulative soil layer thickness (from top to bottom) 
		indxAqLay = GroundwaterSettings.indxAqLay; % index of MODFLOW aquifer layers for each STEMMUS soil layer
		aqLayers = GroundwaterSettings.aqLayers; % elevation of top surface level and all bottom levels of aquifer layers
		
		% (a) Define the upper and lower boundaries of the moving balancing domain
		% the moving balancing domain is located between soilThickUpGWL_start and soilThickUpGWL_end
		[soilThickUpGWL, indxGWLay] = groundwater.findPhreaticSurface(SoilVariables, GroundwaterSettings);
        soilThickUpGWL_end = soilThickUpGWL;
		indxGWLay_end = indxGWLay;
		
		% IS and IMAX are the indecies of the upper and lower levels of the moving boundary
		IS = min(indxGWLay_start, indxGWLay_end) - 2; % the negative 2 or 3 is a user-specified value to define upper boundary of the moving boundary
        IMAX = max(indxGWLay_start, indxGWLay_end) + 2; % the positive 2 is a user-specified value to define lower boundary of the moving boundary
		
		% (b) Call the fluxes to get the botmFlux 				
		QL = EnergyVariables.QL; % total liquid water flux 
		QL_h = EnergyVariables.QL_h; % liquid flux due to matric potential gradient 
		QL_T = EnergyVariables.QL_T; % liquid flux due to temperature gradient
		QL_a = EnergyVariables.QL_a; % liquid flux due to air pressure gradient 		
		QV = EnergyVariables.QV; % total vapor water flux 
		QVH = EnergyVariables.QVH; % vapor water flux due to matric potential gradient 
		QVT = EnergyVariables.QVT; % vapor water flux due to temperature gradient 
		QVa = EnergyVariables.QVa; % vapor water flux due to air pressure gradient 
		%Qa = EnergyVariables.Qa; % dry air flux
		Q = QL_h + QL_T + QL_a + QVH + QVT + QVa; % there is an issue with QVT (value are so high and not realistic)
		Q = QL_h + QL_T + QL_a + QVH + QVa; % to be removed 
		Q_flip = flip(Q(1,:)); % flip the Q because STEMMUS calculations are from bottom to top, and MODFLOW needs the recharge from top to bottom
		botmFlux = Q_flip(IS);
		
		% (c) Calculations of SY
		% Note: In the HYDRUS-MODFLOW paper, Sy (from MODFLOW) was used. In Lianyu STEMMUS_MODFLOW code, a combination of Sy and Ss was used
		K = indxAqLay(indxGWLay_end);
        Thk = aqLayers(1) - aqLayers(K) - soilThickUpGWL_end;
        SY = GroundwaterSettings.SY;
		SS = GroundwaterSettings.SS;
		S = (SY(K) - SS(K) * Thk) * (soilThickUpGWL_start - soilThickUpGWL_end);
		
		% (d) Calculations of sy
		Theta_L = SoilVariables.Theta_L;
		Theta_LL = SoilVariables.Theta_LL;
		% flip the soil moisture to be from top layer to bottom (opposite of Theta_L)       
		STheta_L(1) = Theta_L(NL,2);
		STheta_L(2:1:NN) = Theta_L(NN-1:-1:1,1);
		STheta_LL(1) = Theta_LL(NL,2);
		STheta_LL(2:1:NN) = Theta_LL(NN-1:-1:1,1);
		
		sy = 0;
        for i = IS:IMAX - 1
          sy = sy + 0.5 * (cumLayThick(i + 1) - cumLayThick(i)) * (STheta_LL(i) + STheta_LL(i + 1) - STheta_L(i) - STheta_L(i + 1));
        end

		% (e) Aggregate b, c, and d to get recharge
		recharge = botmFlux + S - sy;
	end
end