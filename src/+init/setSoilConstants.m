function SoilConstants = setSoilConstants(SoilProperties, ForcingData)

    SoilConstants.Ta_msr = ForcingData.Ta_msr;
    SoilConstants.hd = -1e7;
    SoilConstants.hm = -9899;
    SoilConstants.CHST = 0;
    SoilConstants.Elmn_Lnth = 0;
    SoilConstants.Dmark = 0;
    SoilConstants.Vol_qtz = SoilProperties.FOS;
    SoilConstants.Phi_S = [-17.9 -17 -17 -19 -10 -10];
    SoilConstants.Phi_soc = -0.0103;
    SoilConstants.Lamda_soc = 2.7;
    SoilConstants.Theta_soc = 0.6;
    % XK=0.11 for silt loam; For sand XK=0.025
    % SoilConstants.XK is used in updateSoilVariables
    SoilConstants.XK = 0.11;
    SoilConstants.L_f = 3.34 * 1e5; % latent heat of freezing fusion i Kg-1

end
