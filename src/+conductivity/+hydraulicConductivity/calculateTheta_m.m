function theta_m = calculateTheta_m(gama_hh, VanGenuchten)

    theta_s = VanGenuchten.Theta_s;
    theta_r = VanGenuchten.Theta_r;
    alpha = VanGenuchten.Alpha;
    n = VanGenuchten.n;
    m = VanGenuchten.m;

    theta_m = gama_hh * theta_r + (theta_s - gama_hh * theta_r) * (1 + abs(alpha * (-1)) ^ n) ^ m;

end