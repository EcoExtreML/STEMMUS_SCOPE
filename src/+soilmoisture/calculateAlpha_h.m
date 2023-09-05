function alpha_h = calculateAlpha_h(KT, Tp_t, hh)

    ModelSettings = io.getModelSettings();

    if KT <= 3288 + 1103
        H1 = 0;
        H2 = -31;
        H4 = -8000;
        H3L = -600;
        H3H = -300;
        if Tp_t < 0.02 / 3600
            H3 = H3L;
        elseif Tp_t > 0.05 / 3600
            H3 = H3H;
        else
            H3 = H3H + (H3L - H3H) / (0.03 / 3600) * (0.05 / 3600 - Tp_t);
        end
    else
        H1 = -1;
        H2 = -5;
        H4 = -16000;
        H3L = -600;
        H3H = -300;
        if Tp_t < 0.02 / 3600
            H3 = H3L;
        elseif Tp_t > 0.05 / 3600
            H3 = H3H;
        else
            H3 = H3H + (H3L - H3H) / (0.03 / 3600) * (0.05 / 3600 - Tp_t);
        end
    end
    % piecewise linear reduction function
    for i = 1:ModelSettings.NL
        for j = 1:ModelSettings.nD
            MN = i + j - 1;
            if hh(MN) >= H1
                alpha_h(i, j) = 0;
            elseif  hh(MN) >= H2
                alpha_h(i, j) = (H1 - hh(MN)) / (H1 - H2);
            elseif  hh(MN) >= H3
                alpha_h(i, j) = 1;
            elseif  hh(MN) >= H4
                alpha_h(i, j) = (hh(MN) - H4) / (H3 - H4);
            else
                alpha_h(i, j) = 0;
            end
        end
    end
end
