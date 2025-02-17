function [QET, QEB] = calculateEnergyFluxes(SAVE, TT, ModelSettings)
    %{
        Calculate the energy fluxes on the boundary nodes, see STEMMUS Technical
        Notes.
    %}

    if ~GroundwaterSettings.GroundwaterCoupling  % no Groundwater coupling, added by Mostafa
        indxBotm = 1; % index of bottom layer is 1, STEMMUS calculates from bottom to top
    else % Groundwater Coupling is activated
        % index of bottom layer after neglecting saturated layers (from bottom to top)
        indxBotm = GroundwaterSettings.indxBotmLayer;
    end

    % So far these are unused vars
    QET = SAVE(2, 1, 2) - SAVE(2, 2, 2) * TT(ModelSettings.NN - 1) - SAVE(2, 3, 2) * TT(ModelSettings.NN);
    QEB = -SAVE(1, 1, 2) + SAVE(1, 2, 2) * TT(indxBotm) + SAVE(1, 3, 2) * TT(indxBotm + 1);
end
