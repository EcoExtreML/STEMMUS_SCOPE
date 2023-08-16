function [SoilVariables, HeatMatrices, HBoundaryFlux, Srt, r_a_SOIL, Trap, Rn_SOIL, CHK, AVAIL0] = h_sub(SoilVariables, InitialValues, ForcingData, VaporVariables, GasDispersivity, ...
                                                                                                         BoundaryCondition, Delt_t, RHOV, DRHOVh, DRHOVT, D_Ta, KL_T, hN, hOLD, RWU, lEstot, lEctot, KT)

    % TODO add SoilVariables to T, TT, Tss in main script
    % TODO check if KT needed
    % TODO issue AVAIL0 and QMT are used to calculate RS in main script which is unused

    % output
    % DTheta_LLh = SoilVariables.DTheta_LLh;
    % DTheta_LLT, CHK, AVAIL0, HBoundaryFlux.QMT, HBoundaryFlux.QMB, Srt, r_a_SOIL
    % Trap, Rn_SOIL, SAVEDTheta_UUh, SAVEDTheta_LLh
    % C5_a = HeatMatrices.C5_a;

    [HeatVariables, SoilVariables] = hPARM(SoilVariables, VaporVariables, GasDispersivity, InitialValues, ...
                                           RHOV, DRHOVh, DRHOVT, D_Ta, KL_T);

    HeatMatrices = h_MAT(HeatVariables, InitialValues);
    [RHS, HeatMatrices, boundaryFluxArray] = h_EQ(InitialValues, SoilVariables, HeatMatrices, Delt_t);

    [AVAIL0, RHS, HeatMatrices, Precip] = h_BC(BoundaryCondition, HeatMatrices, ForcingData, SoilVariables, InitialValues, ...
                                               TimeProperties, SoilProperties, RHS, hN, KT, Delt_t);
    % TODO issue if should happen, otherwise the output will be empty arrays!
    % TODO issue unused Resis_a
    if BoundaryCondition.NBCh ~= 1 || BoundaryCondition.NBCh ~= 2
        [Rn_SOIL, Evap, EVAP, Trap, r_a_SOIL, Srt] = Evap_Cal(InitialValues, ForcingData, SoilVariables, KT, RWU, lEstot, lEctot);
    end

    [CHK, hh, C4, SAVEhh] = hh_Solve(HeatMatrices.C4, SoilVariables.hh, HeatMatrices.C4_a, RHS);
    % update hh
    SoilVariables.hh = hh;

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
    % TODO in main script replace QMT(KT), QMB(KT)
    HBoundaryFlux = h_Bndry_Flux(boundaryFluxArray, SoilVariables.hh);
end
