function [RHS, SAVE, CHK, SoilVariables, EnergyVariables, gwfluxes] = solveEnergyBalanceEquations(InitialValues, SoilVariables, HeatVariables, TransportCoefficient, ...
                                                                                                  AirVariabes, VaporVariables, GasDispersivity, ThermalConductivityCapacity, ...
                                                                                                  HBoundaryFlux, BoundaryCondition, ForcingData, DRHOVh, DRHOVT, KL_T, ...
                                                                                                  Xah, XaT, Xaa, Srt, L_f, RHOV, RHODA, DRHODAz, L, Delt_t, P_g, P_gg, ...
                                                                                                  TOLD, EVAP, r_a_SOIL, Rn_SOIL, KT, CHK, ModelSettings, GroundwaterSettings)
    %{
        Solve the Energy balance equation with the Thomas algorithm to update
        the soil temperature 'SoilVariables.TT', the finite difference
        time-stepping scheme is exampled as for the soil moisture equation,
        which is derived in 'STEMMUS Technical Notes' section 4, Equation 4.32.
    %}

    EnergyVariables = energy.calculateEnergyParameters(InitialValues, SoilVariables, HeatVariables, TransportCoefficient, AirVariabes, ...
                                                       VaporVariables, GasDispersivity, ThermalConductivityCapacity, DRHOVh, DRHOVT, ...
                                                       KL_T, Xah, XaT, Xaa, Srt, L_f, RHOV, RHODA, DRHODAz, L, ModelSettings, GroundwaterSettings);

    EnergyMatrices = energy.calculateMatricCoefficients(EnergyVariables, InitialValues, ModelSettings, GroundwaterSettings);

    [RHS, EnergyMatrices, SAVE] = energy.assembleCoefficientMatrices(InitialValues, EnergyMatrices, SoilVariables, Delt_t, P_g, P_gg, ModelSettings, GroundwaterSettings);

    [RHS, EnergyMatrices] = energy.calculateBoundaryConditions(BoundaryCondition, EnergyMatrices, HBoundaryFlux, ForcingData, SoilVariables, ...
                                                               EVAP, Delt_t, r_a_SOIL, Rn_SOIL, RHS, L, KT, ModelSettings, GroundwaterSettings);

    [SoilVariables, CHK, RHS, EnergyMatrices] = energy.solveTridiagonalMatrixEquations(EnergyMatrices, SoilVariables, RHS, CHK, ModelSettings, GroundwaterSettings);

    if ~GroundwaterSettings.GroundwaterCoupling  % no Groundwater coupling, added by Mostafa
        indxBotm = 1; % index of bottom layer is 1, STEMMUS calculates from bottom to top
    else % Groundwater Coupling is activated
        % index of bottom layer after neglecting saturated layers (from bottom to top)
        indxBotm = GroundwaterSettings.indxBotmLayer;
    end

    if any(isnan(SoilVariables.TT)) || any(SoilVariables.TT(1:ModelSettings.NN) < ForcingData.Tmin)
        for i = indxBotm:ModelSettings.NN
            SoilVariables.TT(i) = TOLD(i);
        end
    end

    for i = 1:ModelSettings.NN
        if SoilVariables.TT(i) <= -272
            SoilVariables.TT(i) = -272;
        end
    end

    [QET, QEB] = energy.calculateEnergyFluxes(SAVE, SoilVariables.TT, ModelSettings, GroundwaterSettings);
    gwfluxes.energyTopflux = QET; % energy flux at the top boundary node
    gwfluxes.energyBotmflux = QEB; % energy flux at the bottom boundary node
end
