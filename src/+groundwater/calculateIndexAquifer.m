function indxAqLay = calculateIndexAquifer(aqLayers, numAqL)
    %{
        Assign the index of the MODFLOW aquifer that corresponds to each STEMMUS
        soil layer.
        aqLayers            elevation of top surface level and all bottom levels of aquifer layers, received from MODFLOW through BMI
        numAqL              number of MODFLOW aquifer layers, received from MODFLOW through BMI
    %}

    numAqN = numAqL + 1; % number of MODFLOW aquifer nodes
    indxAqLay = zeros(NN, 1);
    indxAqLay(1) = 1;
    for i = 2:NN
        for K = 2:numAqN
            Z1 = aqLayers(K - 1);
            Z0 = aqLayers(K);
            ZZ = aqLayers(1) - soilThick(i);
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