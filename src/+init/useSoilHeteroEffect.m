function [SoilVariables, Genuchten, initH, Btmh] = useSoilHeteroEffect(SoilProperties, SoilConstants, SoilVariables, Genuchten, initX, initND, initT, Eqlspace)
    % TODO check
    SoilVariables.Phi_s = [];
    SoilVariables.Lamda = [];
    ImpedF = repelem(3, 6);

    for i=1:6
        if SoilConstants.SWCC==0
            if SoilConstants.CHST==0
                SoilVariables.Phi_s(i) = SoilConstants.Phi_S(i);
                SoilVariables.Lamda(i) = SoilProperties.Coef_Lamda(i);
            end
            Genuchten.Theta_s(i) = Theta_s_ch(i); %TODO undefined var Theta_s_ch
        end
    end

    if ~Eqlspace
        j = SoilConstants.J;
        for i = 1:length(initX)
            initH(i) = init.calcInitH(Genuchten.Theta_s(j), Genuchten.Theta_r(j), initX(i), Genuchten.n(j), Genuchten.m(j), Genuchten.Alpha(j));
        end
        % TODO check if this Btmh is used somewhere
        Btmh = init.calcInitH(Genuchten.Theta_s(j), Genuchten.Theta_r(j), SoilConstants.BtmX, Genuchten.n(j), Genuchten.m(j), Genuchten.Alpha(j));
        if Btmh==-inf
            Btmh = -1e7;
        end
        Dmark = [];
        for i=1:SoilConstants.totalNumberOfElements % NL
            SoilConstants.Elmn_Lnth = SoilConstants.Elmn_Lnth + SoilConstants.DeltZ(i);
            InitLnth(i) = SoilConstants.Tot_Depth - SoilConstants.Elmn_Lnth;

            if abs(InitLnth(i)-initND(5))<1e-10
                subRoutine = 'subRoutine5';
                [SoilVariables, Genuchten, initH] = init.runSubroutine(subRoutine, SoilConstants, SoilProperties, SoilVariables, Genuchten, initT, initH, initX, ImpedF, Dmark, i);
                Dmark = i + 2;
            end
            if abs(InitLnth(i)-initND(4))<1e-10
                subRoutine = 'subRoutine4';
                [SoilVariables, Genuchten, initH] = init.runSubroutine(subRoutine, SoilConstants, SoilProperties, SoilVariables, Genuchten, initT, initH, initX, ImpedF, Dmark, i);
                Dmark = i + 2;
            end
            if abs(InitLnth(i)-initND(3))<1e-10
                subRoutine = 'subRoutine3';
                [SoilVariables, Genuchten, initH] = init.runSubroutine(subRoutine, SoilConstants, SoilProperties, SoilVariables, Genuchten, initT, initH, initX, ImpedF, Dmark, i);
                Dmark = i + 2;
            end
            if abs(InitLnth(i)-initND(2))<1e-10
                subRoutine = 'subRoutine2';
                [SoilVariables, Genuchten, initH] = init.runSubroutine(subRoutine, SoilConstants, SoilProperties, SoilVariables, Genuchten, initT, initH, initX, ImpedF, Dmark, i);
                Dmark = i + 2;
            end
            if abs(InitLnth(i)-initND(1))<1e-10
                subRoutine = 'subRoutine1';
                [SoilVariables, Genuchten, initH] = init.runSubroutine(subRoutine, SoilConstants, SoilProperties, SoilVariables, Genuchten, initT, initH, initX, ImpedF, Dmark, i);
                Dmark = i + 2;
            end
            if abs(InitLnth(i))<1e-10
                subRoutine = 'subRoutine0';
                [SoilVariables, Genuchten, initH] = init.runSubroutine(subRoutine, SoilConstants, SoilProperties, SoilVariables, Genuchten, initT, initH, initX, ImpedF, Dmark, i);
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