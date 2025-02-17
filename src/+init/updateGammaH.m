function [Gamma_h, Gamma_hh] = updateGammaH(i, SoilVariables)

    % get soil constants
    SoilConstants = io.getSoilConstants();

    hd = SoilConstants.hd;
    hm = SoilConstants.hm;
    hh = SoilVariables.hh;

    if abs(hh(i)) >= abs(hd)
        Gamma_h(i) = 0;
        Gamma_hh(i) = Gamma_h(i);
    elseif abs(hh(i)) >= abs(hm)
        % Gamma_h(i)=1-log(abs(hh(i)))/log(abs(hm));
        Gamma_h(i) = log(abs(hd) / abs(hh(i))) / log(abs(hd) / abs(hm));
        Gamma_hh(i) = Gamma_h(i);
    else
        Gamma_h(i) = 1;
        Gamma_hh(i) = Gamma_h(i);
    end

end
