function gama_hh = calculateGama_hh(hh)
    % get soil constants
    SoilConstants = io.getSoilConstants();

    if abs(hh) >= abs(SoilConstants.hd)
        gama_hh = 0;
    elseif abs(hh) >= abs(SoilConstants.hm)
        gama_hh = log(abs(SoilConstants.hd) / abs(hh)) / log(abs(SoilConstants.hd) / abs(SoilConstants.hm));
    else
        gama_hh = 1;
    end
end
