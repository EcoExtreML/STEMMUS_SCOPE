function [AirMatrices, P_gg, RHS] = Air_Solve(RHS, AirMatrices)

    ModelSettings = io.getModelSettings();
    RHS(1) = RHS(1) / AirMatrices.C6(1, 1);

    for i = 2:ModelSettings.NN
        AirMatrices.C6(i, 1) = AirMatrices.C6(i, 1) - AirMatrices.C6_a(i - 1) * AirMatrices.C6(i - 1, 2) / AirMatrices.C6(i - 1, 1);
        RHS(i) = (RHS(i) - AirMatrices.C6_a(i - 1) * RHS(i - 1)) / AirMatrices.C6(i, 1);
    end

    for i = ModelSettings.NL:-1:1
        RHS(i) = RHS(i) - AirMatrices.C6(i, 2) * RHS(i + 1) / AirMatrices.C6(i, 1);
    end

    for i = 1:ModelSettings.NN
        P_gg(i) = RHS(i);
    end
