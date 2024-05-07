function [CHK, hh, C4] = solveTridiagonalMatrixEquations(C4, hh, C4_a, RHS, GroundwaterSettings)
    %{
        Solve the tridiagonal matrix equations using Thomas algorithm, which is
        in the form of Equation 4.25 (STEMMUS Technical Notes, page 41).
    %}
    ModelSettings = io.getModelSettings();

    if ~GroundwaterSettings.GroundwaterCoupling  % Groundwater Coupling is not activated, added by Mostafa
		indxBotm = 1; % index of bottom layer, by defualt (no groundwater coupling) its layer with index 1, since STEMMUS calcuations starts from bottom to top
	
	else % Groundwater Coupling is activated, added by Mostafa
        cumLayThick = GroundwaterSettings.cumLayThick; % cumulative soil layers thickness
        indxBotm = GroundwaterSettings.indxBotmLayer; % index of bottom boundary layer after neglecting the saturated layers (from bottom to top)	
	end
	
	RHS(indxBotm) = RHS(indxBotm) / C4(indxBotm, 1);
	
	for i = indxBotm + 1:ModelSettings.NN
		C4(i, 1) = C4(i, 1) - C4_a(i - 1) * C4(i - 1, 2) / C4(i - 1, 1);
		RHS(i) = (RHS(i) - C4_a(i - 1) * RHS(i - 1)) / C4(i, 1);
	end

	for i = ModelSettings.NL:-1:indxBotm
		RHS(i) = RHS(i) - C4(i, 2) * RHS(i + 1) / C4(i, 1);
	end
	
    if GroundwaterSettings.GroundwaterCoupling % why?
		for i = indxBotm:-1:2
			RHS(i - 1) = RHS(i) + cumLayThick(ModelSettings.NN - i + 2) - cumLayThick(ModelSettings.NN - i + 1); % check to replace it by DeltaZ_R(i)	
		end
	end
	
	for i = indxBotm:ModelSettings.NN
        CHK(i) = abs(RHS(i) - hh(i));
        hh(i) = RHS(i);
        SAVEhh(i) = hh(i);
    end

    if GroundwaterSettings.GroundwaterCoupling % why -> will make all hh of saturated layers = zero	
		for i = indxBotm:-1:1
			hh(i) = RHS(i);
		end
	end
	
    if any(isnan(SAVEhh)) == 1 || any(~isreal(SAVEhh))
        warning('\n some items of SAVEhh are nan or not real\r');
    end
end
