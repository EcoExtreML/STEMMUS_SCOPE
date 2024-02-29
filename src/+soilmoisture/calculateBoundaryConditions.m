function [AVAIL0, RHS, HeatMatrices, Precip] = calculateBoundaryConditions(BoundaryCondition, HeatMatrices, ForcingData, SoilVariables, InitialValues, ...
                                                                           TimeProperties, SoilProperties, RHS, hN, KT, Delt_t, Evap, GroundwaterSettings)
    %{
        Determine the boundary condition for solving the soil moisture equation.
    %}
    ModelSettings = io.getModelSettings();
    % n is the index of n_th item
    n = ModelSettings.NN;

    C4 = HeatMatrices.C4;
    C4_a = HeatMatrices.C4_a;

    Precip = InitialValues.Precip;
    Precip_msr = ForcingData.Precip_msr;
    Precipp = 0;
    
    %  Apply the bottom boundary condition called for by BoundaryCondition.NBChB	
    if ~GroundwaterCoupling % Groundwater Coupling is not activated, added by Mostafa
        if BoundaryCondition.NBChB == 1            %  Specify matric head at bottom to be ---BoundaryCondition.BChB;
	    RHS(1) = BoundaryCondition.BChB;
	    C4(1, 1) = 1;
	    RHS(2) = RHS(2) - C4(1, 2) * RHS(1);
	    C4(1, 2) = 0;
	    C4_a(1) = 0;
	elseif BoundaryCondition.NBChB == 2        %  Specify flux at bottom to be ---BoundaryCondition.BChB (Positive upwards);
	    RHS(1) = RHS(1) + BoundaryCondition.BChB;
	elseif BoundaryCondition.NBChB == 3        %  BoundaryCondition.NBChB=3, Gravity drainage at bottom--specify flux= hydraulic conductivity;
	    RHS(1) = RHS(1) - SoilVariables.KL_h(1, 1);
	end
    else % Groundwater Coupling is activated, added by Mostafa
	headBotmLayer = GroundwaterSettings.headBotmLayer;  % head at bottom layer, received from MODFLOW through BMI
	indexBotmLayer = GroundwaterSettings.indexBotmLayer; % index of bottom layer that contains current headBotmLayer, received from MODFLOW through BMI
	soilLayerThickness = GroundwaterSettings.soilLayerThickness;
	INBT = n - indexBotmLayer + 1; % soil layer thickness from bottom to top (opposite of soilLayerThickness)  
	BOTm = soilLayerThickness(n); % bottom level of all layers, still need to confirm with Lianyu
	if BoundaryCondition.NBChB == 1            %  Specify matric head at bottom to be ---BoundaryCondition.BChB;
	    RHS(INBT) = (headBotmLayer - BOTm + soilLayerThickness(indexBotmLayer));
	    C4(INBT, 1) = 1;
	    RHS(INBT + 1) = RHS(INBT + 1) - C4(INBT, 2) * RHS(INBT);
	    C4(INBT, 2) = 0;
	    C4_a(INBT) = 0;
	elseif BoundaryCondition.NBChB == 2        %  Specify flux at bottom to be ---BoundaryCondition.BChB (Positive upwards);
	    RHS(INBT) = RHS(INBT) + BoundaryCondition.BChB;
	elseif BoundaryCondition.NBChB == 3        %  BoundaryCondition.NBChB=3, Gravity drainage at bottom--specify flux= hydraulic conductivity;
	    RHS(INBT) = RHS(INBT) - SoilVariables.KL_h(INBT, 1);
	end
    end
    %  Apply the surface boundary condition called for by BoundaryCondition.NBCh
    if BoundaryCondition.NBCh == 1             %  Specified matric head at surface---equal to hN;
        % h_SUR: Observed matric potential at surface. This variable
        % is not calculated anywhere! see issue 98, item 6
        RHS(n) = InitialValues.h_SUR(KT);
        C4(n, 1) = 1;
        RHS(n - 1) = RHS(n - 1) - C4(n - 1, 2) * RHS(n);
        C4(n - 1, 2) = 0;
        C4_a(n - 1) = 0;
    elseif BoundaryCondition.NBCh == 2
        if BoundaryCondition.NBChh == 1
            RHS(n) = hN;
            C4(n, 1) = 1;
            RHS(n - 1) = RHS(n - 1) - C4(n - 1, 2) * RHS(n);
            C4(n - 1, 2) = 0;
        else
            RHS(n) = RHS(n) - BoundaryCondition.BCh;   % a specified matric head (saturation or dryness)was applied;
        end
    else
        Precip_msr(KT) = min(Precip_msr(KT), SoilProperties.Ks0 / (3600 * 24) * TimeProperties.DELT * 10);
        Precip_msr(KT) = min(Precip_msr(KT), SoilProperties.theta_s0 * 50 - ModelSettings.DeltZ(51:54) * SoilVariables.Theta_UU(51:54, 1) * 10);

        if SoilVariables.Tss(KT) > 0
            Precip(KT) = Precip_msr(KT) * 0.1 / TimeProperties.DELT;
        else
            Precip(KT) = Precip_msr(KT) * 0.1 / TimeProperties.DELT;
            Precipp = Precipp + Precip(KT);
            Precip(KT) = 0;
        end

        if SoilVariables.Tss(KT) > 0
            AVAIL0 = Precip(KT) + Precipp + BoundaryCondition.DSTOR0 / Delt_t;
            Precipp = 0;
        else
            AVAIL0 = Precip(KT) + BoundaryCondition.DSTOR0 / Delt_t;
        end

        if BoundaryCondition.NBChh == 1
            RHS(n) = hN;
            C4(n, 1) = 1;
            RHS(n - 1) = RHS(n - 1) - C4(n - 1, 2) * RHS(n);
            C4(n - 1, 2) = 0;
            C4_a(n - 1) = 0;
        else
            RHS(n) = RHS(n) + AVAIL0 - Evap(KT);
        end
    end
    HeatMatrices.C4 = C4;
    HeatMatrices.C4_a = C4_a;
end
