function [SoilVariables] = applySoilHeteroWithInitialFreezing(LatentHeatOfFreezing, SoilVariables, ModelSettings)

    SoilVariables.ISFT = 0;

    for i = 1:ModelSettings.NN
        SoilVariables.h_frez = init.updateHfreez(i, LatentHeatOfFreezing, SoilVariables, ModelSettings);
        SoilVariables.hh_frez(i) = SoilVariables.h_frez(i);
        SoilVariables.h(i) = SoilVariables.h(i) - SoilVariables.h_frez(i);
        SoilVariables.hh(i) = SoilVariables.h(i);
        SoilVariables.SAVEh(i) = SoilVariables.h(i);
        SoilVariables.SAVEhh(i) = SoilVariables.hh(i);

        [SoilVariables.Gamma_h, SoilVariables.Gamma_hh] = init.updateGammaH(i, SoilVariables);

        if ModelSettings.Thmrlefc == 1
            SoilVariables.TT(i) = SoilVariables.T(i);
        end
        if ModelSettings.Soilairefc == 1
            SoilVariables.P_g(i) = 95197.850;
            SoilVariables.P_gg(i) = SoilVariables.P_g(i);
        end
        if i < ModelSettings.NN
            SoilVariables.XWRE(i, 1) = 0;
            SoilVariables.XWRE(i, 2) = 0;
        end
    end

end
