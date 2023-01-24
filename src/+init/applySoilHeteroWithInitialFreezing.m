function [SoilVariables] = applySoilHeteroWithInitialFreezing(SoilConstants, SoilVariables)

    SoilVariables.ISFT = 0;

    for i=1:SoilConstants.numberOfNodes
        SoilVariables.h_frez = init.updateHfreez(i, SoilVariables, SoilConstants);

        SoilVariables.h_frez(i) = SoilVariables.h_frez(i); % TODO check if it is a mistake
        SoilVariables.hh_frez(i) = SoilVariables.h_frez(i);
        SoilVariables.h(i) = SoilVariables.h(i) - SoilVariables.h_frez(i);
        SoilVariables.hh(i) = SoilVariables.h(i);
        SoilVariables.SAVEh(i) = SoilVariables.h(i);
        SoilVariables.SAVEhh(i) = SoilVariables.hh(i);

        [SoilVariables.Gama_h, SoilVariables.Gama_hh] = init.updateGammaH(i, SoilConstants, SoilVariables);

        if SoilConstants.Thmrlefc==1
            SoilVariables.TT(i) = SoilVariables.T(i);
        end
        if SoilConstants.Soilairefc==1
            SoilConstants.P_g(i) = 95197.850;
            SoilConstants.P_gg(i) = SoilConstants.P_g(i);
        end
        if i<SoilConstants.numberOfNodes
            SoilVariables.XWRE(i,1)=0; % TODO check it is set in SOIL1
            SoilVariables.XWRE(i,2)=0;
        end
    %     SoilVariables.XK(i)=0.0425;
    end

end