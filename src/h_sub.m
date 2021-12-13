function h_sub
global hh MN NN
global C1 C2 C4 C3 C4_a C5 C6 C7 
global Chh ChT Khh KhT Kha Vvh VvT Chg DeltZ C5_a
global NL nD bx 
global Delt_t RHS T TT h P_gg SAVE Thmrlefc Soilairefc
global RHOL Gamma_w DTheta_LLh DTheta_LLT
global Theta_L Theta_LL Theta_V Eta V_A
global RHOV DRHOVh DRHOVT KL_h D_Ta KL_T D_V D_Vg 
global COR hThmrl Beta_g Gamma0 KLa_Switch DVa_Switch
global Precip Evap CHK Evapo EVAP
global NBCh NBChB BCh BChB hN KT DSTOR0 NBChh TIME h_SUR AVAIL0 
global QMT QMB QMTT QMBB
global Ta U Ts Rv g HR_a Srt C9    % U_wind is the mean wind speed at height z_ref (m¡¤s^-1), U is the wind speed at each time step.
global Evaptranp_Cal Coefficient_n Coefficient_Alpha Theta_r Theta_s DURTN PME PT_PM_0 rwuef J trap Trap lEstot lEctot 
%global  trap Trap lEstot lEctot PSIs PSI rsss rrr rxx rwuef

[Chh,ChT,Khh,KhT,Kha,Vvh,VvT,Chg,DTheta_LLh,DTheta_LLT]=hPARM(NL,hh,...
h,TT,T,Theta_LL,Theta_L,DTheta_LLh,DTheta_LLT,RHOV,RHOL,Theta_V,V_A,Eta,DRHOVh,...
DRHOVT,KL_h,D_Ta,KL_T,D_V,D_Vg,COR,Beta_g,Gamma0,Gamma_w,KLa_Switch,DVa_Switch,hThmrl,Thmrlefc,nD);
[C1,C2,C4,C3,C4_a,C5,C6,C7,C5_a,C9]=h_MAT(Chh,ChT,Khh,KhT,Kha,Vvh,VvT,Chg,DeltZ,NL,NN,Srt);
[RHS,C4,SAVE]=h_EQ(C1,C2,C4,C5,C6,C7,C5_a,C9,NL,NN,Delt_t,T,TT,h,P_gg,Thmrlefc,Soilairefc);
[AVAIL0,RHS,C4,C4_a,Evap,EVAP,Trap,Precip,bx,Srt]=h_BC(DeltZ,bx,Srt,RHS,NBCh,NBChB,BCh,BChB,hN,KT,Delt_t,DSTOR0,NBChh,TIME,h_SUR,C4,KL_h,Precip,NN,AVAIL0,C4_a,Evap,RHOV,Ta,HR_a,U,Ts,Theta_LL,Rv,g,NL,Evaptranp_Cal,Coefficient_n,Coefficient_Alpha,Theta_r,Theta_s,DURTN,PME,PT_PM_0,hh,rwuef,J,lEstot,lEctot);
[CHK,hh,C4]=hh_Solve(C4,hh,NN,NL,C4_a,RHS);
for MN=1:NN
    if hh(MN)<=-10^(5)
        hh(MN)=-10^(5);
    elseif hh(MN)>=-1e-6
        hh(MN)=-1e-6;
    end
end            
[QMT,QMB]=h_Bndry_Flux(SAVE,hh,NN,KT);
QMTT(KT)=QMT(KT);
QMBB(KT)=QMB(KT);
Evapo(KT)=Evap(KT);
trap(KT)=Trap(KT);