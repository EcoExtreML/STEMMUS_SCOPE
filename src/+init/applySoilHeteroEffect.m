function [SoilVariables, VanGenuchten] = applySoilHeteroEffect(SoilProperties, SoilConstants, SoilVariables, VanGenuchten)

    initX = SoilConstants.InitialValues.initX;
    initND = SoilConstants.InitialValues.initND;
    Eqlspace = SoilConstants.Eqlspace;

    SoilVariables.Phi_s = []; % see issue 139, item 5
    SoilVariables.Lamda = []; % see issue 139, item 5
    ImpedF = repelem(3, 6);

    for i = 1:6
        if SoilConstants.SWCC == 0
            if SoilConstants.CHST == 0
                SoilVariables.Phi_s(i) = SoilConstants.Phi_S(i);
                SoilVariables.Lamda(i) = SoilProperties.Coef_Lamda(i);
            end
        end
    end

    if ~Eqlspace
        j = SoilConstants.J;
        for i = 1:length(initX)
            SoilConstants.InitialValues.initH(i) = init.calcInitH(VanGenuchten.Theta_s(j), VanGenuchten.Theta_r(j), initX(i), VanGenuchten.n(j), VanGenuchten.m(j), VanGenuchten.Alpha(j));
        end
        Dmark = [];
        for i = 1:SoilConstants.totalNumberOfElements % NL
            SoilConstants.Elmn_Lnth = SoilConstants.Elmn_Lnth + SoilConstants.DeltZ(i);
            InitLnth(i) = SoilConstants.Tot_Depth - SoilConstants.Elmn_Lnth;
            for subRoutine = 5:-1:1
                if abs(InitLnth(i) - initND(subRoutine)) < 1e-10
                    [SoilVariables, VanGenuchten, initH] = init.soilHeteroSubroutine(subRoutine, SoilConstants, SoilProperties, SoilVariables, VanGenuchten, ImpedF, Dmark, i);
                    SoilConstants.InitialValues.initH = initH;
                    Dmark = i + 2;
                end
            end
            if abs(InitLnth(i)) < 1e-10
                subRoutine = 0;
                [SoilVariables, VanGenuchten, initH] = init.soilHeteroSubroutine(subRoutine, SoilConstants, SoilProperties, SoilVariables, VanGenuchten, ImpedF, Dmark, i);
                SoilConstants.InitialValues.initH = initH;
            end
        end
    else
        for i = 1:SoilConstants.numberOfNodes
            SoilVariables.h(i) = -95;
            SoilVariables.T(i) = 22;
            SoilVariables.TT(i) = SoilVariables.T(i);
            SoilVariables.IS(i) = 1;
            SoilVariables.IH(i) = 1;
        end
    end
end
