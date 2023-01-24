function [Gama_h, Gama_hh] = updateGamaH(i, SoilConstants, SoilVariables)

    hd = SoilConstants.hd;
    hm = SoilConstants.hm;
    hh = SoilVariables.hh;

    if abs(hh(i))>=abs(hd)
        Gama_h(i)=0;
        Gama_hh(i)=Gama_h(i);
    elseif abs(hh(i))>=abs(hm)
        % Gama_h(i)=1-log(abs(hh(i)))/log(abs(hm));
        Gama_h(i)=log(abs(hd)/abs(hh(i)))/log(abs(hd)/abs(hm));
        Gama_hh(i)=Gama_h(i);
    else
        Gama_h(i)=1;
        Gama_hh(i)=Gama_h(i);
    end

end