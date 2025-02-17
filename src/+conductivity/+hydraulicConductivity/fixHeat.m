function [hh, hh_frez] = fixHeat(hh, hh_frez, Phi_s, ModelSettings)

    if ModelSettings.SWCC == 1
        if ModelSettings.SFCC ~= 1
            if hh > -1e-6
                hh = -1e-6;
            elseif hh < -1e7
                hh = -1e7;
            end
        end
    else
        if hh >= Phi_s
            hh = Phi_s;
        elseif hh <= -1e7
            hh = -1e7;
            hh_frez = -1e-6;
        end
    end
end
