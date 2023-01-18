function  soilTemperature = calcSoilTemp(T01, T02, delta, domainZ)
    %{
        Calculate soil temperature
    %}
    % TODO defines terms delta, domainZ
    soilTemperature = T02 + domainZ * (T01 - T02) / delta;

end