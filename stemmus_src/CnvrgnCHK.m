%%%%%%%%inputs %%%%%%%%%%%%
%xERR,hERR,TERR,Theta_LL,Theta_L,Theta_UU,Theta_U,hh,h,TT,T,KT,TIME,Delt_t,NL,NN,Thmrlefc,NBCh,NBChB,NBCT,NBCTB,tS,uERR
%%%%%%%% outputs %%%%%%%%%%
%KT,TIME,Delt_t,IRPT1,IRPT2,tS
function [KT,TIME,Delt_t,IRPT1,IRPT2,tS,Delt_t0]=CnvrgnCHK(xERR,hERR,TERR,Theta_LL,Theta_L,Theta_UU,Theta_U,hh,h,TT,T,KT,TIME,Delt_t,NL,NN,Thmrlefc,NBCh,NBChB,NBCT,NBCTB,tS,uERR,SAVEhh,SAVETT)
% global Delt_t0
global ISFT TT_CRIT T_CRIT T0 EPCT Precip IBOT
IRPT1=0;
DxMAX=0;
for ML=1:NL
    for ND=1:2
        if NBCh==1 && ML==NL && ND==2
            continue
        elseif NBChB==1 && ML==1 && ND==1
            continue
        else
            DxMAX=max(abs(Theta_LL(ML,ND)-Theta_L(ML,ND)),DxMAX);
        end
    end
end
DuMAX=0;
for ML=1:NL
    for ND=1:2
        if NBCh==1 && ML==NL && ND==2
            continue
        elseif NBChB==1 && ML==1 && ND==1
            continue
        else
            DuMAX=max(abs(Theta_UU(ML,ND)-Theta_U(ML,ND)),DuMAX);
        end
    end
end

DhMAX=0;
for MN=1:NN
    if NBCh==1 && ML==NL && ND==2
        continue
    elseif NBChB==1 && ML==1 && ND==1
        continue
    else
        if abs(hh(MN))>=1E6 %|| h(MN)<-1E7
            DhMAX=0;
        else
            DhMAX=max(abs(hh(MN)-h(MN)),DhMAX);
        end
    end
    if isnan(SAVEhh(MN))
        DhMAX=0;
        DxMAX=0;
        DuMAX=0;
    end
end
if Thmrlefc==1
    DTMAX=0;
    for MN=1:NN
        if NBCT==1 && MN==NN
            continue
        elseif NBCTB==1 && MN==1
            continue
        else
        DTMAX=max(abs(TT(MN)-T(MN)),DTMAX);
        end
        if isnan(SAVETT(MN))
            DTMAX=0;
        end
    end
end
% % IBOT=NN-5;
Q3DF=1;
INBT=NN-IBOT+1;
if Q3DF==1 %&& TIME<86400
    DxMAX=0;
    for ML=INBT+1:NL
        for ND=1:2
            if NBCh==1 && ML==NL && ND==2
                continue
            elseif NBChB==1 && ML==1 && ND==1
                continue
            else
                DxMAX=max(abs(Theta_LL(ML,ND)-Theta_L(ML,ND)),DxMAX);
            end
        end
    end
    DuMAX=0;
    for ML=INBT+1:NL
        for ND=1:2
            if NBCh==1 && ML==NL && ND==2
                continue
            elseif NBChB==1 && ML==1 && ND==1
                continue
            else
                DuMAX=max(abs(Theta_UU(ML,ND)-Theta_U(ML,ND)),DuMAX);
            end
        end
    end
    
    DhMAX=0;
    for MN=INBT+1:NN
        if NBCh==1 && ML==NL && ND==2
            continue
        elseif NBChB==1 && ML==1 && ND==1
            continue
        else
            if hh(MN)<=-1E6 || h(MN)<=-1E6
                DhMAX=0;
            else
                DhMAX=max(abs(hh(MN)-h(MN)),DhMAX);
            end
        end
        if isnan(SAVEhh(MN))
            DhMAX=0;
            DxMAX=0;
            DuMAX=0;
        end
    end
    if Thmrlefc==1
        DTMAX=0;
        for MN=INBT+1:NN
            if NBCT==1 && MN==NN
                continue
            elseif NBCTB==1 && MN==1
                continue
            else
                DTMAX=max(abs(TT(MN)-T(MN)),DTMAX);
            end
        if isnan(SAVETT(MN))
            DTMAX=0;
        end
        end
    end%xERR/DxMAX
end%,uERR/DuMAX
IRPT2=0;
FAC1=min(uERR/DuMAX);
FAC2=hERR/DhMAX;
FAC3=min(FAC1,FAC2);
if Thmrlefc==1
    FAC=min(FAC3,TERR/DTMAX);%
else
    FAC=FAC3;
end
ISFT=0;
if FAC>6
    FAC=6;
    Delt_t0=Delt_t;
    Delt_t=Delt_t*FAC; 
    if Delt_t>43200     %original 1800s
        Delt_t=43200;
    end
return
elseif FAC<0.25
    IRPT2=1;    % IRPT2=2, means the time step will be decreased;
                    % The time step number. Repeat last time step due to excessive change of state.
    TIME=TIME-Delt_t;  % Time released since the start of simulation.
    KT=KT-1;
    Delt_t=Delt_t*FAC;
    tS=tS+1;    

else
    Delt_t0=Delt_t;
    Delt_t=Delt_t*FAC;
    ISFT=0;
    if Delt_t>43200
        Delt_t=43200;
    end
    return
end
    if Delt_t<1e-10
        save('202105021b.mat')
    end
ISFT=0;
