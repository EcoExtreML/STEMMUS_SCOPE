function [SoilVariables, Genuchten, initH] = runSubroutine(subRoutine, SoilConstants, SoilProperties, SoilVariables, Genuchten, InitialValues, ImpedF, Dmark, ML)

    initX = InitialValues.initX;
    initT = InitialValues.initT;
    initH = InitialValues.initH;

    switch subRoutine
        case 'subRoutine5'
            from_id = 1;
            to_id = ML + 1;
            indexOfSoilType = 6; % Index of soil type
            indexOfInit = 6; % index of initH and initT
        case 'subRoutine4'
            from_id = Dmark;
            to_id = ML + 1;
            indexOfSoilType = 4; % Index of soil type
            indexOfInit = 5; % index of initH and initT
        case 'subRoutine3'
            from_id = Dmark;
            to_id = ML + 1;
            indexOfSoilType = 4; % Index of soil type
            indexOfInit = 4; % index of initH and initT
        case 'subRoutine2'
            from_id = Dmark;
            to_id = ML + 1;
            indexOfSoilType = 3; % Index of soil type
            indexOfInit = 3; % index of initH and initT
        case 'subRoutine1'
            from_id = Dmark;
            to_id = ML + 1;
            indexOfSoilType = 2; % Index of soil type
            indexOfInit = 2; % index of initH and initT
        case 'subRoutine0'
            from_id = Dmark;
            to_id = SoilConstants.totalNumberOfElements+1;
            indexOfSoilType = 1; % Index of soil type
            indexOfInit = 1; % index of initH and initT
        otherwise
    end

    for i=from_id:to_id
        if subRoutine=='subRoutine5'
            j = i;
        else
            j = i - 1;
        end

        SoilVariables.IS(i) = indexOfSoilType;
        if subRoutine=='subRoutine4'
            SoilVariables.IS(5:8) = 5;
        end

        J = SoilVariables.IS(i);
        [SoilVariables, Genuchten] = init.updateSoilVariables(Genuchten, SoilVariables, SoilConstants, SoilProperties, j, J);
        SoilVariables.Imped(i) = ImpedF(J);

        initH(indexOfInit) = init.updateInitH(initX(indexOfInit), Genuchten, SoilConstants, SoilVariables, j);

        if subRoutine=='subRoutine5'
            Btmh = init.updateBtmh(Genuchten, SoilConstants, SoilVariables, i);
            SoilVariables.T(i) = SoilConstants.BtmT + (i-1) * (initT(indexOfInit) - SoilConstants.BtmT) / ML;
            SoilVariables.h(i) = Btmh + (i-1) * (initH(indexOfInit) - Btmh) / ML;
            SoilVariables.IH(i) = 1;   % Index of wetting history of soil which would be assumed as dry at the first with the value of 1
        elseif subRoutine=='subRoutine0'
            delta1 = SoilConstants.totalNumberOfElements + 2 - Dmark;
            delta2 = ML + 2 - Dmark; %TODO check if it is ML not NL
            domainZ = i - Dmark + 1;
            SoilVariables.T(i) = init.calcSoilTemp(initT(indexOfInit), initT((indexOfInit+1)), delta1, domainZ);
            SoilVariables.h(i) = init.calcSoilTemp(initH(indexOfInit), initH((indexOfInit+1)), delta2, domainZ);
            SoilVariables.IH(j) = 1;
        else
            delta = ML + 2 - Dmark;
            domainZ = i - Dmark + 1;
            SoilVariables.T(i) = init.calcSoilTemp(initT(indexOfInit), initT((indexOfInit+1)), delta, domainZ);
            SoilVariables.h(i) = init.calcSoilMatricHead(initH(indexOfInit), initH((indexOfInit+1)), delta, domainZ);
            SoilVariables.IH(j) = 1;
        end
    end

end
