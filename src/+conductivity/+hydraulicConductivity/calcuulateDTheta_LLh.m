function dtheta_llh = calcuulate_DTheta_LLh(dtheta_uuh, theta_m, theta_uu, theta_ll, gama_hh, SoilVariables, VanGenuchten)

    theta_r = VanGenuchten.Theta_r;
    alpha = VanGenuchten.Alpha;
    n = VanGenuchten.n;
    m = VanGenuchten.m;

    theta_u = SoilVariables.Theta_U;
    hh = SoilVariables.hh;
    h = SoilVariables.h;
    hh_frez = SoilVariables.hh_frez;
    phi_s = SoilVariables.Phi_s;

    % get model settings
    ModelSettings = io.getModelSettings();

    if ModelSettings.SWCC == 1
        if ModelSettings.SFCC == 1
            if hh >= -1
                dtheta_llh = 0;
            elseif Thmrlefc
                    if Gama_hh == 0
                        dtheta_llh = 0;
                    else
                        subRoutine = 1;
                        dtheta_llh = calculateDTheta(subRoutine, hh, theta_r, theta_m, gama_hh, theta_ll, theta_l, theta_uu, theta_u, theta_m, hh, h, hh_frez, h_frez, phi_s, lamda, hd, hm, alpha, n, m);
                    end
            elseif abs(hh - h) < 1e-3
                    subRoutine = 2;
                    dtheta_llh = calculateDTheta(subRoutine, hh, theta_r, theta_m, gama_hh, theta_ll, theta_l, theta_uu, theta_u, theta_m, hh, h, hh_frez, h_frez, phi_s, lamda, hd, hm, alpha, n, m);
            else
                subRoutine = 3;
                dtheta_llh = calculateDTheta(subRoutine, hh, theta_r, theta_m, gama_hh, theta_ll, theta_l, theta_uu, theta_u, theta_m, hh, h, hh_frez, h_frez, phi_s, lamda, hd, hm, alpha, n, m);
            end
        elseif hh <= -1e7 || theta_ll <= 0.06
                dtheta_llh = 0;
        else
            dtheta_llh = dtheta_uuh;
        end
    else
        if hh <= -1e7 || hh + hh_frez <= -1e7 || hh + hh_frez >= phi_s
            dtheta_llh = 0;
        elseif Thmrlefc
                subRoutine = 4;
                dtheta_llh = calculateDTheta(subRoutine, (hh + hh_frez), theta_r, theta_m, gama_hh, theta_ll, theta_l, theta_uu, theta_u, theta_m, hh, h, hh_frez, h_frez, phi_s, lamda, hd, hm, alpha, n, m);
        elseif abs(hh - h) < 1e-3
                dtheta_llh = (Theta_s - theta_r) * alpha * n * abs(alpha * (hh + hh_frez))^(n - 1) * (-m) * (1 + abs(alpha * (hh + hh_frez))^n)^(-m - 1);
        else
            subRoutine = 2;
            dtheta_llh = calculateDTheta(subRoutine, (hh + hh_frez), theta_r, theta_m, gama_hh, theta_ll, theta_l, theta_uu, theta_u, theta_m, hh, h, hh_frez, h_frez, phi_s, lamda, hd, hm, alpha, n, m);
        end
    end
end