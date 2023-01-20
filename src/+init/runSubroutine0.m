function [SoilVariables, Genuchten, initH] = runSubroutine0(Dmark, SoilConstants, SoilProperties, SoilVariables, Genuchten, initT, initH, initX, ImpedF, ML)

    for i = Dmark:(SoilConstants.totalNumberOfElements+1) % NL
        j = i - 1;
        SoilVariables.IS(j) = 1;
        J = SoilVariables.IS(j);
        [SoilVariables, Genuchten] = init.updateSoilVariables(Genuchten, SoilVariables, SoilConstants, SoilProperties, j, J);
        SoilVariables.Imped(i) = ImpedF(J);
        initH(1) = init.updateInith(initX(1), Genuchten, SoilConstants, SoilVariables, j);

        delta1 = SoilConstants.totalNumberOfElements + 2 - Dmark;
        delta2 = ML + 2 - Dmark; %TODO check if it is ML not NL
        domainZ = i - Dmark + 1;
        SoilVariables.T(i) = init.calcSoilTemp(initT(1), initT(2), delta1, domainZ);
        SoilVariables.h(i) = init.calcSoilTemp(initH(1), initH(2), delta2, domainZ);
        SoilVariables.IH(j) = 1;
    end

end