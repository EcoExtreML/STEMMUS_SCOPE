function [AVAIL0, RHS, HeatMatrices, Precip] = calculateBoundaryConditions(BoundaryCondition, HeatMatrices, ForcingData, SoilVariables, InitialValues, ...
                                                                           TimeProperties, SoilProperties, RHS, hN, KT, Delt_t, Evap, GroundwaterSettings)
    %{
        Determine the boundary condition for solving the soil moisture equation.
    %}
    ModelSettings = io.getModelSettings();
    % NN is the index of n_th item
    NN = ModelSettings.NN;

    C4 = HeatMatrices.C4;
    C4_a = HeatMatrices.C4_a;

    Precip = InitialValues.Precip;
    Precip_msr = ForcingData.Precip_msr;
    Precipp = 0;
	
    if ~GroundwaterSettings.GroundwaterCoupling  % Groundwater Coupling is not activated, added by Mostafa
		indxBotm = 1; % index of bottom layer, by defualt (no groundwater coupling) its layer with index 1, since STEMMUS calcuations starts from bottom to top
	     RHS(indxBotm) = BoundaryCondition.BChB;
	else % Groundwater Coupling is activated
        indxBotmLayer_R = GroundwaterSettings.indxBotmLayer_R;
        indxBotm = GroundwaterSettings.indxBotmLayer; % index of bottom boundary layer after neglecting the saturated layers (from bottom to top)	
        cumLayThick = GroundwaterSettings.cumLayThick; % cumulative soil layers thickness
        topLevel = GroundwaterSettings.topLevel;
		headBotmLayer = GroundwaterSettings.headBotmLayer; % groundwater head at bottom layer, received from MODFLOW through BMI
		RHS(indxBotm) = headBotmLayer - topLevel + cumLayThick(indxBotmLayer_R); % (RHS = zero at the end, need to check with Yijian and Lianyu)
	end	
	
    %  Apply the bottom boundary condition called for by BoundaryCondition.NBChB
    if BoundaryCondition.NBChB == 1            %  Specify matric head at bottom to be ---BoundaryCondition.BChB;
        C4(indxBotm, 1) = 1;
        RHS(indxBotm + 1) = RHS(indxBotm + 1) - C4(indxBotm + 1, 2) * RHS(indxBotm);
        C4(indxBotm, 2) = 0;
        C4_a(indxBotm) = 0;
    elseif BoundaryCondition.NBChB == 2  %  Specify flux at bottom to be ---BoundaryCondition.BChB (Positive upwards);
         RHS(indxBotm) = RHS(indxBotm) + BoundaryCondition.BChB;
    elseif BoundaryCondition.NBChB == 3  %  BoundaryCondition.NBChB=3, Gravity drainage at bottom--specify flux= hydraulic conductivity;
        RHS(indxBotm) = RHS(indxBotm) - SoilVariables.KL_h(indxBotm, 1);
    end
	
    %  Apply the surface boundary condition called for by BoundaryCondition.NBCh
    if BoundaryCondition.NBCh == 1             %  Specified matric head at surface---equal to hN;
        % h_SUR: Observed matric potential at surface. This variable
        % is not calculated anywhere! see issue 98, item 6
        RHS(NN) = InitialValues.h_SUR(KT);
        C4(NN, 1) = 1;
        RHS(NN - 1) = RHS(NN - 1) - C4(NN - 1, 2) * RHS(NN);
        C4(NN - 1, 2) = 0;
        C4_a(NN - 1) = 0;
    elseif BoundaryCondition.NBCh == 2
        if BoundaryCondition.NBChh == 1
            RHS(NN) = hN;
            C4(NN, 1) = 1;
            RHS(NN - 1) = RHS(NN - 1) - C4(NN - 1, 2) * RHS(NN);
            C4(NN - 1, 2) = 0;
        else
            RHS(NN) = RHS(NN) - BoundaryCondition.BCh;   % a specified matric head (saturation or dryness)was applied;
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
            RHS(NN) = hN;
            C4(NN, 1) = 1;
            RHS(NN - 1) = RHS(NN - 1) - C4(NN - 1, 2) * RHS(NN);
            C4(NN - 1, 2) = 0;
            C4_a(NN - 1) = 0;
        else
            RHS(NN) = RHS(NN) + AVAIL0 - Evap(KT);
        end
    end
    HeatMatrices.C4 = C4;
    HeatMatrices.C4_a = C4_a;
end
