function StartInit


global InitT0 InitT1 InitT2 InitT3 InitT4 InitT5 InitT6
global T MN ML NL NN DeltZ Tot_Depth InitLnth
global h Theta_s Theta_r m n Alpha Theta_L Theta_LL hh TT P_g P_gg Ks h_frez hh_frez 
global XOLD XWRE NS J POR Thmrlefc IH IS Eqlspace FACc
global porosity SaturatedMC ResidualMC SaturatedK Coefficient_n Coefficient_Alpha
global NBCh NBCT NBCP NBChB NBCTB NBCPB BChB BCTB BCPB BCh BCT BCP BtmPg 
global DSTOR DSTOR0 RS NBChh DSTMAX IRPT1 IRPT2 Soilairefc XK XWILT 
global HCAP TCON SF TCA GA1 GA2 GB1 GB2 S1 S2 HCD TARG1 TARG2 GRAT VPER 
global TERM ZETA0 CON0 PS1 PS2 i KLT_Switch DVT_Switch KaT_Switch
global Kaa_Switch DVa_Switch KLa_Switch
global KfL_T Theta_II Theta_I Theta_UU Theta_U  L_f g T0 TT_CRIT XUOLD XIOLD ISFT TCON_s TCON_dry TCON_L RHo_bulk Imped TPS1 TPS2 FEHCAP TS1 TS2 TCON0 TCON_min Theta_qtz XSOC
global Lamda Phi_s SWCC XCAP ThermCond Gama_hh Theta_a Gama_h SAVEhh SAVEh
global COR CORh Theta_V Theta_g Se KL_h DTheta_LLh KfL_h DTheta_UUh hThmrl Tr Hystrs KIT RHOI RHOL Coef_Lamda fieldMC Theta_f Ta_msr IGBP_veg_long


%%% SoilConstants for init
global SoilProperties
SoilConstants = init.setSoilConstants(SoilProperties.MSOC, SoilProperties.FOC, SoilProperties.FOS);

% thsese extra vars are set in script Constants.m
SoilConstants.SWCC = SWCC; % 
SoilConstants.J = J; 
SoilConstants.totalNumberOfElements = NL;
SoilConstants.numberOfElements = ML; 
SoilConstants.DeltZ = DeltZ;
SoilConstants.numberOfNodes = NN;
SoilConstants.BtmX = BtmX;
SoilConstants.BtmT = BtmT;
SoilConstants.Tot_Depth = Tot_Depth;
SoilConstants.Thmrlefc = Thmrlefc;
SoilConstants.Soilairefc = Soilairefc;
SoilConstants.P_g = P_g;
SoilConstants.P_gg = P_gg;

FOSL = SoilConstants.FOSL; %% check this var

Ksh(1:6)=[18/(3600*24) 18/(3600*24) 18/(3600*24) 18/(3600*24) 18/(3600*24) 18/(3600*24)];
BtmKsh=Ksh(6);
Ksh0=Ksh(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Considering soil hetero effect modify date: 20170103 %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initX are defined in script Constants.m
global InitX0 InitX1 InitX2 InitX3 InitX4 InitX5 InitX6
global InitND1 InitND2 InitND3 InitND4 InitND5 BtmT BtmX Btmh InitND6% Preset the measured depth to get the initial T, h by interpolation method.
initX = [InitX0 InitX1 InitX2 InitX3 InitX4 InitX5 InitX6];
initND = [InitND1 InitND2 InitND3 InitND4 InitND5 InitND6];
initT = [InitT0, InitT1, InitT2, InitT3, InitT4, InitT5, InitT6];
[SoilVariables, initH, Btmh] = init.useSoilHeteroEffect(SoilProperties, SoilConstants, initX, initND, initT);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Considering soil hetero effect modify date: 20170103 %%%%%%%%%%%%
%%%%%% Perform initial freezing temperature for each soil type.%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[SoilVariables] = init.useSoilHeteroWithInitialFreezing(SoilConstants, XWRE);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Perform initial thermal calculations for each soil type.%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

HCAP(1)=0.998*4.182;
HCAP(2)=0.0003*4.182;
HCAP(3)=0.46*4.182;
HCAP(4)=0.46*4.182;
HCAP(5)=0.6*4.182;
HCAP(6)=0.45*4.182; 
% HCAP(3)=2.66;
% HCAP(4)=2.66;
% HCAP(5)=1.3; % ZENG origial HCAP(3)=0.46*4.182;
% HCAP(4)=0.46*4.182;
% HCAP(5)=0.6*4.182; % J cm^-3 Cels^-1 / g.cm-3---> J g-1 Cels-1;

TCON(1)=1.37e-3*4.182;
TCON(2)=6e-5*4.182;
TCON(3)=2.1e-2*4.182;
TCON(4)=7e-3*4.182;
TCON(5)=6e-4*4.182;
TCON(6)=5.2e-3*4.182;
% TCON(3)=8.8e-2;
% TCON(4)=2.9e-2;TCON(5)=2.5e-3;% ZENG origial TCON(3)=2.1e-2*4.182;
% TCON(4)=7e-3*4.182;
% TCON(5)=6e-4*4.182; % J cm^-1 s^-1 Cels^-1;

SF(1)=0;
SF(2)=0;
SF(3)=0.125;
SF(4)=0.125;
SF(5)=0.5;
SF(6)=0.125;
TCA=6e-5*4.182;GA1=0.035;GA2=0.013; 
% VPER(1)=0.25;
% VPER(2)=0.23;
% VPER(3)=0.01;% for sand VPER(1)=0.65;
% VPER(2)=0;VPER(3)=0; % For Silt Loam; % VPER(1)=0.16;
% VPER(2)=0.33;VPER(3)=0.05;
% VPER(1)=0.41;
% VPER(2)=0.06;

calculateInitialThermal();

% According to hh value get the Theta_LL
% run SOIL2;   % For calculating Theta_LL,used in first Balance calculation.
[hh,COR,CORh,Theta_V,Theta_g,Se,KL_h,Theta_LL,DTheta_LLh,KfL_h,KfL_T,hh_frez,Theta_UU,DTheta_UUh,Theta_II]=SOIL2(hh,COR,hThmrl,NN,NL,TT,Tr,Hystrs,XWRE,Theta_s,IH,KIT,Theta_r,Alpha,n,m,Ks,Theta_L,h,Thmrlefc,POR,Theta_II,CORh,hh_frez,h_frez,SWCC,Theta_U,XCAP,Phi_s,RHOI,RHOL,Lamda,Imped,L_f,g,T0,TT_CRIT,KfL_h,KfL_T,KL_h,Theta_UU,Theta_LL,DTheta_LLh,DTheta_UUh,Se);

for i=1:SoilConstants.totalNumberOfElements % NL
    Theta_L(i,1)=Theta_LL(i,1);
    Theta_L(i,2)=Theta_LL(i,2);
    XOLD(i)=(Theta_L(i,1)+Theta_L(i,2))/2;
    Theta_U(i,1)=Theta_UU(i,1);
    Theta_U(i,2)=Theta_UU(i,2);
    XUOLD(i)=(Theta_U(i,1)+Theta_U(i,2))/2;
    Theta_I(i,1)=Theta_II(i,1);
    Theta_I(i,2)=Theta_II(i,2);
    XIOLD(i)=(Theta_I(i,1)+Theta_I(i,2))/2;
end
% Using the initial condition to get the initial balance
% information---Initial heat storage and initial moisture storage.
KLT_Switch=1;
DVT_Switch=1;
if Soilairefc
    KaT_Switch=1;
    Kaa_Switch=1;
    DVa_Switch=1;
    KLa_Switch=1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% The boundary condition information settings.%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
setBoundaryCondition
