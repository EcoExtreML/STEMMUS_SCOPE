function [RHOV, DRHOVh, DRHOVT] = Density_V(TT, hh, g, Rv, NN)

    for MN = 1:NN
        HR(MN) = exp(hh(MN) * g / (Rv * (TT(MN) + 273.15)));
        if HR(MN) <= 0.041
            HR(MN) = 0.041;
        elseif HR(MN) >= 1
            HR(MN) = 1;
        end
        RHOV_s(MN) = 1e-6 * exp(31.3716 - 6014.79 / (TT(MN) + 273.15) - 7.92495 * 0.001 * (TT(MN) + 273.15)) / (TT(MN) + 273.15);
        DRHOV_sT(MN) = RHOV_s(MN) * (6014.79 / (TT(MN) + 273.15)^2 - 7.92495 * 0.001) - RHOV_s(MN) / (TT(MN) + 273.15);
        if TT(MN) < -20
            RHOV_s(MN) = 1e-6 * exp(31.3716 - 6014.79 / (-20 + 273.15) - 7.92495 * 0.001 * (-20 + 273.15)) / (-20 + 273.15);
            DRHOV_sT(MN) = RHOV_s(MN) * (6014.79 / (-20 + 273.15)^2 - 7.92495 * 0.001) - RHOV_s(MN) / (-20 + 273.15);
        elseif TT(MN) >= 150
            RHOV_s(MN) = 1e-6 * exp(31.3716 - 6014.79 / (150 + 273.15) - 7.92495 * 0.001 * (150 + 273.15)) / (150 + 273.15);
            DRHOV_sT(MN) = RHOV_s(MN) * (6014.79 / (150 + 273.15)^2 - 7.92495 * 0.001) - RHOV_s(MN) / (150 + 273.15);
        end
        RHOV(MN) = RHOV_s(MN) * HR(MN);

        DRHOVh(MN) = RHOV_s(MN) * HR(MN) * g / (Rv * (TT(MN) + 273.15));

        DRHOVT(MN) = RHOV_s(MN) * HR(MN) * (-hh(MN) * g / (Rv * (TT(MN) + 273.15)^2)) + HR(MN) * DRHOV_sT(MN);

    end
