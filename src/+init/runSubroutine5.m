function [SoilVariables, Genuchten, initH, Btmh] = runSubroutine5(SoilConstants, SoilProperties, SoilVariables, Genuchten, initT, initH, initX, ImpedF, ML)

    for i=1:(ML+1) % ML
        SoilVariables.IS(i) = 6; % Index of soil type
        J = SoilVariables.IS(i);
        [SoilVariables, Genuchten] = init.updateSoilVariables(Genuchten, SoilVariables, SoilConstants, SoilProperties, i, J);
        SoilVariables.Imped(i) = ImpedF(J);
        initH(6) = init.updateInith(initX(6), Genuchten, SoilConstants, SoilVariables, i);
        Btmh = init.updateBtmh(Genuchten, SoilConstants, SoilVariables, i);

        SoilVariables.T(i) = SoilConstants.BtmT + (i-1) * (initT(6) - SoilConstants.BtmT) / ML;
        SoilVariables.h(i) = Btmh + (i-1) * (initH(6) - Btmh) / ML;
        SoilVariables.IH(i) = 1;   % Index of wetting history of soil which would be assumed as dry at the first with the value of 1
    end
end