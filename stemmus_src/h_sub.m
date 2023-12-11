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
global Precip Evap CHK EVAP
global NBCh NBChB BCh BChB hN KT DSTOR0 NBChh TIME h_SUR AVAIL0 
global QMT QMB QMTT QMBB Evapo trap RnSOIL PrecipO
global Ta U Ts Rv g HR_a Srt C9    % U_wind is the mean wind speed at height z_ref (m¡¤s^-1), U is the wind speed at each time step.
global rwuef Trap Rn_SOIL hOLD XElemnt
global TT_CRIT T0 h_frez hh_frez Theta_UU Theta_U DTheta_UUh KfL_h Rn SAVEhh CORh r_a_SOIL Resis_a Precip_msr SUMTIME Gvc SAVEDTheta_UUh SAVEDTheta_LLh Rns


[Chh,ChT,Khh,KhT,Kha,Vvh,VvT,Chg,DTheta_LLh,DTheta_LLT,DTheta_UUh,SAVEDTheta_UUh,SAVEDTheta_LLh]=hPARM(NL,hh,...
h,TT,T,Theta_LL,Theta_L,DTheta_LLh,DTheta_LLT,RHOV,RHOL,Theta_V,V_A,Eta,DRHOVh,...
DRHOVT,KfL_h,D_Ta,KL_T,D_V,D_Vg,COR,Beta_g,Gamma0,Gamma_w,KLa_Switch,DVa_Switch,hThmrl,Thmrlefc,nD,TT_CRIT,T0,h_frez,hh_frez,Theta_UU,Theta_U,CORh,DTheta_UUh,Chh,ChT,Khh,KhT);
[C1,C2,C4,C3,C4_a,C5,C6,C7,C5_a,C9]=h_MAT(Chh,ChT,Khh,KhT,Kha,Vvh,VvT,Chg,DeltZ,NL,NN,Srt);
[RHS,C4,SAVE]=h_EQ(C1,C2,C4,C5,C6,C7,C5_a,C9,NL,NN,Delt_t,T,TT,h,P_gg,Thmrlefc,Soilairefc);
[AVAIL0,RHS,C4,C4_a,Rn_SOIL,Evap,EVAP,Trap,r_a_SOIL,Resis_a,Srt,Precip]=h_BC(XElemnt,RHS,NBCh,NBChB,BCh,BChB,hN,KT,Delt_t,DSTOR0,NBChh,TIME,h_SUR,C4,KL_h,NN,C4_a,DeltZ,RHOV,Ta,HR_a,U,Theta_LL,Ts,Rv,g,NL,hh,rwuef,Theta_UU,Rn,T,TT,Gvc,Rns,Srt,Precip_msr,SUMTIME);% h_BC;
[CHK,hh,C4,SAVEhh]=hh_Solve(C4,hh,NN,NL,C4_a,RHS);
if any(isnan(hh)) || any(hh(1:NN)<=-1E12)
    for MN=1:NN
    hh(MN)=hOLD(MN);
    end
end
[QMT,QMB]=h_Bndry_Flux(SAVE,hh,NN,KT);
PrecipO(KT)=Precip(KT);
QMTT(KT)=QMT(KT);
QMBB(KT)=QMB(KT);
Evapo(KT)=Evap(KT);
trap(KT)=Trap(KT);
% RnSOIL(KT)=Rn_SOIL(KT);
