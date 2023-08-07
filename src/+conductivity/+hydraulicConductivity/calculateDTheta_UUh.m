function dtheta_uuh = calculateDTheta_UUh(theta_uu, theta_m, theta_ll, gamma_hh, SoilVariables, VanGenuchten)
    theta_s = VanGenuchten.Theta_s;
    theta_r = VanGenuchten.Theta_r;
    alpha = VanGenuchten.Alpha;
    n = VanGenuchten.n;
    m = VanGenuchten.m;

    theta_u = SoilVariables.Theta_U;
    theta_l = SoilVariables.Theta_L;
    hh = SoilVariables.hh;
    h = SoilVariables.h;
    h_frez = SoilVariables.h_frez;
    hh_frez = SoilVariables.hh_frez;
    phi_s = SoilVariables.Phi_s;
    lamda = SoilVariables.Lamda;

    % get model settings
    ModelSettings = io.getModelSettings();

    heatTerm = hh + hh_frez;
    if ModelSettings.SWCC == 1
        if ModelSettings.SFCC == 1
            if hh >= -1
                if hh_frez >= 0
                    dtheta_uuh = 0;
                else
                    if ModelSettings.Thmrlefc
                        subRoutine = 0;
                        dtheta_uuh = conductivity.hydraulicConductivity.calculateDTheta(subRoutine, heatTerm, theta_s, theta_r, theta_m, gamma_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m);
                    elseif abs(hh - h) < 1e-3
                        subRoutine = 1;
                        dtheta_uuh = conductivity.hydraulicConductivity.calculateDTheta(subRoutine, heatTerm, theta_s, theta_r, theta_m, gamma_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m);
                    else
                        subRoutine = 2;
                        dtheta_uuh = conductivity.hydraulicConductivity.calculateDTheta(subRoutine, heatTerm, theta_s, theta_r, theta_m, gamma_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m);
                    end
                end
            elseif ModelSettings.Thmrlefc
                subRoutine = 0;
                dtheta_uuh = conductivity.hydraulicConductivity.calculateDTheta(subRoutine, heatTerm, theta_s, theta_r, theta_m, gamma_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m);
            end
        elseif hh >= -1e-6 || hh <= -1e7
            dtheta_uuh = 0;
        elseif ModelSettings.Thmrlefc || abs(hh - h) < 1e-3
            subRoutine = 1;
            dtheta_uuh = conductivity.hydraulicConductivity.calculateDTheta(subRoutine, heatTerm, theta_s, theta_r, theta_m, gamma_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m);
        else
            subRoutine = 3;
            dtheta_uuh = conductivity.hydraulicConductivity.calculateDTheta(subRoutine, heatTerm, theta_s, theta_r, theta_m, gamma_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m);
        end
    else
        if hh >= phi_s || hh <= -1e7
            dtheta_uuh = 0;
        elseif ModelSettings.Thmrlefc
            subRoutine = 4;
            dtheta_uuh = conductivity.hydraulicConductivity.calculateDTheta(subRoutine, heatTerm, theta_s, theta_r, theta_m, gamma_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m);
        elseif abs(hh - h) < 1e-3
            subRoutine = 5;
            dtheta_uuh = conductivity.hydraulicConductivity.calculateDTheta(subRoutine, heatTerm, theta_s, theta_r, theta_m, gamma_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m);
        else
            subRoutine = 3;
            dtheta_uuh = conductivity.hydraulicConductivity.calculateDTheta(subRoutine, heatTerm, theta_s, theta_r, theta_m, gamma_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m);
        end
    end
end
