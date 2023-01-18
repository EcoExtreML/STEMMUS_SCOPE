function [SoilVariables, Genuchten, initH, Btmh] = runSubroutine5(SoilConstants, SoilProperties, SoilVariables, Genuchten, initT, initH, initX, ImpedF, ML)

    for i=1:(ML+1) % ML
        SoilVariables.IS(i) = 6; % Index of soil type
        J = SoilVariables.IS(i);
        SoilVariables.POR(i) = SoilProperties.porosity(J);
        SoilVariables.Ks(i) = SoilProperties.SaturatedK(J);
        SoilVariables.Theta_qtz(i) = SoilConstants.Vol_qtz(J);
        SoilVariables.VPER(i,1) = SoilVariables.VPERS(J);
        SoilVariables.VPER(i,2) = SoilVariables.VPERSL(J);
        SoilVariables.VPER(i,3) = SoilVariables.VPERC(J);
        SoilVariables.XSOC(i) = SoilConstants.VPERSOC(J);
        SoilVariables.Imped(i) = ImpedF(J);
        SoilVariables.XK(i) = 0.11; %0.11 This is for silt loam; For sand XK=0.025

        Genuchten = init.updateGenuchtenParameters(Genuchten, SoilConstants, SoilVariables, SoilProperties, i, J);
        SoilVariables = init.updateSoilVariables(Genuchten, SoilVariables, SoilConstants, SoilProperties, i, J);
        initH(6) = init.updateInith(initX(6), Genuchten, SoilConstants, SoilVariables, i);
        Btmh = init.updateBtmh(Genuchten, SoilConstants, SoilVariables, i);

        SoilVariables.T(i) = SoilConstants.BtmT + (i-1) * (initT(6) - SoilConstants.BtmT) / ML;
        SoilVariables.h(i) = Btmh + (i-1) * (initH(6) - Btmh) / ML;
        SoilVariables.IH(i) = 1;   % Index of wetting history of soil which would be assumed as dry at the first with the value of 1
    end
end