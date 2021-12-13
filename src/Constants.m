% function Constants
global DeltZ Delt_t ML NS mL mN nD NL NN SAVE Tot_Depth
global xERR hERR TERR PERR tS
global KT TIME Delt_t0 DURTN TEND NIT KIT Nmsrmn Eqlspace h_SUR Msrmn_Fitting  
global Msr_Mois Msr_Temp Msr_Time 
global Ksoil Rl SMC Ztot DeltZ_R Theta_o rroot frac bbx wfrac RWUtot Rls Tatot LR PSItot sfactortot

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%% The time and domain information setting. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KIT=0;                      % KIT is used to count the number of iteration in a time step; 
NIT=60;                     % Desirable number of iterations in a time step;               
Nmsrmn=17568;       %Nmsrmn=2568*100;  Here, it is made as big as possible, in case a long simulation period containing many time step is defined. 
                                                                                    
DURTN=60*30*17568;     % Duration of simulation period;                                  
KT=0;                        % Number of time steps;                                           
TIME=0;                     % Time of simulation released;                                  

                                                                                    
TEND=TIME+DURTN;     % Time to be reached at the end of simulation period;          
Delt_t=1800;                   % Duration of time step [Unit of second]                       
Delt_t0=Delt_t;           % Duration of last time step;                                  
tS=DURTN/Delt_t;        % Is the tS(time step) needed to be added with 1? 
                                % Cause the start of simulation period is from 0mins, while the input data start from 30mins.
                                                                                    
xERR=0.02;                  % Maximum desirable change of moisture content;                  
hERR=0.1e08;               % Maximum desirable change of matric potential;                
TERR=2;                      % Maximum desirable change of temperature;                
PERR=5000;                  % Maximum desirable change of soil air pressure (Pa,kg.m^-1.s^-1);
                                                                                    
Tot_Depth=500;           % Unit is cm. it should be usually bigger than 0.5m. Otherwise, 
                                 % the DeltZ would be reset in 50cm by hand;                                  
NL=100;                                                                              
Eqlspace=0;                 % Indicator for deciding is the space step equal or not;       
                                                                                    
if ~Eqlspace                                                                     
   run Dtrmn_Z              % Determination of NL, the number of elments;              
else                                                                                
    for ML=1:NL                                                                     
        DeltZ(ML)=Tot_Depth/NL;                                                     
    end                                                                             
end                                                                                 
                                                                                    
NN=NL+1;                    % Number of nodes;                                             
mN=NN+1;                                                                            
mL=NL+1;                    % Number of elements. Prevending the exceeds of size of arraies;
nD=2;                                                                               
NS=1;                          % Number of soil types;                                        
SAVE=zeros(3,3,3);        % Arraies for calculating boundary flux;                       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global h_TE          
global W_Chg         
global l CKTN
global RHOL SSUR RHO_bulk Rv g RDA           
global KL_h KL_T D_Ta 
global Theta_L Theta_LL Se h hh T TT Theta_V DTheta_LLh
global W WW MU_W f0 L_WT
global DhT                             
global GWT Gamma0 MU_W0 MU1 b W0 Gamma_w
global Chh ChT Khh KhT Kha Vvh VvT Chg
global C1 C2 C3 C4 C5 C6 C7 C9
global QL QL_D QL_disp RHS
global HR RHOV_s RHOV DRHOV_sT DRHOVh DRHOVT
global RHODA DRHODAt DRHODAz Xaa XaT Xah
global D_Vg D_V D_A 
global k_g Sa V_A Alpha_Lg POR_C Eta
global P_g P_gg Theta_g P_g0 Beta_g
global MU_a fc Unit_C Hc UnitC
global Cah CaT Caa Kah KaT Kaa Vah VaT Vaa Cag
global Lambda1 Lambda2 Lambda3 c_L c_a c_V L0
global Lambda_eff c_unsat L LL Tr
global CTh CTT CTa KTh KTT KTa VTT VTh VTa CTg
global Kcvh KcvT Kcva Ccvh CcvT Kcah KcaT Kcaa Ccah CcaT Ccaa

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meteorological Forcing Information Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global MO Ta U Ts Zeta_MO        % U_wind is the mean wind speed at height z_ref (m，s^-1), U is the wind speed at each time step.
global Precip SH HR_a UseTs_msrmn      % Notice that Evap and Precip have only one value for each time step. Precip needs to be measured in advance as the input.
global Gsc Sigma_E 
global Rns Rnl     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables information for soil air pressure propagation 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global TopPg 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fluxes information with different mechanisms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global QL_Dts QL_dispts QLts QV_Dts QV_Ats QV_dispts QVts QA_Dts QA_Ats QA_dispts QAts
global QV_D QV_A QV_disp QA_D QA_A QA_disp QL_T QL_h

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variable information for updating the state variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global hOLD TOLD P_gOLD J 
global porosity SaturatedMC ResidualMC SaturatedK Coefficient_n Coefficient_Alpha
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables information for initialization subroutine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global InitND1 InitND2 InitND3 InitND4 InitND5 BtmT BtmX  %Preset the measured depth to get the initial T, h by interpolation method.
global InitT0 InitT1 InitT2 InitT3 InitT4 InitT5 
global InitX0 InitX1 InitX2 InitX3 InitX4 InitX5 
global Thmrlefc hThmrl Hystrs Soilairefc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Effective Thermal conductivity and capacity variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global EHCAP ThmrlCondCap Evaptranp_Cal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables information for boundary condition settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DVhSUM DVTSUM DVaSUM KahSUM KaTSUM KaaSUM  KLhhSUM KLTTSUM
DVhSUM=zeros(Nmsrmn/2,1);DVTSUM=zeros(Nmsrmn/2,1); DVaSUM=zeros(Nmsrmn/2,1); 
KahSUM=zeros(Nmsrmn/2,1); KaTSUM=zeros(Nmsrmn/2,1); KaaSUM=zeros(Nmsrmn/2,1);  
KLhhSUM=zeros(Nmsrmn/2,1); KLTTSUM=zeros(Nmsrmn/2,1);

%> NBCh   Indicator for type of surface boundary condition on mass euqation to be applied;
%>        "1"--Specified matric head; 
%>        "2"--Specified potential moisture flux (potential evaporation rate of precipitation rate);
%>        "3"--Specified atmospheric forcing;
%> NBCT   Indicator for type of surface boundary condtion on energy equation to be applied;
%>        "1"--Specified temperature; 
%>        "2"--Specified heat flux;
%         "3"--Specified atmospheric forcing;
%> NBCP   Indicator for type of surface boundary condition on dry air equation to be applied;
%>        "1"--Specified atmospheric pressure; 
%>        "2"--Specified atmospheric forcing (Measured atmospheric pressure data);                                                                                                   
%> BCh    Value of specified matric head (if NBCh=1) or specified potential moisture flux (if NBCh=2) at surface;
%> BChB   The same as BCh but at the bottom of column;
%> BCT    Value of specified temperature (if NBCT=1) or specified head flux (if NBCT=2) at surface;
%> BCTB   The same as BCT but at the bottom of column;
%> BCPB   Value of specified atmospheric pressure;
%> BCP    The same as BCP but at the bottom of column;
%> hN     Specified value of matric head when a fist-type BC is used;
%> NBChB  Type of boundary condition on matric head at bottom of column;
%>        "1"--Specified head of BChB at bottom;
%>        "2"--Specified moisture flux of BChB;
%>        "3"--Zero matric head gradient at bottom(Gravity drainage);
%> NBCTB  Type of boundary condition on temperature at bottom of column;
%>        "1"--Specified temperature BCTB at bottom; 
%>        "2"--Specified heat flux BCTB at bottom;
%>        "3"--Zero temperature gradient at bottom (advection only);
%> NBCPB  Type of boundary condition on soil air pressure;
%>        "1"--Specified dry air flux BCPB at bottom;
%>        "2"--Zero soil air pressure gradient at bottom;
%> NBChh  Type of surface BC actually applied on a particular trial of a time step when NBCh euqals 2 or 3;
%>        "1"--Specified matric head;
%>        "2"--Specified actual flux;
%> DSTOR  Depth of depression storage at end of current time step;
%> DSTOR0 Depth of depression storage at start of current time step;
%> DSTMAX Depression storage capacity;
%> EXCESS Excess of available water over infiltration rate for current time step,expressed as a rate;
%> AVAIL  Maximum rate at which water can be supplied to the soil from above during the current time step;
%> 
%>
global alpha_h bx Srt rwuef Ts_msr

alpha_h=zeros(mL,nD);      %root water uptake
bx=zeros(NL,1);
bbx=zeros(NL,1);
Srt=zeros(mL,nD);

DTheta_LLh=zeros(mL,nD);
KL_h=zeros(mL,nD);       % The hydraulic conductivity(m，s^-1); 
KL_T=zeros(mL,nD);       % The conductivity controlled by thermal gradient(m^2，Cels^-1，s^-1); 
D_Ta=zeros(mL,nD);      % The thermal dispersivity for soil water (m^2，Cels^-1，s^-1); 
Theta_L=zeros(mL,nD);   % The soil moisture at the start of current time step;  
Theta_LL=zeros(mL,nD);  % The soil moisture at the end of current time step;      
Se=zeros(mL,nD);           % The saturation degree of soil moisture;  
h=zeros(mN,1);              % The matric head at the start of current time step;
hh=zeros(mN,1);             % The matric head at the end of current time step;
T=zeros(mN,1);              % The soil temperature at the start of current time step; 
TT=zeros(mN,1);             % The soil temperature at the end of current time step;   
Theta_V=zeros(mL,nD);    % Volumetric gas content;  
W=zeros(mL,nD);             % Differential heat of wetting at the start of current time step(J，kg^-1);  
WW=zeros(mL,nD);          % Differential heat of wetting at the end of current time step(J，kg^-1);
                                    % Integral heat of wetting in individual time step(J，m^-2); %%%%%%%%%%%%%%% Notice: the formulation of this in 'CondL_Tdisp' is not a sure. %%%%%%%%%%%%%%
MU_W=zeros(mL,nD);        % Visocity of water(kg，m^?6?1，s^?6?1);
f0=zeros(mL,nD);              % Tortusity factor [Millington and Quirk (1961)];                   kg.m^2.s^-2.m^-2.kg.m^-3       
L_WT=zeros(mL,nD);         % Liquid dispersion factor in Thermal dispersivity(kg，m^-1，s^-1)=-------------------------- m^2 (1.5548e-013 m^2);
DhT=zeros(mN,1);             % Difference of matric head with respect to temperature;              m. kg.m^-1.s^-1
RHS=zeros(mN,1);             % The right hand side part of equations in '*_EQ' subroutine;
EHCAP=zeros(mL,nD);        % Effective heat capacity;
Chh=zeros(mL,nD);            % Storage coefficients in moisture mass conservation equation related to matric head;
ChT=zeros(mL,nD);           % Storage coefficients in moisture mass conservation equation related to temperature;
Khh=zeros(mL,nD);           % Conduction coefficients in moisture mass conservation equation related to matric head;
KhT=zeros(mL,nD);           % Conduction coefficients in moisture mass conservation equation related to temperature;
Kha=zeros(mL,nD);           % Conduction coefficients in moisture mass conservation equation related to soil air pressure;
Vvh=zeros(mL,nD);           % Conduction coefficients in moisture mass conservation equation related to matric head;
VvT=zeros(mL,nD);           % Conduction coefficients in moisture mass conservation equation related tempearture;
Chg=zeros(mL,nD);           % Gravity coefficients in moisture mass conservation equation;
C1=zeros(mL,nD);            % The coefficients for storage term related to matric head;
C2=zeros(mL,nD);            % The coefficients for storage term related to tempearture;
C3=zeros(mL,nD);            % Storage term coefficients related to soil air pressure;
C4=zeros(mL,nD);            % Conductivity term coefficients related to matric head;
C5=zeros(mL,nD);            % Conductivity term coefficients related to temperature;
C6=zeros(mL,nD);            % Conductivity term coefficients related to soil air pressure;
C7=zeros(mN,1);             % Gravity term coefficients;
C9=zeros(mN,1);             % root water uptake coefficients;
QL=zeros(mL,nD);            % Soil moisture mass flux (kg，m^-2，s^-1);
QL_D=zeros(mL,nD);         % Convective moisturemass flux (kg，m^-2，s^-1);
QL_disp=zeros(mL,nD);     % Dispersive moisture mass flux (kg，m^-2，s^-1);
QL_h=zeros(mL,nD);     % potential driven moisture mass flux (kg，m^-2，s^-1);
QL_T=zeros(mL,nD);     % temperature driven moisture mass flux (kg，m^-2，s^-1);
HR=zeros(mN,1);             % The relative humidity in soil pores, used for calculatin the vapor density;
RHOV_s=zeros(mN,1);      % Saturated vapor density in soil pores (kg，m^-3);
RHOV=zeros(mN,1);         % Vapor density in soil pores (kg，m^-3);
DRHOV_sT=zeros(mN,1);   % Derivative of saturated vapor density with respect to temperature;
DRHOVh=zeros(mN,1);      % Derivative of vapor density with respect to matric head;
DRHOVT=zeros(mN,1);      % Derivative of vapor density with respect to temperature;
RHODA=zeros(mN,1);        % Dry air density in soil pores(kg，m^-3);
DRHODAz=zeros(mN,1);     % Derivative of dry air density with respect to distance;
DRHODAt=zeros(mN,1);     % Derivative of dry air density with respect to time;
Xaa=zeros(mN,1);            % Coefficients of derivative of dry air density with respect to temperature and matric head;
XaT=zeros(mN,1);            % Coefficients of derivative of dry air density with respect to temperature and matric head;
Xah=zeros(mN,1);            % Coefficients of derivative of dry air density with respect to temperature and matric head;
D_Vg=zeros(mL,1);           % Gas phase longitudinal dispersion coefficient (m^2，s^-1);
D_V=zeros(mL,nD);           % Molecular diffusivity of water vapor in soil(m^2，s^-1);
D_A=zeros(mN,1);            % Diffusivity of water vapor in air (m^2，s^-1);
k_g=zeros(mL,nD);           % Intrinsic air permeability (m^2);
Sa=zeros(mL,nD);            % Saturation degree of gas in soil pores;
V_A=zeros(mL,nD);           % Soil air velocity (m，s^-1);
Alpha_Lg=zeros(mL,nD);    % Longitudinal dispersivity in gas phase (m);
POR_C=zeros(mL,nD);        % The threshold air-filled porosity;
Eta=zeros(mL,nD);            % Enhancement factor for thermal vapor transport in soil.
P_g=zeros(mN,1);             % Soil air pressure at the start of current time step;
P_gg=zeros(mN,1);           % Soil air pressure at the end of current time step;
Theta_g=zeros(mL,nD);     % Volumetric gas content;
Beta_g=zeros(mL,nD);       % The simplified coefficient for the soil air pressure linearization equation;
Cah=zeros(mL,nD);           % Storage coefficients in dry air mass conservation equation related to matric head;
CaT=zeros(mL,nD);           % Storage coefficients in dry air mass conservation equation related to temperature;
Caa=zeros(mL,nD);           % Storage coefficients in dry air mass conservation equation related to soil air pressure;
Kah=zeros(mL,nD);           % Conduction coefficients in dry air mass conservation equation related to matric head;
KaT=zeros(mL,nD);           % Conduction coefficients in dry air mass conservation equation related to temperature;
Kaa=zeros(mL,nD);           % Conduction coefficients in dry air mass conservation equation related to soil air pressure;
Vah=zeros(mL,nD);           % Conduction coefficients in dry air mass conservation equation related to matric head;
VaT=zeros(mL,nD);           % Conduction coefficients in dry air mass conservation equation related to temperature;
Vaa=zeros(mL,nD);           % Conduction coefficients in dry air mass conservation equation related to soil air pressure;
Cag=zeros(mL,nD);           % Gravity coefficients in dry air mass conservation equation;
Lambda_eff=zeros(mL,nD); % Effective heat conductivity;
c_unsat=zeros(mL,nD);     % Effective heat capacity;
L=zeros(mN,1);                % The latent heat of vaporization at the beginning of the time step;
LL=zeros(mN,1);               % The latent heat of vaporization at the end of the time step;
CTh=zeros(mL,nD);           % Storage coefficient in energy conservation equation related to matric head;
CTT=zeros(mL,nD);           % Storage coefficient in energy conservation equation related to temperature;
CTa=zeros(mL,nD);           % Storage coefficient in energy conservation equation related to soil air pressure;
KTh=zeros(mL,nD);           % Conduction coefficient in energy conservation equation related to matric head;
KTT=zeros(mL,nD);           % Conduction coefficient in energy conservation equation related to temperature;
KTa=zeros(mL,nD);           % Conduction coefficient in energy conservation equation related to soil air pressure;
VTT=zeros(mL,nD);           % Conduction coefficient in energy conservation equation related to matric head;
VTh=zeros(mL,nD);           % Conduction coefficient in energy conservation equation related to temperature;
VTa=zeros(mL,nD);           % Conduction coefficient in energy conservation equation related to soil air pressure;
CTg=zeros(mL,nD);           % Gravity coefficient in energy conservation equation;
Kcvh=zeros(mL,nD);          % Conduction coefficient of vapor transport in energy conservation equation related to matric head;
KcvT=zeros(mL,nD);          % Conduction coefficient of vapor transport in energy conservation equation related to temperature;
Kcva=zeros(mL,nD);          % Conduction coefficient of vapor transport in energy conservation equation related to soil air pressure;
Ccvh=zeros(mL,nD);          % Storage coefficient of vapor transport in energy conservation equation related to matric head;
CcvT=zeros(mL,nD);          % Storage coefficient of vapor transport in energy conservation equation related to temperature;
Kcah=zeros(mL,nD);          % Conduction coefficient of dry air transport in energy conservation equation related to matric head;
KcaT=zeros(mL,nD);          % Conduction coefficient of dry air transport in energy conservation equation related to temperature;
Kcaa=zeros(mL,nD);          % Conduction coefficient of dry air transport in energy conservation equation related to soil air pressure;
Ccah=zeros(mL,nD);          % Storage coefficient of dry air transport in energy conservation equation related to matric head;
CcaT=zeros(mL,nD);          % Storage coefficient of dry air transport in energy conservation equation related to temperature;
Ccaa=zeros(mL,nD);          % Storage coefficient of dry air transport in energy conservation equation related to soil air pressure;
Precip=zeros(Nmsrmn,1);    % Precipitation(m.s^-1);
Ta=zeros(Nmsrmn,1);         % Air temperature;
Ts=zeros(Nmsrmn,1);         % Surface temperature;
U=zeros(Nmsrmn,1);          % Wind speed (m.s^-1);
HR_a=zeros(Nmsrmn,1);      % Air relative humidity;
Rns=zeros(Nmsrmn,1);        % Net shortwave radiation(W，m^-2);
Rnl=zeros(Nmsrmn,1);        % Net longwave radiation(W，m^-2);
Rn=zeros(Nmsrmn,1);
h_SUR=zeros(Nmsrmn,1);    % Observed matric potential at surface;
SH=zeros(Nmsrmn,1);         % Sensible heat (W，m^-2);
MO=zeros(Nmsrmn,1);         % Monin-Obukhov's stability parameter (MO Length);
Zeta_MO=zeros(Nmsrmn,1); % Atmospheric stability parameter;
TopPg=zeros(Nmsrmn,1);     % Atmospheric pressure above the surface as the boundary condition (Pa);
QL_Dts=zeros(mL,1);           % Convective moisture mass flux in one time step;
QL_dispts=zeros(mL,1);        % Dispersive moisture mass flux in one time step;
QLts=zeros(mL,1);               % Total moisture mass flux in one time step;
QV_Dts=zeros(mL,1);           % Diffusive vapor mass flux in one time step;
QV_Ats=zeros(mL,1);           % Convective vapor mass flux in one time step;
QV_dispts=zeros(mL,1);        % Dispersive vapor mass flux in one time step;
QVts=zeros(mL,1);               % Total vapor mass flux in one time step;
QA_Dts=zeros(mL,1);            % Diffusive dry air mass flux in one time step;
QA_Ats=zeros(mL,1);            % Convective dry air mass flux in one time step;
QA_dispts=zeros(mL,1);         % Dispersive dry air mass flux in one time step;
QAts=zeros(mL,1);                % Total dry air mass flux in one time step;
QV_D=zeros(mL,1);               % Diffusive vapor mass flux;
QV_A=zeros(mL,1);               % Convective vapor mass flux;
QV_disp=zeros(mL,1);            % Dispersive vapor mass flux;
QA_D=zeros(mL,1);               % Diffusive dry air mass flux;
QA_A=zeros(mL,1);               % Convective dry air mass flux;
QA_disp=zeros(mL,1);            % Dispersive dry air mass flux;
hOLD=zeros(mN,1);                % Array used to get the matric head at the end of last time step and extraplot the matric head at the start of current time step;
TOLD=zeros(mN,1);                % The same meanings of hOLD,but for temperature;
P_gOLD=zeros(mN,1);             % The same meanins of TOLD,but for soil air pressure;
Ksoil=zeros(ML,1);
Rl=ones(ML,1)*150;
SMC=zeros(ML,1);
DeltZ_R=zeros(ML,1);
Theta_o=ones(ML,1);
frac=zeros(ML,1);
wfrac=zeros(ML,1);
RWUtot=zeros(ML,17568);
Rls=zeros(ML,17568);
Tatot=zeros(17568,1);
LR=0;
PSItot=zeros(17568,1);
sfactortot=zeros(17568,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% The indicators needs to be set before the running of this program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
J=1;                                   % Indicator denotes the index of soil type for choosing soil physical parameters;       %
rwuef=0;
Evaptranp_Cal=2;                 % Indicator denotes the method of estimating evapotranspiration; 
                                   % Value of 1 means the ETind method, otherwise, ETdir method; 
UseTs_msrmn=1;                  % Value of 1 means the measurement Ts would be used; Otherwise, 0;                      %
Msrmn_Fitting=1;                  % Value of 1 means the measurement data is used to fit the simulations; 
Hystrs=1;                            % If the value of Hystrs is 1, then the hysteresis is considered, otherwise 0;          %
Thmrlefc=1;                         % Consider the isothermal water flow if the value is 0, otherwise 1;                    %
Soilairefc=1;                         % The dry air transport is considered with the value of 1,otherwise 0;                  %
hThmrl=1;                            % Value of 1, the special calculation of water capacity is used, otherwise 0;           %
h_TE=0;                               % Value of 1 means that the temperature dependence                                      %
                                          % of matric head would be considered.Otherwise,0;                                       %   
W_Chg=1;                            % Value of 0 means that the heat of wetting would                                       %
                                          % be calculated by Milly's method��Otherwise,1. The                                     %  
                                          % method of Lyle Prunty would be used;                                                  %
ThmrlCondCap=1; %1;            % The indicator for choosing Milly's effective thermal capacity and conductivity         %
                                          % formulation to verify the vapor and heat transport in extremly dry soil.              % 
%%%%% 172   27%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SaturatedK=[12/(3600*24)  68/(3600*24)];      % Saturation hydraulic conductivity (cm.s^-1);
SaturatedMC=[0.38 0.43];                              % Saturated water content;
ResidualMC=[0.0008 0.045];                               % The residual water content of soil;
Coefficient_n=[1.5 2.68];                            % Coefficient in VG model;
Coefficient_Alpha=[0.00166 0.145];                   % Coefficient in VG model;
porosity=[0.50 0.45];                                      % Soil porosity;
CKTN=(50+2.575*20);                                     % Constant used in calculating viscosity factor for hydraulic conductivity
l=0.5;                                                           % Coefficient in VG model;
g=981;                                                          % Gravity acceleration (cm.s^-2);
RHOL=1;                                                        % Water density (g.cm^-3);
SSUR=10^5;                                                  % Surface area for loam,for sand 10^2 (cm^-1);
Rv=461.5*1e4;                                               % (cm^2.s^-2.Cels^-1)Gas constant for vapor (original J.kg^-1.Cels^-1);
RDA=287.1*1e4;                                             % (cm^2.s^-2.Cels^-1)Gas constant for dry air (original J.kg^-1.Cels^-1);
RHO_bulk=1.4;                                              % Bulk density of sand (g.cm^-3);
fc=0.036;                                                        % The fraction of clay,for loam,0.036; for sand,0.02;
Unit_C=1;                                                      % Change the mH2O into (kg.m^-1.s^-2)  %101325/10.3;
UnitC=100;                                                    % Change of meter into centimeter;
Hc=0.02;                                                       % Henry's constant;
GWT=7;                                                        % The gain factor(dimensionless),which assesses the temperature
rroot=1.5*1e-3;                                                                   % dependence of the soil water retention curve is set as 7 for 
                                                                   % sand (Noborio et al, 1996);
MU_a=1.846*10^(-4);                                     % (g.cm^-1.s^-1)Viscosity of air (original 1.846*10^(-5)kg.m^-1.s^-1);  
Gamma0=71.89;                                              % The surface tension of soil water at 25 Cels degree. (g.s^-2);
Gamma_w=RHOL*g;                                         % Specific weight of water(g.cm^-2.s^-2);
Lambda1=0.228/UnitC;%-0.197/UnitC;% 0.243/UnitC;    % Coefficients in thermal conductivity;
Lambda2=-2.406/UnitC;%-0.962/UnitC;%  0.393/UnitC;   % W.m^-1.Cels^-1 (1 W.s=J);  From HYDRUS1D heat transport parameter.(Chung Hortan 1987 WRR)
Lambda3=4.909/UnitC;%2.521/UnitC;%  1.534/UnitC;    %%%%%%%%%%%%%%%%%%%%%% UnitC is used to convert m^-1 as cm^-1 %%%%%%%%%%%%%%%%%%%
MU_W0=2.4152*10^(-4);     % Viscosity of water (g.cm^-1.s^-1) at reference temperature(original 2.4152*10^(-5)kg.m^-1.s^-1);
MU1=4742.8;                      % Coefficient for calculating viscosity of water (J.mol^-1);
b=4*10^(-6);                     % Coefficient for calculating viscosity of water (cm);
W0=1.001*10^3;                % Coefficient for calculating differential heat of wetting by Milly's method
L0=597.3*4.182;
Tr=20;                              % Reference temperature
c_L=4.186;                        % Specific heat capacity of liquid water (J，g^-1，Cels^-1) %%%%%%%%% Notice the original unit is 4186kg^-1
c_V=1.870;                        % Specific heat capacity of vapor (J，g^-1，Cels^-1)
c_a=1.255e-3;
%c_a=1.005;                        % 0.0003*4.186; %Specific heat capacity of dry air (J，g^-1，Cels^-1)
Gsc=1360;                         % The solar constant (1360 W，m^-2)
Sigma_E=4.90*10^(-9);       % The stefan-Boltzman constant.(=4.90*10^(-9) MJ，m^-2，Cels^-4，d^-1)
P_g0=951978.50;               % The mean atmospheric pressure (Should be given in new simulation period subroutine.)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input for producing initial soil moisture and soil temperature profile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InitND1=20;    % Unit of it is cm. These variables are used to indicated the depth corresponding to the measurement.
InitND2=40;
InitND3=60;
InitND4=200;
InitND5=300;
% Measured temperature at InitND1 depth at the start of simulation period
InitT0=	9.89;
InitT1=	10.76714;
InitT2=	11.82195;
InitT3=	11.9841;
InitT4=	12.0;
InitT5=	12.6841;
BtmT=16.6;
InitX0=	0.2181060;
InitX1=	0.2227298; % Measured soil moisture content
InitX2=	0.2131723;
InitX3=	0.1987298;
InitX4=	0.1727298;
InitX5=	0.16;
BtmX=0.16;%0.05;    % The initial moisture content at the bottom of the column.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  The measured soil moisture and tempeature data here    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Msrmn_Fitting   
%20, 40, 60, 80, 100cm  
Xdata=xlsread('E:\grassland\SCOPE-master\SCOPE_v1.73\src\INPUT_2013_YM_HOUR','sheet1','a3:s2450');
Xdata=Xdata';
Msr_Mois=0.01.*[Xdata(13,:);Xdata(14,:);Xdata(15,:);Xdata(16,:);Xdata(17,:)];
%20, 40, 60, 80, 100cm  
Msr_Temp=[Xdata(4,:);Xdata(5,:);Xdata(6,:);Xdata(7,:);Xdata(8,:)];
Msr_Time=3600.*Xdata(1,:);
Ts_msr=Xdata(3,:);
ETdata=xlsread('E:\grassland\SCOPE-master\SCOPE_v1.73\src\ET','sheet1','A2:E2449');
ET_H=ETdata(:,1)';
ET_D=ETdata(:,3)';
E_D=ETdata(:,4)';
end


