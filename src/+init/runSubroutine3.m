function [SoilVariables, Genuchten, initH] = runSubroutine3(Dmark, SoilConstants, SoilProperties, SoilVariables, Genuchten, initT, initH, initX, ImpedF, ML)

    for i = Dmark:(ML+1) % ML
        j = i - 1;
        SoilVariables.IS(j) = 4;
        J = SoilVariables.IS(j);
        [SoilVariables, Genuchten] = init.updateSoilVariables(Genuchten, SoilVariables, SoilConstants, SoilProperties, j, J);
        SoilVariables.Imped(i) = ImpedF(J);
        initH(4) = init.updateInith(initX(4), Genuchten, SoilConstants, SoilVariables, j);

        delta = ML + 2 - Dmark;
        domainZ = i - Dmark + 1;
        SoilVariables.T(i) = init.calcSoilTemp(initT(4), initT(5), delta, domainZ);
        SoilVariables.h(i) = init.calcSoilMatricHead(initH(4), initH(5), delta, domainZ);
        SoilVariables.IH(j) = 1;
    end
end