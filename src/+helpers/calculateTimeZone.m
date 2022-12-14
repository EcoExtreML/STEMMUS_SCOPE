function [timeZone] = calculateTimeZone(longitude)
    %{
        This function calculate the time zone based on longitude.

    %}
    timeZone_init = fix(longitude/15);
    if longitude>0
        if abs(mod(longitude, 15)) > 7.5
            timeZone = timeZone_init + 1;
        else
            timeZone = timeZone_init;
        end
    else
        if abs(mod(longitude, 15)) > 7.5
            timeZone = timeZone_init - 1;
        else
            timeZone = timeZone_init;
        end
    end
end