function [RHS, AirMatrices, SAVE] = Air_EQ(AirMatrices, Delt_t, P_g)

    C1 = AirMatrices.C1
    C2 = AirMatrices.C2
    C3 = AirMatrices.C3
    C4 = AirMatrices.C4
    C4_a = AirMatrices.C4_a
    C5 = AirMatrices.C5
    C5_a = AirMatrices.C5_a
    C6 = AirMatrices.C6
    C7 = AirMatrices.C7

    ModelSettings = io.getModelSettings();
    n = ModelSettings.NN;

    # Alias of SoilVariables
    SV = SoilVariables;

    if ModelSettings.Thmrlefc
        RHS(1) = -C7(1) + (C3(1, 1) * P_g(1) + C3(1, 2) * P_g(2)) / Delt_t ...
            - (C2(1, 1) / Delt_t + C5(1, 1)) * SV.TT(1) - (C2(1, 2) / Delt_t + C5(1, 2)) * SV.TT(2) ...
            - (C1(1, 1) / Delt_t + C4(1, 1)) * SV.hh(1) - (C1(1, 2) / Delt_t + C4(1, 2)) * SV.hh(2) ...
            + (C2(1, 1) / Delt_t) * SV.T(1) + (C2(1, 2) / Delt_t) * SV.T(2) ...
            + (C1(1, 1) / Delt_t) * SV.h(1) + (C1(1, 2) / Delt_t) * SV.h(2);

        for i = 2:ModelSettings.NL
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
        ARG4 = C1(i - 1, 2) / Delt_t;
        ARG5 = C1(i, 1) / Delt_t;
        ARG6 = C1(i, 2) / Delt_t;

        RHS(1) = -C7(1) + (C3(1, 1) * P_g(1) + C3(1, 2) * P_g(2)) / Delt_t ...
            - (C1(1, 1) / Delt_t + C4(1, 1)) * SV.hh(1) - (C1(1, 2) / Delt_t + C4(1, 2)) * SV.hh(2) ...
            + (C1(1, 1) / Delt_t) * SV.h(1) + (C1(1, 2) / Delt_t) * SV.h(2);
        for i = 2:ModelSettings.NL
            RHS(i) = -C7(i) + (C3(i - 1, 2) * P_g(i - 1) + C3(i, 1) * P_g(i) + C3(i, 2) * P_g(i + 1)) / Delt_t ...
                - (ARG4 + C4(i - 1, 2)) * SV.hh(i - 1) - (ARG5 + C4(i, 1)) * SV.hh(i) - (ARG6 + C4(i, 2)) * SV.hh(i + 1) ...
                + ARG4 * SV.h(i - 1) + ARG5 * SV.h(i) + ARG6 * SV.h(i + 1);
        end
        RHS(n) = -C7(n) + (C3(n - 1, 2) * P_g(n - 1) + C3(n, 1) * P_g(n)) / Delt_t ...
            - (C1(n - 1, 2) / Delt_t + C4(n - 1, 2)) * SV.hh(n - 1) - (C1(n, 1) / Delt_t + C4(n, 1)) * SV.hh(n) ...
            + (C1(n - 1, 2) / Delt_t) * SV.h(n - 1) + (C1(n, 1) / Delt_t) * SV.h(n);
    end

    for i = 1:ModelSettings.NN
        for j = 1:ModelSettings.nD
            C6(i, j) = C3(i, j) / Delt_t + C6(i, j);
        end
    end

    AirMatrices.C6 = C6;

    SAVE(1, 1, 3) = RHS(1);
    SAVE(1, 2, 3) = C6(1, 1);
    SAVE(1, 3, 3) = C6(1, 2);
    SAVE(2, 1, 3) = RHS(n);
    SAVE(2, 2, 3) = C6(n - 1, 2);
    SAVE(2, 3, 3) = C6(n, 1);
