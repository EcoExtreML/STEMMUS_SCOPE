function indxAqLay = calculateIndexAquifer(aqlevels, numAqL, soilThick)
    %{
        Assign the index of the MODFLOW aquifer that corresponds to each STEMMUS soil layer.
        aqlevels            elevation of top surface level and all bottom levels of aquifer layers
        numAqL              number of MODFLOW aquifer layers, received from MODFLOW through BMI
    %}

    % Load model settings
    ModelSettings = io.getModelSettings();

    numAqN = numAqL + 1; % number of MODFLOW aquifer nodes
    indxAqLay = zeros(ModelSettings.NN, 1);
    indxAqLay(1) = 1;
    for i = 2:ModelSettings.NN
        for K = 2:numAqN
            Z1 = aqlevels(K - 1);
            Z0 = aqlevels(K);
            ZZ = aqlevels(1) - soilThick(i);
            if ZZ <= Z1 && ZZ > Z0
                indxAqLay(i) = K - 1;
                break
            elseif ZZ == Z0 && K == numAqN
                indxAqLay(i) = K - 1;
                break
            end
        end
    end
end
