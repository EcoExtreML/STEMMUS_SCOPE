function theta_m = calculateTheta_m(gama_hh, VanGenuchten, POR)

    theta_s = VanGenuchten.Theta_s;
    theta_r = VanGenuchten.Theta_r;
    alpha = VanGenuchten.Alpha;
    n = VanGenuchten.n;
    m = VanGenuchten.m;

    theta_m = gama_hh * theta_r + (theta_s - gama_hh * theta_r) * (1 + abs(alpha * (-1)) ^ n) ^ m;
    if theta_m >= POR
        theta_m = POR;
    elseif theta_m <= theta_s
        theta_m = theta_s;
    end
end