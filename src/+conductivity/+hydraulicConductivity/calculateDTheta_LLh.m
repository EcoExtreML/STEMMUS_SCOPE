function dtheta_llh = calcuulateDTheta_LLh(dtheta_uuh, theta_m, theta_uu, theta_ll, gamma_hh, SoilVariables, VanGenuchten, ModelSettings)
    theta_s = VanGenuchten.Theta_s;
    theta_r = VanGenuchten.Theta_r;
    alpha = VanGenuchten.Alpha;
    n = VanGenuchten.n;
    m = VanGenuchten.m;

    theta_u = SoilVariables.Theta_U;
    hh = SoilVariables.hh;
    h = SoilVariables.h;
    hh_frez = SoilVariables.hh_frez;
    phi_s = SoilVariables.Phi_s;
    lamda = SoilVariables.Lamda;
    theta_l = SoilVariables.Theta_L;
    h_frez = SoilVariables.h_frez;

    heatTerm = hh + hh_frez;
    if ModelSettings.SWCC == 1
        if ModelSettings.SFCC == 1
            if hh >= -1
                dtheta_llh = 0;
            elseif ModelSettings.Thmrlefc
                if gamma_hh == 0
                    dtheta_llh = 0;
                else
                    subRoutine = 0;
                    dtheta_llh = conductivity.hydraulicConductivity.calculateDTheta(subRoutine, hh, theta_s, theta_r, theta_m, gamma_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m);
                end
            elseif abs(hh - h) < 1e-3
                subRoutine = 1;
                dtheta_llh = conductivity.hydraulicConductivity.calculateDTheta(subRoutine, hh, theta_s, theta_r, theta_m, gamma_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m);
            else
                subRoutine = 3;
                dtheta_llh = conductivity.hydraulicConductivity.calculateDTheta(subRoutine, hh, theta_s, theta_r, theta_m, gamma_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m);
            end
        elseif hh <= -1e7 || theta_ll <= 0.06
            dtheta_llh = 0;
        else
            dtheta_llh = dtheta_uuh;
        end
    else
        if hh <= -1e7 || hh + hh_frez <= -1e7 || hh + hh_frez >= phi_s
            dtheta_llh = 0;
        elseif ModelSettings.Thmrlefc
            subRoutine = 4;
            dtheta_llh = conductivity.hydraulicConductivity.calculateDTheta(subRoutine, heatTerm, theta_s, theta_r, theta_m, gamma_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m);
        elseif abs(hh - h) < 1e-3
            subRoutine = 5;
            dtheta_llh = conductivity.hydraulicConductivity.calculateDTheta(subRoutine, heatTerm, theta_s, theta_r, theta_m, gamma_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m);
        else
            subRoutine = 2;
            dtheta_llh = conductivity.hydraulicConductivity.calculateDTheta(subRoutine, heatTerm, theta_s, theta_r, theta_m, gamma_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m);
        end
    end
end
