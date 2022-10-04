function [ScopeParameters] = calculateTimeZone(ScopeParameters, longitude)
    %{
        This function calculate the time zone based on longitude.

    %}
    timeZone=fix(longitude/15);
        if longitude>0
            if abs(mod(longitude,15))>7.5
                ScopeParameters(50).Val= timeZone+1;
            else
                ScopeParameters(50).Val= timeZone;
            end
        else
            if abs(mod(longitude,15))>7.5
                ScopeParameters(50).Val= timeZone-1;
            else
                ScopeParameters(50).Val= timeZone;
            end
        end
    end