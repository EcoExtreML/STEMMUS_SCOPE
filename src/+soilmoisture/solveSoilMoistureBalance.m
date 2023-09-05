function [SoilVariables, HeatMatrices, HeatVariables, HBoundaryFlux, Rn_SOIL, Evap, EVAP, Trap, r_a_SOIL, Srt, CHK, AVAIL0, Precip] = h_sub(SoilVariables, InitialValues, ForcingData, VaporVariables, GasDispersivity, TimeProperties, SoilProperties, ...
                                                                                                                             BoundaryCondition, Delt_t, RHOV, DRHOVh, DRHOVT, D_Ta, hN, RWU, fluxes, KT, hOLD, Srt)

    [HeatVariables, SoilVariables] = hPARM(SoilVariables, VaporVariables, GasDispersivity, InitialValues, ...
                                           RHOV, DRHOVh, DRHOVT, D_Ta);

    HeatMatrices = h_MAT(HeatVariables, InitialValues, Srt);

    [RHS, HeatMatrices, boundaryFluxArray] = h_EQ(InitialValues, SoilVariables, HeatMatrices, Delt_t);

    if BoundaryCondition.NBCh == 3
        [Rn_SOIL, Evap, EVAP, Trap, r_a_SOIL, Srt] = Evap_Cal(InitialValues, ForcingData, SoilVariables, KT, RWU, fluxes, Srt);
    else
        Rn_SOIL = InitialValues.Rn_SOIL;
        Evap = InitialValues.Evap;
        EVAP = InitialValues.EVAP;
        Trap = [];
        r_a_SOIL = InitialValues.r_a_SOIL;
    end

    [AVAIL0, RHS, HeatMatrices, Precip] = h_BC(BoundaryCondition, HeatMatrices, ForcingData, SoilVariables, InitialValues, ...
                                               TimeProperties, SoilProperties, RHS, hN, KT, Delt_t, Evap);

    % TODO issue if should happen, otherwise the output will be empty arrays!
    % TODO issue unused Resis_a
    [CHK, hh, C4] = hh_Solve(HeatMatrices.C4, SoilVariables.hh, HeatMatrices.C4_a, RHS);
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
    % TODO issue: add doc
    HBoundaryFlux = h_Bndry_Flux(boundaryFluxArray, SoilVariables.hh);

end
