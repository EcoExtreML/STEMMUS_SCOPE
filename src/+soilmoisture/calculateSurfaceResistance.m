function SurfaceResistance = calculateSurfaceResistance(Rn, LAI, theta_ll)
    %% SURFACE RESISTANCE PARAMETERS CALCULATION

    % LAI and light extinction coefficient calculation
    if LAI <= 2
        LAI_act = LAI;
    elseif LAI <= 4
        LAI_act = 2;
    else
        LAI_act = 0.5 * LAI;
    end

    R_a = 0.81;
    R_b = 0.004 * 24 * 11.6;
    R_c = 0.05;
    rl_min = 100;
    rl = rl_min / ((R_b * Rn + R_c) / (R_a * (R_b * Rn + 1)));

    % r_s - SURFACE RESISTANCE
    % [s.m-1]
    % VEG: Dingman pag 208 (canopy conductance) (equivalent to FAO56 pag21 Eq5)
    SurfaceResistance.vegetation = rl / LAI_act;

    % 0.25 set as minmum soil moisture for potential evaporation
    SurfaceResistance.soil = 10.0 * exp(0.3563 * 100.0 * (0.2050 - theta_ll));
end
