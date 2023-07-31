function [D_V, Eta, D_A] = calculateVaporVariables(InitialValues, SoilVariables, VanGenuchten, ThermalConductivityCapacity, TT)
    %{
        This is to calculate vapor diffusivity, vapor dispersivity, and vapor
        enhancement factor.
        Zeng, Y., Su, Z., Wan, L. and Wen, i.: Numerical analysis of
        air-water-heat flow in unsaturated soil: Is it necessary to consider
        airflow in land surface models?, i. Geophys. Res. Atmos., 116(D20),
        20107, doi:10.1029/2011JD015835, 2011.
        Yu, L., Zeng, Y. and Su, Z.: STEMMUS-UEB v1.0.0: integrated modeling of
        snowpack and soil water and energy transfer with three complexity levels
        of soil physical processes, Geosci. Model Dev, 14, 7345-7376,
        doi:10.5194/gmd-14-7345-2021, 2021.
    %}

    Theta_LL = SoilVariables.Theta_LL;
    Theta_g = SoilVariables.Theta_g;
    POR = SoilVariables.POR;
    XK = SoilVariables.XK;
    Theta_UU = SoilVariables.Theta_UU;
    Theta_s = VanGenuchten.Theta_s;

    D_V = InitialValues.D_V;
    Eta = InitialValues.Eta;
    D_A = InitialValues.D_A;

    % get model settings
    ModelSettings = io.getModelSettings();

    for i = 1:ModelSettings.NL
        for j = 1:ModelSettings.nD
            MN = i + j - 1;
            if ModelSettings.ThmrlCondCap
                if Theta_UU(i, j) < XK(i)
                    EnhnLiqIsland = POR(i);
                else
                    EnhnLiqIsland = Theta_g(i, j) * (1 + Theta_UU(i, j) / (POR(i) - XK(i)));
                end

                f0 = Theta_g(i, j)^(7 / 3) / Theta_s(i)^2;
                D_A(MN) = 0.229 * (1 + TT(MN) / 273)^1.75;

                if SoilVariables.DVT_Switch == 1
                    Eta(i, j) = ThermalConductivityCapacity.ZETA(i, j) * EnhnLiqIsland / (f0 * Theta_g(i, j));
                else
                    Eta(i, j) = 0;
                end
            else
                f0 = Theta_g(i, j)^0.67;
                D_A(MN) = 1e4 * 2.12 * 10^(-5) * (1 + TT(MN) / 273.15)^2;
                Eta(i, j) = 8 + 3 * Theta_LL(i, j) / Theta_s(i) - 7 * exp(-((1 + 2.6 / sqrt(ModelSettings.fc)) * Theta_LL(i, j) / Theta_s(i))^3);
            end
            D_V(i, j) = f0 * Theta_g(i, j) * D_A(MN);
        end
    end
end
