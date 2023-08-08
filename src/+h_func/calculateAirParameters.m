function AirParameters = calculateAirParameters(Ta, Ts, HR_a, Z)
    Constants = io.define_constants();

    % compute delta - SLOPE OF SATURATION VAPOUR PRESSURE CURVE
    % [kPa.?C-1]
    % FAO56 pag 37 Eq13
    AirParameters.delta = 4098 * (0.6108 * exp(17.27 * Ta / (Ta + 237.3))) / (Ta + 237.3)^2;

    % ro_a - MEAN AIR DENSITY AT CTE PRESSURE
    % [kg.m-3]
    % FAO56 pag26 box6
    % Z: altitute of the location(m)
    Pa = 101.3 * ((293 - 0.0065 * Z) / 293)^5.26;
    AirParameters.ro_a = Pa / (Constants.R_specific * 1.01 * (Ta + 273.16));

    % compute e0_Ta - saturation vapour pressure at actual air temperature
    % [kPa]
    % FAO56 pag36 Eq11
    AirParameters.e0_Ta = 0.6108 * exp(17.27 * Ta / (Ta + 237.3));
    e0_Ts = 0.6108 * exp(17.27 * Ts / (Ts + 237.3));

    % compute e_a - ACTUAL VAPOUR PRESSURE
    % [kPa]
    % FAO56 pag74 Eq54
    AirParameters.e_a = AirParameters.e0_Ta * HR_a;

    % gama - PSYCHROMETRIC CONSTANT
    % [kPa.?C-1]
    % FAO56 pag31 eq8
    AirParameters.gama = 0.664742 * 1e-3 * Pa;

end