function [hh, hh_frez] = fixHeat()
    % calculate hh and hh_frez
    for i = 1:NL
        for ND = 1:2
            MN = i + ND - 1;
            if SWCC == 1
                if SFCC ~= 1
                    if hh(MN) >= -1e-6
                        hh(MN) = -1e-6;
                    elseif hh(MN) <= -1e7
                        hh(MN) = -1e7;
                    end
                end
            else
                if hh(MN) >= Phi_s(i)
                    hh(MN) = Phi_s(i);
                elseif hh(MN) <= -1e7
                    hh(MN) = -1e7;
                    hh_frez(MN) = -1e-6;
                end
            end
        end
    end


end