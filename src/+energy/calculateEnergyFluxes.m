function [QET, QEB] = calculateEnergyFluxes(SAVE, TT)
    %{
        Calculate the energy fluxes on the boundary nodes, see STEMMUS Technical
        Notes.
    %}

    ModelSettings = io.getModelSettings();
    n = ModelSettings.NN;

    if ~GroundwaterSettings.GroundwaterCoupling  % Groundwater Coupling is not activated, added by Mostafa
        indxBotm = 1; % index of bottom layer, by defualt (no groundwater coupling) its layer with index 1, since STEMMUS calcuations starts from bottom to top
    else % Groundwater Coupling is activated
        indxBotm = GroundwaterSettings.indxBotmLayer; % index of bottom boundary layer after neglecting the saturated layers (from bottom to top)
    end

    % So far these are unused vars
    QET = SAVE(2, 1, 2) - SAVE(2, 2, 2) * TT(n - 1) - SAVE(2, 3, 2) * TT(n);
    QEB = -SAVE(1, 1, 2) + SAVE(1, 2, 2) * TT(indxBotm) + SAVE(1, 3, 2) * TT(indxBotm + 1);
end
