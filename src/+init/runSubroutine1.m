function [SoilVariables, Genuchten, initH] = runSubroutine1(Dmark, SoilConstants, SoilProperties, SoilVariables, Genuchten, initT, initH, initX, ImpedF, ML)

    for i = Dmark:(ML+1) % ML
        j = i - 1;
        SoilVariables.IS(j) = 2;
        J=SoilVariables.IS(j);
        [SoilVariables, Genuchten] = init.updateSoilVariables(Genuchten, SoilVariables, SoilConstants, SoilProperties, j, J);
        SoilVariables.Imped(i) = ImpedF(J);
        initH(2) = init.updateInith(initX(2), Genuchten, SoilConstants, SoilVariables, j);
        delta = ML + 2 - Dmark;
        domainZ = i - Dmark + 1;
        SoilVariables.T(i) = init.calcSoilTemp(initT(2), initT(3), delta, domainZ);
        SoilVariables.h(i) = init.calcSoilMatricHead(initH(2), initH(3), delta, domainZ);
        SoilVariables.IH(j)=1;
    end

end