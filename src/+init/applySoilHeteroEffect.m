function [SoilVariables, VanGenuchten] = applySoilHeteroEffect(SoilProperties, SoilVariables, VanGenuchten, ModelSettings)

    initX = SoilVariables.InitialValues.initX;
    initND = SoilVariables.InitialValues.initND;

    SoilVariables.Phi_s = []; % see issue 139, item 5
    SoilVariables.Lamda = []; % see issue 139, item 5
    ImpedF = repelem(3, 6);

    % get model settings
    Eqlspace = ModelSettings.Eqlspace;

    % Get soil constants for StartInit
    SoilConstants = io.getSoilConstants();

    for i = 1:6
        if ModelSettings.SWCC == 0
            if SoilConstants.CHST == 0
                SoilVariables.Phi_s(i) = SoilConstants.Phi_S(i);
                SoilVariables.Lamda(i) = SoilProperties.Coef_Lamda(i);
            end
        end
    end

    if ~Eqlspace
        j = ModelSettings.J;
        for i = 1:length(initX)
            SoilVariables.InitialValues.initH(i) = init.calcInitH(VanGenuchten.Theta_s(j), VanGenuchten.Theta_r(j), initX(i), VanGenuchten.n(j), VanGenuchten.m(j), VanGenuchten.Alpha(j));
        end
        Dmark = [];
        for i = 1:ModelSettings.NL
            SoilConstants.Elmn_Lnth = SoilConstants.Elmn_Lnth + ModelSettings.DeltZ(i);
            InitLnth(i) = ModelSettings.Tot_Depth - SoilConstants.Elmn_Lnth;
            for subRoutine = 5:-1:1
                if abs(InitLnth(i) - initND(subRoutine)) < 1e-10
                    [SoilVariables, VanGenuchten, initH] = init.soilHeteroSubroutine(subRoutine, SoilProperties, SoilVariables, VanGenuchten, ModelSettings, ImpedF, Dmark, i);
                    SoilVariables.InitialValues.initH = initH;
                    Dmark = i + 2;
                end
            end
            if abs(InitLnth(i)) < 1e-10
                subRoutine = 0;
                [SoilVariables, VanGenuchten, initH] = init.soilHeteroSubroutine(subRoutine, SoilProperties, SoilVariables, VanGenuchten, ModelSettings, ImpedF, Dmark, i);
                SoilVariables.InitialValues.initH = initH;
            end
        end
    else
        for i = 1:ModelSettings.NN
            SoilVariables.h(i) = -95;
            SoilVariables.T(i) = 22;
            SoilVariables.TT(i) = SoilVariables.T(i);
            SoilVariables.IS(i) = 1;
            SoilVariables.IH(i) = 1;
        end
    end
end
