function [Rn_SOIL, Evap, EVAP, Trap, r_a_SOIL, Srt, RWUs, RWUg] = calculateEvapotranspiration(InitialValues, ForcingData, SoilVariables, KT, RWU, fluxes, Srt, GroundwaterSettings)

    ModelSettings = io.getModelSettings();

    if ~GroundwaterSettings.GroundwaterCoupling  % no Groundwater coupling, added by Mostafa
        indxBotm = 1; % index of bottom layer is 1, STEMMUS calculates from bottom to top
    else % Groundwater Coupling is activated
        % index of bottom layer after neglecting saturated layers (from bottom to top)
        indxBotm = GroundwaterSettings.indxBotmLayer;
    end

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

    % Calculate root water uptake from soil water (RWUs) and groundwater (RWUg)
    RWU = RWU * 100; % unit conversion from m/sec to cm/sec
    if GroundwaterSettings.GroundwaterCoupling == 1
        RWUs = sum(RWU(indxBotm:ModelSettings.NL));
        RWUg = sum(RWU(1:indxBotm - 1));
    else
        RWUs = sum(RWU(1:ModelSettings.NL));
        RWUg = 0;
    end
end
