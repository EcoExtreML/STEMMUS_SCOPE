function Enrgy_sub
    global TT NN BCTB Tmin
    global NL hh DeltZ P_gg
    global CTh CTT CTa KTh KTT KTa CTg Vvh VvT Vaa Kaa
    global c_a c_L RHOL DRHOVT DRHOVh RHOV Hc RHODA DRHODAz L WW
    global Theta_V Theta_g QL V_A
    global KL_T D_Ta Lambda_eff c_unsat D_V Eta D_Vg Xah XaT Xaa DTheta_LLT Soilairefc
    global DTheta_LLh DVa_Switch
    global Khh KhT Kha KLhBAR KLTBAR DTDBAR DhDZ DTDZ DPgDZ Beta_g DEhBAR DETBAR QV Qa RHOVBAR EtaBAR
    global C1 C2 C3 C4 C5 C6 C7 C4_a C5_a C6_a VTT VTh VTa
    global Delt_t RHS T h P_g SAVE Thmrlefc
    global QMB SH Precip KT
    global NBCTB NBCT BCT DSTOR0 Ts Ta L_ts TOLD
    global EVAP CHK QET QEB r_a_SOIL Resis_a Tbtm Rn_SOIL QLT QLH QVH QVT QVa h_frez hh_frez SFCC Srt DTheta_UUh TT_CRIT T0 EPCT L_f RHOI g c_i KfL_h SAVEDTheta_LLh SAVEDTheta_UUh Kcah KcaT Kcaa Kcva Ccah CcaT Ccaa
    [CTh, CTT, CTa, KTh, KTT, KTa, VTT, VTh, VTa, CTg, QL, QLT, QLH, QV, QVH, QVT, QVa, Qa, KLhBAR, KLTBAR, DTDBAR, DhDZ, DTDZ, DPgDZ, Beta_g, DEhBAR, DETBAR, RHOVBAR, EtaBAR] = EnrgyPARM(NL, hh, TT, DeltZ, P_gg, Kaa, Vvh, VvT, Vaa, c_a, c_L, DTheta_LLh, RHOV, Hc, RHODA, DRHODAz, L, WW, RHOL, Theta_V, DRHOVh, DRHOVT, KfL_h, D_Ta, KL_T, D_V, D_Vg, DVa_Switch, Theta_g, QL, V_A, Lambda_eff, c_unsat, Eta, Xah, XaT, Xaa, DTheta_LLT, Soilairefc, Khh, KhT, Kha, KLhBAR, KLTBAR, DTDBAR, DhDZ, DTDZ, DPgDZ, Beta_g, DEhBAR, DETBAR, QV, Qa, RHOVBAR, EtaBAR, h_frez, hh_frez, SFCC, Srt, DTheta_UUh, TT_CRIT, T0, EPCT, L_f, RHOI, g, c_i, QLT, QLH, SAVEDTheta_LLh, SAVEDTheta_UUh, Kcah, KcaT, Kcaa, Kcva, Ccah, CcaT, Ccaa, QVa, CTT);
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
