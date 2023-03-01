function ThermalConductivity = calculateInitialThermal(SoilConstants, SoilVariables, VanGenuchten)
    FEHCAP = []; % see issue 139

    HCAP(1) = 0.998 * 4.182;
    HCAP(2) = 0.0003 * 4.182;
    HCAP(3) = 0.46 * 4.182;
    HCAP(4) = 0.46 * 4.182;
    HCAP(5) = 0.6 * 4.182;
    HCAP(6) = 0.45 * 4.182;

    TCON(1) = 1.37e-3 * 4.182;
    TCON(2) = 6e-5 * 4.182;
    TCON(3) = 2.1e-2 * 4.182;
    TCON(4) = 7e-3 * 4.182;
    TCON(5) = 6e-4 * 4.182;
    TCON(6) = 5.2e-3 * 4.182;

    SF(1) = 0;
    SF(2) = 0;
    SF(3) = 0.125;
    SF(4) = 0.125;
    SF(5) = 0.5;
    SF(6) = 0.125;
    TCA = 6e-5 * 4.182;
    GA1 = 0.035;
    GA2 = 0.013;

    % Sum over all phases of dry porous media to find the dry heat capacity
    for j = 1:SoilConstants.totalNumberOfElements % NL
        % and the sums in the dry thermal conductivity;
        S1(j) = SoilVariables.POR(j) * TCA;
        S2(j) = SoilVariables.POR(j);
        HCD(j) = 0;
        SoilVariables.VPERCD(j, 1) = SoilVariables.VPER(j, 1) * (1 - SoilVariables.XSOC(j));
        SoilVariables.VPERCD(j, 2) = (SoilVariables.VPER(j, 2) + SoilVariables.VPER(j, 3)) * (1 - SoilVariables.XSOC(j));
        SoilVariables.VPERCD(j, 3) = SoilVariables.XSOC(j) * (1 - SoilVariables.POR(j)); %
        for i = 3:5
            TARG1 = TCON(i) / TCA - 1;
            GRAT = 0.667 / (1 + TARG1 * SF(i)) + 0.333 / (1 + TARG1 * (1 - 2 * SF(i)));
            S1(j) = S1(j) + GRAT * TCON(i) * SoilVariables.VPERCD(j, i - 2);
            S2(j) = S2(j) + GRAT * SoilVariables.VPERCD(j, i - 2);
            HCD(j) = HCD(j) + HCAP(i) * SoilVariables.VPERCD(j, i - 2);
        end
        ZETA0(j) = 1 / S2(j);
        CON0(j) = 1.25 * S1(j) / S2(j);
        PS1(j) = 0;
        PS2(j) = 0;
        for i = 3:5
            TARG2 = TCON(i) / TCON(1) - 1;
            GRAT = 0.667 / (1 + TARG2 * SF(i)) + 0.333 / (1 + TARG2 * (1 - 2 * SF(i)));
            TERM = GRAT * SoilVariables.VPERCD(j, i - 2);
            PS1(j) = PS1(j) + TERM * TCON(i);
            PS2(j) = PS2(j) + TERM;
        end
        GB1(j) = 0.298 / SoilVariables.POR(j);
        GB2(j) = (GA1 - GA2) / SoilVariables.XWILT(j) + GB1(j);

        %%%%%%%% Johansen thermal conductivity method %%%%%%%
        RHo_bulk(j) = (1 - VanGenuchten.Theta_s(j)) * 2.7 * 1000;         % Unit g.cm^-3
        TCON_dry(j) = (0.135 * RHo_bulk(j) + 64.7) / (2700 - 0.947 * RHo_bulk(j));   % Unit W m-1 K-1 ==> j cm^-1 s^-1 Cels^-1

        %%%%%%%% organic thermal conductivity method %%%%%%%
        TCON_Soc = 0.05;
        TCON_dry(j) = TCON_dry(j) * (1 - SoilVariables.XSOC(j)) + SoilVariables.XSOC(j) * TCON_Soc;

        TCON_qtz = 7.7;
        TCON_o = 2.0;
        TCON_L = 0.57; % thermal conductivities of soil quartz, other soil particles and water; unit  W m-1 K-1
        TCON_s(j) = TCON_qtz^(SoilVariables.Theta_qtz(j)) * TCON_o^(1 - SoilVariables.Theta_qtz(j)); % Johansen solid soil thermal conductivity Unit W m-1 K-1
        TCON_sa = 7.7;
        Theta_sa(j) = SoilVariables.VPER(j, 1) / (1 - SoilVariables.POR(j));
        TCON_slt = 2.74;
        Theta_slt(j) = SoilVariables.VPER(j, 2) / (1 - SoilVariables.POR(j));
        TCON_cl = 1.93;
        Theta_cl(j) = SoilVariables.VPER(j, 3) / (1 - SoilVariables.POR(j)); % thermal conductivities of soil sand, silt and clay, unit  W m-1 K-1
        SF_sa = 0.182;
        SF_slt = 0.0534;
        SF_cl = 0.00775;
        TCON_min(j) = (TCON_sa^(Theta_sa(j)) * TCON_slt^(Theta_slt(j)) * TCON_cl^(Theta_cl(j))) / 100;
        SF_min(j) = SF_sa * Theta_sa(j) + SF_slt * Theta_slt(j) + SF_cl * Theta_cl(j);
        TS1(j) = SoilVariables.POR(j) * TCA;  % and the sums in the dry thermal conductivity;
        TS2(j) = SoilVariables.POR(j);
        TTARG1(j) = TCON_min(j) / TCA - 1;
        TGRAT(j) = 0.667 / (1 + TTARG1(j) * SF_min(j)) + 0.333 / (1 + TTARG1(j) * (1 - 2 * SF_min(j)));
        TS1(j) = TS1(j) + TGRAT(j) * TCON_min(j) * (1 - SoilVariables.POR(j));
        TS2(j) = TS2(j) + TGRAT(j) * (1 - SoilVariables.POR(j));
        TZETA0(j) = 1 / TS2(j);
        TCON0(j) = 1.25 * TS1(j) / TS2(j); % dry thermal conductivity
        TPS1(j) = 0;
        TPS2(j) = 0;
        TTARG2(j) = TCON_min(j) / TCON(1) - 1;
        TGRAT(j) = 0.667 / (1 + TTARG2(j) * SF_min(j)) + 0.333 / (1 + TTARG2(j) * (1 - 2 * SF_min(j)));
        TTERM(j) = TGRAT(j) * (1 - SoilVariables.POR(j));
        TPS1(j) = TPS1(j) + TTERM(j) * TCON_min(j);
        TPS2(j) = TPS2(j) + TTERM(j);

        % Farouki thermal parameter method
        if SoilConstants.ThermCond == 4
            FEHCAP(j) = (2.128 * Theta_sa(j) + 2.385 * Theta_cl(j)) / (Theta_sa(j) + Theta_cl(j)) * 1e6;  % j m-3 K-1
            FEHCAP(j) = FEHCAP(j) * (1 - SoilVariables.XSOC(j)) + SoilVariables.XSOC(j) * 2.5 * 1e6;  % organic effect j m-3 K-1
            TCON_s(j) = (8.8 * Theta_sa(j) + 2.92 * Theta_cl(j)) / (Theta_sa(j) + Theta_cl(j)); % W m-1 K-1
            TCON_s(j) = TCON_s(j) * (1 - SoilVariables.XSOC(j)) + SoilVariables.XSOC(j) * 0.25;  % consider organic effect W m-1 K-1
        end
    end

    ThermalConductivity.HCAP = HCAP;
    ThermalConductivity.SF = SF;
    ThermalConductivity.TCA = TCA;
    ThermalConductivity.GA1 = GA1;
    ThermalConductivity.GA2 = GA2;
    ThermalConductivity.GB1 = GB1;
    ThermalConductivity.GB2 = GB2;
    ThermalConductivity.RHo_bulk = RHo_bulk;
    ThermalConductivity.TCON_dry = TCON_dry;
    ThermalConductivity.S1 = S1;
    ThermalConductivity.S2 = S2;
    ThermalConductivity.HCD = HCD;
    ThermalConductivity.TCON0 = TCON0;
    ThermalConductivity.ZETA0 = ZETA0;
    ThermalConductivity.CON0 = CON0;
    ThermalConductivity.PS1 = PS1;
    ThermalConductivity.PS2 = PS2;
    ThermalConductivity.TCON_s = TCON_s;
    ThermalConductivity.TPS1 = TPS1;
    ThermalConductivity.TPS2 = TPS2;
    ThermalConductivity.FEHCAP = FEHCAP;

end
