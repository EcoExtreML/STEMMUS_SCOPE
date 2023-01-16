function [SoilConstants, SoilVariables, Genuchten, ThermalConductivity, BoundaryCondition] = StartInit(SoilProperties, SiteProperties)

%%% SoilConstants for init
SoilConstants = init.setSoilConstants(SoilProperties.MSOC, SoilProperties.FOC, SoilProperties.FOS);

% these extra vars are set in script Constants.m
global ML NL NN DeltZ Tot_Depth SWCC BtmX BtmT Thmrlefc J Soilairefc P_g P_gg
global h T TT h_frez
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
SoilConstants.h = h;
SoilConstants.T = T;
SoilConstants.TT = TT;
SoilConstants.h_frez = h_frez;

Ksh= repelem(18/(3600*24), 6);
BtmKsh=Ksh(6);
Ksh0=Ksh(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Considering soil hetero effect modify date: 20170103 %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% these are defined in script Constants.m
global InitX0 InitX1 InitX2 InitX3 InitX4 InitX5 InitX6
global InitND1 InitND2 InitND3 InitND4 InitND5 BtmT BtmX Btmh InitND6% Preset the measured depth to get the initial T, h by interpolation method.
global InitT0 InitT1 InitT2 InitT3 InitT4 InitT5 InitT6
global Eqlspace

initX = [InitX0 InitX1 InitX2 InitX3 InitX4 InitX5 InitX6];
initND = [InitND1 InitND2 InitND3 InitND4 InitND5 InitND6];
initT = [InitT0, InitT1, InitT2, InitT3, InitT4, InitT5, InitT6];

Genuchten = init.setGenuchtenParameters(SoilProperties);
SoilVariables = init.setSoilVariables(SoilProperties, SoilConstants, Genuchten);
[SoilVariables, Genuchten, initH, Btmh] = init.useSoilHeteroEffect(SoilProperties, SoilConstants, SoilVariables, Genuchten, initX, initND, initT, Eqlspace);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Considering soil hetero effect modify date: 20170103 %%%%%%%%%%%%
%%%%%% Perform initial freezing temperature for each soil type.%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SoilVariables = init.useSoilHeteroWithInitialFreezing(SoilConstants, SoilVariables);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Perform initial thermal calculations for each soil type.%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is defined in script Constants.m
global ThermCond
ThermalConductivity = calculateInitialThermal(SoilConstants, SoilVariables, Genuchten, ThermCond);

% According to hh value get the Theta_LL
% run SOIL2;   % For calculating Theta_LL,used in first Balance calculation.

% these are defined in script Constants.m
global Theta_L Theta_LL Theta_V Theta_g Se KL_h DTheta_LLh
global KfL_T Theta_II Theta_I Theta_UU Theta_U g T0 TT_CRIT
global KfL_h DTheta_UUh hThmrl Tr
global Hystrs KIT RHOI RHOL

% after refatoring SOIL2, these lines can be removed!
NN = SoilConstants.numberOfNodes;
NL = SoilConstants.totalNumberOfElements;

Theta_s = Genuchten.Theta_s;
Theta_r = Genuchten.Theta_r;
Alpha = Genuchten.Alpha;
n = Genuchten.n;
m = Genuchten.m;

POR = SoilVariables.POR;
h = SoilVariables.h;
Lamda = SoilVariables.Lamda;
Phi_s = SoilVariables.Phi_s;
h_frez = SoilVariables.h_frez;
hh_frez = SoilVariables.hh_frez;
TT = SoilVariables.TT;
hh = SoilVariables.hh;
XWRE = SoilVariables.XWRE;
IH = SoilVariables.IH;
Ks = SoilVariables.Ks;
SWCC = SoilConstants.SWCC;
Imped = SoilVariables.Imped;
XCAP = SoilVariables.XCAP;

L_f=3.34*1e5; %latent heat of freezing fusion J Kg-1
T0=273.15; % unit K

global COR CORh  % defined inside SOIL2
[hh,COR,CORh,Theta_V,Theta_g,Se,KL_h,Theta_LL,DTheta_LLh,KfL_h,KfL_T,hh_frez,Theta_UU,DTheta_UUh,Theta_II]=SOIL2(hh,COR,hThmrl,NN,NL,TT,Tr,Hystrs,XWRE,Theta_s,IH,KIT,Theta_r,Alpha,n,m,Ks,Theta_L,h,Thmrlefc,POR,Theta_II,CORh,hh_frez,h_frez,SWCC,Theta_U,XCAP,Phi_s,RHOI,RHOL,Lamda,Imped,L_f,g,T0,TT_CRIT,KfL_h,KfL_T,KL_h,Theta_UU,Theta_LL,DTheta_LLh,DTheta_UUh,Se);

for i=1:SoilConstants.totalNumberOfElements % NL
    Theta_L(i,1)=Theta_LL(i,1);
    Theta_L(i,2)=Theta_LL(i,2);
    XOLD(i)=(Theta_L(i,1)+Theta_L(i,2))/2; % unused!
    Theta_U(i,1)=Theta_UU(i,1);
    Theta_U(i,2)=Theta_UU(i,2);
    XUOLD(i)=(Theta_U(i,1)+Theta_U(i,2))/2;
    Theta_I(i,1)=Theta_II(i,1);
    Theta_I(i,2)=Theta_II(i,2);
    XIOLD(i)=(Theta_I(i,1)+Theta_I(i,2))/2; % unused!
end
% Using the initial condition to get the initial balance
% information---Initial heat storage and initial moisture storage.
SoilVariables.KLT_Switch=1;
SoilVariables.DVT_Switch=1;
if SoilConstants.Soilairefc
    SoilVariables.KaT_Switch=1;
    % these vars are not used in the main script!
    Kaa_Switch=1;
    DVa_Switch=1;
    KLa_Switch=1;
end

% after refatoring SOIL2, these two lines can be removed!
SoilConstants.KfL_T = KfL_T;
SoilConstants.Theta_II = Theta_II;
SoilConstants.Theta_I = Theta_I;
SoilConstants.Theta_UU = Theta_UU;
SoilConstants.Theta_U = Theta_U;

SoilVariables.hh_frez = hh_frez;
SoilVariables.hh = hh;
SoilVariables.COR = COR;
SoilVariables.CORh = CORh;
SoilVariables.Se = Se;
SoilVariables.KL_h = KL_h;
SoilVariables.Theta_L = Theta_L;
SoilVariables.Theta_LL = Theta_LL;
SoilVariables.DTheta_LLh = DTheta_LLh;
SoilVariables.KfL_h = KfL_h;
SoilVariables.KfL_T = KfL_T;
SoilVariables.Theta_V = Theta_V;
SoilVariables.Theta_g = Theta_g;
SoilVariables.DTheta_UUh = DTheta_UUh;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% The boundary condition information settings.%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is defined in Constants.m
global Ta_msr

IGBP_veg_long = SiteProperties.IGBP_veg_long;
BoundaryCondition = setBoundaryCondition(SoilVariables, SoilConstants, Ta_msr, IGBP_veg_long)
