function [Chh, ChT, Khh, KhT, Kha, Vvh, VvT, Chg, DTheta_LLh, DTheta_LLT, DTheta_UUh, SAVEDTheta_UUh, SAVEDTheta_LLh] = hPARM(NL, hh, ...
                                                                                                                h, TT, T, Theta_LL, Theta_L, DTheta_LLh, DTheta_LLT, RHOV, RHOL, Theta_V, V_A, Eta, DRHOVh, ...
                                                                                                                DRHOVT, KfL_h, D_Ta, KL_T, D_V, D_Vg, COR, Beta_g, Gamma0, Gamma_w, KLa_Switch, DVa_Switch, hThmrl, Thmrlefc, nD, TT_CRIT, T0, h_frez, hh_frez, Theta_UU, Theta_U, CORh, DTheta_UUh, Chh, ChT, Khh, KhT)

    % piecewise linear reduction function parameters of h;(Wesseling
    % 1991,Veenhof and McBride 1994)

    MN = 0;
    for ML = 1:NL
        for ND = 1:2
            MN = ML + ND - 1;
            if hThmrl
                CORhh = -1 * CORh(MN); % -0.0068;
                DhUU = COR(MN) * (hh(MN) + hh_frez(MN) - h(MN) - h_frez(MN) + (hh(MN) + hh_frez(MN)) * CORhh * (TT(MN) - T(MN)));
                DhU = COR(MN) * (hh(MN) - h(MN) + hh(MN) * CORhh * (TT(MN) - T(MN)));
                if DhU ~= 0 && DhUU ~= 0 && abs(Theta_LL(ML, ND) - Theta_L(ML, ND)) > 1e-6 && DTheta_UUh(ML, ND) ~= 0 % && abs(TT(MN)-T(MN))<1e-4
                    DTheta_UUh(ML, ND) = (Theta_LL(ML, ND) - Theta_L(ML, ND)) * COR(MN) / DhUU;
                end
                if DhU ~= 0 && DhUU ~= 0 && abs(Theta_LL(ML, ND) - Theta_L(ML, ND)) > 1e-6 && DTheta_LLh(ML, ND) ~= 0 % && abs(TT(MN)-T(MN))<1e-4
                    DTheta_LLh(ML, ND) = (Theta_UU(ML, ND) - Theta_U(ML, ND)) * COR(MN) / DhU;
                end
                %%
                DTheta_LLT(ML, ND) = DTheta_LLh(ML, ND) * (hh(MN) * CORhh);
                SAVEDTheta_LLT(ML, ND) = DTheta_LLT(ML, ND);
                SAVEDTheta_LLh(ML, ND) = DTheta_LLh(ML, ND);
                SAVEDTheta_UUh(ML, ND) = DTheta_UUh(ML, ND);
            else
                if abs(TT(MN) - T(MN)) > 1e-6
                    DTheta_LLT(ML, ND) = DTheta_LLh(ML, ND) * (hh(MN) / Gamma0) * (0.1425 + 4.76 * 10^(-4) * TT(MN));
                else
                    DTheta_LLT(ML, ND) = (Theta_LL(ML, ND) - Theta_L(ML, ND)) / (TT(MN) - T(MN));
                end
            end
        end
    end

    MN = 0;
    for ML = 1:NL
        for ND = 1:nD
            MN = ML + ND - 1;
            Chh(ML, ND) = (1 - RHOV(MN) / RHOL) * DTheta_LLh(ML, ND) + Theta_V(ML, ND) * DRHOVh(MN) / RHOL;  % DTheta_LLh==>DTheta_UUh
            Khh(ML, ND) = (D_V(ML, ND) + D_Vg(ML)) * DRHOVh(MN) / RHOL + KfL_h(ML, ND); % KL_h==>KfL_h
            Chg(ML, ND) = KfL_h(ML, ND); % KL_h==>KfL_h

            if Thmrlefc == 1
                ChT(ML, ND) = (1 - RHOV(MN) / RHOL) * DTheta_LLT(ML, ND) + Theta_V(ML, ND) * DRHOVT(MN) / RHOL;   % -RHOI/RHOL*KfL_T(ML,ND)*DTheta_LLh(ML,ND)/1e4DTheta_LLT==>DTheta_UUT
                KhT(ML, ND) = (D_V(ML, ND) * Eta(ML, ND) + D_Vg(ML)) * DRHOVT(MN) / RHOL + KL_T(ML, ND) + D_Ta(ML, ND); % -Khh(ML,ND)*1e4*L_f/(g*(T0+TT(MN)))*max(helpers.heaviside1(TT_CRIT(MN)-(TT(MN)+T0)))considering ice freezing pressure*KfL_T(ML,ND);%;%();% KfL_T considering the ice
            end

            if KLa_Switch == 1
                Kha(ML, ND) = RHOV(MN) * Beta_g(ML, ND) / RHOL + KfL_h(ML, ND) / Gamma_w; % KL_h==>KfL_h
            else
                Kha(ML, ND) = 0;
            end

            if DVa_Switch == 1
                Vvh(ML, ND) = -V_A(ML) * DRHOVh(MN) / RHOL;
                VvT(ML, ND) = -V_A(ML) * DRHOVT(MN) / RHOL;
            else
                Vvh(ML, ND) = 0;
                VvT(ML, ND) = 0;
            end
            if isnan(Chh(ML, ND))
                warning('\n Warning: FIX warning message \r');
            end
            if isnan(Khh(ML, ND)) == 1
                warning('\n Warning: FIX warning message \r');
            end
            if isnan(Chg(ML, ND))
                warning('\n Warning: FIX warning message\r');
            end
            if isnan(ChT(ML, ND))
                warning('\n Warning: FIX warning message \r');
            end
            if isnan(KhT(ML, ND))
                warning('\n Warning: FIX warning message \r');
            end
            if ~isreal(Chh(ML, ND))
                warning('\n Warning: FIX warning message \r');
            end
            if ~isreal(Khh(ML, ND)) == 1
                warning('\n Warning: FIX warning message \r');
            end
            if ~isreal(Chg(ML, ND))
                warning('\n Warning: FIX warning message \r');
            end
            if ~isreal(ChT(ML, ND))
                warning('\n Warning: FIX warning message \r');
            end
            if ~isreal(KhT(ML, ND))
                warning('\n Warning: FIX warning message \r');
            end
        end
    end
