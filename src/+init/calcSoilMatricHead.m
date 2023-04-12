function matricHead = calcSoilMatricHead(H01, H02, delta, domainZ)
    %{
        Interpolations of matric potential to the whole soil profile explaind in
        section 5.4.3 in Yijian Zeng & Zhongbo Su (2013): STEMMUS (Simultaneous
        Transfer of Energy, Mass and Momentum in Unsaturated Soil): Department
        of Water Resources, ITC Faculty of Geo-Information Science and Earth
        Observation, University of Twente ISBN: 978-90-6164-351-7
    %}
    matricHead = H02 + domainZ * (H01 - H02) / delta;

end
