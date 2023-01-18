function [SoilVariables, Genuchten, initH] = runSubroutine0(Dmark, SoilConstants, SoilProperties, SoilVariables, Genuchten, initT, initH, initX, ImpedF, ML)

    for i = Dmark:(SoilConstants.totalNumberOfElements+1) % NL
        j = i - 1;
        SoilVariables.IS(j) = 1;
        J = SoilVariables.IS(j);
        SoilVariables.POR(j) = SoilProperties.porosity(J);
        SoilVariables.Ks(j) = SoilProperties.SaturatedK(J);
        SoilVariables.Theta_qtz(j) = SoilConstants.Vol_qtz(J);
        SoilVariables.VPER(j,1) = SoilVariables.VPERS(J);
        SoilVariables.VPER(j,2) = SoilVariables.VPERSL(J);
        SoilVariables.VPER(j,3) = SoilVariables.VPERC(J);
        SoilVariables.XSOC(j) = SoilVariables.VPERSOC(J);
        SoilVariables.Imped(i) = ImpedF(J);
        SoilVariables.XK(j) = 0.11; %0.0450.11 This is for silt loam; For sand XK=0.025

        Genuchten = init.updateGenuchtenParameters(Genuchten, SoilConstants, SoilVariables, SoilProperties, j, J);
        SoilVariables = init.updateSoilVariables(Genuchten, SoilVariables, SoilConstants, SoilProperties, j, J);
        initH(1) = init.updateInith(initX(1), Genuchten, SoilConstants, SoilVariables, j);

        delta1 = SoilConstants.totalNumberOfElements + 2 - Dmark;
        delta2 = ML + 2 - Dmark; %TODO check if it is ML not NL
        domainZ = i - Dmark + 1;
        SoilVariables.T(i) = init.calcSoilTemp(initT(1), initT(2), delta1, domainZ);
        SoilVariables.h(i) = init.calcSoilTemp(initH(1), initH(2), delta2, domainZ);
        SoilVariables.IH(j) = 1;
    end

end