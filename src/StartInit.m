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

    Theta_L = SoilConstants.Theta_L;
    Theta_I = SoilConstants.Theta_I;
    Theta_U = SoilConstants.Theta_U;
    [SoilConstants, SoilVariables] = SOIL2(SoilConstants, SoilVariables, VanGenuchten);

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

    SoilConstants.Theta_I = Theta_I;
    SoilConstants.Theta_U = Theta_U;
    SoilVariables.Theta_L = Theta_L;
end
