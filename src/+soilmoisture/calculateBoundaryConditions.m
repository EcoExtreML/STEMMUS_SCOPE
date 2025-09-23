function [AVAIL0, RHS, HeatMatrices, ForcingData] = calculateBoundaryConditions(BoundaryCondition, HeatMatrices, ForcingData, SoilVariables, InitialValues, ...
                                                                                TimeProperties, SoilProperties, RHS, hN, KT, KIT, Delt_t, Evap, ModelSettings, GroundwaterSettings)
    %{
        Determine boundary conditions for solving the soil moisture equation.
    %}

    n = ModelSettings.NN;
    C4 = HeatMatrices.C4;
    C4_a = HeatMatrices.C4_a;

    %%%%%%  Apply the bottom boundary condition called for by BoundaryCondition.NBChB, modified by Mostafa  %%%%%%
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
    else % Groundwater coupling is activated
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

    %%%%%%  Prepare surface boundary conditions (precipitation and runoff) for BoundaryCondition.NBCh, modified by Mostafa  %%%%%%
    Precip = ForcingData.Precip_msr(KT); % total precipitation (liquid + snow)

    % Check if surface temperature is <= 0 C; if so, precipitation is snow
    % see issue 279 (https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/279)
    % Initialize new variables
    Precip_snowmelt = 0; % snowmelt
    Precip_liquid   = 0; % only rainfall
    Precip_totalLiquid = 0; % total liquid precipitation (rainfall + snowmelt)
    if KT == 1
        Precip_snowAccum = 0; % accumulated snow at first time step
    else
        Precip_snowAccum = ForcingData.Precip_snowAccum; % accumulated snow from previous time step
    end

    if SoilVariables.Tss(KT) <= 0 % surface temperature is equal or less than zero
        Precip_snow = Precip; % snow precipitation
        Precip_liquid = 0;
        Precip_snowmelt = 0;
        Precip_totalLiquid = 0;
        if KIT == 1 % accumulate snow at one iteration only per time step
            Precip_snowAccum = Precip + Precip_snowAccum;
        end
    else % surface temperature > 0 C
        if KIT == 1 % all accumulated snow of previous time steps becomes snowmelt
            Precip_snowmelt = Precip_snowAccum;
            Precip_liquid = Precip;
            Precip_totalLiquid = Precip_liquid + Precip_snowmelt;
            Precip_snowAccum = 0; % reset accumulated snow for following iterations
        else % retrieve values from the previous iteration of the same time step
            Precip_liquid = ForcingData.Precip_liquid;
            Precip_snowmelt = ForcingData.Precip_snowmelt;
            Precip_totalLiquid = ForcingData.Precip_totalLiquid;
        end
        Precip_snow = 0;
    end

    %%% Calculate effective precipitation after removing canopy interception and total runoff  %%%
    % effective precipitation = precipitation - canopy interception - (Dunnian runoff + Hortonian runoff)
    % Note: currently canopy interception is not implemented
    % 1.1. Calculate saturation excess runoff (Dunnian runoff)
    if ~GroundwaterSettings.GroundwaterCoupling  % Groundwater Coupling is not activated
        % Concept is adopted from the CLM model (see issue 232, https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/232)
        % Check also the CLM documents (https://doi.org/10.5065/D6N877R0, https://doi.org/10.1029/2005JD006111)
        wat_Dep = ModelSettings.Tot_Depth / 100; % (m), this assumption water depth = total soil depth is not fully correct (to be improved)
        fover = 0.5; % decay factor (fixed to 0.5 m-1)
        fmax = SoilProperties.fmax; % potential maximum value of fsat
        fsat = (fmax .* exp(-0.5 * fover * wat_Dep)); % fraction of saturated area (unitless)
        runoffDunn = Precip_totalLiquid * fsat; % Dunnian runoff (saturation excess runoff, in cm/sec)
    else % Groundwater Coupling is activated
        % Dunnian runoff = Direct water input from precipitation + return flow
        % (a) Direct water input from precipitation when soil is fully saturated (water table depth = 0)
        % (b) Return flow from groundwater exfiltration, calculated in MODFLOW and added through BMI
        % Here approach (a) is implemented
        runoffDunn = 0; % Dunnian runoff = 0 when soil is not fully saturated
        if GroundwaterSettings.gw_Dep <= 1.0
            runoffDunn = Precip_totalLiquid;
        end
    end

    % 1.2. Remove saturation excess runoff (Dunnian runoff) from precipitation
    effectivePrecip = Precip_totalLiquid - runoffDunn; % Hortonian runoff is removed below

    % 2.1. Calculate infiltration excess runoff (Hortonian runoff) and update effective precipitation
    Ks0 = SoilProperties.Ks0 / (3600 * 24); % saturated vertical hydraulic conductivity. unit conversion from cm/day to cm/sec
    % Note: Ks0 is not adjusted by the fsat as in the CLM model (Check CLM document: https://doi.org/10.5065/D6N877R)
    topThick = 5; % first 5 cm of the soil
    satCap = SoilProperties.theta_s0 * topThick; % saturation capacity represented by saturated water content of the top 5 cm of the soil
    actTheta = ModelSettings.DeltZ(end - 3:end) * SoilVariables.Theta_UU(end - 4:end - 1, 1); % actual moisture of the top 5 cm of the soil
    infCap = (satCap - actTheta) / TimeProperties.DELT; % % infiltration capacity (cm/sec)
    infCap_min = min(Ks0, infCap); % minimum infiltration capacity

    if effectivePrecip > infCap_min
        runoffHort = effectivePrecip - infCap_min; % Hortonian runoff
    else
        runoffHort = 0;
    end
    % 2.2. Update effective precipitation after removing Hortonian runoff
    effectivePrecip = min(effectivePrecip, infCap_min);

    % 2.3. Add depression water to effective precipitation
    AVAIL0 = effectivePrecip + BoundaryCondition.DSTOR0 / Delt_t; % (cm/sec)

    %%%%%%  Apply the bottom boundary condition called for by BoundaryCondition.NBChB  %%%%%%
    if BoundaryCondition.NBCh == 1             %  Specified matric head at surface---equal to hN;
        % h_SUR: Observed matric potential at surface.
        % Note: this variable is not calculated anywhere (see issue 98, item 6)
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
            RHS(n) = RHS(n) - BoundaryCondition.BCh;   % a specified matric head (saturation or dryness) is applied;
        end
    else % (BoundaryCondition.NBCh == 3, Specified atmospheric forcing)
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
    ForcingData.Precip_snowmelt = Precip_snowmelt;
    ForcingData.Precip_totalLiquid = Precip_totalLiquid;
    ForcingData.effectivePrecip = effectivePrecip;
    ForcingData.runoffDunn = runoffDunn;
    ForcingData.runoffHort = runoffHort;
end
