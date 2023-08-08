function AerodynamicResistance = calculateAerodynamicResistance(U)
    %{
    %}
    Constants = io.define_constants();
    k = Constants.k;
    hh_v = 0.12;
    % FAO56 pag20 eq4- (d - zero displacement plane, z_0m - roughness length momentum transfer, z_0h - roughness length heat and vapour transfer, [m], FAO56 pag21 BOX4
    AerodynamicResistance.vegetation = log((2 - (2 * hh_v / 3)) / (0.123 * hh_v)) * log((2 - (2 * hh_v / 3)) / (0.0123 * hh_v)) / ((k^2) * U) * 100;  % s m-1

    AerodynamicResistance.soil  = log((2.0) / 0.001) * log(2.0 / 0.001) / ((k^2) * U) * 100;
end