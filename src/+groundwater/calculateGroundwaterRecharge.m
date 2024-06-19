function [depToGWT_end, indxGWLay_end, gwfluxes] = calculateGroundwaterRecharge(EnergyVariables, SoilVariables, depToGWT_strt, indxGWLay_strt, KT, GroundwaterSettings)
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

                                %%%%%%%%%% Variables definitions %%%%%%%%%%
        Equations of the water balance are implemented in this function (Equations 8-13 of HYDRUS-MODFLOW paper) as follows:
        recharge = recharge_init + (SY - sy) * DeltZ, where:

        gwfluxes                structure that includes the outputs (groundwater recharge and its individual components)
        recharge                groundwater recharge, which is the upper boundary flux of the top layer of the phreatic aquifer (after the correction of the specific yield)
        recharge_init           upper boundary flux into the moving balancing domain (before the correction of the specific yield)
        SS                      specific storage of MODFLOW aquifers
        SY                      large-scale specific yield of the phreatic aquifer
        sy                      small-scale specific yield (dynamically changing water yield) caused by fluctuation of the water table
        depToGWT_strt           soil layer thickness from the top of the soil up to the phreatic surface at the start of the current time step
        indxGWLay_strt          index of the soil layer that includes the phreatic surface at the start of the current time step
        depToGWT_end            soil layer thickness from the top of the soil up to the phreatic surface at the end of the current time step
        indxGWLay_end           index of the soil layer that includes the phreatic surface at the end of the current time step
        Theta_L                 soil moisture at the start of the current time step (bottom to top)
        Theta_LL                soil moisture at the end of the current time step (bottom to top)
        STheta_L                soil moisture at the start of the current time step (top to bottom)
        STheta_LL               soil moisture at the end of the current time step (top to bottom)
        soilThick               cumulative soil layers thickness (from top to bottom)
        indxAqLay               index of the MODFLOW aquifer that corresponds to each STEMMUS soil layer
        aqLayers                elevation of top surface level and all bottom levels of aquifer layers, received from MODFLOW through BMI
    %}

    % Start Recharge calculations
    if GroundwaterSettings.GroundwaterCoupling == 1 % Groundwater coupling is enabled
        % (a) Define the upper and lower boundaries of the moving balancing domain
        % the moving balancing domain is located between depToGWT_strt and depToGWT_end
        [depToGWT_end, indxGWLay_end] = groundwater.findPhreaticSurface(SoilVariables, KT, GroundwaterSettings);
        % indxRchrg and indxRchrgMax are the indecies of the upper and lower levels of the moving boundary
        % Following the HYDRUS-MODFLOW paper and also STEMMUS-MODFLOW, indxRchrg and indxRchrgMax are defined as in the next two lines
        indxRchrgMax = max(indxGWLay_strt, indxGWLay_end) + 2; % the positive 2 is a user-specified value to define lower boundary of the moving boundary
        % indxRchrg = min(indxGWLay_strt, indxGWLay_end) - 3; % the negative 2 or 3 is a user-specified value to define upper boundary of the moving boundary
        % However, I comment the line above and use a slightly different way (ignore the moving layer boundaries and extract recharge from the two layers above groundwater table)
        indxRchrg = min(indxGWLay_strt, indxGWLay_end) - 1;
        indxRchrg_above = min(indxGWLay_strt, indxGWLay_end) - 2;

        % (b) Call the fluxes to get the initial recharge
        % flip the fluxes (because STEMMUS calculations are from bottom to top, and MODFLOW needs the recharge from top to bottom)
        QLh_flip = flip(EnergyVariables.QL_h(1, :)); % liquid flux due to matric potential gradient
        QLT_flip = flip(EnergyVariables.QL_T(1, :)); % liquid flux due to temperature gradient
        QLa_flip = flip(EnergyVariables.QL_a(1, :)); % liquid flux due to air pressure gradient
        QVH_flip = flip(EnergyVariables.QVH(1, :)); % vapor water flux due to matric potential gradient
        QVT_flip = flip(EnergyVariables.QVT(1, :)); % vapor water flux due to temperature gradient
        QVa_flip = flip(EnergyVariables.QVa(1, :)); % vapor water flux due to air pressure gradient
        Q_flip = flip(EnergyVariables.Qtot(1, :)); % total flux (liquid + vapor)

        % (c) Get the recharge_init (before the correction of the specific yeild))
        % to avoid a zero flux value at the layer which recharge will be exporated
        if Q_flip(indxRchrg) == 0
            recharge_init = Q_flip(indxRchrg_above);
        else
            recharge_init = Q_flip(indxRchrg); % mean([Q_flip(indxRchrg), Q_flip(indxRchrg_above)])
        end

        % (d) Calculations of SY
        % Note: In the HYDRUS-MODFLOW paper, Sy (from MODFLOW) was used. In Lianyu STEMMUS_MODFLOW code, a combination of Sy and Ss was used
        indxAqLay = GroundwaterSettings.indxAqLay; % index of MODFLOW aquifer layers for each STEMMUS soil layer
        aqLayers = GroundwaterSettings.aqLayers; % elevation of top surface level and all bottom levels of aquifer layers
        K = indxAqLay(indxGWLay_end);
        Thk = aqLayers(1) - aqLayers(K) - depToGWT_end;
        SY = GroundwaterSettings.SY;
        SS = GroundwaterSettings.SS;
        S = (SY(K) - SS(K) * Thk) * (depToGWT_strt - depToGWT_end);

        % (e) Calculations of sy
        soilThick = GroundwaterSettings.soilThick; % cumulative soil layer thickness (from top to bottom)
        ModelSettings = io.getModelSettings();
        NN = ModelSettings.NN; % Number of nodes
        NL = ModelSettings.NL; % Number of layers
        Theta_L = SoilVariables.Theta_L;
        Theta_LL = SoilVariables.Theta_LL;
        % Flip the soil moisture from top layer to bottom (opposite of Theta_L)
        STheta_L(1) = Theta_L(NL, 2);
        STheta_L(2:1:NN) = Theta_L(NN - 1:-1:1, 1);
        STheta_LL(1) = Theta_LL(NL, 2);
        STheta_LL(2:1:NN) = Theta_LL(NN - 1:-1:1, 1);

        sy = 0;
        for i = indxRchrg:indxRchrgMax - 1
            sy = sy + 0.5 * (soilThick(i + 1) - soilThick(i)) * (STheta_LL(i) + STheta_LL(i + 1) - STheta_L(i) - STheta_L(i + 1));
        end

        % (f) Aggregate c, d, and e to get recharge
        % after couple of testing, it appears that the effect of S and sy is very minor, so they are removed but kept in the code for further investigation
        % recharge = recharge_init + S - sy;
        gwfluxes.recharge = recharge_init; % Note: in STEMMUS +ve means up-flow direction and -ve means down (opposite of MODFLOW), so recharge sign needs to be converted in BMI

        if isnan(recharge) || isinf(recharge)
            gwfluxes.recharge = 0;
        end

        % Outputs to be exported in csv
        gwfluxes.QLh = QLh_flip(indxRchrg);
        gwfluxes.QLT = QLT_flip(indxRchrg);
        gwfluxes.QLa = QLa_flip(indxRchrg);
        gwfluxes.QVH = QVH_flip(indxRchrg);
        gwfluxes.QVT = QVT_flip(indxRchrg);
        gwfluxes.QVa = QVa_flip(indxRchrg);
        % gwfluxes.recharge_init = recharge_init;
        % gwfluxes.S = S;
        % gwfluxes.sy = sy;
    end
end
