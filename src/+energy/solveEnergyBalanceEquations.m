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
    [C1, C2, C3, C4, C4_a, C5, C5_a, C6, C6_a, C7] = Enrgy_MAT(CTh, CTT, CTa, KTh, KTT, KTa, CTg, VTT, VTh, VTa, DeltZ, NL, NN, Soilairefc);
    [RHS, C5, SAVE] = Enrgy_EQ(C1, C2, C3, C4, C4_a, C5, C6_a, C6, C7, NL, NN, Delt_t, T, h, hh, P_g, P_gg, Thmrlefc, Soilairefc);
    [RHS, C5, C5_a] = Enrgy_BC(RHS, KT, NN, c_L, RHOL, QMB, SH, Precip, L, L_ts, NBCTB, NBCT, BCT, BCTB, DSTOR0, Delt_t, T, Ts, Ta, EVAP, C5, C5_a, r_a_SOIL, Resis_a, Tbtm, c_a, Rn_SOIL);
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
