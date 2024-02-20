function Enrgy_BC
global C5 c_L RHOL QMB RHS NN  C5_a L_ts SH Precip L KT
global NBCTB NBCT BCT BCTB DSTOR0 Delt_t T Ts Ta 
global EVAP Rn
%%%%%%%%% Apply the bottom boundary condition called for by NBCTB %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if NBCTB==1
    RHS(1)=BCTB;
    C5(1,1)=1;
    RHS(2)=RHS(2)-C5(1,2)*RHS(1);
    C5(1,2)=0;
    C5_a(1)=0;
elseif NBCTB==2
    RHS(1)=RHS(1)+BCTB;
else    
    C5(1,1)=C5(1,1)-c_L*RHOL*QMB(KT);
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
    RHS(NN)=RHS(NN)+Rn(KT)-RHOL*L_ts(KT)*EVAP(KT)-SH(KT)+RHOL*c_L*(Ta(KT)*Precip(KT)+DSTOR0*T(NN)/Delt_t);  
end
  
