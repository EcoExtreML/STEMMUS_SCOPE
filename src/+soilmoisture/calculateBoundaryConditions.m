function [AVAIL0, RHS, HeatMatrices, Precip, ForcingData] = calculateBoundaryConditions(BoundaryCondition, HeatMatrices, ForcingData, SoilVariables, InitialValues, ...
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
    if ~GroundwaterSettings.GroundwaterCoupling  % no Groundwater coupling
        if BoundaryCondition.NBChB == 1            %  Specify matric head at bottom to be ---BoundaryCondition.BChB;
            RHS(1) = BoundaryCondition.BChB;
            C4(1, 1) = 1;
            RHS(2) = RHS(2) - C4(1, 2) * RHS(1);
            C4(1, 2) = 0;
            C4_a(1) = 0;
        elseif BoundaryCondition.NBChB == 2  %  Specify flux at bottom to be ---BoundaryCondition.BChB (Positive upwards);
            RHS(1) = RHS(1) + BoundaryCondition.BChB;
        elseif BoundaryCondition.NBChB == 3  %  BoundaryCondition.NBChB=3, Gravity drainage at bottom--specify flux= hydraulic conductivity;
            RHS(1) = RHS(1) - SoilVariables.KL_h(1, 1);
        end
    else % Groundwater coupling is activated, added by Mostafa
        indxBotmLayer_R = GroundwaterSettings.indxBotmLayer_R;
        indxBotm = GroundwaterSettings.indxBotmLayer; % index of bottom boundary layer after neglecting the saturated layers (from bottom to top)
        soilThick = GroundwaterSettings.soilThick; % cumulative soil layers thickness
        topLevel = GroundwaterSettings.topLevel;
        headBotmLayer = GroundwaterSettings.headBotmLayer; % groundwater head at bottom layer, received from MODFLOW through BMI
        RHS(indxBotm) = headBotmLayer - topLevel + soilThick(indxBotmLayer_R); % (RHS = zero at the end, need to check with Yijian and Lianyu)
        if BoundaryCondition.NBChB == 1  %  Specify matric head at bottom to be ---BoundaryCondition.BChB;
            RHS(indxBotm) = headBotmLayer - topLevel + soilThick(indxBotmLayer_R);
            C4(indxBotm, 1) = 1;
            RHS(indxBotm + 1) = RHS(indxBotm + 1) - C4(indxBotm, 2) * RHS(indxBotm);
            C4(indxBotm, 2) = 0;
            C4_a(indxBotm) = 0;
        elseif BoundaryCondition.NBChB == 2  %  Specify flux at bottom to be ---BoundaryCondition.BChB (Positive upwards);
            RHS(indxBotm) = RHS(indxBotm) + BoundaryCondition.BChB;
        elseif BoundaryCondition.NBChB == 3  %  BoundaryCondition.NBChB=3, Gravity drainage at bottom--specify flux= hydraulic conductivity;
            RHS(indxBotm) = RHS(indxBotm) - SoilVariables.KL_h(indxBotm, 1);
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
            RHS(n) = RHS(n) - BoundaryCondition.BCh;   % a specified matric head (saturation or dryness) was applied;
        end
    else % (BoundaryCondition.NBCh == 3, Specified atmospheric forcing)

        % Calculate applied infiltration and infiltration excess runoff (Hortonian runoff), modified by Mostafa
        Ks0 = SoilProperties.Ks0 / (3600 * 24); % saturated vertical hydraulic conductivity. unit conversion from cm/day to cm/sec
        % Note: Ks0 is not adjusted by the fsat as in the CLM model (Check CLM document: https://doi.org/10.5065/D6N877R)
        % Check applied infiltration doesn't exceed infiltration capacity
        topThick = 5; % first 5 cm of the soil
        satCap = SoilProperties.theta_s0 * topThick; % saturation capacity represented by saturated water content of the top 5 cm of the soil
        actTheta = ModelSettings.DeltZ(51:54) * SoilVariables.Theta_UU(51:54, 1); % actual moisture of the top 5 cm of the soil
        infCap = (satCap - actTheta) / TimeProperties.DELT; % (cm/sec)
        infCap_min = min(Ks0, infCap);

        % Infiltration excess runoff (Hortonian runoff). Note: Dunnian runoff is calculated in the +io/loadForcingData file
        if Precip_msr(KT) > infCap_min
            ForcingData.R_Hort(KT) = Precip_msr(KT) - infCap_min;
        else
            ForcingData.R_Hort(KT) = 0;
        end

        Precip(KT) = min(Precip_msr(KT), infCap_min);
        ForcingData.applied_inf(KT) = Precip(KT); % applied infiltration after removing Hortonian runoff

        if SoilVariables.Tss(KT) > 0
            Precip(KT) = Precip(KT);
        else
            Precip(KT) = Precip(KT);
            Precipp = Precipp + Precip(KT);
            Precip(KT) = 0;
        end

        if SoilVariables.Tss(KT) > 0
            AVAIL0 = Precip(KT) + Precipp + BoundaryCondition.DSTOR0 / Delt_t; % (cm/sec)
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
