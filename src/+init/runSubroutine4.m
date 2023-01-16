function [SoilVariables, Genuchten, initH] = runSubroutine4(Dmark, SoilConstants, SoilProperties, SoilVariables, Genuchten, initT, initH, initX, ImpedF, ML)

    for i= Dmark:(ML+1) % ML
        j = i - 1;
        SoilVariables.IS(j) = 4;
        SoilVariables.IS(5:8) = 5;
        J = SoilVariables.IS(j);
        SoilVariables.POR(j) = SoilProperties.porosity(J);
        SoilVariables.Ks(j) = SoilProperties.SaturatedK(J);
        SoilVariables.Theta_qtz(j) = SoilConstants.Vol_qtz(J);
        SoilVariables.VPER(j,1) = SoilVariables.VPERS(J);
        SoilVariables.VPER(j,2) = SoilVariables.VPERSL(J);
        SoilVariables.VPER(j,3) = SoilVariables.VPERC(J);
        SoilVariables.XSOC(j) = SoilConstants.VPERSOC(J);
        SoilVariables.Imped(i) = ImpedF(J);
        SoilVariables.XK(j) = 0.11; %0.11 This is for silt loam; For sand XK=0.025

        Genuchten = init.updateGenuchtenParameters(Genuchten, SoilConstants, SoilVariables, SoilProperties, j, J);
        SoilVariables = init.updateSoilVariables(Genuchten, SoilVariables, SoilConstants, SoilProperties, j, J);
        initH(4) = init.updateInith(initX(4), Genuchten, SoilConstants, SoilVariables, j);

        delta = ML + 2 - Dmark;
        domainZ = i - Dmark + 1;
        SoilVariables.T(i) = init.calcSoilTemp(initT(4), initT(5), delta, domainZ);
        SoilVariables.h(i) = init.calcSoilMatricHead(initH(4), initH(5), delta, domainZ);
        SoilVariables.IH(j) = 1;
    end
end