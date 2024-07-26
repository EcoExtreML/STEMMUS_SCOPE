function se = calculateSe(theta_ll, gamma_hh, SoilVariables, ModelSettings)

    % get soil constants
    SoilConstants = io.getSoilConstants();

    hh_frez = SoilVariables.hh_frez;
    POR = SoilVariables.POR;
    hh = SoilVariables.hh;
    phi_s = SoilVariables.Phi_s;
    se = SoilVariables.Se;
    seCalculated = theta_ll / POR;

    if ModelSettings.SWCC == 1
        if ModelSettings.SFCC == 1
            if hh >= -1
                if hh_frez >= 0
                    se = 1;
                elseif Thmrlefc
                    if (hh + hh_frez) <= SoilConstants.hd
                        se = 0;
                    else
                        se = seCalculated;
                    end
                end
            elseif ModelSettings.Thmrlefc
                if (hh + hh_frez) <= SoilConstants.hd
                    se = 0;
                else
                    se = seCalculated;
                end
            end
        elseif theta_ll <= 0.06 || hh <= -1e7
            se = 0;
        else
            se = seCalculated;
        end
    else
        if hh + hh_frez <= -1e7 || hh <= -1e7
            se = 0;
        elseif hh + hh_frez >= phi_s
            se = 1;
        else
            se = seCalculated;
        end
    end

    if se > 1
        se = 1;
    elseif se < 0
        se = 0;
    end
    if isnan(se) == 1
        warning('\n case "isnan(se) == 1" happens. Dont know what to do! \r');
    end
end
