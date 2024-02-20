function CnvrgnCHK
global DxMAX DhMAX DTMAX FAC xERR hERR TERR 
global Theta_LL Theta_L hh h TT T KT TIME Delt_t Delt_t0
global ML NL ND NN MN FAC1 IRPT1 IRPT2
global Thmrlefc NBCh NBChB NBCT NBCTB tS 

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

DhMAX=0;
for MN=1:NN
    if NBCh==1 && ML==NL && ND==2
        continue
    elseif NBChB==1 && ML==1 && ND==1
        continue
    else
    DhMAX=max(abs(hh(MN)-h(MN)),DhMAX);
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
    end
end

IRPT2=0;

FAC1=min(xERR/DxMAX,hERR/DhMAX);
if Thmrlefc==1
    FAC=min(FAC1, TERR/DTMAX);%
else
    FAC=FAC1;
end

if FAC>6
    FAC=6;
    Delt_t0=Delt_t;
    Delt_t=Delt_t*FAC; 
    if Delt_t>1800
        Delt_t=1800;
    end
    return            
elseif FAC<0.25
    IRPT2=1;    % IRPT2=2, means the time step will be decreased;
                    % The time step number. Repeat last time step due to excessive change of state.
    TIME=TIME-Delt_t;  % Time released since the start of simulation.
    KT=KT-1;
    Delt_t=Delt_t*FAC;
    tS=tS+1;    
    
    if Delt_t<1.0e-5
        warning ('Delt_t is getting extremly small.')
    end

else
    Delt_t0=Delt_t;
    Delt_t=Delt_t*FAC;
    if Delt_t>1800
        Delt_t=1800;
    end
    return
end




