function [RHS, AirMatrices] = calculateBoundaryConditions(BoundaryCondition, AirMatrices, ForcingData, RHS, KT, GroundwaterSettings)
    %{
        Determine the boundary condition for solving the dry air equation.
    %}

    TopPg = 100 .* (ForcingData.Pg_msr);
    ModelSettings = io.getModelSettings();
    n = ModelSettings.NN;

    if ~GroundwaterSettings.GroundwaterCoupling  % Groundwater Coupling is not activated, added by Mostafa
		indxBotm = 1; % index of bottom layer, by defualt (no groundwater coupling) its layer with index 1, since STEMMUS calcuations starts from bottom to top
		BtmPg = BtmPg;
	else % Groundwater Coupling is activated
        indxBotm = GroundwaterSettings.indxBotmLayer; % index of bottom boundary layer after neglecting the saturated layers (from bottom to top)	
		BtmPg = GroundwaterSettings.BtmPg;
	end	

    % Apply the bottom boundary condition called for by NBCPB
    if BoundaryCondition.NBCPB == 1  % Bounded bottom with the water table
        RHS(indxBotm) = BtmPg;
        AirMatrices.C6(indxBotm, 1) = 1;
        RHS(indxBotm + 1) = RHS(indxBotm + 1) - AirMatrices.C6(indxBotm, 2) * RHS(indxBotm);
        AirMatrices.C6(indxBotm, 2) = 0;
        AirMatrices.C6_a(indxBotm) = 0;
    elseif BoundaryCondition.NBCPB == 2  % The soil air is allowed to escape from the bottom
        RHS(indxBotm) = RHS(indxBotm) + BoundaryCondition.BCPB;
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
