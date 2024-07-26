function [SoilVariables, HeatMatrices, HeatVariables, HBoundaryFlux, Rn_SOIL, Evap, EVAP, Trap, r_a_SOIL, Srt, CHK, AVAIL0, Precip, RWUs, RWUg, ForcingData] = solveSoilMoistureBalance(SoilVariables, InitialValues, ForcingData, VaporVariables, GasDispersivity, TimeProperties, SoilProperties, ...
                                                                                                                                                                                        BoundaryCondition, Delt_t, RHOV, DRHOVh, DRHOVT, D_Ta, hN, RWU, fluxes, KT, hOLD, Srt, P_gg, ModelSettings, GroundwaterSettings)
    %{
        Solve the soil moisture balance equation with the Thomas algorithm to
        update the soil matric potential 'hh', the finite difference
        time-stepping scheme of this soil moisture equation is derived in
        'STEMMUS Technical Notes' section 4, Equation 4.32.
    %}
    [HeatVariables, SoilVariables] = soilmoisture.calculateMatricCoefficients(SoilVariables, VaporVariables, GasDispersivity, InitialValues, ...
                                                                              RHOV, DRHOVh, DRHOVT, D_Ta, ModelSettings, GroundwaterSettings);

    HeatMatrices = soilmoisture.assembleCoefficientMatrices(HeatVariables, InitialValues, Srt, ModelSettings, GroundwaterSettings);

    [RHS, HeatMatrices, boundaryFluxArray] = soilmoisture.calculateTimeDerivatives(InitialValues, SoilVariables, HeatMatrices, Delt_t, P_gg, ModelSettings, GroundwaterSettings);

    % When BoundaryCondition.NBCh == 3, otherwise Rn_SOIL, Evap, EVAP, Trap,
    % r_a_SOIL, Srt will be empty arrays! see issue 98, item 2
    if BoundaryCondition.NBCh == 3
        [Rn_SOIL, Evap, EVAP, Trap, r_a_SOIL, Srt, RWUs, RWUg] = soilmoisture.calculateEvapotranspiration(InitialValues, ForcingData, SoilVariables, KT, RWU, fluxes, Srt, ModelSettings, GroundwaterSettings);
    else
        Rn_SOIL = InitialValues.Rn_SOIL;
        Evap = InitialValues.Evap;
        EVAP = InitialValues.EVAP;
        Trap = [];
        r_a_SOIL = InitialValues.r_a_SOIL;
    end

    [AVAIL0, RHS, HeatMatrices, Precip, ForcingData] = soilmoisture.calculateBoundaryConditions(BoundaryCondition, HeatMatrices, ForcingData, SoilVariables, InitialValues, ...
                                                                                                TimeProperties, SoilProperties, RHS, hN, KT, Delt_t, Evap, ModelSettings, GroundwaterSettings);

    [CHK, hh, C4] = soilmoisture.solveTridiagonalMatrixEquations(HeatMatrices.C4, SoilVariables.hh, HeatMatrices.C4_a, RHS, ModelSettings, GroundwaterSettings);

    % update structures
    SoilVariables.hh = hh;
    HeatMatrices.C4 = C4;

    % fix hh values
    if ~GroundwaterSettings.GroundwaterCoupling  % no Groundwater coupling, added by Mostafa
        indxBotm = 1; % index of bottom layer is 1, STEMMUS calculates from bottom to top
    else % Groundwater Coupling is activated
        % index of bottom layer after neglecting saturated layers (from bottom to top)
        indxBotm = GroundwaterSettings.indxBotmLayer;
    end

    for i = indxBotm:ModelSettings.NN
        if isnan(SoilVariables.hh(i)) || SoilVariables.hh(i) <= -1E12
            SoilVariables.hh(i) = hOLD(i);
        end
        if SoilVariables.hh(i) > -1e-6
            SoilVariables.hh(i) = -1e-6;
        end
    end

    % calculate boundary flux
    HBoundaryFlux = soilmoisture.calculatesSoilWaterFluxes(boundaryFluxArray, SoilVariables.hh, ModelSettings, GroundwaterSettings);

end
