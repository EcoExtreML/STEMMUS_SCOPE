function SoilLayerSettings = readSoilLayerSettings(soildata)

    SoilLayerSettings.NL = soildata(end, 1);

    SoilLayerSettings.DeltZ_R = transpose(soildata(:, 2));

    SoilLayerSettings.Tot_Depth = sum(SoilLayerSettings.DeltZ_R);

    SoilLayerSettings.R_depth = soildata(1, 3);

end
