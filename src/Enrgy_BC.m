function [RHS,C5,C5_a]=Enrgy_BC(RHS,KT,NN,c_L,RHOL,QMB,SH,Precip,L,L_ts,NBCTB,NBCT,BCT,BCTB,DSTOR0,Delt_t,T,Ts,Ta,EVAP,C5,C5_a,r_a_SOIL,Resis_a,Tbtm,c_a,Rn_SOIL,TT)
global IBOT
%%%%%%%%% Apply the bottom boundary condition called for by NBCTB %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Q3DF=0;
    INBT=NN-IBOT+1;
    
if ~Q3DF
    if NBCTB==1
        RHS(1)=BCTB;%Tbtm(KT);
        C5(1,1)=1;
        RHS(2)=RHS(2)-C5(1,2)*RHS(1);
        C5(1,2)=0;
        C5_a(1)=0;
    elseif NBCTB==2
        RHS(1)=RHS(1)+BCTB;
    else
        C5(1,1)=C5(1,1)-c_L*RHOL*QMB(KT);
    end
else

    % BOTm=XElemnt(NN);
    if NBCTB==1
        if INBT==1
            RHS(INBT)=BCTB;%Tbtm(KT);
        else
            RHS(1)=BCTB;
            RHS(INBT)=TT(INBT);%Tbtm(KT);BCTB;%
        end
        C5(INBT,1)=1;
        RHS(INBT+1)=RHS(INBT+1)-C5(INBT,2)*RHS(INBT);
        C5(INBT,2)=0;
        C5_a(INBT)=0;
    elseif NBCTB==2
        RHS(INBT)=RHS(INBT)+BCTB;
    else
        C5(INBT,1)=C5(INBT,1)-c_L*RHOL*QMB(KT);
    end
end
%%%%%%%%%% Apply the surface boundary condition called by NBCT %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if NBCT==1
    RHS(NN)=Ts(KT);%BCT;%30;
    C5(NN,1)=1;
    RHS(NN-1)=RHS(NN-1)-C5(NN-1,2)*RHS(NN);
    C5(NN-1,2)=0;
    C5_a(NN-1)=0;    
elseif NBCT==2
    RHS(NN)=RHS(NN)-BCT;
else
    L_ts(KT)=L(NN); 
        SH(KT)=0.1200*c_a*(T(NN)-Ta(KT))/r_a_SOIL(KT);%Resis_a(KT);   % J cm-2 s-1
        RHS(NN)=RHS(NN)+100*Rn_SOIL(KT)/1800-RHOL*L_ts(KT)*EVAP(KT)-SH(KT)+RHOL*c_L*(Ta(KT)*Precip(KT)+DSTOR0*T(NN)/Delt_t);    % J cm-2 s-1
end
  
