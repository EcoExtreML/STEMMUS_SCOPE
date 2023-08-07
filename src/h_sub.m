function h_sub

    % input
    % SAVE is updating
    C5_a, Delt_t, T, TT, SAVE, Eta, V_A, RHOV, DRHOVh, DRHOVT
    D_Ta, KL_T, D_V, D_Vg, Beta_g, hN, KT, TIME, Ta, Ts, Gvc, hOLD

    ModelSettings = io.getModelSettings();
    NN = ModelSettings.NN;
    DeltZ = ModelSettings.DeltZ;
    nD = ModelSettings.nD;
    NL = ModelSettings.NL;
    Thmrlefc = ModelSettings.Thmrlefc;
    Soilairefc = ModelSettings.Soilairefc;
    hThmrl = ModelSettings.hThmrl;
    rwuef = ModelSettings.rwuef;
    T0 = ModelSettings.T0;

    Constants = io.define_constants();
    RHOL = Constants.RHOL;
    Gamma_w = Constants.Gamma_w;
    Gamma0 = Constants.Gamma0;
    Rv = Constants.Rv;
    g = Constants.g;

    hh = SoilVariables.hh;
    C1 = InitialValues.C1;
    C2 = InitialValues.C2;
    C3 = InitialValues.C3;
    C4 = InitialValues.C4;
    C5 = InitialValues.C5;
    C6 = InitialValues.C6;
    C7 = InitialValues.C7;
    C9 = InitialValues.C9;
    Chh = InitialValues.Chh;
    ChT = InitialValues.ChT;
    Khh = InitialValues.Khh;
    KhT = InitialValues.KhT;
    Kha = InitialValues.Kha;
    Vvh = InitialValues.Vvh;
    VvT = InitialValues.VvT;
    Chg = InitialValues.Chg;
    bx = InitialValues.bx;
    RHS = InitialValues.RHS;
    P_gg = InitialValues.P_gg;
    Precip = InitialValues.Precip;
    Evap = InitialValues.Evap;
    EVAP = InitialValues.EVAP;
    h_SUR = InitialValues.h_SUR;
    Srt = InitialValues.Srt;
    Rn_SOIL = InitialValues.Rn_SOIL;
    Rn = InitialValues.Rn;
    SAVEDTheta_UUh = InitialValues.SAVEDTheta_UUh;
    SAVEDTheta_LLh = InitialValues.SAVEDTheta_LLh;

    h = SoilVariables.h;
    DTheta_LLh = SoilVariables.DTheta_LLh;
    DTheta_UUh = SoilVariables.DTheta_UUh;
    Theta_LL = SoilVariables.Theta_LL;
    Theta_L = SoilVariables.Theta_L;
    Theta_V = SoilVariables.Theta_V;
    KL_h = SoilVariables.KL_h;
    COR = SoilVariables.COR;
    DVa_Switch = SoilVariables.DVa_Switch;
    KLa_Switch = SoilVariables.KLa_Switch;
    TT_CRIT = SoilVariables.TT_CRIT;
    h_frez = SoilVariables.h_frez;
    hh_frez = SoilVariables.hh_frez;
    Theta_UU = SoilVariables.Theta_UU;
    Theta_U = SoilVariables.Theta_U;
    KfL_h = SoilVariables.KfL_h;
    SAVEhh = SoilVariables.SAVEhh;
    CORh = SoilVariables.CORh;

    NBCh = BoundaryCondition.NBCh;
    BCh = BoundaryCondition.BCh;
    NBChB = BoundaryCondition.NBChB;
    NBCTB = BoundaryCondition.NBCTB;
    BChB = BoundaryCondition.BChB;
    DSTOR0 = BoundaryCondition.DSTOR0;
    NBChh = BoundaryCondition.NBChh;

    % Convert unit to Centimeter-Gram-Second system
    % U_wind is the mean wind speed at height z_ref (m/s^-1), U is the wind
    % speed at each time step.
    U = 100 .* (ForcingData.WS_msr);
    HR_a = 0.01 .* (ForcingData.RH_msr);
    Precip_msr = ForcingData.Precip_msr;

    % output
    hh = SoilVariables.hh;
    DTheta_LLh = SoilVariables.DTheta_LLh;
    DTheta_LLT, CHK, AVAIL0, QMT, QMB, Evapo, Srt, r_a_SOIL
    Trap, Rn_SOIL, Resis_a, SAVEDTheta_UUh, SAVEDTheta_LLh, trap

    [Chh, ChT, Khh, KhT, Kha, Vvh, VvT, Chg, SoilVariables] = hPARM(SoilVariables, TT, T, RHOV, V_A, Eta, DRHOVh, DRHOVT, D_Ta, KL_T, D_V, D_Vg, Beta_g);

    % Srt, root water uptake;
    Srt = InitialValues.Srt;

    [C1, C2, C4, C3, C4_a, C5, C6, C7, C5_a, C9] = h_MAT(Chh, ChT, Khh, KhT, Kha, Vvh, VvT, Chg, Srt);
    [RHS, C4, SAVE] = h_EQ(C1, C2, C4, C5, C6, C7, C5_a, C9, NL, NN, Delt_t, T, TT, h, P_gg, Thmrlefc, Soilairefc);
    [AVAIL0, RHS, C4, C4_a, Rn_SOIL, Evap, EVAP, Trap, r_a_SOIL, Resis_a, Srt, Precip] = h_BC(RHS, NBCh, NBChB, BCh, BChB, hN, KT, Delt_t, DSTOR0, NBChh, TIME, h_SUR, C4, KL_h, NN, C4_a, DeltZ, RHOV, Ta, HR_a, U, Theta_LL, Ts, Rv, g, NL, hh, rwuef, Theta_UU, Rn, T, TT, Gvc, Srt, Precip_msr); % h_BC;
    [CHK, hh, C4, SAVEhh] = hh_Solve(C4, hh, NN, NL, C4_a, RHS);
    if any(isnan(hh)) || any(hh(1:NN) <= -1E12)
        for MN = 1:NN
            hh(MN) = hOLD(MN);
        end
    end
    for MN = 1:NN
        if hh(MN) >= -1e-6
            hh(MN) = -1e-6;
        end
    end
    [QMT, QMB] = h_Bndry_Flux(SAVE, hh, NN, KT);
    Evapo(KT) = Evap(KT);
    trap(KT) = Trap(KT);
end
