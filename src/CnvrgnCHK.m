%%%%%%%% inputs %%%%%%%%%%%%
% xERR,hERR,TERR,Theta_LL,Theta_L,Theta_UU,Theta_U,hh,h,TT,T,KT,TIME,Delt_t,NL,NN,Thmrlefc,NBCh,NBChB,NBCT,NBCTB,tS,uERR
%%%%%%%% outputs %%%%%%%%%%
% KT,TIME,Delt_t,IRPT1,IRPT2,tS
function [KT, TIME, Delt_t, IRPT1, IRPT2, tS] = CnvrgnCHK(Theta_LL, Theta_L, Theta_UU, Theta_U, hh, h, TT, T, KT, TIME, Delt_t, NL, NN, Thmrlefc, NBCh, NBChB, NBCT, NBCTB, tS)
    global Delt_t0
    global ISFT TT_CRIT T_CRIT T0 EPCT
    xERR = 0.02; % Maximum desirable change of moisture content;
    hERR = 0.1e08; % Maximum desirable change of matric potential;
    TERR = 2; % Maximum desirable change of temperature;
    uERR = 0.02;                  % Maximum desirable change of total water content;

    IRPT1 = 0;
    DxMAX = 0;
    for ML = 1:NL
        for ND = 1:2
            if NBCh == 1 && ML == NL && ND == 2
                continue
            elseif NBChB == 1 && ML == 1 && ND == 1
                continue
            else
                DxMAX = max(abs(Theta_LL(ML, ND) - Theta_L(ML, ND)), DxMAX);
            end
        end
    end
    DuMAX = 0;
    for ML = 1:NL
        for ND = 1:2
            if NBCh == 1 && ML == NL && ND == 2
                continue
            elseif NBChB == 1 && ML == 1 && ND == 1
                continue
            else
                DuMAX = max(abs(Theta_UU(ML, ND) - Theta_U(ML, ND)), DuMAX);
            end
        end
    end

    DhMAX = 0;
    for MN = 1:NN
        if NBCh == 1 && ML == NL && ND == 2
            continue
        elseif NBChB == 1 && ML == 1 && ND == 1
            continue
        else
            DhMAX = max(abs(hh(MN) - h(MN)), DhMAX);
        end
    end
    if Thmrlefc == 1
        DTMAX = 0;
        for MN = 1:NN
            if NBCT == 1 && MN == NN
                continue
            elseif NBCTB == 1 && MN == 1
                continue
            else
                DTMAX = max(abs(TT(MN) - T(MN)), DTMAX);
            end
        end
    end

    IRPT2 = 0;

    FAC1 = min(xERR / DxMAX, uERR / DuMAX);
    FAC2 = hERR / DhMAX;
    FAC1 = min(FAC1, FAC2);
    if Thmrlefc == 1
        FAC = min(FAC1, TERR / DTMAX); %
    else
        FAC = FAC1;
    end
    ISFT = 0;
    if FAC > 6
        FAC = 6;
        Delt_t0 = Delt_t;
        Delt_t = Delt_t * FAC;
        if Delt_t > 1800     % original 1800s
            Delt_t = 1800;
        end
        return
    elseif FAC < 0.25
        IRPT2 = 1;    % IRPT2=2, means the time step will be decreased;
        % The time step number. Repeat last time step due to excessive change of state.
        TIME = TIME - Delt_t;  % Time released since the start of simulation.
        KT = KT - 1;
        Delt_t = Delt_t * FAC;
        tS = tS + 1;

        if Delt_t < 1.0e-5
            warning ('Delt_t is getting extremly small.');
        end

    else
        Delt_t0 = Delt_t;
        Delt_t = Delt_t * FAC;
        ISFT = 0;
        if Delt_t > 1800
            Delt_t = 1800;
        end
        return
    end

    ISFT = 0;

    for MN = 1:NN
        if (TT(NN) - (TT_CRIT(NN) - T0)) * (T(NN) - (T_CRIT(NN) - T0)) < 0
            KT = KT - 1;
            TIME = TIME - Delt_t;
            Delt_t = Delt_t * 0.25;
            tS = tS + 1;
            ISFT = 1;  % ISFT=0 indicator of soil thawing start;
            break
        elseif (TT(MN) - (TT_CRIT(MN) - T0)) * (T(MN) - (T_CRIT(MN) - T0)) == 0
            ISFT = 0;  % ISFT=1 indicator of soil freezing start;
            EPCT(MN) = 1;
        else
            ISFT = 0;      % both soil temperatures are below zero, soil is freezing,ISFT=2
            EPCT(NN) = 1;
        end
    end
