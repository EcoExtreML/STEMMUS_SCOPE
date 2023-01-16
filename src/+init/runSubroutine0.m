function [SoilVariables, Genuchten, initH] = runSubroutine0(Dmark, SoilConstants, SoilProperties, Genuchten, initT, initH, ImpedF)

    for i = Dmark:(SoilConstants.totalNumberOfElements+1) % NL
        j = i - 1;
        SoilVariables.IIS(j)=1;
        J=SoilVariables.IIS(j);
        SoilVariables.IPOR(j)= SoilProperties.porosity(J);
        SoilVariables.IKs(j)= SoilProperties.SaturatedK(J);
        SoilVariables.ITheta_qtz(j) = SoilConstants.Vol_qtz(J);
        SoilVariables.IVPER(j,1) = SoilConstants.VPERS(J);
        SoilVariables.IVPER(j,2) = SoilConstants.VPERSL(J);
        SoilVariables.IVPER(j,3) = SoilConstants.VPERC(J);
        SoilVariables.IXSOC(j) = SoilConstants.VPERSOC(J);
        SoilVariables.IImped(i) = SoilConstants.ImpedF(J);
        SoilVariables.IXK(j) = 0.11; %0.0450.11 This is for silt loam; For sand XK=0.025

        Genuchten = updateGenuchtenParameters(Genuchten, SoilConstants, SoilVariables, j, J);
        SoilVariables = updateSoilVariables(Genuchten, SoilConstants, i, j);
        initH(0) = updateInith(initX(0), Genuchten, SoilConstants, SoilVariables, j);

        delta1 = SoilConstants.totalNumberOfElements + 2 - Dmark;
        delta2 = SoilConstants.numberOfElements + 2 - Dmark; %TODO check if it is ML not NL
        domainZ = i - Dmark + 1;
        SoilVariables.IT(i) = calcSoilTemp(initT(0), initT(1), delta, domainZ);
        SoilVariables.Ih(i) = calcSoilTemp(initT(0), initT(1), delta, domainZ);
        SoilVariables.IIH(j) = 1;
    end

end