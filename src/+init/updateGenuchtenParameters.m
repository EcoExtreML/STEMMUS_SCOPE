function Genuchten = updateGenuchtenParameters(SWCC, Genuchten, Constant, Coefficients, i, j)
    if SWCC==1   % VG soil water retention model
            Genuchten = init.defineGenuchtenParameters(SoilProperties, i, j);
    else
        Genuchten.Theta_s(i) = Theta_s_ch(j); % TODO check undefined Theta_s_ch
        Genuchten.Theta_r(i) = SoilProperties.ResidualMC(j);
        if Constant.CHST~=0  % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use          
            Genuchten.Theta_s_min(i)=0.489-0.00126*VPER(i,1)/(1-Coefficients.POR(i))*100;

            Genuchten.Theta_s(i) = Genuchten.Theta_s_min(i)*(1-XSOC(i))+XSOC(i)*Theta_soc;  
            Genuchten.Theta_s(i) = Genuchten.Theta_s_min(i); % TODO check repeated lines
        end
    end
end