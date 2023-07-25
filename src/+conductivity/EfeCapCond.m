function [ETCON, EHCAP, TETCON, EfTCON, ZETA] = EfeCapCond(ThermalConductivity, SoilVariables, VanGenuchten, DRHOVT, L, RHOV)

    % TODO issue rename function
    HCAP = ThermalConductivity.HCAP;
    SF = ThermalConductivity.SF;
    TCA = ThermalConductivity.TCA;
    GA1 = ThermalConductivity.GA1;
    GA2 = ThermalConductivity.GA2;
    GB1 = ThermalConductivity.GB1;
    GB2 = ThermalConductivity.GB2;
    HCD = ThermalConductivity.HCD;
    ZETA0 = ThermalConductivity.ZETA0;
    CON0 = ThermalConductivity.CON0;
    PS1 = ThermalConductivity.PS1;
    PS2 = ThermalConductivity.PS2;
    TCON_dry = ThermalConductivity.TCON_dry;
    TPS1 = ThermalConductivity.TPS1;
    TPS2 = ThermalConductivity.TPS2;
    FEHCAP = ThermalConductivity.FEHCAP;
    TCON0 = ThermalConductivity.TCON0;
    TCON_s = ThermalConductivity.TCON_s;

    XWILT = SoilVariables.XWILT;
    XK = SoilVariables.XK;
    TT = SoilVariables.TT;
    POR = SoilVariables.POR;
    Theta_LL = SoilVariables.Theta_LL;
    D_A = InitialValues.D_A;
    Theta_V = SoilVariables.Theta_V;
    Theta_II = SoilVariables.Theta_II;
    XSOC = SoilVariables.XSOC;

    Theta_s = VanGenuchten.Theta_s;

    % load Constants
    Constants = io.define_constants();

    % get model settings
    ModelSettings = io.getModelSettings();

    MN = 0;
    TCON(1) = 1.37e-3 * 4.182;
    for i = 1:ModelSettings.NL
        for j = 1:ModelSettings.nD
            MN = i + j - 1;
            XXX = Theta_LL(i, j);
            XII = Theta_II(i, j) * Constants.RHOI / Constants.RHOL; % MODIFIED 201905
            if Theta_LL(i, j) < XK(i)
                XXX = XK(i);
            end

            if XXX < XWILT(i)
                SF(2) = GA2 + GB2(i) * XXX;
            else
                SF(2) = GA1 + GB1(i) * XXX;
            end
            D_A(MN) = 0.229 * (1 + TT(MN) / 273)^1.75;
            TCON(2) = TCA + D_A(MN) * L(MN) * DRHOVT(MN); % TCA+D_A(MN)*L(MN)*DRHOVT(MN); % Revised from ""(D_V(i,j)*Eta(i,j)+D_Vg(i))*L(MN)*DRHOVT(MN)
            TCON(6) = 5.2e-3 * 4.182; % ice thermal conductivity
            SF(6) = 0.125;
            TARG(2) = TCON(2) / TCON(1) - 1;
            TARG(6) = TCON(6) / TCON(1) - 1;
            GRAT(2) = 0.667 / (1 + TARG(2) * SF(2)) + 0.333 / (1 + TARG(2) * (1 - 2 * SF(2)));
            GRAT(6) = 0.667 / (1 + TARG(6) * SF(6)) + 0.333 / (1 + TARG(6) * (1 - 2 * SF(6)));
            ETCON(i, j) = (PS1(i) + XXX * TCON(1) + (POR(i) - XXX - XII) * GRAT(2) * TCON(2) + XII * GRAT(6) * TCON(6)) / (PS2(i) + XXX + (POR(i) - XXX - XII) * GRAT(2) + XII * GRAT(6));
            ZETA(i, j) = GRAT(2) / (GRAT(2) * (POR(i) - XXX) + XXX + PS2(i));  % ita_T enhancement factor
            ZETA(i, j) = GRAT(2) / (GRAT(2) * (POR(i) - XXX - XII) + XXX + PS2(i) + XII * GRAT(6));
            if Theta_LL(i, j) == XXX
                EHCAP(i, j) = HCD(i) + HCAP(1) * Theta_LL(i, j);
                EHCAP(i, j) = EHCAP(i, j) + (0.448 * RHOV(MN) * 4.182 + HCAP(2)) * Theta_V(i, j) + HCAP(6) * XII; % The Calorie should be converted as i
            else
                ZETA(i, j) = ZETA0(i) + (ZETA(i, j) - ZETA0(i)) * Theta_LL(i, j) / XXX;
                ETCON(i, j) = CON0(i) + (ETCON(i, j) - CON0(i)) * Theta_LL(i, j) / XXX;
                EHCAP(i, j) = HCD(i) + HCAP(1) * Theta_LL(i, j);
                EHCAP(i, j) = EHCAP(i, j) + (0.448 * RHOV(MN) * 4.182 + HCAP(2)) * Theta_V(i, j) + HCAP(6) * XII; % The Calorie should be converted as i
            end
            %%%%%% simpliefied Vries method by Tian 2016
            TSF(2) = 0.333 * (1 - (POR(i) - XXX - XII) / POR(i));
            TSF(6) = 0.333 * (1 - XII / POR(i));
            TSF(7) = 0.5; % shape factor for organic matter
            D_A(MN) = 0.229 * (1 + TT(MN) / 273)^1.75;
            TCON(2) = TCA + D_A(MN) * L(MN) * DRHOVT(MN); % TCA+D_A(MN)*L(MN)*DRHOVT(MN); % Revised from ""(D_V(i,j)*Eta(i,j)+D_Vg(i))*L(MN)*DRHOVT(MN)
            TCON(6) = 5.2e-3 * 4.182; % ice conductivity
            TCON(7) = 0.25e-2; % soil organic matter conductivity
            TARG(2) = TCON(2) / TCON(1) - 1;
            TARG(6) = TCON(6) / TCON(1) - 1;
            TARG(7) = TCON(7) / TCON(1) - 1;
            TTGRAT(2) = 0.667 / (1 + TARG(2) * TSF(2)) + 0.333 / (1 + TARG(2) * (1 - 2 * TSF(2)));
            TTGRAT(6) = 0.667 / (1 + TARG(6) * TSF(6)) + 0.333 / (1 + TARG(6) * (1 - 2 * TSF(6)));
            TTGRAT(7) = 0.667 / (1 + TARG(7) * TSF(7)) + 0.333 / (1 + TARG(7) * (1 - 2 * TSF(7)));
            if XSOC(i) == 0
                TETCON(i, j) = (TPS1(i) + XXX * TCON(1) + (POR(i) - XXX - XII) * TTGRAT(2) * TCON(2) + XII * TTGRAT(6) * TCON(6)) / (TPS2(i) + XXX + (POR(i) - XXX - XII) * TTGRAT(2) + XII * TTGRAT(6));
            else
                TETCON(i, j) = (TPS1(i) + XXX * TCON(1) + (POR(i) - XXX - XII) * TTGRAT(2) * TCON(2) + XII * TTGRAT(6) * TCON(6) + XSOC(i) * TTGRAT(7) * TCON(7)) / (TPS2(i) + XXX + (POR(i) - XXX - XII) * TTGRAT(2) + XII * TTGRAT(6) + XSOC(i) * TTGRAT(7));
            end
            TZETA(i, j) = TTGRAT(2) / (TTGRAT(2) * (POR(i) - XXX) + XXX + TPS2(i));  % ita_T enhancement factor
            if Theta_LL(i, j) == XXX
                EHCAP(i, j) = HCD(i) + HCAP(1) * Theta_LL(i, j);
                EHCAP(i, j) = EHCAP(i, j) + (0.448 * RHOV(MN) * 4.182 + HCAP(2)) * Theta_V(i, j) + HCAP(6) * XII; % The Calorie should be converted as i
            else
                ZETA(i, j) = ZETA0(i) + (ZETA(i, j) - ZETA0(i)) * Theta_LL(i, j) / XXX;
                TETCON(i, j) = TCON0(i) + (TETCON(i, j) - TCON0(i)) * Theta_LL(i, j) / XXX;
                EHCAP(i, j) = HCD(i) + HCAP(1) * Theta_LL(i, j);
                EHCAP(i, j) = EHCAP(i, j) + (0.448 * RHOV(MN) * 4.182 + HCAP(2)) * Theta_V(i, j) + HCAP(6) * XII; % The Calorie should be converted as i
            end
            %%%%%%%%%%%%%%%%%% Farouki thermal parameter method %%%%%%%%%%%
            %%%%%%%%%%%%%%%%% change 21 July 2017 switch of thermal conductivity%%%%%%
            if ModelSettings.ThermCond == 4 %|| ThermCond==2
                %             FEHCAP(i,j)=(2.128*Theta_sa(i)+2.385*Theta_cl(i))/(Theta_sa(i)+Theta_cl(i))*1e6;  %i m-3 K-1
                %             TCON_s(i)=(8.8*Theta_sa(i)+2.92*Theta_cl(i))/(Theta_sa(i)+Theta_cl(i)); %  W m-1 K-1
                FFEHCAP(i, j) = (FEHCAP(i) * (1 - POR(i)) + 1000 * 4217.7 * Theta_LL(i, j) + 917 * 2117.27 * XII) * 1e-6; % The Calorie should be converted as i
                EHCAP(i, j) = FFEHCAP(i, j);
            end
            %%%%%%%%%%%%%%%%%% Johansen thermal conductivity method %%%%%%%%%%%
            TCON_qtz = 7.7;
            TCON_o = 2.0;
            TCON_L = 0.57; % Theta_qtz(i)=0.47;     % thermal conductivities of soil quartz, other soil particles and water; unit  W m-1 K-1
            if ModelSettings.ThermCond == 2
                TCON_s(i) = TCON_qtz^(Theta_qtz(i)) * TCON_o^(1 - Theta_qtz(i)); % solid soil thermal conductivity Unit W m-1 K-1
            end
            TCON_i(i) = 2.2;
            %%%%% Peters-Lidard et al. 1998 frozen soil thermal conductivity method %%%%%%%
            Satr(i, j) = (Theta_LL(i, j) + XII) / Theta_s(i);
            if Theta_II(i, j) <= 0
                if Theta_LL(i, j) / POR(i) > 0.1
                    K_e(i, j) = log10(Theta_LL(i, j) / POR(i)) + 1;  % Kersten coefficient, weighting dry and wet thermal conductivity
                elseif Theta_LL(i, j) / POR(i) > 0.05
                    K_e(i, j) = 0.7 * log10(Theta_LL(i, j) / POR(i)) + 1;  % Kersten coefficient, weighting dry and wet thermal conductivity
                else
                    K_e(i, j) = 0;
                end
                Coef_k = 1.9; % [4.6 3.55 1.9; 1.7 0.95 0.85];
                K_e1(i, j) = Coef_k * (Theta_LL(i, j) / POR(i)) / (1 + (Coef_k - 1) * (Theta_LL(i, j) / POR(i)));  % Kersten coefficient, weighting dry and wet thermal conductivity
                ALPHA = 0.9; % [1.05,0.9,0.58];
                K_e2(i, j) = exp(ALPHA * (1 - (Theta_LL(i, j) / POR(i))^(ALPHA - 1.33)));   % Lu and Ren 2007; ALPHA=1.05,0.9,0.58
                TCON_sat(i, j) = TCON_s(i)^(1 - Theta_s(i)) * TCON_L^(Theta_s(i));  % saturated soil thermal conductivity Unit W m-1 K-1
                EfTCON(i, j) = K_e(i, j) * (TCON_sat(i, j) - TCON_dry(i)) + TCON_dry(i);
            else
                K_e(i, j) = (Theta_LL(i, j) + Theta_II(i, j)) / POR(i); % +Theta_II(i,j)
                TCON_sat(i, j) = TCON_s(i)^(1 - Theta_s(i)) * TCON_i(i)^(Theta_s(i) - Theta_LL(i, j)) * TCON_L^(Theta_LL(i, j));  % saturated soil thermal conductivity Unit W m-1 K-1
                EfTCON(i, j) = K_e(i, j) * (TCON_sat(i, j) - TCON_dry(i)) + TCON_dry(i);
            end
        end
    end
