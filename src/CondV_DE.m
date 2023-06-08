function [D_V, Eta, D_A] = CondV_DE(Theta_LL, TT, fc, Theta_s, NL, nD, Theta_g, POR, ThmrlCondCap, ZETA, XK, DVT_Switch, Theta_UU)
    MN = 0;
    for ML = 1:NL
        J = ML;
        for ND = 1:nD
            MN = ML + ND - 1;

            if ThmrlCondCap
                if Theta_UU(ML, ND) < XK(J)
                    EnhnLiqIsland(ML, ND) = POR(J); % -Theta_II(ML,ND)*RHOI/RHOL
                else
                    EnhnLiqIsland(ML, ND) = Theta_g(ML, ND) * (1 + Theta_UU(ML, ND) / (POR(J) - XK(J))); % -Theta_II(ML,ND)*RHOI/RHOL
                end

                f0(ML, ND) = Theta_g(ML, ND)^(7 / 3) / Theta_s(J)^2; % Theta_g(ML,ND)^0.67;

                D_A(MN) = 0.229 * (1 + TT(MN) / 273)^1.75; %  cm2/s---------5.8*10^(-7)*(273.15+TT(MN))^2.3/(UnitC^2);%

                if DVT_Switch == 1
                    Eta(ML, ND) = ZETA(ML, ND) * EnhnLiqIsland(ML, ND) / (f0(ML, ND) * Theta_g(ML, ND)); % 0; %
                else
                    Eta(ML, ND) = 0;
                end
            else
                f0(ML, ND) = Theta_g(ML, ND)^0.67;  %
                D_A(MN) = 1e4 * 2.12 * 10^(-5) * (1 + TT(MN) / 273.15)^2;  % 2.12e-5*(1+T/273.15)^2 m2/s---> 1e4*cm2/s
                Eta(ML, ND) = 8 + 3 * Theta_LL(ML, ND) / Theta_s(J) - 7 * exp(-((1 + 2.6 / sqrt(fc)) * Theta_LL(ML, ND) / Theta_s(J))^3);
            end

            D_V(ML, ND) = f0(ML, ND) * Theta_g(ML, ND) * D_A(MN);

        end
    end
    %%%%%%%%%%%%% With UnitC^2, m^2.s^-1 would be converted as cm^2.s^-1 %%%%%%%%%%%%%
