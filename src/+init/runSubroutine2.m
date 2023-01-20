function [SoilVariables, Genuchten, initH] = runSubroutine2(Dmark, SoilConstants, SoilProperties, SoilVariables, Genuchten, initT, initH, initX, ImpedF, ML)

    for i = Dmark:(ML+1) % ML
        j = i - 1;
        SoilVariables.IS(j) = 3;
        J = SoilVariables.IS(j);
        [SoilVariables, Genuchten] = init.updateSoilVariables(Genuchten, SoilVariables, SoilConstants, SoilProperties, j, J);
        SoilVariables.Imped(i) = ImpedF(J);
        initH(3) = init.updateInith(initX(3), Genuchten, SoilConstants, SoilVariables, j);

        delta = ML + 2 - Dmark;
        domainZ = i - Dmark + 1;
        SoilVariables.T(i) = init.calcSoilTemp(initT(3), initT(4), delta, domainZ);
        SoilVariables.h(i) = init.calcSoilMatricHead(initH(3), initH(4), delta, domainZ);
        SoilVariables.IH(j) = 1;
    end

end