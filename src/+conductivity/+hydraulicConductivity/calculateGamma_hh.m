function gamma_hh = calculateGamma_hh(hh)
    % get soil constants
    SoilConstants = io.getSoilConstants();

    if abs(hh) >= abs(SoilConstants.hd)
        gamma_hh = 0;
    elseif abs(hh) >= abs(SoilConstants.hm)
        gamma_hh = log(abs(SoilConstants.hd) / abs(hh)) / log(abs(SoilConstants.hd) / abs(SoilConstants.hm));
    else
        gamma_hh = 1;
    end
end
