function Trap_1 = calculateTrap_1(Tp_t, bx, alpha_h, TT)

    ModelSettings = io.getModelSettings();

    Trap_1 = 0;
    for i = 1:ModelSettings.NL
        for j = 1:ModelSettings.nD
            Srt_1(i, j) = alpha_h(i, j) * bx(i, j) * Tp_t;
            if TT(i) < 0
                Srt_1(i:ModelSettings.NL, j) = 0;
            end
        end
        % root water uptake integration by DeltZ;
        Trap_1 = Trap_1 + (Srt_1(i, 1) + Srt_1(i, 2)) / 2 * ModelSettings.DeltZ(i);
    end
end