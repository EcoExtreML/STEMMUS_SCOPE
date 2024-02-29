function [SoilVariables, HeatMatrices, HeatVariables, HBoundaryFlux, Rn_SOIL, Evap, EVAP, Trap, r_a_SOIL, Srt, CHK, AVAIL0, Precip] = solveSoilMoistureBalance(SoilVariables, InitialValues, ForcingData, VaporVariables, GasDispersivity, TimeProperties, SoilProperties, ...
                                                                                                                                                               BoundaryCondition, Delt_t, RHOV, DRHOVh, DRHOVT, D_Ta, hN, RWU, fluxes, KT, hOLD, Srt, P_gg, GroundwaterSettings)
    %{
        Solve the soil moisture balance equation with the Thomas algorithm to
        update the soil matric potential 'hh', the finite difference
        time-stepping scheme of this soil moisture equation is derived in
        'STEMMUS Technical Notes' section 4, Equation 4.32.
    %}
    [HeatVariables, SoilVariables] = soilmoisture.calculateMatricCoefficients(SoilVariables, VaporVariables, GasDispersivity, InitialValues, ...
                                                                              RHOV, DRHOVh, DRHOVT, D_Ta);

    HeatMatrices = soilmoisture.assembleCoefficientMatrices(HeatVariables, InitialValues, Srt);

    [RHS, HeatMatrices, boundaryFluxArray] = soilmoisture.calculateTimeDerivatives(InitialValues, SoilVariables, HeatMatrices, Delt_t, P_gg);

    % When BoundaryCondition.NBCh == 3, otherwise Rn_SOIL, Evap, EVAP, Trap,
    % r_a_SOIL, Srt will be empty arrays! see issue 98, item 2
    if BoundaryCondition.NBCh == 3
        [Rn_SOIL, Evap, EVAP, Trap, r_a_SOIL, Srt] = soilmoisture.calculateEvapotranspiration(InitialValues, ForcingData, SoilVariables, KT, RWU, fluxes, Srt);
    else
        Rn_SOIL = InitialValues.Rn_SOIL;
        Evap = InitialValues.Evap;
        EVAP = InitialValues.EVAP;
        Trap = [];
        r_a_SOIL = InitialValues.r_a_SOIL;
    end
  
    [AVAIL0, RHS, HeatMatrices, Precip] = soilmoisture.calculateBoundaryConditions(BoundaryCondition, HeatMatrices, ForcingData, SoilVariables, InitialValues, ...
                                                                                   TimeProperties, SoilProperties, RHS, hN, KT, Delt_t, Evap, GroundwaterSettings);

    [CHK, hh, C4] = soilmoisture.solveTridiagonalMatrixEquations(HeatMatrices.C4, SoilVariables.hh, HeatMatrices.C4_a, RHS);
    % update structures
    SoilVariables.hh = hh;
    HeatMatrices.C4 = C4;

    % fix hh values
    ModelSettings = io.getModelSettings();
    for i = 1:ModelSettings.NN
        if isnan(SoilVariables.hh(i)) || SoilVariables.hh(i) <= -1E12
            SoilVariables.hh(i) = hOLD(i);
        end
        if SoilVariables.hh(i) > -1e-6
            SoilVariables.hh(i) = -1e-6;
        end
    end

    % calculate boundary flux
    HBoundaryFlux = soilmoisture.calculatesSoilWaterFluxes(boundaryFluxArray, SoilVariables.hh);

end
