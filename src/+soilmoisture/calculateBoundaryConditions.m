function [AVAIL0, RHS, HeatMatrices, ForcingData] = calculateBoundaryConditions(BoundaryCondition, HeatMatrices, ForcingData, SoilVariables, InitialValues, ...
                                                                                TimeProperties, SoilProperties, RHS, hN, KT, KIT, Delt_t, Evap, ModelSettings, GroundwaterSettings)
    %{
        Determine the boundary condition for solving the soil moisture equation.
    %}

    n = ModelSettings.NN;
    C4 = HeatMatrices.C4;
    C4_a = HeatMatrices.C4_a;

    %%%%%%  Apply the bottom boundary condition called for by BoundaryCondition.NBChB  %%%%%%
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

    %%%%%%  Apply the surface boundary condition called for by BoundaryCondition.NBCh  %%%%%%
    Precip = ForcingData.Precip_msr(KT); % total precipitation (liquid + snow)
    runoffDunn = ForcingData.runoffDunnian(KT); % Dunnian runoff (calculated in +io/loadForcingData file)

    % Check if surface temperature is less than zero, then Precipitation is snow (modified by Mostafa)
    if KT == 1 % see issue 279 (https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/279)
        Precip_snowAccum = 0; % initalize accumulated snow for first time step
    else
        Precip_snowAccum = ForcingData.Precip_snowAccum;
    end

    if SoilVariables.Tss(KT) <= 0 % surface temperature is equal or less than zero
        Precip_snow = Precip; % snow precipitation
        Precip_liquid = 0; % liquid precipitation (rainfall)
        runoffDunn = 0; % update Dunnian runoff in case precpitation is snow
        if KIT == 1 % accumulate snow at one iteration only within the time step
            Precip_snowAccum = Precip + Precip_snowAccum;
        else
            Precip_snowAccum = Precip_snowAccum;
        end
    else % surface temperature is more than zero
        if KIT == 1 % add accumulated snow of previous time steps to liquid precipitation at first time step when surface temperature > zero
            Precip_liquid = Precip + Precip_snowAccum;
            Precip_snowAccum = 0;
        else
            Precip_liquid = ForcingData.Precip_liquid;
        end
        Precip_snow = 0;
    end

    %%% Calculate effective precipitation after removing canopy interception and total runoff  %%%
    % effective precipitation = precipitation - canopy interception - (Dunnian runoff + Hortonian runoff)
    % Currently, canopy interception is not implemented in the code yet
    % (1) Remove saturation excess runoff (Dunnian runoff)
    effectivePrecip = Precip_liquid - runoffDunn; % Hortonian runoff is removed below

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
        % (2) Calculate infiltration excess runoff (Hortonian runoff) and update effective precpitation, modified by Mostafa
        Ks0 = SoilProperties.Ks0 / (3600 * 24); % saturated vertical hydraulic conductivity. unit conversion from cm/day to cm/sec
        % Note: Ks0 is not adjusted by the fsat as in the CLM model (Check CLM document: https://doi.org/10.5065/D6N877R)
        topThick = 5; % first 5 cm of the soil
        satCap = SoilProperties.theta_s0 * topThick; % saturation capacity represented by saturated water content of the top 5 cm of the soil
        actTheta = ModelSettings.DeltZ(end - 3:end) * SoilVariables.Theta_UU(end - 4:end - 1, 1); % actual moisture of the top 5 cm of the soil
        infCap = (satCap - actTheta) / TimeProperties.DELT; % infiltration capcaity (cm/sec)
        infCap_min = min(Ks0, infCap); % minimum infiltration capcaity

        if effectivePrecip > infCap_min
            runoffHort = effectivePrecip - infCap_min; % Hortonian runoff
        else
            runoffHort = 0;
        end
        % Update effective precipitation after removing Hortonian runoff
        effectivePrecip = min(effectivePrecip, infCap_min);

        % Add depression water to effective precipitation
        AVAIL0 = effectivePrecip + BoundaryCondition.DSTOR0 / Delt_t; % (cm/sec)

        if BoundaryCondition.NBChh == 1
            RHS(n) = hN;
            C4(n, 1) = 1;
            RHS(n - 1) = RHS(n - 1) - C4(n - 1, 2) * RHS(n);
            C4(n - 1, 2) = 0;
            C4_a(n - 1) = 0;
        else
            RHS(n) = RHS(n) + AVAIL0 - Evap;
        end
    end

    % Outputs to be exported or used in other functions
    HeatMatrices.C4 = C4;
    HeatMatrices.C4_a = C4_a;
    ForcingData.Precip = Precip;
    ForcingData.Precip_liquid = Precip_liquid;
    ForcingData.Precip_snow = Precip_snow;
    ForcingData.Precip_snowAccum = Precip_snowAccum;
    ForcingData.effectivePrecip = effectivePrecip;
    ForcingData.runoffDunn = runoffDunn;
    ForcingData.runoffHort = runoffHort;
end
