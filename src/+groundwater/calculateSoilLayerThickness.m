function soilThick = calculateSoilLayerThickness()
    %{
        Calculate soil layers thickness (cumulative layers thickness; e.g. 1, 2,
        3, 5, 10, ......., 480, total soil depth)

        soilThick           cumulative soil layers thickness (from top to bottom)

    %}

    % Load model settings
    ModelSettings = io.getModelSettings();

    soilThick = zeros(ModelSettings.NN, 1); % cumulative soil layers thickness
    soilThick(1) = 0;

    for i = 2:ModelSettings.NL
        soilThick(i) = soilThick(i - 1) + ModelSettings.DeltZ_R(i - 1);
    end
    soilThick(ModelSettings.NN) = ModelSettings.Tot_Depth; % total soil depth

end
