%function [AVAIL0,RHS,C4,C4_a,Evap,EVAP,Trap,Precip,Srt]=h_BC(lEstot,lEctot,PSIs,PSI,rsss,rrr,rxx,Srt,RHS,NBCh,NBChB,BCh,BChB,hN,KT,Delt_t,DSTOR0,NBChh,h_SUR,C4,KL_h,Precip,NN,AVAIL0,C4_a,Evap,rwuef) 
function [AVAIL0,RHS,C4,C4_a,Evap,EVAP,Trap,Precip,bx,Srt]=h_BC(DeltZ,bx,Srt,RHS,NBCh,NBChB,BCh,BChB,hN,KT,Delt_t,DSTOR0,NBChh,TIME,h_SUR,C4,KL_h,Precip,NN,AVAIL0,C4_a,Evap,RHOV,Ta,HR_a,U,Ts,Theta_LL,Rv,g,NL,Evaptranp_Cal,Coefficient_n,Coefficient_Alpha,Theta_r,Theta_s,DURTN,PME,PT_PM_0,hh,rwuef,J,lEstot,lEctot)
%global Precip
%%%%%%%%%% Apply the bottom boundary condition called for by NBChB %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
else     
%[Evap,EVAP,Trap,Srt]= Evap_Cal(KT,lEstot,lEctot,PSIs,PSI,rsss,rrr,rxx,rwuef);
 [Evap,EVAP,Trap,bx,Srt]= Evap_Cal(bx,Srt,DeltZ,TIME,RHOV,Ta,HR_a,U,Theta_LL,Ts,Rv,g,NL,NN,KT,Evaptranp_Cal,Coefficient_n,Coefficient_Alpha,Theta_r,Theta_s,DURTN,PME,PT_PM_0,hh,rwuef,J,lEstot,lEctot);   
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

