function [Rn_SOIL, Evap, EVAP, Trap, r_a_SOIL, Srt] = calculateEvapotranspiration(InitialValues, ForcingData, SoilVariables, KT, RWU, fluxes, Srt)
    % TODO issue if TIME <= 1800 * 3600 Rn_SOIL(KT) = Rn(KT) * 0.68;
    % TODO issue if KT <= 1047 r_s_SOIL = 10.0 * exp(0.3563 * 100.0 * (0.2050 - Theta_LL_sur))
    % TODO issue Evap and EVAP and Evapo (unused)
    % TODO issue Trap and trap (unused)

    Rn_SOIL = InitialValues.Rn_SOIL;
    Evap = InitialValues.Evap;
    EVAP = InitialValues.EVAP;

    Constants = io.define_constants();
    ModelSettings = io.getModelSettings();

    % Calculate Air parameters
    % TODO issue Z is hardcoded!
    Z = 3421;  % altitute of the location(m)
    HR_a = 0.01 .* (ForcingData.RH_msr(KT));
    Ta = ForcingData.Ta_msr(KT);
    Ts = SoilVariables.Tss(KT);
    % TODO fix function name
    AirParameters = h_func.calculateAirParameters(Ta, Ts, HR_a, Z);
    DELTA = AirParameters.delta;
    ro_a = AirParameters.ro_a;
    e_a = AirParameters.e_a;
    gama = AirParameters.gama;
    e0_Ta = AirParameters.e0_Ta;

    Rn = (ForcingData.Rn_msr(KT)) * 8.64 / 24 / 100 * 1;
    Rn_SOIL = Rn * 0.68;

    %% SURFACE RESISTANCE PARAMETERS CALCULATION
    LAI = ForcingData.LAI_msr(KT);
    Theta_LL = SoilVariables.Theta_LL(ModelSettings.NL, 2);
    SR = h_func.calculateSurfaceResistance(Rn, LAI, Theta_LL);

    % calculate Aerodynamic Resistance
    U = 100 .* (ForcingData.WS_msr(KT));
    AR = h_func.calculateAerodynamicResistance(U);
    r_a_SOIL = AR.soil;

    % PT/PE - Penman-Montheith mm.day-1, FAO56 pag19 eq3
    PT_PM_VEG = (DELTA * Rn + 3600 * ro_a * Constants.cp_specific * (e0_Ta - e_a) / AR.vegetation) / (Constants.lambdav * (DELTA + gama * (1 + SR.vegetation / AR.vegetation))) / 3600;

    if LAI == 0
        PT_PM_VEG = 0;
    end

    PE_PM_SOIL = (DELTA * Rn_SOIL + 3600 * ro_a * Constants.cp_specific * (e0_Ta - e_a) / AR.soil) / (Constants.lambdav * (DELTA + gama * (1 + SR.soil / AR.soil))) / 3600;
    Evap(KT) = 0.1 * PE_PM_SOIL; % transfer to second value-G_SOIL(KT)
    EVAP(KT, 1) = Evap(KT);
    Tp_t = 0.1 * PT_PM_VEG; % transfer to second value

    if ModelSettings.rwuef == 1
        % TODO issue unused code below to calculate Trap(KT)
        % calculate alpha_h
        alpha_h =  h_func.calculateAlpha_h(KT, Tp_t, SoilVariables.hh);

        % calculate bx
        bx =  h_func.calculateBx(InitialValues);

        % root zone water uptake
        % calculate Trap_1
        Trap_1 =  h_func.calculateTrap_1(Tp_t, bx, alpha_h, SoilVariables.TT);

        % consideration of water compensation effect
        if Tp_t == 0
            Trap(KT) = 0;
        else
            wt = Trap_1 / Tp_t;
            wc = 1; % compensation coefficient
            Trap(KT) = 0;
            for i = 1:ModelSettings.NL
                for j = 1:ModelSettings.nD
                    if wt < wc
                        Srt(i, j) = alpha_h(i, j) * bx(i, j) * Tp_t / wc;
                        if SoilVariables.TT(i) < 0
                            Srt(i:ModelSettings.NL, j) = 0;
                        end
                    else
                        Srt(i, j) = alpha_h(i, j) * bx(i, j) * Tp_t / wt;
                    end
                end
                % root water uptake integration by ModelSettings.DeltZ;
                Trap(KT) = Trap(KT) + (Srt(i, 1) + Srt(i, 2)) / 2 * ModelSettings.DeltZ(i);
            end
        end
    end
    if fluxes.lEctot < 1000 && fluxes.lEstot < 800 && fluxes.lEctot > -300 && fluxes.lEstot > -300 && any(SoilVariables.TT > 5)
        lambda1      = (2.501 - 0.002361 * Ta) * 1E6;
        lambda2      = (2.501 - 0.002361 * SoilVariables.Tss(KT)) * 1E6;
        Evap(KT) = fluxes.lEstot / lambda2 * 0.1; % transfer to second value unit: cm s-1
        EVAP(KT, 1) = Evap(KT);
        Tp_t = fluxes.lEctot / lambda1 * 0.1; % transfer to second value
        Srt1 = RWU * 100 ./ ModelSettings.DeltZ';
    else
        Evap(KT) = 0; % transfer to second value unit: cm s-1
        EVAP(KT, 1) = Evap(KT);
        Tp_t = 0; % transfer to second value
        Srt1 = 0 ./ ModelSettings.DeltZ';
    end
    % TODO issue values of Srt and Trap are replaced by new calculations!
    for i = 1:ModelSettings.NL
        for j = 1:ModelSettings.nD
            Srt(i, j) = Srt1(i, 1);
        end
    end
    Trap(KT) = Tp_t;   % root water uptake integration by ModelSettings.DeltZ;
end
