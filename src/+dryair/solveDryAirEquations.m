function [RHS, SAVE, P_gg] = Air_sub(SoilVariables, GasDispersivity, TransportCoefficient, InitialValues, GasDispersivity,...
                                     BoundaryCondition, P_gg, Xah, XaT, Xaa, RHODA, KT, Delt_t)

    AirVariabes = AirPARM(SoilVariables, GasDispersivity, TransportCoefficient, InitialValues, GasDispersivity,...
                          P_gg, Xah, XaT, Xaa, RHODA);

    AirMatrices = Air_MAT(AirVariabes, InitialValues);

    [RHS, AirMatrices, SAVE] = Air_EQ(AirMatrices, Delt_t, P_g);

    [RHS, AirMatrices] = Air_BC(BoundaryCondition, AirMatrices, ForcingData, RHS, KT);

    [AirMatrices, P_gg, RHS] = Air_Solve(RHS, AirMatrices);
