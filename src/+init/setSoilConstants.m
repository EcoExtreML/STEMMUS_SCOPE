function SoilConstants = setSoilConstants(Constants, ModelSettings, InitialValues, SoilData, SoilProperties, ForcingData)

    % create SoilConstants structure holding initial values
    SoilConstants = struct();
    soil_fields = {
                   'P_g', 'P_gg', 'h', 'T', 'TT', 'h_frez', 'Theta_L', ...
                   'Theta_LL', 'Theta_V', 'Theta_g', 'Se', 'KL_h', ...
                   'DTheta_LLh', 'KfL_T', 'Theta_II', 'Theta_I', ...
                   'Theta_UU', 'Theta_U', 'TT_CRIT', 'KfL_h', 'DTheta_UUh'
                  };
    for field = soil_fields
        SoilConstants.(field{1}) = InitialValues.(field{1});
    end

    % Add variables from SoilData
    for field = fieldnames(SoilData)'
        SoilConstants.(field{1}) = SoilData.(field{1});
    end

    SoilConstants.Ta_msr = ForcingData.Ta_msr;

    SoilConstants.g = Constants.g;
    SoilConstants.RHOI = Constants.RHOI;
    SoilConstants.RHOL = Constants.RHOL;

    SoilConstants.hd = -1e7;
    SoilConstants.hm = -9899;
    SoilConstants.CHST = 0;
    SoilConstants.Elmn_Lnth = 0;
    SoilConstants.Dmark = 0;
    SoilConstants.Vol_qtz = SoilProperties.FOS;
    SoilConstants.VPERSOC = equations.calc_msoc_fraction(SoilProperties.MSOC); % fraction of soil organic matter
    SoilConstants.FOSL = 1 - SoilProperties.FOC - SoilProperties.FOS - SoilConstants.VPERSOC;
    SoilConstants.Phi_S = [-17.9 -17 -17 -19 -10 -10];
    SoilConstants.Phi_soc = -0.0103;
    SoilConstants.Lamda_soc = 2.7;
    SoilConstants.Theta_soc = 0.6;
    SoilConstants.XK = 0.11; % 0.11 This is for silt loam; For sand XK=0.025

    SoilConstants.totalNumberOfElements = ModelSettings.NL;
    SoilConstants.numberOfNodes = ModelSettings.NN;
    SoilConstants.numberOfElements = ModelSettings.ML;

    fields = {
              'SWCC', 'J', 'DeltZ', 'Tot_Depth', 'Thmrlefc', 'Soilairefc', ...
              'T0', 'Tr', 'KIT', 'hThmrl', 'Hystrs', 'Eqlspace', 'ThermCond'
             };
    for field = fields
        SoilConstants.(field{1}) = ModelSettings.(field{1});
    end
end
