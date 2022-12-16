function SoilVariables = setSoilVariables(SoilProperties, Constant, Genuchten)

    % SoilVariables.XK = 0.09; %0.11 This is for silt loam; For sand XK=0.025
    SoilVariables.XK = Genuchten.Theta_r + 0.02; %0.11 This is for silt loam; For sand XK=0.025
    SoilVariables.XWILT = equations.van_genuchten(Genuchten.Theta_s, Genuchten.Theta_r, Genuchten.Alpha, -1.5e4, Genuchten.n, Genuchten.m);
    SoilVariables.XCAP = equations.van_genuchten(Genuchten.Theta_s, Genuchten.Theta_r, Genuchten.Alpha, -336, Genuchten.n, Genuchten.m);

    SoilVariables.POR = SoilProperties.porosity;
    SoilVariables.VPERS = SoilProperties.FOC.*(1-SoilVariables.POR);
    SoilVariables.VPERSL = Constant.FOSL.*(1-SoilVariables.POR);
    SoilVariables.VPERC = SoilProperties.FOC.*(1-SoilVariables.POR);

    SoilVariables.Ks = SoilProperties.SaturatedK;

end