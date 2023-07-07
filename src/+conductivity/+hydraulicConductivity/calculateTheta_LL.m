function theta_ll = calculateTheta_LL(theta_uu, theta_ii, theta_m, SoilVariables, VanGenuchten)
    % load Constants
    Constants = io.define_constants();

    hh = SoilVariables.hh;
    hh_frez = SoilVariables.hh_frez;
    gama_hh = SoilVariables.Gama_hh;
    phi_s = SoilVariables.Phi_s;
    lamda = SoilVariables.Lamda;

    theta_s = VanGenuchten.Theta_s;
    theta_r = VanGenuchten.Theta_r;
    alpha = VanGenuchten.Alpha;
    n = VanGenuchten.n;
    m = VanGenuchten.m;

    % calculate theta_ll
    if SWCC == 1
        if SFCC == 1
            if hh >= -1 && hh_frez >= 0
                    theta_ll = theta_s;
            elseif Thmrlefc
                subRoutine = 0;
                theta = calculateTheta(subRoutine, theta_m, (hh + hh_frez), gama_hh, theta_s, theta_r, lamda, phi_s, alpha, n, m);
            end
        else
            if hh >= -1e-6 && TT + 273.15 > (273.15 + 1)
                    theta_ll = theta_s;
            elseif hh <= -1e7
                theta_ll = theta_r;
            elseif TT + 273.15 > (273.15 + 1)
                    subRoutine = 2;
                    theta = calculateTheta(subRoutine, theta_m, (hh + hh_frez), gama_hh, theta_s, theta_r, lamda, phi_s, alpha, n, m);
            else
                theta_ll = theta_uu - theta_ii * Constants.RHOI / Constants.RHOL;
            end
            if theta_ll <= 0.06
                theta_ll = 0.06;
            end
        end
    else
        if hh >= phi_s
            subRoutine = 1;
            theta = calculateTheta(subRoutine, theta_m, (hh + hh_frez), gama_hh, theta_s, theta_r, lamda, phi_s, alpha, n, m);
        elseif hh <= -1e7
            theta_ll = theta_r;
        end
    end
end