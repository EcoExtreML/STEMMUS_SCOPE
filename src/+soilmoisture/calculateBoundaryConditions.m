function [AVAIL0, RHS, HeatMatrices, Precip] = calculateBoundaryConditions(BoundaryCondition, HeatMatrices, ForcingData, SoilVariables, InitialValues, ...
                                                                           TimeProperties, SoilProperties, RHS, hN, KT, Delt_t, Evap)
    %{
        Determine the boundary condition for solving the soil moisture equation.
    %}
    ModelSettings = io.getModelSettings();
    % n is the index of n_th item
    n = ModelSettings.NN;

    C4 = HeatMatrices.C4;
    C4_a = HeatMatrices.C4_a;

    Precip = InitialValues.Precip;
    Precip_msr = ForcingData.Precip_msr;

    Precipp = 0;
    %  Apply the bottom boundary condition called for by BoundaryCondition.NBChB
    if BoundaryCondition.NBChB == 1            %  Specify matric head at bottom to be ---BoundaryCondition.BChB;
        RHS(1) = BoundaryCondition.BChB;
        C4(1, 1) = 1;
        RHS(2) = RHS(2) - C4(1, 2) * RHS(1);
        C4(1, 2) = 0;
        C4_a(1) = 0;
    elseif BoundaryCondition.NBChB == 2        %  Specify flux at bottom to be ---BoundaryCondition.BChB (Positive upwards);
        RHS(1) = RHS(1) + BoundaryCondition.BChB;
    elseif BoundaryCondition.NBChB == 3        %  BoundaryCondition.NBChB=3,Gravity drainage at bottom--specify flux= hydraulic conductivity;
        RHS(1) = RHS(1) - SoilVariables.KL_h(1, 1);
    end

    %  Apply the surface boundary condition called for by BoundaryCondition.NBCh
    if BoundaryCondition.NBCh == 1             %  Specified matric head at surface---equal to hN;
        % TODO issue h_SUR is not calculated anywhere!
        RHS(n) = InitialValues.h_SUR(KT);
        C4(n, 1) = 1;
        RHS(n - 1) = RHS(n - 1) - C4(n - 1, 2) * RHS(n);
        C4(n - 1, 2) = 0;
        C4_a(n - 1) = 0;
    elseif BoundaryCondition.NBCh == 2
        if BoundaryCondition.NBChh == 1
            RHS(n) = hN;
            C4(n, 1) = 1;
            RHS(n - 1) = RHS(n - 1) - C4(n - 1, 2) * RHS(n);
            C4(n - 1, 2) = 0;
        else
            RHS(n) = RHS(n) - BoundaryCondition.BCh;   % a specified matric head (saturation or dryness)was applied;
        end
    else
        Precip_msr(KT) = min(Precip_msr(KT), SoilProperties.Ks0 / (3600 * 24) * TimeProperties.DELT * 10);
        Precip_msr(KT) = min(Precip_msr(KT), SoilProperties.theta_s0 * 50 - ModelSettings.DeltZ(51:54) * SoilVariables.Theta_UU(51:54, 1) * 10);

        if SoilVariables.Tss(KT) > 0
            Precip(KT) = Precip_msr(KT) * 0.1 / TimeProperties.DELT;
        else
            Precip(KT) = Precip_msr(KT) * 0.1 / TimeProperties.DELT;
            Precipp = Precipp + Precip(KT);
            Precip(KT) = 0;
        end

        if SoilVariables.Tss(KT) > 0
            AVAIL0 = Precip(KT) + Precipp + BoundaryCondition.DSTOR0 / Delt_t;
            Precipp = 0;
        else
            AVAIL0 = Precip(KT) + BoundaryCondition.DSTOR0 / Delt_t;
        end

        if BoundaryCondition.NBChh == 1
            RHS(n) = hN;
            C4(n, 1) = 1;
            RHS(n - 1) = RHS(n - 1) - C4(n - 1, 2) * RHS(n);
            C4(n - 1, 2) = 0;
            C4_a(n - 1) = 0;
        else
            RHS(n) = RHS(n) + AVAIL0 - Evap(KT);
        end
    end
    HeatMatrices.C4 = C4;
    HeatMatrices.C4_a = C4_a;
end
