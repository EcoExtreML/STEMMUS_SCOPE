function matricHead = calcSoilMatricHead(H01, H02, delta, domainZ)
    %{
        Calculate soil temperature
    %}
    % TODO defines terms delta, domainZ
    matricHead = H02 + domainZ * (H01-H02) / delta;

end