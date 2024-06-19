function [RHS, SAVE, CHK, SoilVariables, EnergyVariables] = solveEnergyBalanceEquations(InitialValues, SoilVariables, HeatVariables, TransportCoefficient, ...
                                                                                        AirVariabes, VaporVariables, GasDispersivity, ThermalConductivityCapacity, ...
                                                                                        HBoundaryFlux, BoundaryCondition, ForcingData, DRHOVh, DRHOVT, KL_T, ...
                                                                                        Xah, XaT, Xaa, Srt, L_f, RHOV, RHODA, DRHODAz, L, Delt_t, P_g, P_gg, ...
                                                                                        TOLD, Precip, EVAP, r_a_SOIL, Rn_SOIL, KT, CHK, GroundwaterSettings)
    %{
        Solve the Energy balance equation with the Thomas algorithm to update
        the soil temperature 'SoilVariables.TT', the finite difference
        time-stepping scheme is exampled as for the soil moisture equation,
        which is derived in 'STEMMUS Technical Notes' section 4, Equation 4.32.
    %}

    EnergyVariables = energy.calculateEnergyParameters(InitialValues, SoilVariables, HeatVariables, TransportCoefficient, AirVariabes, ...
                                                       VaporVariables, GasDispersivity, ThermalConductivityCapacity, ...
                                                       DRHOVh, DRHOVT, KL_T, Xah, XaT, Xaa, Srt, L_f, RHOV, RHODA, DRHODAz, L, GroundwaterSettings);

    EnergyMatrices = energy.calculateMatricCoefficients(EnergyVariables, InitialValues, GroundwaterSettings);

    [RHS, EnergyMatrices, SAVE] = energy.assembleCoefficientMatrices(EnergyMatrices, SoilVariables, Delt_t, P_g, P_gg, GroundwaterSettings);

    [RHS, EnergyMatrices] = energy.calculateBoundaryConditions(BoundaryCondition, EnergyMatrices, HBoundaryFlux, ForcingData, ...
                                                               SoilVariables, Precip, EVAP, Delt_t, r_a_SOIL, Rn_SOIL, RHS, L, KT, GroundwaterSettings);

    [SoilVariables, CHK, RHS, EnergyMatrices] = energy.solveTridiagonalMatrixEquations(EnergyMatrices, SoilVariables, RHS, CHK, GroundwaterSettings);

    if ~GroundwaterSettings.GroundwaterCoupling  % Groundwater Coupling is not activated, added by Mostafa
        indxBotm = 1; % index of bottom layer, by defualt (no groundwater coupling) its layer with index 1, since STEMMUS calcuations starts from bottom to top
    else % Groundwater Coupling is activated, added by Mostafa
        indxBotm = GroundwaterSettings.indxBotmLayer; % index of bottom boundary layer after neglecting the saturated layers (from bottom to top)
    end

    ModelSettings = io.getModelSettings();
    if any(isnan(SoilVariables.TT)) || any(SoilVariables.TT(1:ModelSettings.NN) < ForcingData.Tmin)
        for i = indxBotm:ModelSettings.NN
            SoilVariables.TT(i) = TOLD(i);
        end
    end

    if GroundwaterSettings.GroundwaterCoupling
        % Assign the groundwater temperature to the saturated layers, added by Mostafa
        for i = indxBotm - 1:-1:1
            SoilVariables.TT(i) = tempBotm;
        end
    end

    for i = 1:ModelSettings.NN
        if SoilVariables.TT(i) <= -272
            SoilVariables.TT(i) = -272;
        end
    end

    % These are unused vars, but I comment them for future reference,
    % See issue 100, item 2
    % [QET, QEB] = energy.calculateEnergyFluxes(SAVE, TT)(SAVE, SoilVariables.TT);
end
