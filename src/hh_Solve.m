function [CHK, hh, C4, SAVEhh] = hh_Solve(C4, hh, NN, NL, C4_a, RHS)

    TTheta_UU = zeros(NL + 1, 2);
    hdry(1:NN) = -5e5;
    hwet(1:NN) = -1;
    DTTheta_UU = zeros(NL + 1, 2);
    TGama_hh = zeros(NL + 1, 1);
    TTheta_m = zeros(NL, 1);
    RHS(1) = RHS(1) / C4(1, 1);
    SAVDTheta_LLh = zeros(NL + 1, 2);
    INDICATOR = 0;

    for ML = 2:NN
        C4(ML, 1) = C4(ML, 1) - C4_a(ML - 1) * C4(ML - 1, 2) / C4(ML - 1, 1);
        RHS(ML) = (RHS(ML) - C4_a(ML - 1) * RHS(ML - 1)) / C4(ML, 1);
    end

    for ML = NL:-1:1
        RHS(ML) = RHS(ML) - C4(ML, 2) * RHS(ML + 1) / C4(ML, 1);
    end
    for MN = 1:NN
        CHK(MN) = abs(RHS(MN) - hh(MN));
        hh(MN) = RHS(MN);
        SAVEhh(MN) = hh(MN);
    end

    if isnan(SAVEhh) == 1
        warning('\n Warning: FIX warning message \r');
    end
    if ~isreal(SAVEhh)
        warning('\n Warning: FIX warning message \r');
    end
