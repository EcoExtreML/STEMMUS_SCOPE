function k_g = calculateGasConductivity(InitialValues, TransportCoefficient, VanGenuchten, SoilVariables, ModelSettings)
    %{
        This is to calculate the intrinsic permeability of soil for gas flow.
        Scanlon, B. R. (2000), Soil gas movement in unsaturated systems, in
        Handbook of Soil Science, edited by M. E. Sumner, pp. A277-A319, CRC
        Press, Boca Raton, Fla.
        Zeng, Y., Su, Z., Wan, L. and Wen, i.: Numerical analysis of
        air-water-heat flow in unsaturated soil: Is it necessary to consider
        airflow in land surface models?, i. Geophys. Res. Atmos., 116(D20),
        20107, doi:10.1029/2011JD015835, 2011.
    %}

    % load Constants
    Constants = io.define_constants();

    k_g = InitialValues.k_g;
    m = VanGenuchten.m;

    for i = 1:ModelSettings.NL
        for j = 1:ModelSettings.nD
            MN = i + j - 1;
            Sa = SoilVariables.Theta_g(i, j) / SoilVariables.POR(i);
            if ModelSettings.SWCC == 1
                k_g(i, j) = SoilVariables.Ks(i) * TransportCoefficient.MU_W(i, j) * (1 - Sa^0.5) * (1 - (1 - (1 - Sa^(1 / m(i))))^m(i))^2 / (Constants.g * Constants.RHOL);
            else
                k_g(i, j) = 0;
            end
            if ModelSettings.Soilairefc == 1
                k_g(i, j) = (SoilVariables.Ks(i) * TransportCoefficient.MU_W(i, j) * (1 - Sa^0.5) * (1 - (1 - (1 - Sa^(1 / m(i))))^m(i))^2 / (Constants.g * Constants.RHOL)) * 10^(-1 * SoilVariables.Imped(MN) * SoilVariables.Ratio_ice(i, j));
            else
                k_g(i, j) = 0;
            end
        end
    end
end
