function [SoilVariables, Genuchten, initH] = runSubroutine1(Dmark, SoilConstants, SoilProperties, SoilVariables, Genuchten, initT, initH, initX, ImpedF, ML)

    for i = Dmark:(ML+1) % ML
        j = i - 1;
        SoilVariables.IS(j) = 3;
        J=SoilVariables.IS(j);
        SoilVariables.POR(j) = SoilProperties.porosity(J);
        SoilVariables.Ks(j) = SoilProperties.SaturatedK(J);
        SoilVariables.Theta_qtz(j) = SoilConstants.Vol_qtz(J);
        SoilVariables.VPER(j,1) = SoilVariables.VPERS(J);
        SoilVariables.VPER(j,2) = SoilVariables.VPERSL(J);
        SoilVariables.VPER(j,3) = SoilVariables.VPERC(J);
        SoilVariables.XSOC(j) = SoilVariables.VPERSOC(J);
        SoilVariables.Imped(i) = ImpedF(J);
        SoilVariables.XK(j) = 0.11; %0.0490.11 This is for silt loam; For sand XK=0.025

        Genuchten = init.updateGenuchtenParameters(Genuchten, SoilConstants, SoilVariables, SoilProperties, j, J);
        SoilVariables = init.updateSoilVariables(Genuchten, SoilVariables, SoilConstants, SoilProperties, j, J);
        initH(2) = init.updateInith(initX(2), Genuchten, SoilConstants, SoilVariables, j);

        delta = ML + 2 - Dmark;
        domainZ = i - Dmark + 1;
        SoilVariables.T(i) = init.calcSoilTemp(initT(2), initT(3), delta, domainZ);
        SoilVariables.h(i) = init.calcSoilMatricHead(initH(2), initH(3), delta, domainZ);
        SoilVariables.IH(j)=1;
    end

end