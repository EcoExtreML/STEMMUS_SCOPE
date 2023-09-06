function [Rn_SOIL, Evap, EVAP, Trap, r_a_SOIL, Srt] = calculateEvapotranspiration(InitialValues, ForcingData, SoilVariables, KT, RWU, fluxes, Srt)

    ModelSettings = io.getModelSettings();

    Rn = (ForcingData.Rn_msr(KT)) * 8.64 / 24 / 100 * 1;
    Rn_SOIL = Rn * 0.68;

    % calculate Aerodynamic Resistance
    U = 100 .* (ForcingData.WS_msr(KT));
    AR = soilmoisture.calculateAerodynamicResistance(U);
    r_a_SOIL = AR.soil;

    Ta = ForcingData.Ta_msr(KT);
    Evap = InitialValues.Evap;
    EVAP = InitialValues.EVAP;

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

    for i = 1:ModelSettings.NL
        for j = 1:ModelSettings.nD
            Srt(i, j) = Srt1(i, 1);
        end
    end
    Trap(KT) = Tp_t;   % root water uptake integration by ModelSettings.DeltZ;
end
