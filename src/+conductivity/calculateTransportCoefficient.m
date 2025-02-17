function TransportCoefficient = calculateTransportCoefficient(InitialValues, SoilVariables, VanGenuchten, Delt_t, ModelSettings)
    %{
        This is to calculate the transport coefficient for absorbed liquid flow
        due to temperature gradient.
        Groenevelt, P. H., and B. D. Kay (1974), On the interaction of water and
        heat transport in frozen and unfrozen soils: II. The liquid phase, Soil
        Sci. Soc. Am. Proc., 38, 400-404,
        Zeng, Y., Su, Z., Wan, L. and Wen, i.: Numerical analysis of
        air-water-heat flow in unsaturated soil: Is it necessary to consider
        airflow in land surface models?, i. Geophys. Res. Atmos., 116(D20),
        20107, doi:10.1029/2011JD015835, 2011.
    %}

    % Tortuosity Factor is a reverse of the tortuosity. In "L_WT", tortuosity
    % should be used. That is why "f0" is in the numerator. Note: f0 in L_WT
    % has been changed as 1.5. The Rv in MU_W should be 8.31441 i/mol.K.

    TransportCoefficient.W = InitialValues.W;
    TransportCoefficient.WW = InitialValues.WW;
    TransportCoefficient.MU_W = InitialValues.MU_W;
    TransportCoefficient.D_Ta = InitialValues.D_Ta;

    % load Constants
    Constants = io.define_constants();

    for i = 1:ModelSettings.NL
        for j = 1:ModelSettings.nD
            MN = i + j - 1;
            if ModelSettings.W_Chg == 0
                W = 0;
                WW = 0;
                WARG = SoilVariables.Theta_LL(i, j) * 10^7 / ModelSettings.SSUR;
                if WARG < 80
                    W = Constants.W0 * exp(-WARG);
                    WW = Constants.W0 * exp(-WARG);
                end
            else
                W = -0.2932 * (SoilVariables.h(MN)) / 1000;
                WW = -0.2932 * (SoilVariables.hh(MN)) / 1000;
                if W > 2932
                    W = 2932;
                end
                if WW > 2932
                    WW = 2932;
                end
            end
            f0 = SoilVariables.Theta_g(i, j)^(7 / 3) / VanGenuchten.Theta_s(i)^2;

            % SSUR and RHO_bulk could also be set as an array to consider more
            % than one soil type;
            H_W = Constants.RHOL * WW * (SoilVariables.Theta_LL(i, j) - SoilVariables.Theta_L(i, j)) / ((ModelSettings.SSUR / Constants.RHO_bulk) * Delt_t);
            if SoilVariables.TT(MN) < -20
                MU_W = 3.71e-2;
            elseif SoilVariables.TT(MN) > 150
                MU_W = 1.81e-3;
            else
                MU_W = Constants.MU_W0 * exp(Constants.MU1 / (8.31441 * (SoilVariables.TT(MN) + 133.3)));
            end
            L_WT = f0 * 1e7 * 1.5550e-13 * SoilVariables.POR(i) * H_W / (Constants.b * MU_W);
            if SoilVariables.KLT_Switch == 1
                D_Ta = L_WT / (Constants.RHOL * (SoilVariables.TT(MN) + 273.15));
            else
                D_Ta = 0;
            end
            TransportCoefficient.W(i, j) = W;
            TransportCoefficient.WW(i, j) = WW;
            TransportCoefficient.D_Ta(i, j) = D_Ta;
            TransportCoefficient.MU_W(i, j) = MU_W;
        end
    end
end
