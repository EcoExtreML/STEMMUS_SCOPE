function solveEnergyBalanceEquations
    %{
        Solve the Energy balance equation with the Thomas algorithm to update
        the soil temperature 'TT', the finite difference time-stepping scheme is
        exampled as for the soil moisture equation, which is derived in 'STEMMUS
        Technical Notes' section 4, Equation 4.32.
    %}

    EnergyVariables = energy.calculateEnergyParameters(InitialValues, SoilVariables, HeatVariables, TransportCoefficient, AirVariabes, ...
                                                       VaporVariables, GasDispersivity, ThermalConductivityCapacity, ...
                                                       DRHOVh, DRHOVT, KL_T, Xah, XaT, Xaa, Srt, L_f, RHOV, RHODA, DRHODAz, L);
    EnergyMatrices = energy.calculateMatricCoefficients(EnergyVariables, InitialValues);
    [RHS, EnergyMatrices, SAVE] = energy.assembleCoefficientMatrices(EnergyMatrices, SoilVariables, Delt_t, P_g, P_gg);
    [RHS, EnergyMatrices] = energy.calculateBoundaryConditions(BoundaryCondition, EnergyMatrices, HBoundaryFlux, ForcingData, ...
                                                        Precip, EVAP, Delt_t, r_a_SOIL, Rn_SOIL, RHS, L, KT);
    [TT, CHK, RHS, C5] = Enrgy_Solve(C5, C5_a, TT, NN, NL, RHS);
    DeltT = abs(TT - TOLD);
    if any(isnan(TT)) || any(TT(1:NN) < Tmin) %|| any(DeltT(1:NN)>30) %isnan(TT)==1
        for MN = 1:NN
            TT(MN) = TOLD(MN);
        end
    end
    for MN = 1:NN
        if TT(MN) <= -272
            TT(MN) = -272;
        end
    end
    [QET, QEB] = Enrgy_Bndry_Flux(SAVE, TT, NN);

end
