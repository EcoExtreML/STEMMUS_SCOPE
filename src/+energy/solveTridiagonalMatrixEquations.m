function [SoilVariables, CHK, RHS, EnergyMatrices] = solveTridiagonalMatrixEquations(EnergyMatrices, SoilVariables, RHS, CHK, GroundwaterSettings)
    %{
        Use Thomas algorithm to solve the tridiagonal matrix equations, which
        is in the form of Equation 4.25, STEMMUS Technical Notes, page 41.
    %}

    ModelSettings = io.getModelSettings();
	
	if ~GroundwaterSettings.GroundwaterCoupling  % Groundwater Coupling is not activated, added by Mostafa
		indxBotm = 1;	
		
	else % Groundwater Coupling is activated, added by Mostafa
        indxBotm = GroundwaterSettings.indxBotmLayer; % index of bottom boundary layer after neglecting the saturated layers (from bottom to top)	
	end
	
	RHS(indxBotm) = RHS(indxBotm) / EnergyMatrices.C5(indxBotm, 1);
	
	for i = indxBotm + 1:ModelSettings.NN
        EnergyMatrices.C5(i, 1) = EnergyMatrices.C5(i, 1) - EnergyMatrices.C5_a(i - 1) * EnergyMatrices.C5(i - 1, 2) / EnergyMatrices.C5(i - 1, 1);
        RHS(i) = (RHS(i) - EnergyMatrices.C5_a(i - 1) * RHS(i - 1)) / EnergyMatrices.C5(i, 1);
    end

    for i = ModelSettings.NL:-1:indxBotm
        RHS(i) = RHS(i) - EnergyMatrices.C5(i, 2) * RHS(i + 1) / EnergyMatrices.C5(i, 1);
    end

    if GroundwaterSettings.GroundwaterCoupling % why?
		for i = indxBotm:-1:2
			RHS(i - 1) = 0; %RHS(i) + cumLayThick(ModelSettings.NN - i + 2) - cumLayThick(ModelSettings.NN - i + 1);	
		end
	end
	
	for i = indxBotm:ModelSettings.NN
        CHK(i) = abs(RHS(i) - SoilVariables.TT(i));
        SoilVariables.TT(i) = RHS(i);
    end
end
