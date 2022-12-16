function [SoilVariables, initH] = runSubroutine2(Dmark, SoilConstants, SoilProperties, Genuchten, initT, initH, ImpedF)
    
    for i = Dmark:(SoilConstants.numberOfElements+1) % ML
        j = i - 1;
        SoilVariables.IS(j) = 3;
        J = SoilVariables.IS(j);
        SoilVariables.POR(j) = SoilProperties.porosity(J);
        SoilVariables.Ks(j) = SoilProperties.SaturatedK(J);
        SoilVariables.Theta_qtz(j) = SoilConstants.Vol_qtz(J);
        SoilVariables.VPER(j,1) = SoilConstants.VPERS(J);
        SoilVariables.VPER(j,2) = SoilConstants.VPERSL(J);
        SoilVariables.VPER(j,3) = SoilConstants.VPERC(J);
        SoilVariables.XSOC(j) = SoilConstants.VPERSOC(J);
        SoilVariables.Imped(i) = SoilConstants.ImpedF(J);
        SoilVariables.XK(j) = 0.11; %0.0490.11 This is for silt loam; For sand XK=0.025

        Genuchten = updateGenuchtenParameters(Genuchten, SoilConstants, SoilVariables, j, J);
        Coefficients = updateSoilVariables(Genuchten, SoilConstants, i, j);
        initH(2) = updateInith(initX(2), Genuchten, SoilConstants, SoilVariables, j);

        delta = SoilConstants.numberOfElements + 2 - Dmark;
        domainZ = i - Dmark + 1;
        SoilVariables.T(i) = calcSoilTemp(initT(2), initT(3), delta, domainZ);
        SoilVariables.h(i) = calcSoilMatricHead(initH(2), initH(3), delta, domainZ);
        SoilVariables.IH(j) = 1;
    end

end