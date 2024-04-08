% function [FTop, zGWT1] = calculateGroundwaterRecharge(RTop, zGWT0, indxGWLay0, Shh, STheta_L, STheta_LL, SY, SS, soilLayerThickness, GroundwaterSettings)
function [FTop, zGWT1] = calculateGroundwaterRecharge(RTop, zGWT0, indxGWLay0, Shh, STheta_L, STheta_LL, soilLayerThickness, GroundwaterSettings)
    %{
        added by Mostafa, modified after Lianyu
		The concept followed to calculate groundwater recharge can be found in:
		(a) HYDRUS-MODFLOW paper https://doi.org/10.5194/hess-23-637-2019
		(b) and also in STEMMUS-MODFLOW preprint https://doi.org/10.5194/gmd-2022-221
		To clculate groundwater recharge, a water balance analysis is prepared at the moving balancing domain
		The water balance analysis is described in section 2.5 and Figure 2.b (balancing domain) of HYDRUS-MODFLOW paper
		
										%%%%%%%%%% Variables definations %%%%%%%%%%		
		Equations of the water balance are implemented in this function (Equations 8-13 of HYDRUS-MODFLOW paper) as follows:
		FTOP = RTOP + (SY - sy) * DeltZ, where:
		FTOP: groundwater recharge into top layer of phreatic aquifer(cumualtive upper boundary flux)
		RTOP: upper boundary flux into the moving balancing domain
		SY: large-scale specific yeild of the phreatic aquifer (recieved from MODFLOW)
		sy: small-scale specific yeild (dynamically changing water yield) caused by fluctuation of the water table
		zGWT0: soil layer thickness from the top of the soil up to the phreatic surface at the start of current time step
		indxGWLay0: index of the soil layer that include the phreatic surface (saturated zone) at the start of current time step
    	zGWT1: soil layer thickness from the top of the soil up to the phreatic surface at the end of current time step
		indxGWLay1: index of the soil layer that include the phreatic surface (saturated zone) at the end of current time step
		Sh: soil matric potential (from bottom layer to top; opposite of hh) at the start of the current time step
		Shh: soil matric potential (from bottom layer to top; opposite of hh) at the end of the current time step
		Theta_L: the soil moisture at the start of current time step;
		Theta_LL: the soil moisture at the end of current time step;
	%}
    
	% Load model settings
    ModelSettings = io.getModelSettings();
    NN = ModelSettings.NN; % Number of nodes;
    NL = ModelSettings.NL; % Number of layers
	TDeltZ = flip(ModelSettings.DeltZ);
	
	% Load Groundwater settings	
	GroundwaterSettings = io.readGroundwaterSettings();

	% Start Recharge calculations		
	if GroundwaterSettings.GroundwaterCoupling == 1  % Groundwater coupling is enabled
		% Load boundary conditions	
		soilLayerThickness = GroundwaterSettings.soilLayerThickness; % cumulative soil layer thickness (from top to bottom) 
		headBotmLayer = GroundwaterSettings.headBotmLayer; % head at bottom layer, received from MODFLOW through BMI
		indexBotmLayer = GroundwaterSettings.indexBotmLayer;
		INBT = NN - indexBotmLayer + 1;

		% (a) Define the upper and lower boundaries of the moving balancing domain
		% the moving balancing domain is located between zGWT0 and zGWT1
		[zGWT1, indxGWLay1] = soilmoisture.findPhreaticSurface(Shh, soilLayerThickness, GroundwaterSettings)
        
		IS = min(indxGWLay0, indxGWLay1) - 3; % the negative 3 is a user-specified value to define upper boundary of the moving boundary
        IMAX = max(indxGWLay0, indxGWLay1) + 2; % the positive 2 is a user-specified value to define lower boundary of the moving boundary
		
		% (b) Calculations of RTOP
		%{		
		EnergyParameters = energy.calculateEnergyParameters();
		for i = INBT : NL
			QL(i) = EnergyParameters.QL(i); % not correct yet
		end 
		QL(NN) = QMT(KT);
		QV = EnergyParameters.QV;
		Qa = EnergyParameters.Qa;
		Q = QL + QV + Qa;
		RTOP = flip(Q(:,1));
		
		% Load soil water flux		
		HBoundaryFlux = soilmoisture.calculatesSoilWaterFluxes(SAVE, hh)
		%QMT = HBoundaryFlux.QMT;
		%}
		
		% (c) Calculations of Sy
		% Note: In the HYDRUS-MODFLOW paper, Sy (from MODFLOW) was used. In the STEMMUS_MODFLOW code, a combination of Sy and Ss was used
		% KKT = KPILLAR(indxGWLay1);  % not defined yet
        % THK = BOT(1) - BOT(KKT) - zGWT1;
        S = 0.05 * 100 % S = (SY(KKT) - SS(KKT) * THK) * (zGWT0 - zGWT1);
		
		% (d) Calculations of sy
        sy = 0;
        for I = IS : IMAX-1
          sy = sy + 0.5 * (soilLayerThickness(I+1) - soilLayerThickness(I)) * (STheta_LL(I) + STheta_LL(I+1) - STheta_L(I) - STheta_L(I+1));
        end

		% Aggregate b, c, and d 
		FTop = RTOP(IS) + S - sy;
	end
end