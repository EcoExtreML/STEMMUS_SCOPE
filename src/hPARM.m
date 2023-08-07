function [Chh, ChT, Khh, KhT, Kha, Vvh, VvT, Chg, SoilVariables] = hPARM(SoilVariables, TT, T, RHOV, V_A, Eta, DRHOVh, DRHOVT, D_Ta, KL_T, D_V, D_Vg, Beta_g)

    % TODO issue refactor inputs and output using struct
    ModelSettings = io.getModelSettings();

    Constants = io.define_constants();
    RHOL = Constants.RHOL;

    hh = SoilVariables.hh;
    h = SoilVariables.h;
    Theta_LL = SoilVariables.Theta_LL;
    Theta_L = SoilVariables.Theta_L;
    DTheta_LLh = SoilVariables.DTheta_LLh;
    DTheta_UUh = SoilVariables.DTheta_UUh;
    Theta_V = SoilVariables.Theta_V;
    KfL_h = SoilVariables.KfL_h;
    COR = SoilVariables.COR;
    h_frez = SoilVariables.h_frez;
    hh_frez = SoilVariables.hh_frez;
    Theta_UU = SoilVariables.Theta_UU;
    Theta_U = SoilVariables.Theta_U;
    CORh = SoilVariables.CORh;

    % piecewise linear reduction function parameters of h;(Wesseling
    % 1991,Veenhof and McBride 1994)
    DTheta_LLT = [];
    for i = 1:ModelSettings.NL
        for j = 1:ModelSettings.nD
            MN = i + j - 1;
            if ModelSettings.hThmrl
                CORhh = -1 * CORh(MN);
                DhUU = COR(MN) * (hh(MN) + hh_frez(MN) - h(MN) - h_frez(MN) + (hh(MN) + hh_frez(MN)) * CORhh * (TT(MN) - T(MN)));
                DhU = COR(MN) * (hh(MN) - h(MN) + hh(MN) * CORhh * (TT(MN) - T(MN)));
                if DhU ~= 0 && DhUU ~= 0 && abs(Theta_LL(i, j) - Theta_L(i, j)) > 1e-6 && DTheta_UUh(i, j) ~= 0
                    DTheta_UUh(i, j) = (Theta_LL(i, j) - Theta_L(i, j)) * COR(MN) / DhUU;
                end
                if DhU ~= 0 && DhUU ~= 0 && abs(Theta_LL(i, j) - Theta_L(i, j)) > 1e-6 && DTheta_LLh(i, j) ~= 0
                    DTheta_LLh(i, j) = (Theta_UU(i, j) - Theta_U(i, j)) * COR(MN) / DhU;
                end

                DTheta_LLT(i, j) = DTheta_LLh(i, j) * (hh(MN) * CORhh);
                SAVEDTheta_LLT(i, j) = DTheta_LLT(i, j);
                SAVEDTheta_LLh(i, j) = DTheta_LLh(i, j);
                SAVEDTheta_UUh(i, j) = DTheta_UUh(i, j);
            else
                if abs(TT(MN) - T(MN)) > 1e-6
                    DTheta_LLT(i, j) = DTheta_LLh(i, j) * (hh(MN) / Constants.Gamma0) * (0.1425 + 4.76 * 10^(-4) * TT(MN));
                else
                    DTheta_LLT(i, j) = (Theta_LL(i, j) - Theta_L(i, j)) / (TT(MN) - T(MN));
                end
            end

            Chh(i, j) = (1 - RHOV(MN) / RHOL) * DTheta_LLh(i, j) + Theta_V(i, j) * DRHOVh(MN) / RHOL;
            Khh(i, j) = (D_V(i, j) + D_Vg(i)) * DRHOVh(MN) / RHOL + KfL_h(i, j);
            Chg(i, j) = KfL_h(i, j);

            if ModelSettings.Thmrlefc == 1
                ChT(i, j) = (1 - RHOV(MN) / RHOL) * DTheta_LLT(i, j) + Theta_V(i, j) * DRHOVT(MN) / RHOL;
                KhT(i, j) = (D_V(i, j) * Eta(i, j) + D_Vg(i)) * DRHOVT(MN) / RHOL + KL_T(i, j) + D_Ta(i, j);
            end

            if SoilVariables.KLa_Switch == 1
                Kha(i, j) = RHOV(MN) * Beta_g(i, j) / RHOL + KfL_h(i, j) / Constants.Gamma_w;
            else
                Kha(i, j) = 0;
            end

            if SoilVariables.DVa_Switch == 1
                Vvh(i, j) = -V_A(i) * DRHOVh(MN) / RHOL;
                VvT(i, j) = -V_A(i) * DRHOVT(MN) / RHOL;
            else
                Vvh(i, j) = 0;
                VvT(i, j) = 0;
            end
            if isnan(Chh(i, j))
                warning('\n Warning: FIX warning message \r');
            end
            if isnan(Khh(i, j)) == 1
                warning('\n Warning: FIX warning message \r');
            end
            if isnan(Chg(i, j))
                warning('\n Warning: FIX warning message\r');
            end
            if isnan(ChT(i, j))
                warning('\n Warning: FIX warning message \r');
            end
            if isnan(KhT(i, j))
                warning('\n Warning: FIX warning message \r');
            end
            if ~isreal(Chh(i, j))
                warning('\n Warning: FIX warning message \r');
            end
            if ~isreal(Khh(i, j)) == 1
                warning('\n Warning: FIX warning message \r');
            end
            if ~isreal(Chg(i, j))
                warning('\n Warning: FIX warning message \r');
            end
            if ~isreal(ChT(i, j))
                warning('\n Warning: FIX warning message \r');
            end
            if ~isreal(KhT(i, j))
                warning('\n Warning: FIX warning message \r');
            end
        end
    end
    SoilVariables.DTheta_LLh = DTheta_LLh;
    SoilVariables.DTheta_LLT = DTheta_LLT;
    SoilVariables.DTheta_UUh = DTheta_UUh;
    SoilVariables.SAVEDTheta_UUh = SAVEDTheta_UUh;
    SoilVariables.SAVEDTheta_LLh = SAVEDTheta_LLh;
end
