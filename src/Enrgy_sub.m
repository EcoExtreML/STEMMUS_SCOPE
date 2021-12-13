function Enrgy_sub
global TT MN NN BCTB
global NL hh DeltZ P_gg
global CTh CTT CTa KTh KTT KTa CTg Vvh VvT Vaa Kaa
global c_a c_L RHOL DRHOVT DRHOVh RHOV Hc RHODA DRHODAz L WW 
global Theta_V Theta_g QL V_A 
global KL_h KL_T D_Ta Lambda_eff c_unsat D_V Eta D_Vg Xah XaT Xaa DTheta_LLT Soilairefc
global DTheta_LLh DVa_Switch
global Khh KhT Kha KLhBAR KLTBAR DTDBAR DhDZ DTDZ DPgDZ Beta_g DEhBAR DETBAR QV Qa RHOVBAR EtaBAR
global C1 C2 C3 C4 C5 C6 C7 C4_a C5_a C6_a VTT VTh VTa
global Delt_t RHS T h P_g SAVE Thmrlefc
global QMB SH Precip KT
global NBCTB NBCT BCT DSTOR0 Ts Ta L_ts 
global EVAP Rn CHK QET QEB

for MN=1:NN
   %if isreal(TT(MN))==0
        TT(MN)=real(TT(MN));         
   % end
end

% EnrgyPARM;
[CTh,CTT,CTa,KTh,KTT,KTa,VTT,VTh,VTa,CTg,QL,QV,Qa,KLhBAR,KLTBAR,DTDBAR,DhDZ,DTDZ,DPgDZ,Beta_g,DEhBAR,DETBAR,RHOVBAR,EtaBAR]=EnrgyPARM(NL,hh,TT,DeltZ,P_gg,Kaa,Vvh,VvT,Vaa,c_a,c_L,DTheta_LLh,RHOV,Hc,RHODA,DRHODAz,L,WW,RHOL,Theta_V,DRHOVh,DRHOVT,KL_h,D_Ta,KL_T,D_V,D_Vg,DVa_Switch,Theta_g,QL,V_A,Lambda_eff,c_unsat,Eta,Xah,XaT,Xaa,DTheta_LLT,Soilairefc,Khh,KhT,Kha,KLhBAR,KLTBAR,DTDBAR,DhDZ,DTDZ,DPgDZ,Beta_g,DEhBAR,DETBAR,QV,Qa,RHOVBAR,EtaBAR);
% Enrgy_MAT;
[C1,C2,C3,C4,C4_a,C5,C5_a,C6,C6_a,C7]=Enrgy_MAT(CTh,CTT,CTa,KTh,KTT,KTa,CTg,VTT,VTh,VTa,DeltZ,NL,NN,Soilairefc);
% Enrgy_EQ;
[RHS,C5,SAVE]=Enrgy_EQ(C1,C2,C3,C4,C4_a,C5,C6_a,C6,C7,NL,NN,Delt_t,T,h,hh,P_g,P_gg,Thmrlefc,Soilairefc);
% Enrgy_BC;
[RHS,C5,C5_a]=Enrgy_BC(RHS,KT,NN,c_L,RHOL,QMB,SH,Precip,L,L_ts,NBCTB,NBCT,BCT,BCTB,DSTOR0,Delt_t,T,Ts,Ta,EVAP,Rn,C5,C5_a);
% Enrgy_Solve;
[TT,CHK,RHS,C5]= Enrgy_Solve(C5,C5_a,TT,NN,NL,RHS);
for MN=1:NN
  % if isreal(TT(MN))==0
        TT(MN)=real(TT(MN));         
  %  end
end

% Enrgy_Bndry_Flux;
[QET,QEB]=Enrgy_Bndry_Flux(SAVE,TT,NN);