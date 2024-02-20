function h_BC
global RHS KL_h Precip Evap NN C4 IBOT
global NBCh NBChB BCh BChB hN KT Delt_t DSTOR0 NBChh TIME h_SUR AVAIL0 C4_a XElemnt hBOT
%%%%%%%%%% Apply the bottom boundary condition called for by NBChB %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if NBChB==1            %-----> Specify matric head at bottom to be ---BChB;
%     RHS(1)=BChB;
%     C4(1,1)=1;
%     RHS(2)=RHS(2)-C4(1,2)*RHS(1);
%     C4(1,2)=0;
%     C4_a(1)=0;
% elseif NBChB==2        %-----> Specify flux at bottom to be ---BChB (Positive upwards);
%     RHS(1)=RHS(1)+BChB;
% elseif NBChB==3        %-----> NBChB=3,Gravity drainage at bottom--specify flux= hydraulic conductivity;
%     RHS(1)=RHS(1)-KL_h(1,1);
% end
% IBOT=NN-5;
Q3DF=1;
INBT=NN-IBOT+1;
BOTm=XElemnt(NN);
if Q3DF
    if NBChB==1            %-----> Specify matric head at bottom to be ---BChB;
        RHS(INBT)=(hBOT(KT)-BOTm+XElemnt(IBOT));
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
    Evap_Cal;
    if TIME>22*3600 && TIME<27*3600
        Precip(KT)=0.35/3600; 
    else
        Precip(KT)=0;
    end
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

