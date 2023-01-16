function SoilVariables = updateSoilVariables(Genuchten, SoilVariables, SoilConstants, i, j)
    if SoilConstants.SWCC==1   % VG soil water retention model
        SoilVariables.XK(i) = SoilProperties.ResidualMC(j) + 0.02;
        SoilVariables.XWILT(i) = equations.van_genuchten(Genuchten.Theta_s(i), Genuchten.Theta_r(i), Genuchten.Alpha(i), -1.5e4, Genuchten.n(i), Genuchten.m(i));
        SoilVariables.XCAP(i) = equations.van_genuchten(Genuchten.Theta_s(i), Genuchten.Theta_r(i), Genuchten.Alpha(i), -336, Genuchten.n(i), Genuchten.m(i));
    else
        if SoilConstants.CHST==0  % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use
            SoilVariables.Phi_s(i) = SoilConstants.Phi_S(j);
            SoilVariables.Lamda(i) = SoilProperties.Coef_Lamda(j);
        else
            SoilVariables.Phi_s(i) = init.calcPhi_s(SoilVariables.VPER(i,1), SoilVariables.POR, SoilConstants.Phi_soc, SoilVariables.XSOC);

            SoilVariables.Lamda(i) = init.calcLambda(SoilVariables.VPER(i,3), SoilVariables.POR, SoilVariables.Lamda_soc, SoilVariables.XSOC);
        end
        SoilVariables.XWILT(i) = Genuchten.Theta_s(i) * ((-1.5e4) / SoilVariables.Phi_s(i)) ^(-1 * SoilVariables.Lamda(i));
end