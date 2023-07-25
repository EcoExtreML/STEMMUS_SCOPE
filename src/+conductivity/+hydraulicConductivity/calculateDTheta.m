function dtheta = calculateDTheta(subRoutine, heat_term, theta_s, theta_r, theta_m, gama_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m)

    % get soil constants
    SoilConstants = io.getSoilConstants();

    switch subRoutine
        case 0
            % for DTheta_LLh, heat_term = hh
            % for DTheta_UUh, heat_term = hh + hh_frez
            A = (-theta_r) / (abs(heat_term) * log(abs(SoilConstants.hd / SoilConstants.hm))) * (1 - (1 + abs(alpha * heat_term)^n)^(-m));
            B = alpha * n * m * (theta_m - gama_hh * theta_r);
            C = ((1 + abs(alpha * heat_term)^n)^(-m - 1));
            D = (abs(alpha * heat_term)^(n - 1));
            dtheta = A -  B * C * D;
            if (hh + hh_frez) <= SoilConstants.hd
                dtheta = 0;
            end
        case 1
            % heat_term = hh or  hh + hh_frez
            A = (theta_m - theta_r) * alpha * n;
            B =  abs(alpha * heat_term)^(n - 1) * (-m);
            C = (1 + abs(alpha * heat_term)^n)^(-m - 1);
            dtheta = A * B * C;
        case 2
            A = theta_ll - theta_l;
            B = hh + hh_frez - h - h_frez;
            dtheta = A / B;
        case 3
            A = theta_uu - theta_u;
            B = hh - h;
            dtheta = A / B;
        case 4
            dtheta = theta_s / phi_s * (hh / phi_s)^(-1 * lamda - 1);
        case 5
            % heat_term = hh or  hh + hh_frez
            A = (theta_s - theta_r) * alpha * n;
            B =  abs(alpha * heat_term)^(n - 1) * (-m);
            C = (1 + abs(alpha * heat_term)^n)^(-m - 1);
            dtheta = A * B * C;
    end
end
