function HBoundaryFlux = calculatesSoilWaterFluxes(SAVE, hh, GroundwaterSettings)
    %{
        Calculate the soil water fluxes on the boundary node.
    %}
    ModelSettings = io.getModelSettings();

    if ~GroundwaterSettings.GroundwaterCoupling  % Groundwater Coupling is not activated, added by Mostafa
		indxBotm = 1; % index of bottom layer, by defualt (no groundwater coupling) its layer with index 1, since STEMMUS calcuations starts from bottom to top
	else % Groundwater Coupling is activated
        indxBotm = GroundwaterSettings.indxBotmLayer; % index of bottom boundary layer after neglecting the saturated layers (from bottom to top)	
	end

    HBoundaryFlux.QMT = SAVE(2, 1, 1) - SAVE(2, 2, 1) * hh(ModelSettings.NN - 1) - SAVE(2, 3, 1) * hh(ModelSettings.NN);
    HBoundaryFlux.QMB = -SAVE(1, 1, 1) + SAVE(1, 2, 1) * hh(indxBotm) + SAVE(1, 3, 1) * hh(indxBotm + 1);
end
