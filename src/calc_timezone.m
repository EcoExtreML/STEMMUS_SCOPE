% calculate the time zone based on longitude
function [ScopeParameters] = calc_timezone(ScopeParameters,Longitude)
TZ=fix(Longitude/15);
TZZ=mod(Longitude,15);
    if Longitude>0
        if abs(TZZ)>7.5
            ScopeParameters(50).Val= TZ+1;
        else
            ScopeParameters(50).Val= TZ;
        end
    else
        if abs(TZZ)>7.5
            ScopeParameters(50).Val= TZ-1;
        else
            ScopeParameters(50).Val= TZ;
        end
    end
end