function [RHS, SAVE, CHK, SoilVariables] = solveEnergyBalanceEquations(InitialValues, SoilVariables, HeatVariables, TransportCoefficient, ...
                                                                       AirVariabes, VaporVariables, GasDispersivity, ThermalConductivityCapacity, ...
                                                                       HBoundaryFlux, BoundaryCondition, ForcingData, DRHOVh, DRHOVT, KL_T, ...
                                                                       Xah, XaT, Xaa, Srt, L_f, RHOV, RHODA, DRHODAz, L, Delt_t, P_g, P_gg, ...
                                                                       TOLD, Precip, EVAP, r_a_SOIL, Rn_SOIL, KT, CHK)
    %{
        Solve the Energy balance equation with the Thomas algorithm to update
        the soil temperature 'SoilVariables.TT', the finite difference
        time-stepping scheme is exampled as for the soil moisture equation,
        which is derived in 'STEMMUS Technical Notes' section 4, Equation 4.32.
    %}

    EnergyVariables = energy.calculateEnergyParameters(InitialValues, SoilVariables, HeatVariables, TransportCoefficient, AirVariabes, ...
                                                       VaporVariables, GasDispersivity, ThermalConductivityCapacity, ...
                                                       DRHOVh, DRHOVT, KL_T, Xah, XaT, Xaa, Srt, L_f, RHOV, RHODA, DRHODAz, L);

    EnergyMatrices = energy.calculateMatricCoefficients(EnergyVariables, InitialValues);

    [RHS, EnergyMatrices, SAVE] = energy.assembleCoefficientMatrices(EnergyMatrices, SoilVariables, Delt_t, P_g, P_gg);

    [RHS, EnergyMatrices] = energy.calculateBoundaryConditions(BoundaryCondition, EnergyMatrices, HBoundaryFlux, ForcingData, ...
                                                               SoilVariables, Precip, EVAP, Delt_t, r_a_SOIL, Rn_SOIL, RHS, L, KT);

    [SoilVariables, CHK, RHS, EnergyMatrices] = energy.solveTridiagonalMatrixEquations(EnergyMatrices, SoilVariables, RHS, CHK);

    ModelSettings = io.getModelSettings();
    if any(isnan(SoilVariables.TT)) || any(SoilVariables.TT(1:ModelSettings.NN) < ForcingData.Tmin)
        for i = 1:ModelSettings.NN
            SoilVariables.TT(i) = TOLD(i);
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
