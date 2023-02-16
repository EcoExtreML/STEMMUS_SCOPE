function  soilTemperature = calcSoilTemp(T01, T02, delta, domainZ)
    %{
        Interpolations of oil temperature to the whole soil profile explaind in
        section 5.4.3 in Yijian Zeng & Zhongbo Su (2013): STEMMUS (Simultaneous
        Transfer of Energy, Mass and Momentum in Unsaturated Soil): Department
        of Water Resources, ITC Faculty of Geo-Information Science and Earth
        Observation, University of Twente ISBN: 978–90–6164–351–7
    %}
    soilTemperature = T02 + domainZ * (T01 - T02) / delta;

end