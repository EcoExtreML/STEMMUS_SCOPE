function GasDispersivity = calculateGasDispersivity(InitialValues, SoilVariables, P_gg, k_g)
    %{
        This is to calculate the gas phase longitudinal dispersivity.
        Zeng, Y., Su, Z., Wan, L. and Wen, i.: Numerical analysis of
        air-water-heat flow in unsaturated soil: Is it necessary to consider
        airflow in land surface models?, i. Geophys. Res. Atmos., 116(D20),
        20107, doi:10.1029/2011JD015835, 2011.
    %}

    % get model settings
    ModelSettings = io.getModelSettings();

    % get model constants
    Constants = io.define_constants();

    V_A = InitialValues.V_A;
    D_Vg = InitialValues.D_Vg;
    Beta_g = InitialValues.Beta_g;
    DPgDZ = InitialValues.DPgDZ;
    Alpha_Lg = InitialValues.Alpha_Lg;

    for i = 1:ModelSettings.NL
        for j = 1:ModelSettings.nD
            Sa = 1 - SoilVariables.Se(i, j);
            Beta_g(i, j) = (k_g(i, j) / Constants.MU_a);
            Alpha_Lg(i, j) = 0.078 * (13.6 - 16 * Sa + 3.4 * Sa^5) * 100;
        end

        DPgDZ(i) = (P_gg(i + 1) - P_gg(i)) / ModelSettings.DeltZ(i);
        Alpha_LgBAR(i) = (Alpha_Lg(i, 1) + Alpha_Lg(i, 2)) / 2;

        Beta_gBAR = (Beta_g(i, 1) + Beta_g(i, 2)) / 2;
        V_A(i) = -Beta_gBAR * DPgDZ(i);
        if SoilVariables.KaT_Switch == 1
            D_Vg(i) = Alpha_LgBAR(i) * abs(V_A(i));
        else
            D_Vg(i) = 0;
        end
    end

    GasDispersivity.D_Vg = D_Vg;
    GasDispersivity.V_A = V_A;
    GasDispersivity.Beta_g = Beta_g;
    GasDispersivity.DPgDZ = DPgDZ;
end
