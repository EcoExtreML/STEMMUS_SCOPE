function SoilVariables = SOIL2(ModelSettings, SoilConstants, SoilVariables, VanGenuchten)

    % these lines can be removed after issue 181
    NN = ModelSettings.NN;
    NL = ModelSettings.NL;
    SWCC = ModelSettings.SWCC;
    Thmrlefc = ModelSettings.Thmrlefc;
    T0 = ModelSettings.T0;
    Tr = ModelSettings.Tr;
    KIT = ModelSettings.KIT;
    hThmrl = ModelSettings.hThmrl;
    Hystrs = ModelSettings.Hystrs;

    Theta_s = VanGenuchten.Theta_s;
    Theta_r = VanGenuchten.Theta_r;
    Alpha = VanGenuchten.Alpha;
    n = VanGenuchten.n;
    m = VanGenuchten.m;

    POR = SoilVariables.POR;
    h = SoilVariables.h;
    Lamda = SoilVariables.Lamda;
    Phi_s = SoilVariables.Phi_s;

    h_frez = SoilVariables.h_frez;
    hh_frez = SoilVariables.hh_frez;
    TT = SoilVariables.TT;
    hh = SoilVariables.hh;
    COR = SoilVariables.COR;
    CORh = SoilVariables.CORh;
    XWRE = SoilVariables.XWRE;
    IH = SoilVariables.IH;
    Ks = SoilVariables.Ks;
    Imped = SoilVariables.Imped;
    XCAP = SoilVariables.XCAP;

    Theta_L = SoilVariables.Theta_L;
    Theta_LL = SoilVariables.Theta_LL;
    Theta_V = SoilVariables.Theta_V;
    Theta_g = SoilVariables.Theta_g;
    Se = SoilVariables.Se;
    KL_h = SoilVariables.KL_h;
    DTheta_LLh = SoilVariables.DTheta_LLh;
    KfL_T = SoilVariables.KfL_T;
    Theta_II = SoilVariables.Theta_II;
    Theta_I = SoilVariables.Theta_I;
    Theta_UU = SoilVariables.Theta_UU;
    Theta_U = SoilVariables.Theta_U;
    TT_CRIT = SoilVariables.TT_CRIT;
    KfL_h = SoilVariables.KfL_h;
    DTheta_UUh = SoilVariables.DTheta_UUh;

    % get Constants
    Constants = io.define_constants();
    g = Constants.g;
    RHOI = Constants.RHOI;
    RHOL = Constants.RHOL;

    % TODO issue L_f is used with different value in main script
    L_f = SoilConstants.L_f;

    if hThmrl == 1
        for MN = 1:NN
            CORh(MN) = 0.0068;
            COR(MN) = exp(-1 * CORh(MN) * (TT(MN) - Tr)); % *COR21(MN)

            if COR(MN) == 0
                COR(MN) = 1;
            end
        end
    else
        for MN = 1:NN
            COR(MN) = 1;
        end
    end

    for MN = 1:NN
        hhU(MN) = COR(MN) * hh(MN);
        hh(MN) = hhU(MN);
    end
    [Theta_LL, Se, KfL_h, KfL_T, DTheta_LLh, hh, hh_frez, Theta_UU, DTheta_UUh, Theta_II, KL_h] = CondL_h(SoilConstants, SoilVariables, Theta_r, Theta_s, Alpha, hh, hh_frez, h_frez, n, m, Ks, NL, Theta_L, h, KIT, TT, Thmrlefc, POR, SWCC, Theta_U, XCAP, Phi_s, RHOI, RHOL, Lamda, Imped, L_f, g, T0, TT_CRIT, Theta_II, KfL_h, KfL_T, KL_h, Theta_UU, Theta_LL, DTheta_LLh, DTheta_UUh, Se);
    for MN = 1:NN
        hhU(MN) = hh(MN);
        hh(MN) = hhU(MN) / COR(MN);
    end
    if Hystrs == 0
        for i = 1:NL
            for ND = 1:2
                Theta_V(i, ND) = POR(i) - Theta_UU(i, ND); % -Theta_II(i,ND); % Theta_LL==>Theta_UU
                if Theta_V(i, ND) <= 1e-14
                    Theta_V(i, ND) = 1e-14;
                end
                Theta_g(i, ND) = Theta_V(i, ND);
            end
        end
    else
        for i = 1:NL
            for ND = 1:2
                if IH(i) == 2
                    if XWRE(i, ND) < Theta_LL(i, ND)
                        Theta_V(i, ND) = POR(i) - Theta_LL(i, ND) - Theta_II(i, ND);
                    else
                        XSAVE = Theta_LL(i, ND);
                        Theta_LL(i, ND) = XSAVE * (1 + (XWRE(i, ND) - Theta_LL(i, ND)) / Theta_s(i));
                        if KIT > 0
                            DTheta_LLh(i, ND) = DTheta_LLh(i, ND) * (Theta_LL(i, ND) / XSAVE - XSAVE / Theta_s(i));
                        end
                        Theta_V(i, ND) = POR(i) - Theta_LL(i, ND) - Theta_II(i, ND);
                    end
                end
                if IH(i) == 1
                    if XWRE(i, ND) > Theta_LL(i, ND)
                        XSAVE = Theta_LL(i, ND);
                        Theta_LL(i, ND) = (2 - XSAVE / Theta_s(i)) * XSAVE;
                        if KIT > 0
                            DTheta_LLh(i, ND) = 2 * DTheta_LLh(i, ND) * (1 - XSAVE / Theta_s(i));
                        end
                        Theta_V(i, ND) = POR(i) - Theta_LL(i, ND) - Theta_II(i, ND);
                    else
                        Theta_LL(i, ND) = Theta_LL(i, ND) + XWRE(i, ND) * (1 - Theta_LL(i, ND) / Theta_s(i));
                        if KIT > 0
                            DTheta_LLh(i, ND) = DTheta_LLh(i, ND) * (1 - XWRE(i, ND) / Theta_s(i));
                        end
                        Theta_V(i, ND) = POR(i) - Theta_LL(i, ND) - Theta_II(i, ND);
                    end
                end
                if Theta_V(i, ND) <= 1e-14    % consider the negative conditions?
                    Theta_V(i, ND) = 1e-14;
                end
                Theta_g(i, ND) = Theta_V(i, ND);
            end
        end
    end
    SoilVariables.KfL_T = KfL_T;
    SoilVariables.Theta_II = Theta_II;
    SoilVariables.Theta_UU = Theta_UU;

    SoilVariables.hh_frez = hh_frez;
    SoilVariables.hh = hh;
    SoilVariables.COR = COR;
    SoilVariables.CORh = CORh;
    SoilVariables.Se = Se;
    SoilVariables.KL_h = KL_h;
    SoilVariables.Theta_LL = Theta_LL;
    SoilVariables.DTheta_LLh = DTheta_LLh;
    SoilVariables.KfL_h = KfL_h;
    SoilVariables.Theta_V = Theta_V;
    SoilVariables.Theta_g = Theta_g;
    SoilVariables.DTheta_UUh = DTheta_UUh;
end
