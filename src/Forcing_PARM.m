function InterpolateForcingData(ForcingData, SoilData)
    %{
        Reconstruct the driving forces e.g. Ta, RH, Wind, Pressure,
        precipitation, etc. to be a continuous function of time via Fourier
        transformation, e.g. through identifying the dominant frequency etc.
    %}

    global Rn TIMEOLD DELT Precip Gvc Tss
    global Ta Ts U HR_a SH Rns Rnl KT P_Va RHOV_A Rv TopPg h_SUR NBCT

    if TIMEOLD == KT
        Ta(KT) = 0;
        HR_a(KT) = 0;
        Ts(KT) = 0;
        U(KT) = 0;
        SH(KT) = 0;
        Rns(KT) = 0;
        Rnl(KT) = 0;
        Rn(KT) = 0;
        TopPg(KT) = 0;
        h_SUR(KT) = 0;
    end
    if NBCT == 1 && KT == 1
        Ts(1) = 0;
    end

    ForcingData.WS_msr(ForcingData.WS_msr < 0.05) = 0.05;
    Ta(KT) = ForcingData.Ta_msr(KT);
    HR_a(KT) = 0.01 .* (ForcingData.RH_msr(KT));
    U(KT) = 100 .* (ForcingData.WS_msr(KT));
    Rns(KT) = (ForcingData.Rns_msr(KT)) * 8.64 / 24 / 100 * 1;
    TopPg(KT) = 100 .* (ForcingData.Pg_msr(KT));
    Ts(KT) = SoilData.Tss;
    Rn(KT) = (ForcingData.Rn_msr(KT)) * 8.64 / 24 / 100 * 1;
    Precip(KT) = ForcingData.Precip_msr(KT) * 0.1 / DELT;
    Gvc(KT) = ForcingData.LAI_msr(KT);

    % The atmospheric vapor pressure (KPa)  (1000Pa=1000.1000.g.100^-1.cm^-1.s^-2)
    P_Va(KT) = 0.611 * exp(17.27 * Ta(KT) / (Ta(KT) + 237.3)) * HR_a(KT);

    RHOV_A(KT) = P_Va(KT) * 1e4 / (Rv * (Ta(KT) + 273.15));

end