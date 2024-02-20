clc;
clearvars -except HPILR1N HPILR0 RrNG KTN TTIME TTEND KTNUM BOT_NODES KPILLAR BOTm SYSTG SSSTG itlevel2 itlevel IP0STm ...
    STMHPLR0 STMHPLR1N STMZTB0 STMZTB1 STMRrN STMRrO STMSY STMSS Q3DF ADAPTF RrNGG RrOGG ...
    TP_gg TP_gOLD TTTt TTOLD ThOLD THH h0 hh0 IBOTSTM KPILRSTM IPSTM TSim_Theta TSim_Temp ...
    STMHPLR02 STMHPLR1N2 STMZTB02 STMZTB12 STMRrN2 STMRrO2 STMSY2 STMSS2 RrNGG2 RrOGG2 IPSTM2 ...
    TP_gg2 TP_gOLD2 TTTt2 TTOLD2 ThOLD2 THH2 h02 hh02 IBOTSTM2 TSim_Theta2 TSim_Temp2 STETEND2 iBOTNODEs

close all;
run Constants

% function MainLoop
global i tS KT Delt_t TEND TIME MN NN NL ML ND hOLD TOLD h hh T TT P_gOLD P_g P_gg Delt_t0
global KIT NIT TimeStep Processing
global SUMTIME hhh TTT P_ggg Theta_LLL DSTOR Thmrlefc CHK Theta_LL Theta_L 
global NBCh AVAIL Evap DSTOR0 EXCESS QMT RS BCh hN hSAVE NBChh DSTMAX Soilairefc Precip
global TSAVE IRPT1 IRPT2 AVAIL0 TIMEOLD TIMELAST L 
global D_Vg Theta_g Sa V_A k_g MU_a DeltZ Alpha_Lg
global J Beta_g KaT_Switch Theta_s
global D_V D_A fc Eta nD POR Se 
global ThmrlCondCap ZETA XK DVT_Switch 
global m g MU_W Ks RHOL
global Lambda1 Lambda2 Lambda3 c_unsat Lambda_eff RHO_bulk
global RHODA RHOV c_a c_V c_L
global ETCON EHCAP
global Xaa XaT Xah RDA Rv KL_T
global DRHOVT DRHOVh DRHODAt DRHODAz
global hThmrl Tr COR IS Hystrs XWRE
global Theta_V DTheta_LLh IH KL_h
global W WW D_Ta SSUR
global W_Chg itlevel1 iBOTNODEs h0 hh0
global KLT_Switch Theta_r Alpha n CKTN XOLD
global Chh ChT Khh KhT Kha Vvh VvT Chg DTheta_LLT C1 C2 C4 C3 C4_a C5 C6 C7 C5_a RHS SAVE EVAP QMB Gamma0 Gamma_w KLa_Switch DVa_Switch NBChB BChB h_SUR Ta HR_a U Ts 
global QL KLhBAR KLTBAR DhDZ DTDZ DPgDZ DTDBAR QV Qa DEhBAR DETBAR RHOVBAR EtaBAR BtmPg TopPg NBCPB BCPB NBCP BCP Kaa Vaa SH L_ts NBCTB NBCT BCT BCTB Rn Hc Evapo xERR hERR TERR QMTT QMBB Ts_Min Ts_Max  

Ts_Min=0;Ts_Max=80;
run StartInit;   % Initialize Temperature, Matric potential and soil air pressure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TIMEOLD=0;
TIMELAST=0;
itlevel1=0;
  