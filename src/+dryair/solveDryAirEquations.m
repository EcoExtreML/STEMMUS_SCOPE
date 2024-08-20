function [AirVariabes, RHS, SAVE, P_gg] = solveDryAirEquations(SoilVariables, GasDispersivity, TransportCoefficient, InitialValues, VaporVariables, ...
                                                               BoundaryCondition, ForcingData, P_gg, P_g, Xah, XaT, Xaa, RHODA, KT, Delt_t, ModelSettings, GroundwaterSettings)
    %{
        Solve the dry air equation with the Thomas algorithm to update the soil
        air pressure 'P_gg', the finite difference time-stepping scheme is
        exampled as for the soil moisture equation, which derived in 'STEMMUS
        Technical Notes' section 4, Equation 4.32.
    %}
    AirVariabes = dryair.calculateDryAirParameters(SoilVariables, GasDispersivity, TransportCoefficient, InitialValues, VaporVariables, ...
                                                   P_gg, Xah, XaT, Xaa, RHODA, ModelSettings, GroundwaterSettings);

    AirMatrices = dryair.calculateMatricCoefficients(AirVariabes, InitialValues, ModelSettings, GroundwaterSettings);

    [RHS, AirMatrices, SAVE] = dryair.assembleCoefficientMatrices(AirMatrices, SoilVariables, Delt_t, P_g, ModelSettings, GroundwaterSettings);

    [RHS, AirMatrices] = dryair.calculateBoundaryConditions(BoundaryCondition, AirMatrices, ForcingData, RHS, KT, P_gg, ModelSettings, GroundwaterSettings);

    [AirMatrices, P_gg, RHS] = dryair.solveTridiagonalMatrixEquations(RHS, AirMatrices, ModelSettings, GroundwaterSettings);

end
