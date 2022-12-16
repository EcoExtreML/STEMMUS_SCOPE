function [SoilVariables, initH, Btmh] = runSubroutine5(SoilConstants, SoilProperties, Genuchten, initT, initH, ImpedF)

    for i=1:(SoilConstants.numberOfElements+1) % ML
        SoilVariables.IS(i) = 6; % Index of soil type
        J = SoilVariables.IS(i);
        SoilVariables.POR(i) = SoilProperties.porosity(J);
        SoilVariables.Ks(i) = SoilProperties.SaturatedK(J);
        SoilVariables.Theta_qtz(i) = SoilConstants.Vol_qtz(J);
        SoilVariables.VPER(i,1) = SoilVariables.VPERS(J);
        SoilVariables.VPER(i,2) = SoilVariables.VPERSL(J);
        SoilVariables.VPER(i,3) = SoilVariables.VPERC(J);
        SoilVariables.XSOC(i) = SoilConstants.VPERSOC(J);
        SoilVariables.Imped(i) = ImpedF(J);  %TODO check undefined
        SoilVariables.XK(i) = 0.11; %0.11 This is for silt loam; For sand XK=0.025
        
        Genuchten = updateGenuchtenParameters(Genuchten, SoilConstants, SoilVariables, i, J);
        SoilVariables = updateSoilVariables(Genuchten, SoilConstants, i, J);
        initH(5) = updateInith(initX(5), Genuchten, SoilConstants, SoilVariables, i);
        Btmh = updateBtmh(Genuchten, SoilConstants, SoilVariables, i);
        
        SoilVariables.T(i) = SoilConstants.BtmT + (i-1) * (initT(5) - SoilConstants.BtmT) / numberOfElements;
        SoilVariables.h(i) = Btmh + (i-1) * (initH(5) - Btmh) / numberOfElements;
        SoilVariables.IH(i) = 1;   % Index of wetting history of soil which would be assumed as dry at the first with the value of 1 
    end
end