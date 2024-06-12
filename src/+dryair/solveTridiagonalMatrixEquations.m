function [AirMatrices, P_gg, RHS] = solveTridiagonalMatrixEquations(RHS, AirMatrices, GroundwaterSettings)
    %{
        Use Thomas algorithm to solve the tridiagonal matrix equations, which is
        in the form of Equation 4.25 STEMMUS Technical Notes, page 41.
    %}

    ModelSettings = io.getModelSettings();

    if ~GroundwaterSettings.GroundwaterCoupling  % Groundwater Coupling is not activated, added by Mostafa
        indxBotm = 1; % index of bottom layer, by defualt (no groundwater coupling) its layer with index 1, since STEMMUS calcuations starts from bottom to top
    else % Groundwater Coupling is activated
        indxBotm = GroundwaterSettings.indxBotmLayer; % index of bottom boundary layer after neglecting the saturated layers (from bottom to top)
    end

    RHS(indxBotm) = RHS(indxBotm) / AirMatrices.C6(indxBotm, 1);

    for i = indxBotm + 1:ModelSettings.NN
        AirMatrices.C6(i, 1) = AirMatrices.C6(i, 1) - AirMatrices.C6_a(i - 1) * AirMatrices.C6(i - 1, 2) / AirMatrices.C6(i - 1, 1);
        RHS(i) = (RHS(i) - AirMatrices.C6_a(i - 1) * RHS(i - 1)) / AirMatrices.C6(i, 1);
    end

    for i = ModelSettings.NL:-1:indxBotm
        RHS(i) = RHS(i) - AirMatrices.C6(i, 2) * RHS(i + 1) / AirMatrices.C6(i, 1);
    end

    for i = indxBotm:ModelSettings.NN
        P_gg(i) = RHS(i);
    end
end
