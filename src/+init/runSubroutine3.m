function [SoilVariables, Genuchten, initH] = runSubroutine3(Dmark, SoilConstants, SoilProperties, SoilVariables, Genuchten, initT, initH, initX, ImpedF, ML)

    for i = Dmark:(ML+1) % ML
        j = i -1;
        SoilVariables.IS(j) = 4;
        J = SoilVariables.IS(j);
        SoilVariables.POR(j) = SoilProperties.porosity(J);
        SoilVariables.Ks(j) = SoilProperties.SaturatedK(J);
        SoilVariables.Theta_qtz(j) = SoilConstants.Vol_qtz(J);
        SoilVariables.VPER(j,1) = SoilConstants.VPERS(J);
        SoilVariables.VPER(j,2) = SoilConstants.VPERSL(J);
        SoilVariables.VPER(j,3) = SoilConstants.VPERC(J);
        SoilVariables.XSOC(j) = SoilConstants.VPERSOC(J);
        SoilVariables.Imped(i) = SoilConstants.ImpedF(J);
        SoilVariables.XK(j) = 0.11; %0.0550.11 This is for silt loam; For sand XK=0.025

        Genuchten = init.updateGenuchtenParameters(Genuchten, SoilConstants, SoilVariables, SoilProperties, j, J);
        SoilVariables = init.updateSoilVariables(Genuchten, SoilVariables, SoilConstants, SoilProperties, i, j);
        initH(3) = init.updateInith(initX(3), Genuchten, SoilConstants, SoilVariables, j);

        delta = ML + 2 - Dmark;
        domainZ = i - Dmark + 1;
        SoilVariables.T(i) = init.calcSoilTemp(initT(3), initT(4), delta, domainZ);
        SoilVariables.h(i) = init.calcSoilMatricHead(initH(3), initH(4), delta, domainZ);
        SoilVariables.IH(j) = 1;
    end
end