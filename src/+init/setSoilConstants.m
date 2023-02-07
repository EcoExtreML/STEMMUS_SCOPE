function SoilConstants = setSoilConstants(SoilConstants, MSOC, FOC, FOS)

    SoilConstants.hd = -1e7;
    SoilConstants.hm = -9899;
    SoilConstants.CHST = 0;
    SoilConstants.Elmn_Lnth = 0;
    SoilConstants.Dmark = 0;
    SoilConstants.Vol_qtz = FOS;
    SoilConstants.VPERSOC = equations.calc_msoc_fraction(MSOC); % fraction of soil organic matter
    SoilConstants.FOSL = 1 - FOC - FOS - SoilConstants.VPERSOC;
    SoilConstants.Phi_S = [-17.9 -17 -17 -19 -10 -10];
    SoilConstants.Phi_soc = -0.0103;
    SoilConstants.Lamda_soc = 2.7;
    SoilConstants.Theta_soc = 0.6;

end