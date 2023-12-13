function [BCh,AVAIL0,RHS,C4,C4_a,Rn_SOIL,Evap,EVAP,Trap,r_a_SOIL,Resis_a,Srt,Precip]=h_BC(XElemnt,RHS,NBCh,NBChB,BCh,BChB,hN,KT,Delt_t,DSTOR0,NBChh,TIME,h_SUR,C4,KL_h,NN,C4_a,DeltZ,RHOV,Ta,HR_a,U,Theta_LL,Ts,Rv,g,NL,hh,rwuef,Theta_UU,Rn,T,TT,Gvc,Rns,Srt,Precip_msr,SUMTIME,Coefficient_n,Coefficient_Alpha,Theta_s,Theta_r,EVAP_PT,TRAP_PT) %[AVAIL0,RHS,C4,C4_a,Evap,EVAP,Trap,Precip,bx,r_a_SOIL,Resis_a]=h_BC(DeltZ,bx,RHS,NBCh,NBChB,BCh,BChB,hN,KT,Delt_t,DSTOR0,NBChh,TIME,h_SUR,C4,KL_h,Precip,NN,AVAIL0,C4_a,Evap,RHOV,Ta,HR_a,U,Ts,Theta_LL,Rv,g,NL,hh,rwuef,Theta_UU,Rn,T,TT,Gvc,Rns) 
%%%%%%%%%% Apply the bottom boundary condition called for by NBChB %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global IBOT hBOT

Q3DF=1;

if ~Q3DF
    if NBChB==1            %-----> Specify matric head at bottom to be ---BChB;
        RHS(1)=BChB;
        C4(1,1)=1;
        RHS(2)=RHS(2)-C4(1,2)*RHS(1);
        C4(1,2)=0;
        C4_a(1)=0;
    elseif NBChB==2        %-----> Specify flux at bottom to be ---BChB (Positive upwards);
        RHS(1)=RHS(1)+BChB;
    elseif NBChB==3        %-----> NBChB=3,Gravity drainage at bottom--specify flux= hydraulic conductivity;
        RHS(1)=RHS(1)-KL_h(1,1);
    end
else
%     IBOT=NN-5;
    INBT=NN-IBOT+1;
    BOTm=XElemnt(NN);
    
    if NBChB==1            %-----> Specify matric head at bottom to be ---BChB;
        RHS(INBT)=(hBOT-BOTm+XElemnt(IBOT));
        C4(INBT,1)=1;
        RHS(INBT+1)=RHS(INBT+1)-C4(INBT,2)*RHS(INBT);
        C4(INBT,2)=0;
        C4_a(INBT)=0;
    elseif NBChB==2        %-----> Specify flux at bottom to be ---BChB (Positive upwards);
        RHS(INBT)=RHS(INBT)+BChB;
    elseif NBChB==3        %-----> NBChB=3,Gravity drainage at bottom--specify flux= hydraulic conductivity;
        RHS(INBT)=RHS(INBT)-KL_h(INBT,1);
    end
end
    [Rn_SOIL,Evap,EVAP,Trap,r_a_SOIL,Resis_a,Srt]= Evap_Cal(DeltZ,TIME,RHOV,Ta,HR_a,U,Theta_LL,Ts,Rv,g,NL,NN,KT,hh,rwuef,Theta_UU,Rn,T,TT,Gvc,Rns,Srt,Coefficient_n,Coefficient_Alpha,Theta_s,Theta_r,EVAP_PT,TRAP_PT);
     DELT=86400;%3600;
    NoTime(KT)=fix(SUMTIME(KT)/DELT);
     if NoTime(KT)<=0
         Precip(KT)=Precip_msr(1);%0.1/DELT;
     elseif NoTime(KT)>=length(Precip_msr)
         Precip(KT)=Precip_msr(end);%0.1/DELT;
     else
        Precip(KT)=Precip_msr(NoTime(KT));%0.1/DELT;
     end
     BCh=EVAP(KT)-Precip(KT);
%%%%%%%%%% Apply the surface boundary condition called for by NBCh  %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if NBCh==1             %-----> Specified matric head at surface---equal to hN;
    RHS(NN)=h_SUR(KT);
    C4(NN,1)=1;
    RHS(NN-1)=RHS(NN-1)-C4(NN-1,2)*RHS(NN);
    C4(NN-1,2)=0;
    C4_a(NN-1)=0;
elseif NBCh==2
    if NBChh==1
        RHS(NN)=hN;
        C4(NN,1)=1;
        RHS(NN-1)=RHS(NN-1)-C4(NN-1,2)*RHS(NN);
        C4(NN-1,2)=0;
    else
        RHS(NN)=RHS(NN)-BCh;   %> and a specified matric head (saturation or dryness)was applied;
    end
    AVAIL0=Precip(KT)+DSTOR0/Delt_t;
else


AVAIL0=Precip(KT)+DSTOR0/Delt_t;
    if NBChh==1
        RHS(NN)=hN;
        C4(NN,1)=1;
        RHS(NN-1)=RHS(NN-1)-C4(NN-1,2)*RHS(NN);
        C4(NN-1,2)=0;
        C4_a(NN-1)=0;
    else
        RHS(NN)=RHS(NN)+AVAIL0-Evap(KT);
    end
end

