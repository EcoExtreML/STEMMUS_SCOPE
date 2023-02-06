function SoilVariables = setSoilVariables(SoilProperties, SoilConstants, VanGenuchten)

    % SoilVariables.XK = 0.09; %0.11 This is for silt loam; For sand XK=0.025
    SoilVariables.XK = VanGenuchten.Theta_r + 0.02; %0.11 This is for silt loam; For sand XK=0.025
    SoilVariables.XWILT = equations.van_genuchten(VanGenuchten.Theta_s, VanGenuchten.Theta_r, VanGenuchten.Alpha, -1.5e4, VanGenuchten.n, VanGenuchten.m);
    SoilVariables.XCAP = equations.van_genuchten(VanGenuchten.Theta_s, VanGenuchten.Theta_r, VanGenuchten.Alpha, -336, VanGenuchten.n, VanGenuchten.m);

    SoilVariables.POR = SoilProperties.porosity;
    SoilVariables.VPERS = SoilProperties.FOS'.*(1-SoilVariables.POR);
    SoilVariables.VPERSL = SoilConstants.FOSL'.*(1-SoilVariables.POR);
    SoilVariables.VPERC = SoilProperties.FOC'.*(1-SoilVariables.POR);
    SoilVariables.VPERSOC = SoilConstants.VPERSOC;

    SoilVariables.Ks = SoilProperties.SaturatedK;

    SoilVariables.h = SoilConstants.h;
    SoilVariables.T = SoilConstants.T;
    SoilVariables.TT = SoilConstants.TT;
    SoilVariables.h_frez = SoilConstants.h_frez;

end