function HBoundaryFlux = calculatesSoilWaterFluxes(SAVE, hh, GroundwaterSettings)
    %{
        Calculate the soil water fluxes on the boundary node.
    %}
    ModelSettings = io.getModelSettings();

    if ~GroundwaterSettings.GroundwaterCoupling  % no Groundwater coupling, added by Mostafa
        indxBotm = 1; % index of bottom layer is 1, STEMMUS calculates from bottom to top
    else % Groundwater Coupling is activated
        % index of bottom layer after neglecting saturated layers (from bottom to top)           
        indxBotm = GroundwaterSettings.indxBotmLayer;
    end

    HBoundaryFlux.QMT = SAVE(2, 1, 1) - SAVE(2, 2, 1) * hh(ModelSettings.NN - 1) - SAVE(2, 3, 1) * hh(ModelSettings.NN);
    HBoundaryFlux.QMB = -SAVE(1, 1, 1) + SAVE(1, 2, 1) * hh(indxBotm) + SAVE(1, 3, 1) * hh(indxBotm + 1);
end
