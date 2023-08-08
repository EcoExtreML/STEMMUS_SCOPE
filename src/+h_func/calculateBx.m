function bx = calculateBx(InitialValues)

    ModelSettings = io.getModelSettings();
    bx = InitialValues.bx;

    Elmn_Lnth = 0;
    RL = sum(ModelSettings.DeltZ);
    Elmn_Lnth(1) = 0;
    RB = 0.9;
    LR = log(0.01) / log(RB);
    RY = 1 - RB^(LR);

    if LR <= 1
        for i = 1:ModelSettings.NL - 1      % ignore the surface root water uptake 1cm
            for j = 1:ModelSettings.nD
                MN = i + j - 1;
                bx(i, j) = 0;
            end
        end
    else
        FRY = zeros(ModelSettings.NL, 1);
        bx = zeros(ModelSettings.NL, 2);
        for i = 2:ModelSettings.NL
            Elmn_Lnth(i) = Elmn_Lnth(i - 1) + ModelSettings.DeltZ(i - 1);
            if Elmn_Lnth < RL - LR
                FRY(i) = 1;
            else
                FRY(i) = (1 - RB^(RL - Elmn_Lnth(i))) / RY;
            end
        end
        for i = 1:ModelSettings.NL - 1
            bx(i) = FRY(i) - FRY(i + 1);
            if bx(i) < 0
                bx(i) = 0;
            end
            bx(ModelSettings.NL) = FRY(ModelSettings.NL);
        end
        for i = 1:ModelSettings.NL
            for j = 1:ModelSettings.nD
                MN = i + j - 1;
                bx(i, j) = bx(MN);  %TODO issue reseting bx by bx!
            end
        end
    end
end