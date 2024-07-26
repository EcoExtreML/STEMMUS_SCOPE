function [SoilVariables, VanGenuchten, ThermalConductivity] = StartInit(SoilVariables, SoilProperties, VanGenuchten, ModelSettings)

    Ksh = repelem(18 / (3600 * 24), 6);
    BtmKsh = Ksh(6);
    Ksh0 = Ksh(1);

    LatentHeatOfFreezing = 3.34 * 1e5; % latent heat of freezing fusion i Kg-1
    KIT = 0; % KIT is used to count the number of iteration in a time step;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% Considering soil hetero effect modify date: 20170103 %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [SoilVariables, VanGenuchten] = init.applySoilHeteroEffect(SoilProperties, SoilVariables, VanGenuchten, ModelSettings);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% Considering soil hetero effect modify date: 20170103 %%%%%%%%%%%%
    %%%%%% Perform initial freezing temperature for each soil type.%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    SoilVariables = init.applySoilHeteroWithInitialFreezing(LatentHeatOfFreezing, SoilVariables, ModelSettings);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% Perform initial thermal calculations for each soil type.%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ThermalConductivity = init.calculateInitialThermal(SoilVariables, VanGenuchten, ModelSettings);

    % SoilVariables will be updated in UpdateSoilWaterContent
    SoilVariables = UpdateSoilWaterContent(KIT, LatentHeatOfFreezing, SoilVariables, VanGenuchten, ModelSettings);

    Theta_L = SoilVariables.Theta_L;
    Theta_I = SoilVariables.Theta_I;
    Theta_U = SoilVariables.Theta_U;

    Theta_LL = SoilVariables.Theta_LL;
    Theta_UU = SoilVariables.Theta_UU;
    Theta_II = SoilVariables.Theta_II;

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
    SoilVariables.DVa_Switch = [];
    SoilVariables.KLa_Switch = [];
    if ModelSettings.Soilairefc
        SoilVariables.KaT_Switch = 1;
        SoilVariables.DVa_Switch = 1;
        SoilVariables.KLa_Switch = 1;
    end

    SoilVariables.Theta_I = Theta_I;
    SoilVariables.Theta_U = Theta_U;
    SoilVariables.Theta_L = Theta_L;
end
