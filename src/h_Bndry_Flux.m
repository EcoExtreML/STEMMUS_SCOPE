function HBoundaryFlux = h_Bndry_Flux(SAVE, hh)
    ModelSettings = io.getModelSettings();

    HBoundaryFlux.QMT = SAVE(2, 1, 1) - SAVE(2, 2, 1) * hh(ModelSettings.NN - 1) - SAVE(2, 3, 1) * hh(ModelSettings.NN);
    HBoundaryFlux.QMB = -SAVE(1, 1, 1) + SAVE(1, 2, 1) * hh(1) + SAVE(1, 3, 1) * hh(2);
end
