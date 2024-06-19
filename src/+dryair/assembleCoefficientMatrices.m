function [RHS, AirMatrices, SAVE] = assembleCoefficientMatrices(AirMatrices, SoilVariables, Delt_t, P_g, GroundwaterSettings)
    %{
        Assemble the coefficient matrices of Equation 4.32 STEMMUS Technical
        Notes, page 44, for dry air equation.
    %}

    C1 = AirMatrices.C1;
    C2 = AirMatrices.C2;
    C3 = AirMatrices.C3;
    C4 = AirMatrices.C4;
    C4_a = AirMatrices.C4_a;
    C5 = AirMatrices.C5;
    C5_a = AirMatrices.C5_a;
    C6 = AirMatrices.C6;
    C7 = AirMatrices.C7;

    ModelSettings = io.getModelSettings();
    n = ModelSettings.NN;

    % Alias of SoilVariables
    SV = SoilVariables;

    if ~GroundwaterSettings.GroundwaterCoupling  % Groundwater coupling is not activated
        % index of bottom layer = 1, since STEMMUS calculations start from bottom to top
        indxBotm = 1;
    else % Groundwater Coupling is activated
        % index of bottom boundary layer after neglecting the saturated layers (from bottom to top)
        indxBotm = GroundwaterSettings.indxBotmLayer;
    end

    if ModelSettings.Thmrlefc
        RHS(indxBotm) = -C7(indxBotm) + (C3(indxBotm, 1) * P_g(indxBotm) + C3(indxBotm, 2) * P_g(indxBotm + 1)) / Delt_t ...
            - (C2(indxBotm, 1) / Delt_t + C5(indxBotm, 1)) * SV.TT(indxBotm) - (C2(indxBotm, 2) / Delt_t + C5(indxBotm, 2)) * SV.TT(indxBotm + 1) ...
            - (C1(indxBotm, 1) / Delt_t + C4(indxBotm, 1)) * SV.hh(indxBotm) - (C1(indxBotm, 2) / Delt_t + C4(indxBotm, 2)) * SV.hh(indxBotm + 1) ...
            + (C2(indxBotm, 1) / Delt_t) * SV.T(indxBotm) + (C2(indxBotm, 2) / Delt_t) * SV.T(indxBotm + 1) ...
            + (C1(indxBotm, 1) / Delt_t) * SV.h(indxBotm) + (C1(indxBotm, 2) / Delt_t) * SV.h(indxBotm + 1);

        for i = indxBotm + 1:ModelSettings.NL
            ARG1 = C2(i - 1, 2) / Delt_t;
            ARG2 = C2(i, 1) / Delt_t;
            ARG3 = C2(i, 2) / Delt_t;

            ARG4 = C1(i - 1, 2) / Delt_t;
            ARG5 = C1(i, 1) / Delt_t;
            ARG6 = C1(i, 2) / Delt_t;

            RHS(i) = -C7(i) + (C3(i - 1, 2) * P_g(i - 1) + C3(i, 1) * P_g(i) + C3(i, 2) * P_g(i + 1)) / Delt_t ...
                - (ARG1 + C5_a(i - 1)) * SV.TT(i - 1) - (ARG2 + C5(i, 1)) * SV.TT(i) - (ARG3 + C5(i, 2)) * SV.TT(i + 1) ...
                - (ARG4 + C4_a(i - 1)) * SV.hh(i - 1) - (ARG5 + C4(i, 1)) * SV.hh(i) - (ARG6 + C4(i, 2)) * SV.hh(i + 1) ...
                + ARG1 * SV.T(i - 1) + ARG2 * SV.T(i) + ARG3 * SV.T(i + 1) ...
                + ARG4 * SV.h(i - 1) + ARG5 * SV.h(i) + ARG6 * SV.h(i + 1);
        end

        RHS(n) = -C7(n) + (C3(n - 1, 2) * P_g(n - 1) + C3(n, 1) * P_g(n)) / Delt_t ...
            - (C2(n - 1, 2) / Delt_t + C5_a(n - 1)) * SV.TT(n - 1) - (C2(n, 1) / Delt_t + C5(n, 1)) * SV.TT(n) ...
            - (C1(n - 1, 2) / Delt_t + C4_a(n - 1)) * SV.hh(n - 1) - (C1(n, 1) / Delt_t + C4(n, 1)) * SV.hh(n) ...
            + (C2(n - 1, 2) / Delt_t) * SV.T(n - 1) + (C2(n, 1) / Delt_t) * SV.T(n) ...
            + (C1(n - 1, 2) / Delt_t) * SV.h(n - 1) + (C1(n, 1) / Delt_t) * SV.h(n);
    else
        RHS(indxBotm) = -C7(indxBotm) + (C3(indxBotm, 1) * P_g(indxBotm) + C3(indxBotm, 2) * P_g(indxBotm + 1)) / Delt_t ...
            - (C1(indxBotm, 1) / Delt_t + C4(indxBotm, 1)) * SV.hh(indxBotm) - (C1(indxBotm, 2) / Delt_t + C4(indxBotm, 2)) * SV.hh(indxBotm + 1) ...
            + (C1(indxBotm, 1) / Delt_t) * SV.h(indxBotm) + (C1(indxBotm, 2) / Delt_t) * SV.h(indxBotm + 1);
        for i = indxBotm + 1:ModelSettings.NL
            ARG4 = C1(i - 1, 2) / Delt_t;
            ARG5 = C1(i, 1) / Delt_t;
            ARG6 = C1(i, 2) / Delt_t;
            RHS(i) = -C7(i) + (C3(i - 1, 2) * P_g(i - 1) + C3(i, 1) * P_g(i) + C3(i, 2) * P_g(i + 1)) / Delt_t ...
                - (ARG4 + C4(i - 1, 2)) * SV.hh(i - 1) - (ARG5 + C4(i, 1)) * SV.hh(i) - (ARG6 + C4(i, 2)) * SV.hh(i + 1) ...
                + ARG4 * SV.h(i - 1) + ARG5 * SV.h(i) + ARG6 * SV.h(i + 1);
        end
        RHS(n) = -C7(n) + (C3(n - 1, 2) * P_g(n - 1) + C3(n, 1) * P_g(n)) / Delt_t ...
            - (C1(n - 1, 2) / Delt_t + C4(n - 1, 2)) * SV.hh(n - 1) - (C1(n, 1) / Delt_t + C4(n, 1)) * SV.hh(n) ...
            + (C1(n - 1, 2) / Delt_t) * SV.h(n - 1) + (C1(n, 1) / Delt_t) * SV.h(n);
    end

    for i = indxBotm:ModelSettings.NN
        for j = 1:ModelSettings.nD
            C6(i, j) = C3(i, j) / Delt_t + C6(i, j);
        end
    end

    AirMatrices.C6 = C6;

    SAVE(1, 1, 3) = RHS(indxBotm);
    SAVE(1, 2, 3) = C6(indxBotm, 1);
    SAVE(1, 3, 3) = C6(indxBotm, 2);
    SAVE(2, 1, 3) = RHS(n);
    SAVE(2, 2, 3) = C6(n - 1, 2);
    SAVE(2, 3, 3) = C6(n, 1);
end
