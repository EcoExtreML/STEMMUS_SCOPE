function [SoilConstants, SoilVariables, VanGenuchten, ThermalConductivity] = StartInit(SoilConstants, SoilProperties, SoilData, SiteProperties)

    Ksh = repelem(18 / (3600 * 24), 6);
    BtmKsh = Ksh(6);
    Ksh0 = Ksh(1);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% Considering soil hetero effect modify date: 20170103 %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    VanGenuchten = init.setVanGenuchtenParameters(SoilProperties);
    SoilVariables = init.setSoilVariables(SoilProperties, SoilConstants, VanGenuchten);
    [SoilVariables, VanGenuchten] = init.applySoilHeteroEffect(SoilProperties, SoilConstants, SoilData, SoilVariables, VanGenuchten);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% Considering soil hetero effect modify date: 20170103 %%%%%%%%%%%%
    %%%%%% Perform initial freezing temperature for each soil type.%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    SoilVariables = init.applySoilHeteroWithInitialFreezing(SoilConstants, SoilVariables);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% Perform initial thermal calculations for each soil type.%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ThermalConductivity = init.calculateInitialThermal(SoilConstants, SoilVariables, VanGenuchten);

    % According to hh value get the Theta_LL
    % run SOIL2;   % For calculating Theta_LL,used in first Balance calculation.

    Theta_L = SoilConstants.Theta_L;
    Theta_LL = SoilConstants.Theta_LL;
    Theta_V = SoilConstants.Theta_V;
    Theta_g = SoilConstants.Theta_g;
    Se = SoilConstants.Se;
    KL_h = SoilConstants.KL_h;
    DTheta_LLh = SoilConstants.DTheta_LLh;
    KfL_T = SoilConstants.KfL_T;
    Theta_II = SoilConstants.Theta_II;
    Theta_I = SoilConstants.Theta_I;
    Theta_UU = SoilConstants.Theta_UU;
    Theta_U = SoilConstants.Theta_U;
    TT_CRIT = SoilConstants.TT_CRIT;
    KfL_h = SoilConstants.KfL_h;
    DTheta_UUh = SoilConstants.DTheta_UUh;

    % get Constants
    Constants = io.define_constants();
    g = Constants.g;
    RHOI = Constants.RHOI;
    RHOL = Constants.RHOL;

    % after refatoring SOIL2, these lines can be removed later, see issue 95!
    % get model settings
    ModelSettings = io.getModelSettings();
    NN = ModelSettings.NN;
    NL = ModelSettings.NL;
    SWCC = ModelSettings.SWCC;
    Thmrlefc = ModelSettings.Thmrlefc;
    T0 = ModelSettings.T0;
    Tr = ModelSettings.Tr;
    KIT = ModelSettings.KIT;
    hThmrl = ModelSettings.hThmrl;
    Hystrs = ModelSettings.Hystrs;

    Theta_s = VanGenuchten.Theta_s;
    Theta_r = VanGenuchten.Theta_r;
    Alpha = VanGenuchten.Alpha;
    n = VanGenuchten.n;
    m = VanGenuchten.m;

    POR = SoilVariables.POR;
    h = SoilVariables.h;
    Lamda = SoilVariables.Lamda;
    Phi_s = SoilVariables.Phi_s;

    h_frez = SoilVariables.h_frez;
    hh_frez = SoilVariables.hh_frez;
    TT = SoilVariables.TT;
    hh = SoilVariables.hh;
    XWRE = SoilVariables.XWRE;
    IH = SoilVariables.IH;
    Ks = SoilVariables.Ks;
    Imped = SoilVariables.Imped;
    XCAP = SoilVariables.XCAP;

    L_f = 3.34 * 1e5; % latent heat of freezing fusion J Kg-1
    T0 = 273.15; % unit K

    % these two are defined inside SOIL2, see issue 95
    COR = [];
    CORh = [];
    [hh, COR, CORh, Theta_V, Theta_g, Se, KL_h, Theta_LL, DTheta_LLh, KfL_h, KfL_T, hh_frez, Theta_UU, DTheta_UUh, Theta_II] = SOIL2(SoilConstants, SoilVariables, hh, COR, hThmrl, NN, NL, TT, Tr, Hystrs, XWRE, Theta_s, IH, KIT, Theta_r, Alpha, n, m, Ks, Theta_L, h, Thmrlefc, POR, Theta_II, CORh, hh_frez, h_frez, SWCC, Theta_U, XCAP, Phi_s, RHOI, RHOL, Lamda, Imped, L_f, g, T0, TT_CRIT, KfL_h, KfL_T, KL_h, Theta_UU, Theta_LL, DTheta_LLh, DTheta_UUh, Se);

    for i = 1:ModelSettings.NL
        Theta_L(i, 1) = Theta_LL(i, 1);
        Theta_L(i, 2) = Theta_LL(i, 2);
        XOLD(i) = (Theta_L(i, 1) + Theta_L(i, 2)) / 2; % used in SOIL1!
        Theta_U(i, 1) = Theta_UU(i, 1);
        Theta_U(i, 2) = Theta_UU(i, 2);
        XUOLD(i) = (Theta_U(i, 1) + Theta_U(i, 2)) / 2;
        Theta_I(i, 1) = Theta_II(i, 1);
        Theta_I(i, 2) = Theta_II(i, 2);
        XIOLD(i) = (Theta_I(i, 1) + Theta_I(i, 2)) / 2; % unused!
    end
    SoilVariables.XOLD = XOLD;
    % Using the initial condition to get the initial balance
    % information---Initial heat storage and initial moisture storage.
    SoilVariables.KLT_Switch = 1;
    SoilVariables.DVT_Switch = 1;
    SoilVariables.KaT_Switch = [];
    if ModelSettings.Soilairefc
        SoilVariables.KaT_Switch = 1;
        % these vars are not used in the main script!
        Kaa_Switch = 1;
        DVa_Switch = 1;
        KLa_Switch = 1;
    end

    % TODO after refatoring SOIL2, these two lines can be removed! see issue 96!
    SoilConstants.KfL_T = KfL_T;
    SoilConstants.Theta_II = Theta_II;
    SoilConstants.Theta_I = Theta_I;
    SoilConstants.Theta_UU = Theta_UU;
    SoilConstants.Theta_U = Theta_U;

    SoilVariables.hh_frez = hh_frez;
    SoilVariables.hh = hh;
    SoilVariables.COR = COR;
    SoilVariables.CORh = CORh;
    SoilVariables.Se = Se;
    SoilVariables.KL_h = KL_h;
    SoilVariables.Theta_L = Theta_L;
    SoilVariables.Theta_LL = Theta_LL;
    SoilVariables.DTheta_LLh = DTheta_LLh;
    SoilVariables.KfL_h = KfL_h;
    SoilVariables.KfL_T = KfL_T;
    SoilVariables.Theta_V = Theta_V;
    SoilVariables.Theta_g = Theta_g;
    SoilVariables.DTheta_UUh = DTheta_UUh;
