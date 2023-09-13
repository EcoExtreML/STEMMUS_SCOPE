function [RHS, SAVE, P_gg] = solveDryAirEquations(SoilVariables, GasDispersivity, TransportCoefficient, InitialValues, GasDispersivity, ...
                                                  BoundaryCondition, P_gg, Xah, XaT, Xaa, RHODA, KT, Delt_t)
    %{
        Solve the dry air equation with the Thomas algorithm to update the soil
        air pressure 'P_gg', the finite difference time-stepping scheme is
        exampled as for the soil moisture equation, which derived in 'STEMMUS
        Technical Notes' section 4, Equation 4.32.
    %}
    AirVariabes = dryair.calculateDryAirParameters(SoilVariables, GasDispersivity, TransportCoefficient, InitialValues, GasDispersivity, ...
                                                   P_gg, Xah, XaT, Xaa, RHODA);

    AirMatrices = dryair.calculateMatricCoefficients(AirVariabes, InitialValues);

    [RHS, AirMatrices, SAVE] = dryair.assembleCoefficientMatrices(AirMatrices, Delt_t, P_g);

    [RHS, AirMatrices] = dryair.calculateBoundaryConditions(BoundaryCondition, AirMatrices, ForcingData, RHS, KT);

    [AirMatrices, P_gg, RHS] = dryair.solveTridiagonalMatrixEquations(RHS, AirMatrices);
