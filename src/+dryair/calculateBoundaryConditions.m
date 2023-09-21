function [RHS, AirMatrices] = calculateBoundaryConditions(BoundaryCondition, AirMatrices, ForcingData, RHS, KT)
    %{
        Determine the boundary condition for solving the dry air equation.
    %}

    TopPg = 100 .* (ForcingData.Pg_msr);
    ModelSettings = io.getModelSettings();
    n = ModelSettings.NN;

    % Apply the bottom boundary condition called for by NBCPB
    if BoundaryCondition.NBCPB == 1  % Bounded bottom with the water table
        RHS(1) = BtmPg;
        AirMatrices.C6(1, 1) = 1;
        RHS(2) = RHS(2) - AirMatrices.C6(1, 2) * RHS(1);
        AirMatrices.C6(1, 2) = 0;
        AirMatrices.C6_a(1) = 0;
    elseif BoundaryCondition.NBCPB == 2  % The soil air is allowed to escape from the bottom
        RHS(1) = RHS(1) + BoundaryCondition.BCPB;
    end

    % Apply the surface boundary condition called by NBCP
    if BoundaryCondition.NBCP == 1  % Ponded infiltration with Bonded bottom
        RHS(n) = BtmPg;
        AirMatrices.C6(n, 1) = 1;
        RHS(n - 1) = RHS(n - 1) - AirMatrices.C6(n - 1, 2) * RHS(n);
        AirMatrices.C6(n - 1, 2) = 0;
        AirMatrices.C6_a(n - 1) = 0;
    elseif BoundaryCondition.NBCP == 2  % Specified flux on the surface
        RHS(n) = RHS(n) - BoundaryCondition.BCP;
    else
        RHS(n) = TopPg(KT);
        AirMatrices.C6(n, 1) = 1;
        RHS(n - 1) = RHS(n - 1) - AirMatrices.C6(n - 1, 2) * RHS(n);
        AirMatrices.C6(n - 1, 2) = 0;
        AirMatrices.C6_a(n - 1) = 0;
    end
end
