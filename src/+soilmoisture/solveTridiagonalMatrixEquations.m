function [CHK, hh, C4] = hh_Solve(C4, hh, C4_a, RHS)
    ModelSettings = io.getModelSettings();

    RHS(1) = RHS(1) / C4(1, 1);

    for i = 2:ModelSettings.NN
        C4(i, 1) = C4(i, 1) - C4_a(i - 1) * C4(i - 1, 2) / C4(i - 1, 1);
        RHS(i) = (RHS(i) - C4_a(i - 1) * RHS(i - 1)) / C4(i, 1);
    end

    for i = ModelSettings.NL:-1:1
        RHS(i) = RHS(i) - C4(i, 2) * RHS(i + 1) / C4(i, 1);
    end
    for i = 1:ModelSettings.NN
        CHK(i) = abs(RHS(i) - hh(i));
        hh(i) = RHS(i);
        SAVEhh(i) = hh(i);
    end

    if isnan(SAVEhh) == 1 || ~isreal(SAVEhh)
        warning('\n SAVEhh == 1 or not real\r');
    end
end
