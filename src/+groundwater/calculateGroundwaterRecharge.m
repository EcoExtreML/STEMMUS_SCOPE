function gwfluxes = calculateGroundwaterRecharge(EnergyVariables, SoilVariables, KT, ModelSettings, GroundwaterSettings)
    %{
        Added by Mostafa, modified after Lianyu
        The concept followed to calculate groundwater recharge can be found in:
        (a) HYDRUS-MODFLOW paper https://doi.org/10.5194/hess-23-637-2019
        (b) and also in STEMMUS-MODFLOW preprint https://doi.org/10.5194/gmd-2022-221
        To calculate groundwater recharge, a water balance analysis is prepared at the moving balancing domain
        The water balance analysis is described in section 2.5 and Figure 2.b (balancing domain) of HYDRUS-MODFLOW paper

                                %%%%%%%%%% Important note %%%%%%%%%%
        The index order for the soil layers in STEMMUS is from bottom to top (NN:1), where NN is the number of STEMMUS soil layers,
        which is the opposite of MODFLOW (top to bottom). So, when converting information between STEMMUS and MODFLOW, indices need to be flipped

        The concept of the moving balancing domain, used in the HYDRUS-MODFLOW paper and also STEMMUS-MODFLOW, is not adopted here (its effect is minor)
        Instead, a different simple approach is followed (extract recharge from the layer above groundwater table)

                                %%%%%%%%%% Variables definitions %%%%%%%%%%
        Equations of the water balance are implemented in this function (Equations 8-13 of HYDRUS-MODFLOW paper) as follows:
        recharge = recharge_init + (SY - sy) * DeltZ, where:

        gwfluxes                structure that includes the outputs (groundwater recharge and it's individual components)
        indxRchrg               index of the soil layer where the recharge is calculated
        recharge                groundwater recharge, which is the upper boundary flux of the top layer of the phreatic aquifer (after the correction of the specific yield)
        recharge_init           upper boundary flux into the moving balancing domain (before the correction of the specific yield)
        SS                      specific storage of MODFLOW aquifers
        SY                      large-scale specific yield of the phreatic aquifer
        sy                      small-scale specific yield (dynamically changing water yield) caused by fluctuation of the water table
        Theta_L                 soil moisture at the start of the current time step (bottom to top)
        Theta_LL                soil moisture at the end of the current time step (bottom to top)
        STheta_L                soil moisture at the start of the current time step (top to bottom)
        STheta_LL               soil moisture at the end of the current time step (top to bottom)
        soilThick               cumulative soil layers thickness (from top to bottom)
        indxAqLay               index of the MODFLOW aquifer that corresponds to each STEMMUS soil layer
        aqlevels                elevation of top surface level and all bottom levels of aquifer layers, received from MODFLOW through BMI
    %}

    % (a) Call the fluxes that contribute to the initial recharge
    % flip the fluxes (because STEMMUS calculations are from bottom to top, and MODFLOW needs the recharge from top to bottom)
    QLh_flip = flip(EnergyVariables.QL_h(1, :)); % liquid flux due to matric potential gradient
    QLT_flip = flip(EnergyVariables.QL_T(1, :)); % liquid flux due to temperature gradient
    QLa_flip = flip(EnergyVariables.QL_a(1, :)); % liquid flux due to air pressure gradient
    QVH_flip = flip(EnergyVariables.QVH(1, :)); % vapor water flux due to matric potential gradient
    QVT_flip = flip(EnergyVariables.QVT(1, :)); % vapor water flux due to temperature gradient
    QVa_flip = flip(EnergyVariables.QVa(1, :)); % vapor water flux due to air pressure gradient
    Q_flip = flip(EnergyVariables.Qtot(1, :)); % total flux (liquid + vapor)

    % (b) Get the recharge_init (before the correction of the specific yield))
    % to avoid a zero flux value at the layer which recharge will be exported
    for j = 1:ModelSettings.NL - 1
        rech_lay = Q_flip(j);
        rech_nextlay = Q_flip(j + 1);
        if (rech_nextlay == 0 || rech_nextlay == -0) && rech_lay ~= 0
            recharge_init = rech_lay;
            indxRchrg = j; % index of the recharge layer
            break
        else
            continue
        end
    end

    %{
    % (c) Calculations of SY
    % Note: In the HYDRUS-MODFLOW paper, Sy (from MODFLOW) was used. In Lianyu STEMMUS_MODFLOW code, a combination of Sy and Ss was used
    aqlevels = GroundwaterSettings.aqlevels; % elevation of top surface level and all bottom levels of aquifer layers
    numAqL = GroundwaterSettings.numAqL; % number of MODFLOW aquifer layers
    soilThick = GroundwaterSettings.soilThick; % cumulative soil layer thickness (from top to bottom)
    indxAqLay = groundwater.calculateIndexAquifer(aqlevels, numAqL, soilThick, ModelSettings.NN); % index of MODFLOW aquifer layers for each STEMMUS soil layer

    K = indxAqLay(indxGWLay_end);
    Thk = aqlevels(1) - aqlevels(K) - depToGWT_end;
    SY = GroundwaterSettings.SY;
    SS = GroundwaterSettings.SS;
    S = (SY(K) - SS(K) * Thk) * (depToGWT_strt - depToGWT_end);

    % (d) Calculations of sy
    Theta_L = SoilVariables.Theta_L;
    Theta_LL = SoilVariables.Theta_LL;
    % Flip the soil moisture from top layer to bottom (opposite of Theta_L)
    STheta_L(1) = Theta_L(ModelSettings.NL, 2);
    STheta_L(2:1:ModelSettings.NN) = Theta_L(ModelSettings.NN - 1:-1:1, 1);
    STheta_LL(1) = Theta_LL(ModelSettings.NL, 2);
    STheta_LL(2:1:ModelSettings.NN) = Theta_LL(ModelSettings.NN - 1:-1:1, 1);

    sy = 0;
    for i = indxRchrg:indxRchrgMax - 1
        sy = sy + 0.5 * (soilThick(i + 1) - soilThick(i)) * (STheta_LL(i) + STheta_LL(i + 1) - STheta_L(i) - STheta_L(i + 1));
    end

    % (e) Aggregate b, c, and d to get recharge
    % recharge = recharge_init + S - sy;
    %}

    % after couple of tests, it appears that the effect of S and sy is very minor, so they are commented but kept in the code for further investigation
    gwfluxes.recharge = recharge_init; % Note: in STEMMUS +ve means up-flow direction and -ve means down (opposite of MODFLOW), so recharge sign needs to be converted in BMI

    if isnan(gwfluxes.recharge) || isinf(gwfluxes.recharge)
        gwfluxes.recharge = 0;
    end

    % check 1
    diff = abs(GroundwaterSettings.indxBotmLayer_R - indxRchrg);
    if diff > 1
        warning('Index of the bottom layer boundary that includes groundwater head ~= index of the recharge layer + 1!');
    end

    % Outputs to be exported in csv or exposed to BMI
    gwfluxes.QLh = QLh_flip(indxRchrg);
    gwfluxes.QLT = QLT_flip(indxRchrg);
    gwfluxes.QLa = QLa_flip(indxRchrg);
    gwfluxes.QVH = QVH_flip(indxRchrg);
    gwfluxes.QVT = QVT_flip(indxRchrg);
    gwfluxes.QVa = QVa_flip(indxRchrg);
    gwfluxes.indxRchrg = indxRchrg;
    % gwfluxes.recharge_init = recharge_init;
    % gwfluxes.S = S;
    % gwfluxes.sy = sy;
end
