function ThermalConductivityCapacity = calculateThermalConductivityCapacity(InitialValues, ThermalConductivity, SoilVariables, VanGenuchten, DRHOVT, L, RHOV)

    % get model settings
    ModelSettings = io.getModelSettings();

    % load Constants
    Constants = io.define_constants();

    Theta_LL = SoilVariables.Theta_LL;
    c_unsat = InitialValues.c_unsat;
    Lambda_eff = InitialValues.Lambda_eff;

    if ModelSettings.ThmrlCondCap == 1
        [ETCON, EHCAP, TETCON, EfTCON, ZETA] = conductivity.EfeCapCond(ThermalConductivity, SoilVariables, VanGenuchten, DRHOVT, L, RHOV);
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
                elseif Lambda_eff(i, j) >= 0.02
                    Lambda_eff(i, j) = 0.02;
                else
                    Lambda_eff(i, j) = Lambda_eff(i, j);
                end
                c_unsat(i, j) = EHCAP(i, j);
            end
        else
            MN = i + j - 1;
            Lambda_eff(i, j) = Constants.Lambda1 + Constants.Lambda2 * Theta_LL(i, j) + Constants.Lambda3 * Theta_LL(i, j)^0.5; % 3.6*0.001*4.182; % It is possible to add the dispersion effect here to consider the heat dispersion.
            c_unsat(i, j) = 837 * RHO_bulk / 1000 + Theta_LL(i, j) * Constants.c_L + Theta_g(i, j) * (RHODA(MN) * Constants.c_a + RHOV(MN) * Constants.c_V); % 9.79*0.1*4.182;%
        end
    end
    ThermalConductivityCapacity.c_unsat = c_unsat;
    ThermalConductivityCapacity.Lambda_eff = Lambda_eff;
    ThermalConductivityCapacity.ZETA = ZETA;
    ThermalConductivityCapacity.ETCON = ETCON;
    ThermalConductivityCapacity.EHCAP = EHCAP;
    ThermalConductivityCapacity.TETCON = TETCON;
    ThermalConductivityCapacity.EfTCON = EfTCON;
end
