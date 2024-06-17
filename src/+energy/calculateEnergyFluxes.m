function [QET, QEB] = calculateEnergyFluxes(SAVE, TT)
    %{
        Calculate the energy fluxes on the boundary nodes, see STEMMUS Technical
        Notes.
    %}

    ModelSettings = io.getModelSettings();
    n = ModelSettings.NN;
    QET = SAVE(2, 1, 2) - SAVE(2, 2, 2) * TT(n - 1) - SAVE(2, 3, 2) * TT(n);
    QEB = -SAVE(1, 1, 2) + SAVE(1, 2, 2) * TT(1) + SAVE(1, 3, 2) * TT(2);
end
