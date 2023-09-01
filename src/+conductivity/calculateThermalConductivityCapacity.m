function ThermalConductivityCapacity = calculateThermalConductivityCapacity(InitialValues, ThermalConductivity, SoilVariables, VanGenuchten, DRHOVT, L, RHOV)
    %{
        This is to calculate thermal conductivity and thermal capacity.
        Chung, S. O., and R. Horton (1987), Soil heat and water flow with a
        partial surface mulch, Water Resour. Res., 23(12), 2175-2186,
        Zeng, Y., Su, Z., Wan, L. and Wen, J.: Numerical analysis of
        air-water-heat flow in unsaturated soil: Is it necessary to consider
        airflow in land surface models?, J. Geophys. Res. Atmos., 116(D20),
        20107, doi:10.1029/2011JD015835, 2011.
    %}

    % get model settings
    ModelSettings = io.getModelSettings();

    % load Constants
    Constants = io.define_constants();

    Theta_LL = SoilVariables.Theta_LL;
    c_unsat = InitialValues.c_unsat;
    Lambda_eff = InitialValues.Lambda_eff;
    RHO_bulk = ThermalConductivity.RHO_bulk;

    if ModelSettings.ThmrlCondCap == 1
        [ETCON, EHCAP, TETCON, EfTCON, ZETA] = conductivity.calculateSoilThermalProperites(InitialValues, ThermalConductivity, SoilVariables, VanGenuchten, DRHOVT, L, RHOV);
    end

    for i = 1:ModelSettings.NL
        for j = 1:ModelSettings.nD
            if ModelSettings.ThmrlCondCap == 1
                if ModelSettings.ThermCond == 1
                    Lambda_eff(i, j) = ETCON(i, j);
                elseif ModelSettings.ThermCond == 2
                    Lambda_eff(i, j) = EfTCON(i, j) / 100;
                elseif ModelSettings.ThermCond == 3
                    Lambda_eff(i, j) = TETCON(i, j);
                elseif ModelSettings.ThermCond == 4
                    Lambda_eff(i, j) = EfTCON(i, j) / 100;
                end
                if Lambda_eff(i, j) <= 0
                    Lambda_eff(i, j) = 0.0008;
                elseif Lambda_eff(i, j) > 0.02
                    Lambda_eff(i, j) = 0.02;
                end
                c_unsat(i, j) = EHCAP(i, j);
            else
                MN = i + j - 1;
                Lambda_eff(i, j) = Constants.Lambda1 + Constants.Lambda2 * Theta_LL(i, j) + Constants.Lambda3 * Theta_LL(i, j)^0.5;
                c_unsat(i, j) = 837 * RHO_bulk / 1000 + Theta_LL(i, j) * Constants.c_L + Theta_g(i, j) * (RHODA(MN) * Constants.c_a + RHOV(MN) * Constants.c_V);
            end
        end
    end
    ThermalConductivityCapacity.c_unsat = c_unsat;
    ThermalConductivityCapacity.Lambda_eff = Lambda_eff;
    ThermalConductivityCapacity.ZETA = ZETA;
end
