function [RHS, EnergyMatrices, SAVE] = assembleCoefficientMatrices(EnergyMatrices, SoilVariables, Delt_t, P_g, P_gg, GroundwaterSettings)
    %{
        assembles the coefficient matrices of Equation 4.32, STEMMUS Technical
        Notes, page 44, the example was only shown for the soil moisture
        equation, but here it is for the energy equation.
    %}
    C1 = EnergyMatrices.C1;
    C2 = EnergyMatrices.C2;
    C3 = EnergyMatrices.C3;
    C4 = EnergyMatrices.C4;
    C4_a = EnergyMatrices.C4_a;
    C5 = EnergyMatrices.C5;
    C5_a = EnergyMatrices.C5_a;
    C6 = EnergyMatrices.C6;
    C7 = EnergyMatrices.C7;

    ModelSettings = io.getModelSettings();
    n = ModelSettings.NN;

    if ModelSettings.Soilairefc == 1 % see https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/227
        C6_a = EnergyMatrices.C6_a;
    end

    if ~GroundwaterSettings.GroundwaterCoupling  % no Groundwater coupling, added by Mostafa
        indxBotm = 1; % index of bottom layer is 1, STEMMUS calculates from bottom to top
    else % Groundwater Coupling is activated
        % index of bottom layer after neglecting saturated layers (from bottom to top)
        indxBotm = GroundwaterSettings.indxBotmLayer;
    end

    % Alias of SoilVariables
    SV = SoilVariables;

    if ModelSettings.Soilairefc && ModelSettings.Thmrlefc
        RHS(indxBotm) = -C7(indxBotm) + (C2(indxBotm, 1) * SV.T(indxBotm) + C2(indxBotm, 2) * SV.T(indxBotm + 1)) / Delt_t ...
            - (C1(indxBotm, 1) / Delt_t + C4(indxBotm, 1)) * SV.hh(indxBotm) - (C1(indxBotm, 2) / Delt_t + C4(indxBotm, 2)) * SV.hh(indxBotm + 1) ...
            - (C3(indxBotm, 1) / Delt_t + C6(indxBotm, 1)) * P_gg(indxBotm) - (C3(indxBotm, 2) / Delt_t + C6(indxBotm, 2)) * P_gg(indxBotm + 1) ...
            + (C3(indxBotm, 1) / Delt_t) * P_g(indxBotm) + (C3(indxBotm, 2) / Delt_t) * P_g(indxBotm + 1) ...
            + (C1(indxBotm, 1) / Delt_t) * SV.h(indxBotm) + (C1(indxBotm, 2) / Delt_t) * SV.h(indxBotm + 1);

        for i = indxBotm + 1:ModelSettings.NL
            ARG1 = C3(i - 1, 2) / Delt_t;
            ARG2 = C3(i, 1) / Delt_t;
            ARG3 = C3(i, 2) / Delt_t;

            ARG4 = C1(i - 1, 2) / Delt_t;
            ARG5 = C1(i, 1) / Delt_t;
            ARG6 = C1(i, 2) / Delt_t;

            RHS(i) = -C7(i) + (C2(i - 1, 2) * SV.T(i - 1) + C2(i, 1) * SV.T(i) + C2(i, 2) * SV.T(i + 1)) / Delt_t ...
                - (ARG1 + C6_a(i - 1)) * P_gg(i - 1) - (ARG2 + C6(i, 1)) * P_gg(i) - (ARG3 + C6(i, 2)) * P_gg(i + 1) ...
                - (ARG4 + C4_a(i - 1)) * SV.hh(i - 1) - (ARG5 + C4(i, 1)) * SV.hh(i) - (ARG6 + C4(i, 2)) * SV.hh(i + 1) ...
                + ARG1 * P_g(i - 1) + ARG2 * P_g(i) + ARG3 * P_g(i + 1) ...
                + ARG4 * SV.h(i - 1) + ARG5 * SV.h(i) + ARG6 * SV.h(i + 1);
        end

        RHS(n) = -C7(n) + (C2(n - 1, 2) * SV.T(n - 1) + C2(n, 1) * SV.T(n)) / Delt_t ...
            - (C3(n - 1, 2) / Delt_t + C6_a(n - 1)) * P_gg(n - 1) - (C3(n, 1) / Delt_t + C6(n, 1)) * P_gg(n) ...
            - (C1(n - 1, 2) / Delt_t + C4_a(n - 1)) * SV.hh(n - 1) - (C1(n, 1) / Delt_t + C4(n, 1)) * SV.hh(n) ...
            + (C3(n - 1, 2) / Delt_t) * P_g(n - 1) + (C3(n, 1) / Delt_t) * P_g(n) ...
            + (C1(n - 1, 2) / Delt_t) * SV.h(n - 1) + (C1(n, 1) / Delt_t) * SV.h(n);

    elseif ~ModelSettings.Soilairefc && ModelSettings.Thmrlefc
        RHS(indxBotm) = -C7(indxBotm) + (C2(indxBotm, 1) * SV.T(indxBotm) + C2(indxBotm, 2) * SV.T(indxBotm + 1)) / Delt_t ...
            - (C1(indxBotm, 1) / Delt_t + C4(indxBotm, 1)) * SV.hh(indxBotm) - (C1(indxBotm, 2) / Delt_t + C4(indxBotm, 2)) * SV.hh(indxBotm + 1) ...
            + (C1(indxBotm, 1) / Delt_t) * SV.h(indxBotm) + (C1(indxBotm, 2) / Delt_t) * SV.h(indxBotm + 1);
        for i = indxBotm + 1:ModelSettings.NL
            ARG4 = C1(i - 1, 2) / Delt_t;
            ARG5 = C1(i, 1) / Delt_t;
            ARG6 = C1(i, 2) / Delt_t;

            RHS(i) = -C7(i) + (C2(i - 1, 2) * SV.T(i - 1) + C2(i, 1) * SV.T(i) + C2(i, 2) * SV.T(i + 1)) / Delt_t ...
                - (ARG4 + C4(i - 1, 2)) * SV.hh(i - 1) - (ARG5 + C4(i, 1)) * SV.hh(i) - (ARG6 + C4(i, 2)) * SV.hh(i + 1) ...
                + ARG4 * SV.h(i - 1) + ARG5 * SV.h(i) + ARG6 * SV.h(i + 1);
        end

        RHS(n) = -C7(n) + (C2(n - 1, 2) * SV.T(n - 1) + C2(n, 1) * SV.T(n)) / Delt_t ...
            - (C1(n - 1, 2) / Delt_t + C4(n - 1, 2)) * SV.hh(n - 1) - (C1(n, 1) / Delt_t + C4(n, 1)) * SV.hh(n) ...
            + (C1(n - 1, 2) / Delt_t) * SV.h(n - 1) + (C1(n, 1) / Delt_t) * SV.h(n);

    else
        RHS(indxBotm) = -C7(indxBotm) + (C2(indxBotm, 1) * SV.T(indxBotm) + C2(indxBotm, 2) * SV.T(indxBotm + 1)) / Delt_t;
        for i = indxBotm + 1:ModelSettings.NL
            RHS(i) = -C7(i) + (C2(i - 1, 2) * SV.T(i - 1) + C2(i, 1) * SV.T(i) + C2(i, 2) * SV.T(i + 1)) / Delt_t;
        end
        RHS(n) = -C7(n) + (C2(n - 1, 2) * SV.T(n - 1) + C2(n, 1) * SV.T(n)) / Delt_t;
    end

    for i = indxBotm:ModelSettings.NN
        for j = 1:ModelSettings.nD
            C5(i, j) = C2(i, j) / Delt_t + C5(i, j);
        end
    end

    EnergyMatrices.C5 = C5;

    SAVE(1, 1, 2) = RHS(indxBotm);
    SAVE(1, 2, 2) = C5(indxBotm, 1);
    SAVE(1, 3, 2) = C5(indxBotm, 2);
    SAVE(2, 1, 2) = RHS(n);
    SAVE(2, 2, 2) = C5(n - 1, 2);
    SAVE(2, 3, 2) = C5(n, 1);
end
