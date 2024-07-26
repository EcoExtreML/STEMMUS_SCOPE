function [SoilVariables, CHK, RHS, EnergyMatrices] = solveTridiagonalMatrixEquations(EnergyMatrices, SoilVariables, RHS, CHK, ModelSettings, GroundwaterSettings)
    %{
        Use Thomas algorithm to solve the tridiagonal matrix equations, which
        is in the form of Equation 4.25, STEMMUS Technical Notes, page 41.
    %}

    if ~GroundwaterSettings.GroundwaterCoupling  % no Groundwater coupling, added by Mostafa
        indxBotm = 1; % index of bottom layer is 1, STEMMUS calculates from bottom to top
    else % Groundwater Coupling is activated
        % index of bottom layer after neglecting saturated layers (from bottom to top)
        indxBotm = GroundwaterSettings.indxBotmLayer;
    end

    RHS(indxBotm) = RHS(indxBotm) / EnergyMatrices.C5(indxBotm, 1);

    for i = indxBotm + 1:ModelSettings.NN
        EnergyMatrices.C5(i, 1) = EnergyMatrices.C5(i, 1) - EnergyMatrices.C5_a(i - 1) * EnergyMatrices.C5(i - 1, 2) / EnergyMatrices.C5(i - 1, 1);
        RHS(i) = (RHS(i) - EnergyMatrices.C5_a(i - 1) * RHS(i - 1)) / EnergyMatrices.C5(i, 1);
    end

    for i = ModelSettings.NL:-1:indxBotm
        RHS(i) = RHS(i) - EnergyMatrices.C5(i, 2) * RHS(i + 1) / EnergyMatrices.C5(i, 1);
    end

    if GroundwaterSettings.GroundwaterCoupling
        for i = indxBotm:-1:2
            RHS(i - 1) = RHS(i); % assign the groundwater temperature to the saturated layers
        end
        % correct soil temp above groundwater table (avoid wrong temp behaviour in case RHS(indxBotm) > RHS(indxBotm + 1))
        % RHS(indxBotm + 1) = (RHS(indxBotm) + RHS(indxBotm + 2)) / 2;
    end

    for i = 1:ModelSettings.NN
        CHK(i) = abs(RHS(i) - SoilVariables.TT(i));
        SoilVariables.TT(i) = RHS(i);
    end
end
