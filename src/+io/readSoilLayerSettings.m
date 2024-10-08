function SoilLayerSettings = readSoilLayerSettings(soilLayersFile)
    soildata = dlmread(soilLayersFile, ',', 1, 0);  % skip column names

    SoilLayerSettings.NL = soildata(end, 1);
    SoilLayerSettings.ML = SoilLayerSettings.NL;

    SoilLayerSettings.DeltZ_R = transpose(soildata(:, 2));
    SoilLayerSettings.DeltZ = flip(SoilLayerSettings.DeltZ_R);

    SoilLayerSettings.Tot_Depth = sum(SoilLayerSettings.DeltZ_R);
    SoilLayerSettings.R_depth = soildata(1, 3);
end
