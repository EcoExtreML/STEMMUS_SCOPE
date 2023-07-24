function SoilVariables = UpdateSoilWaterContent(KIT, L_f, SoilVariables, VanGenuchten)
    %{
        Update SoilWaterContent i.e. Theta_LL.
    %}

    % get model settings
    ModelSettings = io.getModelSettings();

    Theta_s = VanGenuchten.Theta_s;

    POR = SoilVariables.POR;
    TT = SoilVariables.TT;
    hh = SoilVariables.hh;
    XWRE = SoilVariables.XWRE;
    IH = SoilVariables.IH;

    COR = [];
    CORh = [];

    if ModelSettings.hThmrl == 1
        for MN = 1:ModelSettings.NN
            CORh(MN) = 0.0068;
            COR(MN) = exp(-1 * CORh(MN) * (TT(MN) - ModelSettings.Tr)); % *COR21(MN)

            if COR(MN) == 0
                COR(MN) = 1;
            end
        end
    else
        for MN = 1:ModelSettings.NN
            COR(MN) = 1;
        end
    end

    for MN = 1:ModelSettings.NN
        hhU(MN) = COR(MN) * hh(MN);
        hh(MN) = hhU(MN);
    end

    SoilVariables = conductivity.calculateHydraulicConductivity(SoilVariables, VanGenuchten, KIT, L_f);
    Theta_LL = SoilVariables.Theta_LL;
    DTheta_LLh = SoilVariables.DTheta_LLh;
    Theta_UU = SoilVariables.Theta_UU;
    Theta_II = SoilVariables.Theta_II;

    for MN = 1:ModelSettings.NN
        hhU(MN) = hh(MN);
        hh(MN) = hhU(MN) / COR(MN);
    end
    if ModelSettings.Hystrs == 0
        for i = 1:ModelSettings.NL
            for ND = 1:2
                Theta_V(i, ND) = POR(i) - Theta_UU(i, ND); % -Theta_II(i,ND); % Theta_LL==>Theta_UU
                if Theta_V(i, ND) <= 1e-14
                    Theta_V(i, ND) = 1e-14;
                end
                Theta_g(i, ND) = Theta_V(i, ND);
            end
        end
    else
        for i = 1:ModelSettings.NL
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
    SoilVariables.hh = hh;
    SoilVariables.COR = COR;
    SoilVariables.CORh = CORh;
    SoilVariables.Theta_V = Theta_V;
    SoilVariables.Theta_g = Theta_g;
end
