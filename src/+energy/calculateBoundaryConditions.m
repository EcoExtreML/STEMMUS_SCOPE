function [RHS, EnergyMatrices] = calculateBoundaryConditions(BoundaryCondition, EnergyMatrices, HBoundaryFlux, ForcingData, SoilVariables, ...
                                                             Evap, Delt_t, r_a_SOIL, Rn_SOIL, RHS, L, KT, ModelSettings, GroundwaterSettings)
    %{
        Determine the boundary condition for solving the energy equation, see
        STEMMUS Technical Notes.
    %}

    n = ModelSettings.NN;
    Constants = io.define_constants();

    if ~GroundwaterSettings.GroundwaterCoupling  % no Groundwater coupling, added by Mostafa
        indxBotm = 1; % index of bottom layer is 1, STEMMUS calculates from bottom to top
        tempBotm = BoundaryCondition.BCTB;
    else % Groundwater Coupling is activated
        % index of bottom layer after neglecting saturated layers (from bottom to top)
        indxBotm = GroundwaterSettings.indxBotmLayer;
        tempBotm = GroundwaterSettings.tempBotm; % groundwater temperature
    end

    % Apply the bottom boundary condition called for by BoundaryCondition.NBCTB
    if BoundaryCondition.NBCTB == 1
        RHS(indxBotm) = tempBotm;
        EnergyMatrices.C5(indxBotm, 1) = 1;
        RHS(indxBotm + 1) = RHS(indxBotm + 1) - EnergyMatrices.C5(indxBotm, 2) * RHS(indxBotm);
        EnergyMatrices.C5(indxBotm, 2) = 0;
        EnergyMatrices.C5_a(indxBotm) = 0;
    elseif BoundaryCondition.NBCTB == 2
        RHS(indxBotm) = RHS(indxBotm) + BoundaryCondition.BCTB;
    else
        EnergyMatrices.C5(indxBotm, 1) = EnergyMatrices.C5(indxBotm, 1) - Constants.c_L * Constants.RHOL * HBoundaryFlux.QMB;
    end

    % Apply the surface boundary condition called by BoundaryCondition.NBCT
    if BoundaryCondition.NBCT == 1
        if isreal(SoilVariables.Tss(KT))
            RHS(n) = SoilVariables.Tss(KT);
        else
            RHS(n) = ForcingData.Ta_msr(KT);
        end
        EnergyMatrices.C5(n, 1) = 1;
        RHS(n - 1) = RHS(n - 1) - EnergyMatrices.C5(n - 1, 2) * RHS(n);
        EnergyMatrices.C5(n - 1, 2) = 0;
        EnergyMatrices.C5_a(n - 1) = 0;
    elseif BoundaryCondition.NBCT == 2
        RHS(n) = RHS(n) - BoundaryCondition.BCT;
    else
        L_ts = L(n);
        SH = 0.1200 * Constants.c_a * (SoilVariables.T(n) - ForcingData.Ta_msr(KT)) / r_a_SOIL(KT);
        RHS(n) = RHS(n) + 100 * Rn_SOIL(KT) / 1800 - Constants.RHOL * L_ts * Evap - SH + Constants.RHOL * Constants.c_L * (ForcingData.Ta_msr(KT) * ForcingData.applied_inf + BoundaryCondition.DSTOR0 * SoilVariables.T(n) / Delt_t);    % J cm-2 s-1
    end
end
