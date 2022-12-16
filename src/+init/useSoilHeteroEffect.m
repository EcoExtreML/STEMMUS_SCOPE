function [SoilVariables, initH, Btmh] = useSoilHeteroEffect(SoilProperties, SoilConstants, initX, initND, initT)

    ImpedF=[3 3 3 3 3 3 3];
    Genuchten = init.setGenuchtenParameters(SoilProperties);
    SoilVariables = init.setSoilVariables(SoilProperties, SoilConstants, Genuchten)

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
        Btmh = equations.calcInitH(Genuchten.Theta_s(j), Genuchten.Theta_r(j), BtmX, Genuchten.n(j), Genuchten.m(j), Genuchten.Alpha(j));
        if Btmh==-inf
            Btmh = -1e7;
        end
        for i=1:SoilConstants.totalNumberOfElements
            Elmn_Lnth = SoilConstants.Elmn_Lnth + SoilConstants.DeltZ(i);
            InitLnth(i) = SoilConstants.Tot_Depth - Elmn_Lnth;

            if abs(InitLnth(i)-initND(5))<1e-10
                % TODO check if Btmh needed here
                [SoilVariables, initH, Btmh] = init.runSubroutine5(SoilConstants, SoilProperties, Genuchten, initT, initH, ImpedF);
                Dmark = i + 2;
            end
            if abs(InitLnth(i)-initND(4))<1e-10
                [SoilVariables, initH] = init.runSubroutine4(Dmark, SoilConstants, SoilProperties, Genuchten, initT, initH, ImpedF);
                Dmark = i + 2;
            end
            if abs(InitLnth(i)-initND(3))<1e-10
                [SoilVariables, initH] = init.runSubroutine3(Dmark, SoilConstants, SoilProperties, Genuchten, initT, initH, ImpedF);
                Dmark = i + 2;
            end
            if abs(InitLnth(i)-initND(2))<1e-10
                [SoilVariables, initH] = init.runSubroutine2(Dmark, SoilConstants, SoilProperties, Genuchten, initT, initH, ImpedF);
                Dmark = i + 2;
            end
            if abs(InitLnth(i)-initND(1))<1e-10
                [SoilVariables, initH] = init.runSubroutine1(Dmark, SoilConstants, SoilProperties, Genuchten, initT, initH, ImpedF);
                Dmark = i + 2;
            end
            if abs(InitLnth(i))<1e-10
                [SoilVariables, initH] = init.runSubroutine0(Dmark, SoilConstants, SoilProperties, Genuchten, initT, initH, ImpedF);
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