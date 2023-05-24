function [ETCON, EHCAP, TETCON, EfTCON, ZETA] = EfeCapCond(HCAP, SF, TCA, GA1, GA2, GB1, GB2, HCD, ZETA0, CON0, PS1, PS2, XWILT, XK, TT, NL, POR, Theta_LL, DRHOVT, L, D_A, RHOV, Theta_V, Theta_II, TCON_dry, Theta_s, XSOC, ThermCond, TPS1, TPS2, TCON0, TCON_s, FEHCAP, RHOI, RHOL, ETCON, EHCAP, TETCON, EfTCON, ZETA)
    global TCON
    MN = 0;
    TCON(1) = 1.37e-3 * 4.182;
    for ML = 1:NL
        for ND = 1:2
            MN = ML + ND - 1;
            J = ML; % J=IS(ML);
            XXX = Theta_LL(ML, ND);
            XII = Theta_II(ML, ND) * RHOI / RHOL; % MODIFIED 201905
            if Theta_LL(ML, ND) < XK(J)
                XXX = XK(J);
            end

            if XXX < XWILT(J)
                SF(2) = GA2 + GB2(J) * XXX;
            else
                SF(2) = GA1 + GB1(J) * XXX;
            end
            D_A(MN) = 0.229 * (1 + TT(MN) / 273)^1.75;
            TCON(2) = TCA + D_A(MN) * L(MN) * DRHOVT(MN); % TCA+D_A(MN)*L(MN)*DRHOVT(MN); % Revised from ""(D_V(ML,ND)*Eta(ML,ND)+D_Vg(ML))*L(MN)*DRHOVT(MN)
            TCON(6) = 5.2e-3 * 4.182; % ice thermal conductivity
            SF(6) = 0.125;
            TARG(2) = TCON(2) / TCON(1) - 1;
            TARG(6) = TCON(6) / TCON(1) - 1;
            GRAT(2) = 0.667 / (1 + TARG(2) * SF(2)) + 0.333 / (1 + TARG(2) * (1 - 2 * SF(2)));
            GRAT(6) = 0.667 / (1 + TARG(6) * SF(6)) + 0.333 / (1 + TARG(6) * (1 - 2 * SF(6)));
            ETCON(ML, ND) = (PS1(J) + XXX * TCON(1) + (POR(J) - XXX - XII) * GRAT(2) * TCON(2) + XII * GRAT(6) * TCON(6)) / (PS2(J) + XXX + (POR(J) - XXX - XII) * GRAT(2) + XII * GRAT(6));
            ZETA(ML, ND) = GRAT(2) / (GRAT(2) * (POR(J) - XXX) + XXX + PS2(J));  % ita_T enhancement factor
            ZETA(ML, ND) = GRAT(2) / (GRAT(2) * (POR(J) - XXX - XII) + XXX + PS2(J) + XII * GRAT(6));
            if Theta_LL(ML, ND) == XXX
                EHCAP(ML, ND) = HCD(J) + HCAP(1) * Theta_LL(ML, ND);
                EHCAP(ML, ND) = EHCAP(ML, ND) + (0.448 * RHOV(MN) * 4.182 + HCAP(2)) * Theta_V(ML, ND) + HCAP(6) * XII; % The Calorie should be converted as J
            else
                ZETA(ML, ND) = ZETA0(J) + (ZETA(ML, ND) - ZETA0(J)) * Theta_LL(ML, ND) / XXX;
                ETCON(ML, ND) = CON0(J) + (ETCON(ML, ND) - CON0(J)) * Theta_LL(ML, ND) / XXX;
                EHCAP(ML, ND) = HCD(J) + HCAP(1) * Theta_LL(ML, ND);
                EHCAP(ML, ND) = EHCAP(ML, ND) + (0.448 * RHOV(MN) * 4.182 + HCAP(2)) * Theta_V(ML, ND) + HCAP(6) * XII; % The Calorie should be converted as J
            end
            %%%%%% simpliefied Vries method by Tian 2016
            TSF(2) = 0.333 * (1 - (POR(J) - XXX - XII) / POR(J));
            TSF(6) = 0.333 * (1 - XII / POR(J));
            TSF(7) = 0.5; % shape factor for organic matter
            D_A(MN) = 0.229 * (1 + TT(MN) / 273)^1.75;
            TCON(2) = TCA + D_A(MN) * L(MN) * DRHOVT(MN); % TCA+D_A(MN)*L(MN)*DRHOVT(MN); % Revised from ""(D_V(ML,ND)*Eta(ML,ND)+D_Vg(ML))*L(MN)*DRHOVT(MN)
            TCON(6) = 5.2e-3 * 4.182; % ice conductivity
            TCON(7) = 0.25e-2; % soil organic matter conductivity
            TARG(2) = TCON(2) / TCON(1) - 1;
            TARG(6) = TCON(6) / TCON(1) - 1;
            TARG(7) = TCON(7) / TCON(1) - 1;
            TTGRAT(2) = 0.667 / (1 + TARG(2) * TSF(2)) + 0.333 / (1 + TARG(2) * (1 - 2 * TSF(2)));
            TTGRAT(6) = 0.667 / (1 + TARG(6) * TSF(6)) + 0.333 / (1 + TARG(6) * (1 - 2 * TSF(6)));
            TTGRAT(7) = 0.667 / (1 + TARG(7) * TSF(7)) + 0.333 / (1 + TARG(7) * (1 - 2 * TSF(7)));
            if XSOC(J) == 0
                TETCON(ML, ND) = (TPS1(J) + XXX * TCON(1) + (POR(J) - XXX - XII) * TTGRAT(2) * TCON(2) + XII * TTGRAT(6) * TCON(6)) / (TPS2(J) + XXX + (POR(J) - XXX - XII) * TTGRAT(2) + XII * TTGRAT(6));
            else
                TETCON(ML, ND) = (TPS1(J) + XXX * TCON(1) + (POR(J) - XXX - XII) * TTGRAT(2) * TCON(2) + XII * TTGRAT(6) * TCON(6) + XSOC(J) * TTGRAT(7) * TCON(7)) / (TPS2(J) + XXX + (POR(J) - XXX - XII) * TTGRAT(2) + XII * TTGRAT(6) + XSOC(J) * TTGRAT(7));
            end
            TZETA(ML, ND) = TTGRAT(2) / (TTGRAT(2) * (POR(J) - XXX) + XXX + TPS2(J));  % ita_T enhancement factor
            if Theta_LL(ML, ND) == XXX
                EHCAP(ML, ND) = HCD(J) + HCAP(1) * Theta_LL(ML, ND);
                EHCAP(ML, ND) = EHCAP(ML, ND) + (0.448 * RHOV(MN) * 4.182 + HCAP(2)) * Theta_V(ML, ND) + HCAP(6) * XII; % The Calorie should be converted as J
            else
                ZETA(ML, ND) = ZETA0(J) + (ZETA(ML, ND) - ZETA0(J)) * Theta_LL(ML, ND) / XXX;
                TETCON(ML, ND) = TCON0(J) + (TETCON(ML, ND) - TCON0(J)) * Theta_LL(ML, ND) / XXX;
                EHCAP(ML, ND) = HCD(J) + HCAP(1) * Theta_LL(ML, ND);
                EHCAP(ML, ND) = EHCAP(ML, ND) + (0.448 * RHOV(MN) * 4.182 + HCAP(2)) * Theta_V(ML, ND) + HCAP(6) * XII; % The Calorie should be converted as J
            end
            %%%%%%%%%%%%%%%%%% Farouki thermal parameter method %%%%%%%%%%%
            %%%%%%%%%%%%%%%%% change 21 July 2017 switch of thermal conductivity%%%%%%
            if ThermCond == 4 %|| ThermCond==2
                %             FEHCAP(ML,ND)=(2.128*Theta_sa(J)+2.385*Theta_cl(J))/(Theta_sa(J)+Theta_cl(J))*1e6;  %J m-3 K-1
                %             TCON_s(J)=(8.8*Theta_sa(J)+2.92*Theta_cl(J))/(Theta_sa(J)+Theta_cl(J)); %  W m-1 K-1
                FFEHCAP(ML, ND) = (FEHCAP(J) * (1 - POR(J)) + 1000 * 4217.7 * Theta_LL(ML, ND) + 917 * 2117.27 * XII) * 1e-6; % The Calorie should be converted as J
                EHCAP(ML, ND) = FFEHCAP(ML, ND);
            end
            %%%%%%%%%%%%%%%%%% Johansen thermal conductivity method %%%%%%%%%%%
            TCON_qtz = 7.7;
            TCON_o = 2.0;
            TCON_L = 0.57; % Theta_qtz(J)=0.47;     % thermal conductivities of soil quartz, other soil particles and water; unit  W m-1 K-1
            if ThermCond == 2
                TCON_s(J) = TCON_qtz^(Theta_qtz(J)) * TCON_o^(1 - Theta_qtz(J)); % solid soil thermal conductivity Unit W m-1 K-1
            end
            TCON_i(J) = 2.2;
            %%%%% Peters-Lidard et al. 1998 frozen soil thermal conductivity method %%%%%%%
            Satr(ML, ND) = (Theta_LL(ML, ND) + XII) / Theta_s(J);
            if Theta_II(ML, ND) <= 0
                if Theta_LL(ML, ND) / POR(J) > 0.1
                    K_e(ML, ND) = log10(Theta_LL(ML, ND) / POR(J)) + 1;  % Kersten coefficient, weighting dry and wet thermal conductivity
                elseif Theta_LL(ML, ND) / POR(J) > 0.05
                    K_e(ML, ND) = 0.7 * log10(Theta_LL(ML, ND) / POR(J)) + 1;  % Kersten coefficient, weighting dry and wet thermal conductivity
                else
                    K_e(ML, ND) = 0;
                end
                Coef_k = 1.9; % [4.6 3.55 1.9; 1.7 0.95 0.85];
                TCON_sat(ML, ND) = TCON_s(J)^(1 - Theta_s(J)) * TCON_L^(Theta_s(J));  % saturated soil thermal conductivity Unit W m-1 K-1
                EfTCON(ML, ND) = K_e(ML, ND) * (TCON_sat(ML, ND) - TCON_dry(J)) + TCON_dry(J);
            else
                K_e(ML, ND) = (Theta_LL(ML, ND) + Theta_II(ML, ND)) / POR(J); % +Theta_II(ML,ND)
                TCON_sat(ML, ND) = TCON_s(J)^(1 - Theta_s(J)) * TCON_i(J)^(Theta_s(J) - Theta_LL(ML, ND)) * TCON_L^(Theta_LL(ML, ND));  % saturated soil thermal conductivity Unit W m-1 K-1
                EfTCON(ML, ND) = K_e(ML, ND) * (TCON_sat(ML, ND) - TCON_dry(J)) + TCON_dry(J);
            end
        end
    end
