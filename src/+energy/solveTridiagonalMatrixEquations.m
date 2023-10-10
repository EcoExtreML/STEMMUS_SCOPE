function [SoilVariables, CHK, RHS, EnergyMatrices] = solveTridiagonalMatrixEquations(EnergyMatrices, SoilVariables, RHS, CHK)
    %{
        Use Thomas algorithm to solve the tridiagonal matrix equations, which
        is in the form of Equation 4.25, STEMMUS Technical Notes, page 41.
    %}

    ModelSettings = io.getModelSettings();
    RHS(1) = RHS(1) / EnergyMatrices.C5(1, 1);

    for i = 2:ModelSettings.NN
        EnergyMatrices.C5(i, 1) = EnergyMatrices.C5(i, 1) - EnergyMatrices.C5_a(i - 1) * EnergyMatrices.C5(i - 1, 2) / EnergyMatrices.C5(i - 1, 1);
        RHS(i) = (RHS(i) - EnergyMatrices.C5_a(i - 1) * RHS(i - 1)) / EnergyMatrices.C5(i, 1);
    end

    for i = ModelSettings.NL:-1:1
        RHS(i) = RHS(i) - EnergyMatrices.C5(i, 2) * RHS(i + 1) / EnergyMatrices.C5(i, 1);
    end

    for i = 1:ModelSettings.NN
        CHK(i) = abs(RHS(i) - SoilVariables.TT(i));
        SoilVariables.TT(i) = RHS(i);
    end
end
