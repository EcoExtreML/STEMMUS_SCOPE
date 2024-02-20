% function Constants
% clear -global DeltZ
global DeltZ Delt_t ML NS mL mN nD NL NN SAVE Tot_Depth
global xERR hERR TERR PERR tS
global KT TIME Delt_t0 DURTN TEND NIT KIT Nmsrmn Eqlspace h_SUR Msrmn_Fitting  
global Msr_Mois Msr_Temp Msr_Time RADS XElemnt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% The time and domain information setting. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KIT=0;                      % KIT is used to count the number of iteration in a time step; 
NIT=30;                     % Desirable number of iterations in a time step;               
Nmsrmn=100*1000;       % Here, it is made as big as possible, in case a long simulation period containing many time step is defined. 
                                                                                    
DURTN=60*30*2*100;     % Duration of simulation period;                                  
KT=0;                        % Number of time steps;                                           
TIME=0;                     % Time of simulation released;                                  

                                                                                    
TEND=TIME+DURTN;     % Time to be reached at the end of simulation period;          
Delt_t=3600*0.00001;                   % Duration of time step [Unit of second]                       
Delt_t0=Delt_t;           % Duration of last time step;                                  
tS=DURTN/Delt_t;        % Is the tS(time step) needed to be added with 1? 
                                % Cause the start of simulation period is from 0mins, while the input data start from 30mins.
                                                                                    
xERR=0.02;                  % Maximum desirable change of moisture content;                  
hERR=0.1e08;               % Maximum desirable change of matric potential;                
TERR=2;                      % Maximum desirable change of temperature;                
PERR=5000;                  % Maximum desirable change of soil air pressure (Pa,kg.m^-1.s^-1);
                                                                                    
Tot_Depth=1000;           % Unit is cm. it should be usually bigger than 0.5m. Otherwise, 
                                 % the DeltZ would be reset in 50cm by hand;                                  
NL=200;                                                                              
Eqlspace=1;                 % Indicator for deciding is the space step equal or not;       
DeltZ=zeros(1,NL);                                                                                    
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

XElemnt=zeros(NN,1);
XElemnt(1)=0;
TDeltZ=flip(DeltZ);
for ML=2:NL
    XElemnt(ML)=XElemnt(ML-1)+TDeltZ(ML-1);
end
XElemnt(NN)=Tot_Depth;

SAVE=zeros(3,3,3);        % Arraies for calculating boundary flux;                       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global h_TE          
global W_Chg         
global l CKTN
global RHOL SSUR RHO_bulk Rv g RDA           
global KL_h KL_T D_Ta 
global Theta_L Theta_LL Se h hh T TT Theta_V 
global W WW MU_W f0 L_WT
global DhT                             
global GWT Gamma0 MU_W0 MU1 b W0 Gamma_w
global Chh ChT Khh KhT Kha Vvh VvT Chg
global C1 C2 C3 C4 C5 C6 C7 
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
global QV_D QV_A QV_disp QA_D QA_A QA_disp 

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
global InitX1 InitX2 InitX3 InitX4 InitX5 
global Thmrlefc hThmrl Hystrs Soilairefc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Effective Thermal conductivity and capacity variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global EHCAP ThmrlCondCap DTheta_LLh ETCON CHK KLhBAR COR DhDZ DTDZ TQL QLH QLT DTDBAR IS IH XK XOLD XWRE ZETA KLTBAR
global Ts_f Ts_a0 Ts_a Ts_b SH_f SH_a0 SH_a SH_b Rns_f Rns_a0 Rns_a Rns_b
global Rnl_f Rnl_a0 Rnl_a Rnl_b Pg_f Pg_a0 Pg_a Pg_b 
global Ta_f Ta_a0 Ta_a Ta_b Ua_f Ua_a0 Ua_a Ua_b HRa_f HRa_a0 HRa_a HRa_b
global Hsur_f Hsur_a0 Hsur_a Hsur_b Rn_f Rn_a0 Rn_a Rn_b Rn
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
global STMHPLR02 STMHPLR1N2 STMZTB02 STMZTB12 STMRrN2 STMRrO2 IPSTM2
global TP_gg2 TP_gOLD2 TTTt2 TTOLD2 ThOLD2 THH2 IBOTSTM2 TSim_Theta2 TSim_Temp2
NumMeas=200;
NPILR=11;
% THH2=zeros(NN+1,NumMeas,NPILR);
% ThOLD2=zeros(NN+1,NumMeas,NPILR);%(1:NN+1,KTN,IP0STm)=hOLD(1:NN+1).*0;
% TTOLD2=zeros(NN,NumMeas,NPILR);%(1:NN,KTN,IP0STm)=TOLD(1:NN).*0;
% TTTt2=zeros(NN,NumMeas,NPILR);%(1:NN,KTN,IP0STm)=TT(1:NN).*0;
% TP_gOLD2=zeros(NN,NumMeas,NPILR);%(1:NN,KTN,IP0STm)=P_gOLD(1:NN).*0;
% TP_gg2=zeros(NN,NumMeas,NPILR);%(1:NN,KTN,IP0STm)=P_gg(1:NN).*0;
% 
% TSim_Theta2=zeros(NL,NumMeas,NPILR);%(1:NL,KTN,IP0STm)=Theta_LL(NL:-1:1,1).*0;
% TSim_Temp2=zeros(NL,NumMeas,NPILR);%(1:NL,KTN,IP0STm)=TT(NL:-1:1).*0;
% STMHPLR02=zeros(NumMeas,NPILR);%(KTN,IP0STm)=HPILR0.*0;
% STMHPLR1N2=zeros(NumMeas,NPILR);%(KTN,IP0STm)=HPILR1N.*0;
% STMZTB02=zeros(NumMeas,NPILR);%(KTN)=ZTB0G.*0;
% STMZTB12=zeros(NumMeas,NPILR);%(KTN)=ZTB1G.*0;
% STMRrN2=zeros(NumMeas,NPILR);%(KTN,IP0STm)=RrNGG.*0;
% STMRrO2=zeros(NumMeas,NPILR);%(KTN,IP0STm)=RrOGG.*0;
% IBOTSTM2=zeros(NumMeas,NPILR);%(KTN,IP0STm)=IBOT.*0;
% IPSTM2=zeros(NumMeas,NPILR);%(KTN,IP0STm)=IP0STm.*0;
        
XK=zeros(1,mL);
XOLD=zeros(1,mL);
KLTBAR=zeros(1,mL);
XWRE=zeros(mL,nD);
ZETA=zeros(mL,nD);
QLH=zeros(mL,1);            % Soil moisture mass flux (kg，m^-2，s^-1);
QLT=zeros(mL,1);            % Soil moisture mass flux (kg，m^-2，s^-1);
TQL=zeros(mL,1);
DhDZ=zeros(1,mL);
DTDZ=zeros(1,mL);
COR=zeros(1,mL);
KLhBAR=zeros(1,mL);
DTDBAR=zeros(1,mL);
IS=zeros(1,mL);
IH=zeros(1,mL);
CHK=zeros(1,mL);
DTheta_LLh=zeros(mL,nD);
ETCON=zeros(mL,nD);

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
QL=zeros(mL,nD);            % Soil moisture mass flux (kg，m^-2，s^-1);
QL_D=zeros(mL,nD);         % Convective moisturemass flux (kg，m^-2，s^-1);
QL_disp=zeros(mL,nD);     % Dispersive moisture mass flux (kg，m^-2，s^-1);
HR=zeros(mN,1);             % The relative humidity in soil pores, used for calculatin the vapor density;
RHOV_s=zeros(mN,1);      % Saturated vapor density in soil pores (kg，m^-3);
RHOV=zeros(mN,1);         % Vapor density in soil pores (kg，m^-3);
DRHOV_sT=zeros(mN,1);   % Derivative of saturated vapor density with respect to temperature;
DRHOVh=zeros(mN,1);      % Derivative of vapor density with respect to matric head;
DRHOVT=zeros(mN,1);      % Derivative of vapor density with respect to temperature;
RHODA=zeros(mN,1);        % Dry air density in soil pores(kg，m^-3);
DRHODAt=zeros(mN,1);     % Derivative of dry air density with respect to time;
DRHODAz=zeros(mN,1);     % Derivative of dry air density with respect to distance;
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% The indicators needs to be set before the running of this program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
J=1;                                   % Indicator denotes the index of soil type for choosing soil physical parameters;       %
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
% % SaturatedK=[172/(3600*24)  68/(3600*24)  ];      % Saturation hydraulic conductivity (cm.s^-1);
% % SaturatedMC=[0.382 0.43];                              % Saturated water content;
% % ResidualMC=[0.017 0.045];                               % The residual water content of soil;
% % Coefficient_n=[3.6098 2.68];                            % Coefficient in VG model;
% % Coefficient_Alpha=[0.00236 0.145];                   % Coefficient in VG model;
% % porosity=[0.41 0.45];                                      % Soil porosity;
% SaturatedK=[24.96]./86400;%[2.67*1e-3  1.79*1e-3 1.14*1e-3 4.57*1e-4 2.72*1e-4];      %[2.3*1e-4  2.3*1e-4 0.94*1e-4 0.94*1e-4 0.68*1e-4] 0.18*1e-4Saturation hydraulic conductivity (cm.s^-1);
% SaturatedMC=[0.43];                              % 0.42 0.55 Saturated water content;
% Coefficient_n=[1.56];                            %1.2839 1.3519 1.2139 Coefficient in VG model;
% Coefficient_Alpha=[0.036];                   % 0.02958 0.007383 Coefficient in VG model;
% ResidualMC=[0.078];                               %0.037 0.017 0.078 The residual water content of soil;
% porosity=[0.43];                                      % Soil porosity;
SaturatedK=[1.04]./86400;%[2.67*1e-3  1.79*1e-3 1.14*1e-3 4.57*1e-4 2.72*1e-4];      %[2.3*1e-4  2.3*1e-4 0.94*1e-4 0.94*1e-4 0.68*1e-4] 0.18*1e-4Saturation hydraulic conductivity (cm.s^-1);
SaturatedMC=[0.43];                              % 0.42 0.55 Saturated water content;
Coefficient_n=[1.56];                            %1.2839 1.3519 1.2139 Coefficient in VG model;
Coefficient_Alpha=[0.036];                   % 0.02958 0.007383 Coefficient in VG model;
ResidualMC=[0.078];                               %0.037 0.017 0.078 The residual water content of soil;
porosity=[0.46];                                      % Soil porosity;
CKTN=(50+2.575*20);                                     % Constant used in calculating viscosity factor for hydraulic conductivity
l=0.5;                                                           % Coefficient in VG model;
g=981;                                                          % Gravity acceleration (cm.s^-2);
RHOL=1;                                                        % Water density (g.cm^-3);
SSUR=10^2;                                                  % Surface area for sand (cm^-1);
Rv=461.5*1e4;                                               % (cm^2.s^-2.Cels^-1)Gas constant for vapor (original J.kg^-1.Cels^-1);
RDA=287.1*1e4;                                             % (cm^2.s^-2.Cels^-1)Gas constant for dry air (original J.kg^-1.Cels^-1);
RHO_bulk=1.67;                                              % Bulk density of sand (g.cm^-3);
fc=0.02;                                                        % The fraction of clay for sand;
Unit_C=1;                                                      % Change the mH2O into (kg.m^-1.s^-2)  %101325/10.3;
UnitC=100;                                                    % Change of meter into centimeter;
Hc=0.02;                                                       % Henry's constant;
GWT=7;                                                        % The gain factor(dimensionless),which assesses the temperature
                                                                   % dependence of the soil water retention curve is set as 7 for 
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
c_a=1.005;                        % 0.0003*4.186; %Specific heat capacity of dry air (J，g^-1，Cels^-1)
Gsc=1360;                         % The solar constant (1360 W，m^-2)
Sigma_E=4.90*10^(-9);       % The stefan-Boltzman constant.(=4.90*10^(-9) MJ，m^-2，Cels^-4，d^-1)
P_g0=824025.288;               % The mean atmospheric pressure (Should be given in new simulation period subroutine.)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input for producing initial soil moisture and soil temperature profile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InitND1=2;    % Unit of it is cm. These variables are used to indicated the depth corresponding to the measurement.
InitND2=5;
InitND3=10;
InitND4=20;
InitND5=50;
InitT0=20.84; % Measured temperature at InitND1 depth at the start of simulation period
InitT1=20.92; 
InitT2=24.49;             
InitT3=28.17;
InitT4=28.83;
InitT5=28.73;
BtmT=29;
InitX1=0.019581677;   % Measured soil moisture content
InitX2=0.020693359;
InitX3=0.019593432;
InitX4=0.018163215;
InitX5=0.049687617;
BtmX=0.1;%0.05;    % The initial moisture content at the bottom of the column.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meteorological Forcing Data (Parameters for Fourier Transformation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 9
Ta_f=[0.000976563	0.001953125	0.002929688	0.00390625	0.018554688	0.01953125	0.020507813	0.021484375	0.022460938];
Ta_a0=-10804.00671; 
Ta_a=[10507.6704	2859.938833	-2897.52997	358.9562265	5.894943759	-10.00404508	8.403440248	0.085490368	-4.949473085];
Ta_b=[14293.04065	-9075.894735	959.2827642	264.4686273	1.580033519	-9.354309784	12.81937569	-19.48781447	5.332580961];
% 17
Ua_f=[0.008789063	0.012695313	0.013671875	0.01953125	0.020507813	0.021484375	0.022460938	0.024414063	0.025390625	0.026367188	0.037109375	0.038085938	0.0390625	0.040039063	0.049804688	0.05078125	0.051757813];
Ua_a0=1.610281516;
Ua_a=[0.226609202	5.429429329	-4.381566739	211.8114107	-622.6849758	3.557418501	698.0060134	-270.7285641	-92.92677705	74.11810995	8.079855157	-17.23731118	2.969139967	3.666868248	0.03849065	-2.190920721	1.561847609];
Ua_b=[-0.104121457	0.381571342	-6.253890771	-32.12284219	-534.4821409	1300.018064	-606.8982542	-416.0908854	332.6569113	-36.12999958	-2.176693224	-10.90623515	17.52283703	-4.642978912	-1.741298719	2.243006533	0.184007604];
% 7
HRa_f=[0.001953125	0.002929688	0.00390625	0.004882813	0.01953125	0.020507813	0.021484375];
HRa_a0=2153.442845;
HRa_a=[2119.573946	-7458.054059	3145.69697	55.30294891	-27.9553139	7.494000231	25.19076661];
HRa_b=[-6452.0938	2335.93216	2440.943828	-821.3540799	-10.64378071	66.83340009	-15.2169329];
% 10
Ts_f=[0.0078125	0.008789063	0.015625	0.016601563	0.018554688	0.01953125	0.020507813	0.021484375	0.022460938	0.0234375];
Ts_a0=28.6630993992975;
Ts_a=[-23.5537528449931	36.514947676942	-850.946032289256	1560.85917902259	9416.40359476681	-23300.7174149404	11057.2959298822	8020.60870410711	-6979.41094930083	1065.50623817224];
Ts_b=[21.2115143219661	9.56544223175478	-19.4848790148251	1888.11674856871	-5743.32780805577	-7394.27243042945	25462.0216125091	-16931.4388172067	1975.76093987008	696.254244101508];
% 10
SH_f=[0.018554688	0.01953125	0.020507813	0.021484375	0.022460938	0.0234375	0.040039063	0.041015625	0.041992188	0.04296875];
SH_a0=27.37025515;
SH_a=[391.5128037	93.14688391	-3179.985888	3919.2251	-1192.835385	-107.937764	15.10567141	-67.07811836	52.76499712	9.47547267];
SH_b=[352.8877654	-2213.97529	2522.268205	598.8624671	-1764.006036	491.0437618	-10.82803789	-4.226028793	92.2902774	-37.65148137];
% 16
Rns_f=[0.018554688	0.01953125	0.020507813	0.021484375	0.022460938	0.0234375	0.025390625	0.026367188	0.029296875	0.030273438	0.033203125	0.0390625	0.040039063	0.041015625	0.041992188	0.04296875];
Rns_a0=260.7400536;
Rns_a=[-14387.20545	-1519425.492	7586689.611	-9217091.41	-4370827.944	10926311.8	-1971674.377	-1907370.812	-4303.508268	468538.6882	18675.92899	71164.61733	30156.68473	-184464.8224	95323.36794	-7528.861135];
Rns_b=[-264078.3571	1482846.804	624538.0884	-12625669.61	18695826.2	-5675624.976	-5918226.381	3151984.03	999358.4029	-393225.3582	-53265.52678	78151.98441	-235598.171	120564.9018	27928.25808	-16603.38185];
% 17
Rnl_f=[0.00390625	0.004882813	0.005859375	0.01171875	0.012695313	0.013671875	0.016601563	0.018554688	0.01953125	0.020507813	0.021484375	0.022460938	0.0234375	0.025390625	0.041015625	0.041992188	0.04296875];
Rnl_a0=415088.5422;
Rnl_a=[3393018.831	-358073.5063	-2848771.672	1885835.63	-10643330.02	5113122.774	3562351.611	19787752.21	-25302907.18	-8980871.476	20181654.03	-6228488.885	-5038.014379	28788.56265	19.19880734	-40.70550138	10.94991267];
Rnl_b=[2239904.578	-7038791.678	2309938.781	-4376510.254	1651020.555	6085513.886	4236950.89	-3830600.043	-27379605.84	34916134.37	-7115875.999	-4493021.134	1374409.126	8777.861284	-22.25463102	37.31344201	6.013217001];
% 13
Pg_f=[0.001953125	0.00390625	0.005859375	0.0078125	0.009765625	0.013671875	0.015625	0.017578125	0.01953125	0.021484375	0.025390625	0.041015625	0.04296875];
Pg_a0=-1139428.24;
Pg_a=[-365530.7019	1704341.979	554022.0026	-493903.3578	-155395.3228	-61309.60296	15164.03427	30383.20728	973.5035168	-1766.610762	-36.13199478	50.83197469	50.01323617];
Pg_b=[2243872.642	571554.1673	-1049953.776	-373974.5894	147479.606	28074.3736	56691.27097	-2633.417354	-10085.88803	-441.5838393	-10.86551641	11.37959513	32.69005767];
% 7
Hsur_f=[0.001953125	0.002929688	0.00390625	0.004882813	0.005859375	0.006835938	0.0078125];
Hsur_a0=597534668;
Hsur_a=[604394550.8	-3404005462	2767479270	-237373615.1	-465095726	144358705.7	-7293666.795];
Hsur_b=[-2283090744	1425086492	1584439843	-1773346231	464093817.1	19987630.5	-13093681.94];
% 17
Rn_f=[0.002929688	0.00390625	0.017578125	0.018554688	0.01953125	0.020507813	0.021484375	0.022460938	0.0234375	0.025390625	0.026367188	0.029296875	0.0390625	0.040039063	0.041015625	0.041992188	0.04296875];
Rn_a0=1047.702872;
Rn_a=[2428.767946	-1780.536655	418856.7706	-1890437.519	-1596431.949	15055938.58	-19405147.07	5155062.667	3165012.125	-898799.6044	-9768.660929	4900.743791	5025.128103	-4227.092145	-8547.908547	7924.185359	-1168.827536];
Rn_b=[-1332.862789	-667.0553222	-4488.078205	-2226403.984	9128684.252	-8639215.488	-7205481.797	14620605.41	-5314139.71	-785760.3038	415216.8182	9159.331983	2113.843436	-13939.49246	13052.16553	-850.9263368	-1106.871032];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  The measured meteorological forcing data here    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if UseTs_msrmn==0    
    Ta=[22.34911	22.08085	21.9437     21.90485	21.47198	21.33739	21.19064	20.8455     20.2413     19.70109	19.09265	18.5818     17.81258	18.09554	18.55972	20.08628	2145858	21.46137	21.83199	22.71776	23.88039	24.91357	25.3	26.34917	26.4365	27.05658	27.69775	28.333	28.84784	29.55372	29.41076	29.74818	30.14161	30.1307	30.36094	30.31573	30.53989	30.13784	29.48332	28.38464	27.90254	27.53267	27.44629	26.49465	22.90242	20.93325	18.34734	17.06573	16.20294	16.09014	16.02491	15.53945	15.00848	15.22405	15.5644	15.84796	15.94014	16.00804	16.10089	15.9033	16.10124	16.19489	16.5104	16.98878	17.76461	17.85668	18.13109	18.56202	18.84793	19.27466	19.89812	20.64597	21.23211	21.85375	22.58069	23.05565	23.32275	23.85385	24.01387	23.87553	24.25214	24.94683	25.08735	25.9479	25.54184	25.4248	26.17946	25.87995	25.06067	24.74506	24.18395	23.79313	23.44396	22.77184	22.20459	22.00632	21.61278	21.45883	21.31977	20.60284	20.23949	19.8827	19.92265	19.16415	18.67626	18.55314	18.66049	18.44489	18.21434	17.73932	18.60181	19.42447	19.92231	22.17292	22.62506	23.19135	24.15568	24.91628	25.46629	25.62236 ...
    26.27328	26.79583	27.40626	27.67651	28.25779	28.52451	28.49785	28.94805	29.32512	29.89615	29.40367	29.48273	29.74791	29.88925	29.39799	28.98665	27.60164	27.4245	27.20782	26.88382	26.51922	25.74306	25.62682	25.31013	24.75926	24.34648	24.06645	24.06347	23.25702	22.90522	22.53314	22.61145	21.96293	21.32988	21.37391	20.05413	19.92954	19.83999	20.93033	22.04109	23.0476	24.92449	25.6804	25.7617	26.96993	27.63457	28.71328	28.86314	29.32146	29.87092	30.5281	30.68509	31.20968	31.6445	32.15456	32.21565	31.82245	31.55206	31.46128	32.07857	32.59726	32.30512	32.57084	32.37531	30.88828	29.56798	28.18185	28.72603	28.84612	28.07238	27.05215	27.5148	26.21373	25.74941	25.55785	25.32332	24.87248	24.51993	23.75113	23.47871	23.1323	21.95293	21.6661	21.41296	20.56921	21.06269	21.39856	21.90592	23.05549	24.26575	24.51796	25.45896	26.08843	27.18309	28.08641	29.61793	30.87799	30.91236	31.19925	32.38343	32.58171	32.49626	32.81152	33.10008	32.53932	33.06035	32.70296	32.7579	32.52504	32.47959	32.35258	31.28153	30.8373	31.04731	30.42455	29.62004	29.50904	29.2184	28.86706	28.93667 ...
    28.54947	27.89692	27.25048	26.76734	26.44343	26.18277	25.29298	24.4338     24.56739	23.46272	22.66134	22.41165	21.78237	21.89264	22.47362	23.61378	24.72714	24.43485	25.77474	26.02064	26.67442	27.76523	28.04309	29.62463	30.67925	32.10138	32.77304	32.89296	32.53029	34.05974	34.14439	34.61956	34.39663	33.65699	33.54756	33.19653	32.82656	32.36272	31.85353	31.47099	31.09442	30.7833	30.61995	30.33521	30.01518	29.71348	29.61893	29.26477	28.09302];

    %  Unit of windspeed (cm/s)
    U=100.*[1.927436	1.231519	0.5772015	0.5849676	0.6801574	1.288549	2.475805	3.242662	2.748127	2.156359	1.928138	0.9926827	0.6256304	0.5975307	1.359582	0.6973325	0.4575729	0.8773909	1.055897	0.9658201	0.7992468	0.9049413	1.626939	1.437318	1.574064	1.747936	1.418516	1.530129	1.090953	1.391263	1.459047	1.250231	1.265892	1.532277	2.01887	2.80792	1.651943	2.046276	3.228311	3.429431	3.021736	2.865603	3.320559	3.788761	3.864691	3.756976	2.860137	1.50589	2.096365	1.783206	1.390627	2.316371	1.742304	1.557098	1.454751	0.8792159	0.8883296	1.201068	0.8640571	1.041409	1.382299	1.456153	1.132573	0.9558319	1.07468	1.61706	1.878334	2.054146	2.122523	2.597373	2.350837	2.100847	2.07478	1.787513	1.978764	1.90557	2.228193	2.654663	2.957298	2.889453	2.178835	1.93426	2.018147	2.089373	1.56593	1.349836	0.899054	1.657149	1.679108	1.33697	0.7672836	1.660757	2.613182	2.551244	1.910067	1.659593	1.926177	1.841748	1.207997	0.4100078	0.5852845	0.675545	0.8009673	0.6411009	0.6977854	1.350606	1.72954	1.127149	1.402533	1.339189	0.8695591	0.4640933	0.7263972	0.4593065	0.7736031	1.033994	1.54065	3.223178	3.305756	3.201476...
    2.810293	2.504833	1.847456	1.973105	1.68848     2.295661	2.197783	1.680437	1.605041	1.476195	1.998963	1.51754	1.446133	1.176675	1.986356	1.454146	1.741989	1.741403	2.748496	3.137715	2.826068	1.828006	2.423369	2.014861	1.744103	1.490432	0.769572	0.8283849	0.5583987	0.5590569	0.8309873	1.113481	0.7829934	1.006383	1.6582	1.002995	1.263355	1.369138	1.272201	1.284112	1.332308	0.7220955	1.254813	1.420602	1.259676	1.946782	1.693711	1.944019	2.570809	2.340115	1.859028	2.414262	1.81762	1.907653	1.601469	1.594824	2.511909	2.878947	1.208261	1.724574	1.317784	1.09889	1.46562	0.7874424	0.7389765	0.4746557	0.434911	2.115772	1.909155	1.959856	1.622128	1.506059	1.514034	2.100094	2.296509	1.329899	1.334409	1.560721	3.203914	2.873805	2.184857	1.776869	1.748592	1.563574	0.9921934	0.9084439	0.5352255	1.363289	0.6573755	0.5451193	0.7258974	0.578126	0.9509155	1.01075	1.080778	1.008385	1.238277	1.789354	1.359308	1.043428	2.595447	3.173955	2.515616	3.095206	2.246315	2.15658	1.972175	1.237193	1.397199	1.055768	0.7219682	0.5700312	0.3745568	0.801311	0.750815	1.311427	1.864743	1.720572	1.632836	2.13418 ...
    2.200018	1.428164	1.054279	0.7506945	1.245508	1.486903	1.026603	0.8395652	1.348614	0.9890695	0.4985991	0.7328085	0.3929378	1.281571	1.250018	0.3747835	0.7746684	1.290049	0.789389	1.142893	1.086709	0.8473147	1.148907	1.482077	2.240503	1.636529	1.41551	1.64637	1.690252	1.244411	0.9265659	1.045506	1.390633	3.742559	3.941386	3.643435	4.192641	4.662417	3.989298	3.466082	3.408207	2.736091	3.239032	3.887338	2.505711	1.500946	2.313302	1.170125	0.8389792];

    HR_a=0.01.*[29.65007	30.21174	30.06392	30.21696	37.06613	39.76908	42.55196	44.33071	47.52628	51.29594	53.67534	54.72605	53.6096	51.69205	49.2043	44.59216	41.14327	40.69259	40.0119	35.62817	31.89355	29.60778	24.6016	19.06615	20.91725	19.01947	19.60281	16.15041	16.95515	13.89209	13.09315	12.82296	11.56708	10.83642	10.81788	9.756131	10.79458	13.94367	15.33206	17.48486	18.04227	19.36717	19.38055	24.4418	41.24764	45.41146	58.66312	66.5191	73.1663	71.54961	70.35083	76.35168	81.14974	77.49287	74.00489	72.77064	72.49713	71.00472	70.84137	74.03126	72.41166	71.9422	71.896	70.7073	66.59055	67.04407	65.95601	65.05597	63.27943	63.3856	61.03339	58.01993	54.92577	52.25447	48.91373	45.63402	38.92729	35.84746	33.89658	34.27483	31.4926	28.51337	27.15347	24.94025	23.73692	24.92368	19.98662	21.39338	19.91824	22.02153	25.24923	28.63707	29.73352	37.65208	39.53113	38.17223	37.543	36.60137	38.3587	40.12325	45.134	46.14648	43.97566	47.58824	49.08398	48.03111	44.9285	44.52745	44.21249	47.50281	44.14931	41.65252	38.41914	32.82386	29.94158	28.50648	27.47914	25.28018	23.91846	24.23245 ...
    22.1626     19.98575	16.48924	13.93844	13.63082	14.7326     14.85673	13.59237	12.75998	11.40982	13.72254	11.14366	12.7809	15.11589	11.21042	15.77544	19.03245	17.47181	16.80066	17.78768	18.47232	20.97782	21.12538	23.06829	25.25428	21.14195	23.62548	18.6935	21.38194	22.97615	23.31044	21.76818	23.68418	24.69757	25.32924	28.45438	32.14031	32.4489	28.04008	27.067	23.89446	21.86401	20.54937	21.7305	20.40413	18.39699	16.28928	17.08722	13.85909	12.68575	12.11322	11.88268	10.15078	9.405664	8.715136	8.22573	11.05903	9.981248	9.257621	8.110769	9.363474	8.127586	6.564724	7.471061	8.39889	11.33779	13.65752	9.712625	8.057193	8.322045	9.127317	7.916311	9.198134	9.66153	9.528995	9.812968	10.14808	10.11353	11.16917	12.45835	19.15876	23.74502	24.20291	24.57962	28.15664	25.70671	26.48725	28.42989	26.12499	23.32849	24.64053	23.10378	22.50279	21.32915	18.76597	15.55476	13.33835	12.92738	12.91924	8.622942	6.438275	6.728084	6.857343	5.819787	6.845289	4.882464	4.598882	5.564017	5.716192	6.02666	7.274657	9.58174	11.26088	8.812814	9.901905	10.74224	10.29395	11.81134	12.28362	14.23576 ...
    18.60107	20.24229	21.73751	22.87816	23.51505	24.68279	26.4942     28.5851     30.13113	33.3813     34.36024	35.39885	39.1249	40.26175	38.4519	37.79243	37.67194	37.94366	32.67601	34.68272	35.52916	32.53063	31.76932	24.04429	18.98478	15.35093	16.17149	16.28939	16.50417	12.29468	10.72805	10.24096	11.33363	9.177711	9.219362	9.543737	9.565406	9.645529	9.810944	10.20783	10.45257	10.40235	10.64789	11.57434	12.1929	12.67451	12.57681	13.07654	17.15799];

    Ts=[20.83695	20.363	19.92061	20.11816	19.68042	19.56734	18.62723	17.56711	16.57853	15.74766	14.91911	14.1001	13.30104	13.28701	12.82958	15.76593	19.64384	24.00665	28.92643	34.04549	39.13022	44.12008	47.27105	50.59801	54.28285	56.59531	59.78813	61.68841	61.51165	59.44023	57.840	57.07215	57.36077	56.33359	53.23259	48.92972	45.92591	44.80338	38.79252	31.75445	27.96464	25.49388	25.59244	25.8104	19.58073	17.60206	16.62011	16.66479	17.06537	16.94309	7.40055	17.01493	16.86122	16.45534	15.73143	15.6985	15.7297	13.90491	13.18485	12.75903	12.26671	12.17875	12.66977	13.91901	15.53419	17.20183	18.97081	20.82015	22.62183	23.9759	25.81061	28.06696	29.33768	31.60881	32.81923	33.51236	33.64154	34.71385	34.93576	33.59181	32.5173	33.48554	32.61084	33.89907	29.29748	27.79008	27.03176	25.30569	21.98165	20.05439	18.88522	17.84539	17.34708	16.94267	16.14408	15.71529	15.16063	14.76554	14.42592	13.98513	13.53513	13.12393	12.53663	12.09594	11.79424	11.35673	10.93586	10.68977	10.37849	10.67416	11.59184	13.68973	14.65573	18.78403	21.39509	25.39157	29.57357	32.40987	35.64066	38.78417 ...
    42.20654	45.3297	48.45158	50.3798	52.21966	52.25471	52.00988	52.40582	51.46925	49.94986	47.11126	43.49106	40.84101	37.92818	33.81723	30.17812	27.16711	26.83957	25.34253	23.70696	23.00367	22.03939	21.78788	21.49734	20.99615	20.39758	19.86336	19.27927	18.48883	17.84151	17.37722	18.01547	17.43598	16.77345	16.90646	15.847	16.15783	15.79401	14.20499	15.6778	19.3783	23.60619	27.99841	32.45438	37.22423	40.79987	44.89747	48.13213	50.05589	52.74518	55.21329	56.01251	57.97785	58.30751	57.22073	55.4277	55.26908	51.97387	43.15436	43.33772	42.30756	39.40253	35.41155	31.47855	25.94879	22.94489	20.50418	19.56579	18.6191	18.01733	17.0235	16.76183	16.20226	15.61836	15.39904	14.99261	14.60118	14.43929	14.35981	14.45044	14.93129	14.90831	14.53536	13.75482	13.42565	13.88814	15.20857	17.11037	20.66081	25.07594	28.94432	32.27071	37.23856	42.10179	47.02217	50.04642	55.40405	52.36839	51.24461	50.89354	50.62249	51.85381	55.13955	53.25797	50.43031	46.8236	42.10065	40.40272	38.02709	36.28147	34.41101	31.13408	29.29525	27.26007	25.04525	23.65215	23.15796	23.50468	23.62644	23.46229 ...
    21.09842	20.82595	19.36606	18.08406	17.67754	17.38115	16.6387	16.09091	15.88114	15.33596	14.78803	14.44633	14.0935	14.68903	16.18179	18.6572	21.77846	25.75281	30.40187	34.77284	39.29933	43.94135	47.80758	51.17722	53.49745	56.98752	59.60363	60.61584	61.72474	65.0271	54.67896	55.76689	53.97405	44.85655	43.20436	40.34054	37.37268	35.06417	32.44098	30.6936	28.97188	27.73639	26.87283	26.51071	26.02767	25.36289	24.96094	23.1988    21.71289];

    % Unit in cm/s
    Precip=10.*[0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	4.23333e-7	0	1.41111e-7	1.128889e-6	    1.552222e-6	    2.82222e-7	0	0	0	1.41111e-7	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0 ...
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0 ...
    0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0];

    % Unit in W.cm^-2
    SH=(1/1800*1e-4).*[-2.486955	-0.5170174	-0.6521624	-1.207538	-5.966414	-4.603765	-7.969757	-11.43095	-12.54935	-13.10833	-10.64763	-9.351619	-1.777406	1.579859	8.281392	5.323565	7.93919	27.24977	28.23603	57.06918	71.12315	76.57605	80.45295	130.3249	132.6744	128.9893	165.4138	169.6944	134.3199	150.5553	123.0607	105.3615	113.0263	109.6589	133.5773	138.7209	42.03819	45.7594	60.36187	20.83902	-5.877442	-11.08631	-12.67701	-57.98075	-40.91671	-79.47047	78.33548	-1.602683	6.377197	5.423969	8.825412	17.0069	14.1853	9.663255	0.05295556	7.135858	-0.4105129	-7.183064	-5.366732	-5.750487	-12.9931	-3.848513	-3.372591	-3.20098	8.940372	19.94806	30.56743	43.29476	55.41721	71.80681	71.74727	74.90984	75.18217	75.8913	85.99931	80.1226	71.37175	78.45457	84.43712	62.63364	38.12376	42.90557	27.39329	47.49936	15.63304	7.492813	8.409717	7.344462	-4.200715	-1.05767	-2.596777	1.086884	-11.9057	-15.16423	-9.540477	-10.26085	-8.021585	-12.86671	-7.738112	-1.865291	2.089929	-6.183284	-8.256113	-2.344005	-0.5158015	-10.25812	1.736624	-7.087214	2.593108	-4.154183	0.01784944	-11.18902	-4.682511	8.956227	21.1688	37.7539	43.40958	54.28531	53.84568	68.87871...
    82.76784	92.93419	84.42224	103.2428	128.0968	117.3929	112.6032	98.93932	85.91603	82.46363	63.53817	39.70197	28.61277	31.80153	9.783641	0.005646656	-19.5593	-22.51033	-20.73463	-28.53712	-20.12985	-24.36191	-25.48474	-29.49145	-18.84578	-13.23109	-3.563203	2.734492	-4.255701	-13.65619	-2.462865	1.644216	8.402968	-2.914965	-24.00339	-12.40516	-12.08872	-11.09817	-13.9942	-14.78226	17.66661	12.93043	21.0172	36.59923	32.65203	45.05592	73.89886	83.14138	87.47607	110.2944	115.802	104.5105	101.4776	122.4391	100.9803	119.2308	105.2176	47.74308	25.06222	56.62264	28.3217	12.82459	17.43451	2.963839	-15.15324	-9.370335	-1.270773	-38.72868	-32.17643	-31.22624	-15.64185	-28.64272	-24.33425	-2.743001	-23.79344	-25.64924	-28.25541	-18.59106	-3.157835	16.2996	-22.83162	3.276955	-5.753808	-28.90639	-4.749114	-6.711102	-10.50068	-5.59311	7.363235	30.02521	23.44019	32.99652	68.34673	70.22894	87.2372	105.8824	142.2858	58.64227	68.12868	75.75592	108.9362	88.47243	83.50666	104.3109	48.95999	92.57763	47.04994	12.22647	17.24847	13.84992	4.246371	0.3827942	1.286064	-1.683968	-3.335021	-30.67842	-9.495636	-8.203163	-11.26124	-17.75885...
    -15.67768	-24.4295	-10.42964	-5.804358	-10.52122	-22.7517	-1.225176	-9.119349	-21.42698	-19.72326	-8.662035	-3.700187	-4.619163	-2.301741	-2.458558	-1.239485	4.911222	5.99758	27.04661	36.04489	60.70829	85.46827	84.4149	91.30257	118.34	144.6437	120.4618	125.0823	97.70659	148.8398	93.86427	96.11619	81.88057	99.51881	97.68602	79.2851	86.36118	43.98791	27.75598	16.53875	6.018047	-2.077465	-8.508606	-9.537034	-12.35062	-6.751902	-9.486929	-8.882349	-9.143075];

    % Unit in W.cm^-2
    Rns=(1/1800*1e-4).*[-2.033	-2.335	-2.843	-3.114	-2.611	-2.774	-2	-1.958	-1.843	-2.499	-2.536	-3.09	-1.065	19.41	79.52	154.61	232.16	308.9	386.5	458.5	525.9	586.9	620.6	676.5	717.1	732.6	772.5	780	684.7	648.7	582.3	588.9	583	554.6	487.1	424.9	326.3	308	188.9	69.96	22.69	1.587	-3.05	-1.533	-8.136	-6.743	-7.477	-9.52	-9.04	-9.26	-8.428	-7.601	-5.749	-6.326	-4.367	-4.277	-4.192	-5.411	-5.401	-5.058	-2.077	20.21	79.43	158.97	240.37	329.12	418.2	500	573.9	639.6	695.9	757.5	739.6	782.7	780.7	686.2	688.8	722.5	640.1	527	376.5	448.5	408.6	456.	213.44	206.09	178.55	143.45	43.98	14.99	-3.227	-4.874	-3.407	-2.334	-2.967	-3.173	-2.962	-3.094	-3.092	-3.403	-4.401	-4.857	-4.568	-3.943	-3.568	-4.07	-3.675	-3.055	1.843	26.11	73.82	145.23	172.3	308.4	362.5	471	558.5	620.5	674.3	719.4 ...
    754.3	782	791.6	800.1	785.8	766.9	733.3	691.4	636.9	571.5	505.8	388.9	349.4	262.2	179.98	104.49	22.59	6.51	-4.062	-3.431	-3.281	-3.556	-4.171	-3.706	-3.626	-4.64	-4.525	-5.907	-4.519	-5.766	-6.098	-5.249	-4.048	-4.791	-3.764	-3.33	-1.076	15.12	84.01	164.76	245.83	324.6	405.5	481.6	551.4	616	670.9	716.6	758.8	781.2	792.8	792.8	796.6	777.9	702.6	618.5	675.8	543	259.8	367.1	348.3	262.8	183.91	102.93	22.27	5.42	-4.79	-6.987	-4.533	-4.443	-4.138	-4.581	-3.447	-3.768	-4.564	-3.757	-3.65	-3.96	-3.056	-3.238	-2.014	-2.318	-3.095	-3.278	-0.208	22.08	68.55	123.78	208	281.1	348.2	400	480.7	586.1	640.8	671.4	762.8	546.3	531.4	530.8	552.4	633	666.2	614.7	475.3	401.7	254.5	228	180.98	145.97	104.07	41.94	26.33	3.071	-3.542	-3.303	-2.982	-2.79	-2.332	-2.325 ...
    -1.802	-1.857	-2.77	-3.278	-3.812	-2.518	-3.29	-3.492	-3.661	-2.924	-3.463	-4.347	-0.812	21.76	67.23	128.69	199.15	269.2	342.5	416.5	486.9	550.6	606.2	654.6	698	721.7	733.6	715.9	733.6	771.3	353.3	513.3	372.2	248.4	302	227.18	146.13	118.51	61.61	38.86	13.79	2.381	-2.251	-1.658	-1.621	-1.905	-2.095	-1.884	-1.963];
    % Unit in W.cm^-2 Rsd downward solar radiation
    RADS=(1/1800*1e-4).*[0	0	0	0	0	0	0	0	0	0	0	0	3.446	30.96	107.1	204	300.5	399.4	501.9	596.2	683.4	761.5	810	886	938	959	1012	1023	901	853	769.3	779.3	772.8	740.1	659	580.8	449.7	428.4	271.6	104.9	35.2	7.317	0	0	0.924	2.047	0	0	0	0	0.332	0	0	0.459	1.767	0.951	0.714	0.057	0.01	0.004	3.698	29.6	101.9	198	293.3	401.1	510.5	610.5	701	785	857	936	917	973	976	859	868	914	816	677.5	484.2	578.6	531.4	598.2	278.7	277.8	243.7	203.9	60.37	25.76	2.517	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	7.168	38.58	98.8	191.4	224.1	396.3	462.5	602.2	713	797.6	869	926 ...
    971	1006	1019	1032	1014	991	950	900	832	749.7	668.8	520.4	473.9	359.2	255.6	155.5	33.15	15.11	0.748	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0.001	4.718	25.69	113.7	217.9	320.8	419.2	523.2	622.6	711.2	793.6	864	922	978	1008	1024	1025	1032	1010	915	807	886	718.4	345.2	494.7	473.1	363.5	262.9	155.1	34	14.77	0.7	0.605	0	0	0.016	0	0	0	0	0	0	0	0	0	0	0	0	0	5.02	35.51	96.6	168.5	277.2	368.4	454.2	521.8	623.3	761.2	831	869	991	711.8	694.6	694.1	724.7	834	879	812	630.9	536	340.1	304.6	242.8	197.1	142.8	59.56	39.92	9.57	0.064	0	0	0	0	0 ...
    0	0	0	0	0	0	0	0.002	0.014	0	0	0.024	4.109	35.07	93.6	172.9	262.7	356	449.1	542.5	633.4	712.6	784.9	850	909	942	962	952	959	1012	462.3	674.3	489.1	331.4	406.9	306.2	198	158.6	83.5	54.07	21.14	6.382	0.009	0	0	0	0	0	0];

    % Unit in  W.cm^-2
    Rnl=(1/1800*(-1e-4)).*[59.3	57.4	55.5	47.1	49.6	49.1	62.1	74.1	79.7	82.1	82.2	80.1	77.1	78.6	83.9	97.1	114.7	134.3	158.1	184.8	212.5	241.5	260.7	285.4	310.2	325.6	346.1	359.2	348.8	328.8	318.4	310.4	324	322.2	304.1	272.5	242.9	217.7	187.1	159.8	134	117.2	85.3	63	26.5	25.8	16.6	15.8	18.3	20.1	22.4	19.5	18	17.8	15.1	12.9	12.3	8.7	6	4.9	2.4	-1.1	-5.3	-12.3	-13.8	-8.7	0.4	114	128.4	133.3	141.7	148.6	156.4	165.4	168.8	163.1	168.1	178.2	177.2	152.6	137.3	156.2	154.4	180	158	146.3	146.5	141.1	126.6	116.3	106.7	103.2	91.8	87.6	90	85.9	85.2	82.4	80.1	81.4	81.7	82	81.7	81.6	79	79.1	78.1	75.3	77	78.7	80.6	87.7	96.1	112.6	127.1	146.4	166.8	181.4	198.9	216.7 ...
    237.3	257.2	278.3	293.6	302.6	301.6	301.1	303.3	297.2	286.9	267.6	246.4	22.1	209.7	184.4	167.3	144.5	132.7	124.3	119.5	116.4	113.7	112.4	110.2	108.7	106.3	105	102.1	100.8	99.8	99	97.6	96.3	95.4	95.6	94.8	94.1	95.6	99.1	111	125	143.6	163.5	184.7	209	229.4	252.9	273.6	287.7	305.2	321.3	327.8	341.2	344.6	336.8	319.3	304.6	280.3	210.4	231.8	235.7	220.4	201.4	179.8	151.9	136.7	126.2	119.5	118.2	116.1	113.6	113.5	112.1	111.2	110.3	108.6	106.7	103.1	103.5	101	91.6	82.8	85.9	86.8	85.8	89.3	96	106.6	121.3	139.7	154.9	174	199.7	230	258.3	275.7	306.9	267.7	241.6	241.7	247.6	258	281	272.6	267.4	233	192.6	173.6	157.9	137.2	123.2	101.7	90.2	78.8	80.8	78	72.7	63.5	58	60.9 ...
    87.2	75.6	82.4	84.8	83.9	83.4	80.2	78.9	79.1	78.1	77.3	76.4	76.9	79.6	86.2	98	112.2	127.8	149	169.1	191.4	216.9	237.9	258.4	273.4	293.4	311.5	319.6	324.4	335.1	256.1	249	226.2	163.4	179.6	159.9	120	108.9	95.1	85.3	75.2	68.7	63.4	60.1	57.5	56.6	56.6	69.9	71.9];

    % Unit in Pa=kg.m^-1.s^-2-->10 g.cm^-1.s^-2
    TopPg=10.*[87615.43	87625.13	87612.43	87622.63	87635.96	87637.48	87629.81	87612.53	87634.64	87638.4	87650.06	87655.4	87686.58	87711.56	87718.32	87724.75	87733.38	87738.09	87731.39	87717	87694.07	87681.85	87662.34	87645.48	87596.08	87560.52	87522.66	87479.91	87427.78	87378.7	87335.56	87313.44	87271.71	87234.1	87212.97	87189.9	87171.99	87159.58	87144.79	87138.67	87218.73	87280.01	87292.2	87356.35	87526.9	87727.41	87851.52	87976.3	88018.78	88026.18	88013.47	87996.84	87992.71	87920.24	87868.18	87871.27	87893.01	87916.93	87928.32	87942.61	87961.52	88002.75	88026.18	88045.81	88094.38	88113.73	88110.81	88123.39	88119.94	88107.22	88088.46	88082.38	88059.66	88026.76	87982.86	87939.06	87898.67	87850.72	87818.01	87793.59	87775.59	87750.72	87721.28	87698.85	87678.36	87670.72	87678.48	87686.18	87688.14	87714.25	87728.36	87752.52	87788.6	87843.06	87863.2	87873.02	87863.82	87865.55	87859.23	87837.61	87817.86	87798.77	87782.36	87759.21	87757.84	87746.09	87737.6	87741.51	87747.96	87763.45	87777.05	87796.56	87812.04	87820.43	87827.43	87821.53	87809.06	87798.26	87791.51	87778.02 ...
    87752.39	87724.47	87684.39	87648.13	87612.87	87567.84	87530.77	87496.99	87473.03	87444.57	87418.82	87417.11	87401.4	87384.8	87375.37	87373.72	87379.61	87388.71	87406.42	87431.16	87461.12	87475.96	87482.53	87471.11	87460.68	87438.85	87409.75	87392.63	87380.99	87360.56	87339.29	87335.7	87326.42	87322.62	87320.49	87326.41	87336.68	87357.72	87359.53	87357.68	87351.73	87361.92	87371.97	87371.03	87358.48	87361.57	87354.08	87340.84	87335.21	87310.33	87273.67	87244.47	87218.85	87197.56	87174.26	87145.9	87117.45	87102.03	87075.55	87047.2	87022.83	87009.12	86990.57	86996.26	86995.8	86995.42	86993	87010.31	87062.81	87103.02	87125.09	87135.14	87133.45	87119.98	87098.43	87082.16	87047.87	87013.31	86978.32	86967.8	86964.7	86954.33	86923.82	86909.04	86924.79	86928.63	86925.45	86920.9	86914.53	86921.88	86916.11	86898.85	86877.37	86863.13	86847.29	86811.67	86778.85	86739.62	86730.8	86717.24	86691.47	86665.75	86640.43	86633.06	86616.74	86604.9	86590.06	86583.05	86562.52	86537.6	86535.83	86555.2	86562.55	86575.83	86573.17	86577.8	86605.92	86634.1	86653.59	86670.65 ...
    86665.94	86674.7	86674.3	86684.22	86675.89	86663.43	86665.08	86659.13	86660.93	86673.93	86689.09	86692.68	86709.14	86720.92	86743.3	86759.96	86784.68	86809.66	86838.97	86852.25	86842.51	86827.65	86829.59	86812.31	86785.19	86766.9	86730.18	86700.62	86688.34	86660.34	86634.55	86617.08	86598.79	86602.56	86607.89	86618.46	86639.95	86664.86	86723.12	86769.55	86828.03	86870.26	86898.28	86940.61	86999.96	87056.87	87076.33	87065.17	87055.9];

    h_SUR=[-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-264.9885143	-264.9885143	-264.9885143	-264.9885143	-264.9885143	-264.9885143	-264.9885143	-264.9885143	-264.9885143	-264.9885143	-264.9885143	-264.9885143	-264.9885143	-264.9885143	-264.9885143	-264.9885143	-264.9885143	-3840.55078	-264.9885143	-3840.55078	-3840.55078	-3840.55078	-3840.55078	-264.9885143	-216.6597048	-177.1004264	-157.3605762	-128.4598449	-113.9661381	-105.9416792	-102.1167534	-99.86205717	-98.808973	-96.83265414	-95.90311913	-95.00899728	-94.14787312	-93.31756053	-92.51607521	-91.74161097	-91.74161097	-90.99251946	-90.26729265	-90.26729265	-89.56454764	-89.56454764	-89.56454764	-88.88301343	-88.88301343	-88.88301343	-88.88301343	-88.88301343	-88.88301343	-88.88301343	-89.56454764	-89.56454764	-89.56454764	-89.56454764	-89.56454764	-90.26729265	-90.26729265	-90.26729265	-90.26729265	-90.99251946	-90.99251946	-91.74161097	-91.74161097	-91.74161097	-92.51607521	-92.51607521	-92.51607521	-92.51607521	-92.51607521	-92.51607521	-93.31756053	-93.31756053	-93.31756053	-93.31756053	-93.31756053	-93.31756053	-93.31756053	-94.14787312	-94.14787312	-94.14787312	-94.14787312	-94.14787312	-94.14787312	-94.14787312	-94.14787312	-93.31756053	-93.31756053	-93.31756053	-92.51607521	-92.51607521...
    -91.74161097	-91.74161097	-91.74161097	-90.99251946	-90.99251946	-90.26729265	-90.26729265	-90.26729265	-90.26729265	-90.26729265	-90.26729265	-90.26729265	-90.26729265	-90.26729265	-90.26729265	-90.99251946	-90.99251946	-91.74161097	-91.74161097	-91.74161097	-92.51607521	-92.51607521	-92.51607521	-93.31756053	-93.31756053	-93.31756053	-93.31756053	-94.14787312	-94.14787312	-94.14787312	-94.14787312	-94.14787312	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-94.14787312	-94.14787312	-93.31756053	-93.31756053	-93.31756053	-92.51607521	-92.51607521	-92.51607521	-92.51607521	-91.74161097	-91.74161097	-91.74161097	-91.74161097	-91.74161097	-92.51607521	-92.51607521	-92.51607521	-92.51607521	-92.51607521	-93.31756053	-93.31756053	-93.31756053	-94.14787312	-94.14787312	-94.14787312	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-95.90311913	-95.90311913	-95.90311913	-95.90311913	-95.90311913	-95.90311913	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-95.90311913	-95.90311913	-95.90311913	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-94.14787312	-94.14787312	-94.14787312	-94.14787312	-94.14787312	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-95.00899728	-95.90311913	-95.90311913	-95.90311913	-95.90311913	-95.90311913	-96.83265414	-96.83265414 ...
    -96.83265414	-96.83265414	-96.83265414	-96.83265414	-97.80027963	-97.80027963	-97.80027963	-97.80027963	-97.80027963	-97.80027963	-97.80027963	-98.808973	-98.808973	-98.808973	-98.808973	-98.808973	-98.808973	-98.808973	-98.808973	-98.808973	-98.808973	-98.808973	-98.808973	-97.80027963	-97.80027963	-97.80027963	-97.80027963	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-96.83265414	-97.80027963	-97.80027963	-97.80027963	-97.80027963	-98.808973	-98.808973	-98.808973	-98.808973	-98.808973	-99.86205717	-99.86205717];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  The measured soil moisture and tempeature data here    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Msrmn_Fitting   
%10, 20, 30, 40, 50cm    
Msr_Mois=[0.019581677	0.01969055	0.019803132	0.019906406	0.020003898	0.020102943	0.020193722	0.020269897	0.02034637	0.020419675	0.02050636	0.020594019	0.020665362	0.020773087	0.020888801	0.021005347	0.021129852	0.021201175	0.021217036	0.021194865	0.021123318	0.020996464	0.02079471	0.020542535	0.020284925	0.020032434	0.019730756	0.019434949	0.019117139	0.018793407	0.018487064	0.018236672	0.018039483	0.017883947	0.017709586	0.017533809	0.017419708	0.017383988	0.017383464	0.017380499	0.01745448	0.017609898	0.017811321	0.018057764	0.017840217	0.017786706	0.017961737	0.017630447	0.017331391	0.021890502	0.030887393	0.040074093	0.048230792	0.056125052	0.060931939	0.062897125	0.063924406	0.064509551	0.064845487	0.065070385	0.065210201	0.065284123	0.065334449	0.06539979	0.06541363	0.06533359	0.065126576	0.064876188	0.064495758	0.063999092	0.06342189	0.062825258	0.062164165	0.061459503	0.060740845	0.059998798	0.059228743	0.058548136	0.057915038	0.057249853	0.056659773	0.05619408	0.055786571	0.055439934	0.05505271	0.054594043	0.054340269	0.054100075	0.053813525	0.053549652	0.053374055	0.053233469	0.053118747	0.053015769	0.052904523	0.052803944	0.052721018	0.052633913	0.052555032	0.05248023	0.052399836	0.052329028	0.052254117	0.052200577	0.052139131	0.05208536	0.052031962	0.051982373	0.051932617	0.051886468	0.051849632	0.05182273	0.051789157	0.05173997	0.051701382	0.051596901	0.051496131	0.05135684	0.051197406	0.051052228	0.050901113	0.050745052	0.050576315	0.050423403	0.050279277	0.050141797	0.049996308	0.049844404	0.049704542	0.04956357	0.049409948	0.049238535	0.04908181	0.048961306	0.048827608	0.048674409	0.048541534	0.048410232	0.048350282	0.048297592	0.048271607	0.048240243	0.048206413	0.04818843 ...
0.048164545	0.048141001	0.048118257	0.048094455	0.048068006	0.048050708	0.048026907	0.048019921	0.048012484	0.04799538	0.047983905	0.047980878	0.047971549	0.047966683	0.047971434	0.048019164	0.048060446	0.048099451	0.048075032	0.048010696	0.047935382	0.047832448	0.047722338	0.047624952	0.047535212	0.047424973	0.047310469	0.047184527	0.047054142	0.046916835	0.046763127	0.046613472	0.046446633	0.046298364	0.046092615	0.045928689	0.04584441	0.045742189	0.045618461	0.0454664	0.045330306	0.045210627	0.045141512	0.045108518	0.045091593	0.045081029	0.045066064	0.045052307	0.045047053	0.045041125	0.045034359	0.045034642	0.04501798	0.044998648	0.04500324	0.044994911	0.044977134	0.044964205	0.044948058	0.04493724	0.044917623	0.04491922	0.044920453	0.04493572	0.044963857	0.04499252	0.044992361	0.044932574	0.04487026	0.044793583	0.04470517	0.044616329	0.044524769	0.044402042	0.044195255	0.044008645	0.043881671	0.043735657	0.043622833	0.043502341	0.043335986	0.043147251	0.04296946	0.042825791	0.042740334	0.042658337	0.042581534	0.042514817	0.042447545	0.042402547	0.042368866	0.042344025	0.042337806	0.042335317	0.042339602	0.042326366	0.042325067	0.042305412	0.042287802	0.042270709	0.042252386	0.042256048	0.042252945	0.042256232	0.042261178	0.042274105	0.042268291	0.042273616	0.042288775	0.04229322	0.042319703	0.042361849	0.042412537	0.042440796	0.042441683	0.042393686	0.042346811	0.042261359	0.042165892	0.042057972	0.041939487	0.041804626	0.041670998	0.041514458	0.041328086	0.041150021	0.040951643	0.040706771	0.040537197	0.040327442	0.040144185	0.040045578	0.039971691	0.039902843	0.039867407	0.039842117	0.039831115	0.039819994	0.039829019	0.039839107	0.039846354	0.039854497	0.039854714	0.039851179 0.03983960;
0.020693359	0.020672996	0.020650054	0.020628548	0.020604993	0.020588708	0.020572256	0.020551459	0.020526908	0.020503383	0.020478963	0.020453224	0.020431375	0.020409599	0.02039097	0.020390235	0.020348314	0.02033383	0.020327034	0.020325934	0.020323676	0.020327034	0.020337074	0.020363692	0.020377396	0.020400003	0.020429633	0.020460296	0.020498222	0.02055006	0.02059649	0.020628704	0.020678476	0.0207283	0.020762416	0.020784592	0.020824853	0.020869494	0.020884125	0.020886479	0.020890737	0.020890737	0.020891267	0.020885361	0.020742169	0.020654945	0.020614257	0.020492073	0.020287832	0.020135599	0.020009436	0.019963514	0.019927631	0.019908578	0.019854418	0.019809241	0.019772175	0.019733481	0.019701255	0.019669439	0.019641398	0.019616802	0.019591223	0.019581291	0.019579252	0.019572703	0.019577742	0.019582311	0.019597776	0.019616688	0.01964155	0.01968256	0.019736288	0.019794645	0.019866374	0.019943773	0.020027972	0.020118635	0.020208812	0.020290744	0.02037179	0.020451267	0.020519686	0.020596567	0.020645787	0.020696188	0.02074467	0.020782166	0.020787683	0.020794217	0.020794746	0.0207842	0.020761693	0.020737324	0.020698276	0.020664964	0.020626912	0.020590517	0.020560632	0.02052318	0.020484276	0.02045084	0.02042609	0.020394123	0.020363287	0.020335626	0.020304997	0.02027879	0.020256533	0.020229093	0.020203272	0.02019258	0.020188196	0.020200233	0.020214064	0.020232616	0.020263257	0.020307678	0.020366727	0.020435732	0.020518152	0.020607562	0.020711626	0.020829338	0.020961994	0.021108595	0.021250314	0.021397175	0.021553395	0.02170447	0.021850492	0.021987791	0.022109403	0.02221861	0.022299364	0.022362491	0.02239023	0.022408229	0.022410623	0.02239704	0.022370237	0.022328751	0.022283824	0.022237199 ...
0.022181847	0.022119796	0.02205801	0.021978972	0.021911688	0.02184223	0.021781853	0.021728847	0.021669139	0.021617398	0.021597699	0.021539245	0.021502298	0.021468818	0.021429453	0.021407148	0.021389852	0.021389852	0.021391981	0.021390966	0.021407288	0.021442125	0.021481464	0.021535029	0.021608608	0.021699995	0.021804933	0.021933921	0.022069139	0.02222997	0.022391784	0.022557481	0.022732098	0.02289786	0.023054455	0.023192804	0.023328503	0.023445901	0.023545504	0.023616071	0.02366484	0.023695096	0.023711004	0.023695794	0.023669258	0.023623671	0.023568373	0.023505153	0.023434595	0.023359613	0.023277783	0.02319744	0.023112907	0.02303517	0.022960932	0.022893404	0.022827195	0.022764838	0.022705201	0.022648045	0.022592456	0.022551074	0.022510598	0.022474224	0.022453776	0.022446034	0.02243813	0.022437025	0.022446403	0.022469429	0.02251226	0.022568657	0.022645122	0.02275536	0.022861217	0.02297235	0.023103905	0.023224892	0.02334525	0.023467871	0.023600348	0.023716844	0.02382999	0.023940882	0.024037678	0.024112625	0.024185333	0.024236922	0.024269134	0.024285872	0.024291947	0.024281988	0.024267783	0.024237115	0.024201951	0.024158301	0.024113715	0.024067192	0.024024327	0.023966598	0.023905018	0.023846674	0.023779004	0.023713713	0.02365943	0.023592879	0.023536508	0.023478071	0.023417306	0.023365947	0.023321169	0.023291891	0.023272865	0.023257886	0.023246508	0.023249729	0.02326299	0.023282952	0.02332603	0.023384997	0.023465516	0.023552037	0.02366484	0.023790197	0.023928413	0.0240768	0.024262956	0.024426463	0.024576638	0.024713066	0.024838698	0.024956745	0.025048271	0.025121859	0.025171998	0.025194917	0.025211462	0.025209092	0.025191714	0.025173357	0.025144072	0.025106137	0.025064102	0.025019466 0.025;
0.019593432	0.019588598	0.019579875	0.019577761	0.019576704	0.019565513	0.019562097	0.019555683	0.019546441	0.019539578	0.019531509	0.019527268	0.019516621	0.019506806	0.019499706	0.019518995	0.019593734	0.019593432	0.019590769	0.019584878	0.01958148	0.019582594	0.01958435	0.019586842	0.019585464	0.019588655	0.019591298	0.019593432	0.019596605	0.019605767	0.019614817	0.019624665	0.019634458	0.019641871	0.019649816	0.019654224	0.019669742	0.019684567	0.019693071	0.01970171	0.019703358	0.019713175	0.019720094	0.019729688	0.019736706	0.019740253	0.019744293	0.019765454	0.019830842	0.019856817	0.01990692	0.019930378	0.019942914	0.019958148	0.01996359	0.019962674	0.019955475	0.01994845	0.01993696	0.019923091	0.019912449	0.019898456	0.019881687	0.019866488	0.019859844	0.01985122	0.019839822	0.01982972	0.019821979	0.019813138	0.019802759	0.019796355	0.019788394	0.019781309	0.019781252	0.019781081	0.019781309	0.019785051	0.019794778	0.019804888	0.019816465	0.019830081	0.019846253	0.01986091	0.019875954	0.019894873	0.019914108	0.019933049	0.019942914	0.019959828	0.019970256	0.019978279	0.01998812	0.019992592	0.019997257	0.019998556	0.020000162	0.019995345	0.019990452	0.019986458	0.019978489	0.019971536	0.019968651	0.019955704	0.019945319	0.019932667	0.019919638	0.019905433	0.019890223	0.019874258	0.019861671	0.019855503	0.019840868	0.019834476	0.019828446	0.019821979	0.019813727	0.019812663	0.019812663	0.019811598	0.01981213	0.019812663	0.019821276	0.019832193	0.019852667	0.019871173	0.019899904	0.019929138	0.019961967	0.019996549	0.020034363	0.020075227	0.020114702	0.020157931	0.020190254	0.020227457	0.020257728	0.020289741	0.020320896	0.020351192	0.02037498	0.020396966	0.020414321	0.02043033 ...
0.020437398	0.02044408	0.02043703	0.020431434	0.020422121	0.020414224	0.020400932	0.020397121	0.020381862	0.020368157	0.020354843	0.020339912	0.020326166	0.02031831	0.020293135	0.020284747	0.020272738	0.020262409	0.020255686	0.020246421	0.020239701	0.020241376	0.020255686	0.020255686	0.020255686	0.020258383	0.020270367	0.020282973	0.020291881	0.020308971	0.020335722	0.020359016	0.020391241	0.020420631	0.020452604	0.02048577	0.020516755	0.020557619	0.02059433	0.020624907	0.020656563	0.020686063	0.020715061	0.020740684	0.020764039	0.020781227	0.02079907	0.020808152	0.020817745	0.020817745	0.020815532	0.020803924	0.020795391	0.020783575	0.020768614	0.020754578	0.020739512	0.020725332	0.020714124	0.020696832	0.020678554	0.020664087	0.020646819	0.020632385	0.020615776	0.020608438	0.020596937	0.020590128	0.020579256	0.020575795	0.020571965	0.020573053	0.020574706	0.020576864	0.02058828	0.02059398	0.020609041	0.02062294	0.020644774	0.020667245	0.020693905	0.020716194	0.020741231	0.020771723	0.020802965	0.020830905	0.020859455	0.020890737	0.020919788	0.020940629	0.020962446	0.020983923	0.020998385	0.021010117	0.021022227	0.021029397	0.021034873	0.021038775	0.021036804	0.02103182	0.021026088	0.021013858	0.020999724	0.020992895	0.020980814	0.020966103	0.020950711	0.020936444	0.020928488	0.02091217	0.020897546	0.020884066	0.020875828	0.02086518	0.020851713	0.02084891	0.020838212	0.020833804	0.020833804	0.020833804	0.020833804	0.020842679	0.02085283	0.020869964	0.020888539	0.020912052	0.020940629	0.020972396	0.021004861	0.021041297	0.021073411	0.021110135	0.021145533	0.021179918	0.021216039	0.021250036	0.021278174	0.021309312	0.021330502	0.021348009	0.021361069	0.021373041	0.021380918	0.021388996 0.0214;
0.018163215	0.018159532	0.018159532	0.018154515	0.018146955	0.018144736	0.018138675	0.018129946	0.018126881	0.018116173	0.018115164	0.018114677	0.018105217	0.018100569	0.018098065	0.018100569	0.01809857	0.018084451	0.018069493	0.018050243	0.018028077	0.018002228	0.017979522	0.017961245	0.017938534	0.017916665	0.017897656	0.017882987	0.017865626	0.017851526	0.017848525	0.017835076	0.017823615	0.017817404	0.017808768	0.017797816	0.017794142	0.017793161	0.017787652	0.017778044	0.017778044	0.017776565	0.017778044	0.017774623	0.017528464	0.01739694	0.017356521	0.017059499	0.016514838	0.01643945	0.016399081	0.016359247	0.016312866	0.01625612	0.016258671	0.016262474	0.016273005	0.016274881	0.016277282	0.01628217	0.016284994	0.016286872	0.016287345	0.01629017	0.016300103	0.016302506	0.016314458	0.016327245	0.01634653	0.016371665	0.016398979	0.016427206	0.016466866	0.016503463	0.016540638	0.016579693	0.016618767	0.016654897	0.016686714	0.0167169	0.016738848	0.016759591	0.016779644	0.016797023	0.016804794	0.016821171	0.01683792	0.016849673	0.016861361	0.016876181	0.016888589	0.016898236	0.016912418	0.016918837	0.01692839	0.016933411	0.016942761	0.016944683	0.016948528	0.016954834	0.016958889	0.016958889	0.016960327	0.016963706	0.016967034	0.016968767	0.016969721	0.016967311	0.016965353	0.016960812	0.016959859	0.016958889	0.016956913	0.016948528	0.016944683	0.016943228	0.016933584	0.016924738	0.016916467	0.016910654	0.016899827	0.016897285	0.016890232	0.016888105	0.016887621	0.016888105	0.016888105	0.016888105	0.016890992	0.016901591	0.016909547	0.016922679	0.016939194	0.016953396	0.016969582	0.016992126	0.017005765	0.017024811	0.017048702	0.017070787	0.017092349	0.017119415	0.017143525	0.017166747 ...
0.01719163	0.0172047	0.017215101	0.017221466	0.017229441	0.017236299	0.017244314	0.017257005	0.017257968	0.017261855	0.017263852	0.017270385	0.017271348	0.017272329	0.017272329	0.017272329	0.017271839	0.017261575	0.017256042	0.017244891	0.017228952	0.017216238	0.017201258	0.017190146	0.0171749	0.017159156	0.017151636	0.017143682	0.017143141	0.017139601	0.017142705	0.017143682	0.017143682	0.017154863	0.017162349	0.017171618	0.01718384	0.01719474	0.017206151	0.017226328	0.017241636	0.017258791	0.017280634	0.017302827	0.017322159	0.017343909	0.017367785	0.017389904	0.017410895	0.017428749	0.017440252	0.017447336	0.017459146	0.017467028	0.017473607	0.017473607	0.017473607	0.017475071	0.017480028	0.017479693	0.017479005	0.017474577	0.017473607	0.017473607	0.017473607	0.017473554	0.017461579	0.017456184	0.017436992	0.017424997	0.017413975	0.017401004	0.017390537	0.017387125	0.017379352	0.017373357	0.017372882	0.017372882	0.017372882	0.017372882	0.017373357	0.017373357	0.017374816	0.017383555	0.01738811	0.017398893	0.0174113	0.017422391	0.017433892	0.017452659	0.017467522	0.01747807	0.017495471	0.017509861	0.017525248	0.017539742	0.017554242	0.01756875	0.017584132	0.017590188	0.01759761	0.017603226	0.017603722	0.017603722	0.017603722	0.017603722	0.017603722	0.017603722	0.017603722	0.017603722	0.017603722	0.017603722	0.017601206	0.017592154	0.017589197	0.017591251	0.017590383	0.017587692	0.017576803	0.01757436	0.017562999	0.017559797	0.017554684	0.017545842	0.017545346	0.017542394	0.017544374	0.017544851	0.017544321	0.017545629	0.017547309	0.017558665	0.017566786	0.017582185	0.017594173	0.017605245	0.01762125	0.017639161	0.017657065	0.017675619	0.017696318	0.017714736	0.017730746	0.017741389 0.0178;
0.049687617	0.049687617	0.049673346	0.049660623	0.049655791	0.04964971	0.049647902	0.049646423	0.049640737	0.049632126	0.049631732	0.049615532	0.049603804	0.0496018	0.049602424	0.049622827	0.049648855	0.049664404	0.049695839	0.049749233	0.049801409	0.049860506	0.049915687	0.0499615	0.050012985	0.050058654	0.050100415	0.05014795	0.050177053	0.050195843	0.050208316	0.050220163	0.050237374	0.050250185	0.050251046	0.050233468	0.05022301	0.050220991	0.050207258	0.050163889	0.050122989	0.050093012	0.050066647	0.050052807	0.050164021	0.050105207	0.050122162	0.050381652	0.049272698	0.040675732	0.037685357	0.035938207	0.035566049	0.035781171	0.036001897	0.036133448	0.03623787	0.03630763	0.036367067	0.036425879	0.036477936	0.036536471	0.036583197	0.036634702	0.03670574	0.036792804	0.036894089	0.03701372	0.037166294	0.037345255	0.037545205	0.03774931	0.037975728	0.038197049	0.038419673	0.038640096	0.038850905	0.039046615	0.039232827	0.039397055	0.039539217	0.039663713	0.039788873	0.03989834	0.040023623	0.040140221	0.040241068	0.040349241	0.040441645	0.040541691	0.040625461	0.040703028	0.040783722	0.040865595	0.040931627	0.040997165	0.04106347	0.041123141	0.041184392	0.041232278	0.041271924	0.041313449	0.041360983	0.041402915	0.041440829	0.041482721	0.041525849	0.041566964	0.041606062	0.041638966	0.041670731	0.041698423	0.041722451	0.041752327	0.041788117	0.041835916	0.04187858	0.041916189	0.041926827	0.041942402	0.041970855	0.041989235	0.04198403	0.04197597	0.041974245	0.041959407	0.041953074	0.04197249	0.041989741	0.04203226	0.042072779	0.04214259	0.042220645	0.042313816	0.042422431	0.042548359	0.04268409	0.042833503	0.042980633	0.043124196	0.043259626	0.043383479	0.043501012	0.043615296 ...
0.043715985	0.043824319	0.043918697	0.044023842	0.044120221	0.044206573	0.044292227	0.044383637	0.044456907	0.044538383	0.044607303	0.044675082	0.044738012	0.044804024	0.044859573	0.044899002	0.044919839	0.044920118	0.04490442	0.044885444	0.044819546	0.044778582	0.044678138	0.044579678	0.04454171	0.044473312	0.044400026	0.044321435	0.044269507	0.044214609	0.044175662	0.044139739	0.044127911	0.04415448	0.044194152	0.044284182	0.044366237	0.044445798	0.044535302	0.044628737	0.044735541	0.044843981	0.044967294	0.045106049	0.045238746	0.045365664	0.045471362	0.045581423	0.04568351	0.045779282	0.045871253	0.045954138	0.046043679	0.046126245	0.046205625	0.046279916	0.046351975	0.046406135	0.046469179	0.046522977	0.046575103	0.046635434	0.046680285	0.046718378	0.046745707	0.046765179	0.046751954	0.046738223	0.046678099	0.046641197	0.046625618	0.046569345	0.046518993	0.046423817	0.046369014	0.046350429	0.046345192	0.046354089	0.046376494	0.046374979	0.046380123	0.046403325	0.046441251	0.046503407	0.046563777	0.046640121	0.046711816	0.046777994	0.046849879	0.046925294	0.0470011	0.047076947	0.04715752	0.047231635	0.047296207	0.047363068	0.04741569	0.047474042	0.047524784	0.047573891	0.047632232	0.047683267	0.047724927	0.047774575	0.04782104	0.047860488	0.047902369	0.047946011	0.047986487	0.048026565	0.048065147	0.048108199	0.048131848	0.048132783	0.048132783	0.048024728	0.047890144	0.047898959	0.047887602	0.04789098	0.047883421	0.047871905	0.047868175	0.047858012	0.047858012	0.047873835	0.047860328	0.047908933	0.047941311	0.047974023	0.048044355	0.048132977	0.048196795	0.048275725	0.04834619	0.048406	0.048472496	0.048532852	0.048590008	0.048652822	0.048706391	0.048765522	0.048822907	0.048870855 0.049];

% 2, 5, 10, 20, 50cm
Msr_Temp=[20.62308	20.07432	19.54978	19.40169	19.0833	18.87895	18.36823	17.68819	16.97869	16.11598	15.3955	14.62776	13.87208	14.00272	15.27499	18.26059	21.67124	24.07135	27.36326	32.71575	37.36908	42.05737	44.64062	47.04889	51.24971	53.74803	57.43676	59.1611	60.22037	58.7479	57.86428	57.375	57.98317	57.56142	54.49681	50.42173	48.47773	46.95489	42.0659	36.62358	32.73815	30.14336	28.6659	27.73499	20.50232	17.09797	15.77924	15.16123	14.95475	14.79607	15.08499	14.38752	14.16785	14.08611	13.97301	13.83783	13.99054	13.43888	12.93376	12.65939	12.31905	12.36762	13.01903	14.5133	16.28454	17.56258	19.27017	21.81632	23.90135	25.39958	27.47968	30.0065	31.73706	34.23271	35.83315	36.80592	36.9493	38.25373	39.00106	36.96285	36.0911	36.61942	35.84108	37.16446	34.24343	32.07902	31.69902	30.367	27.221	25.01684	23.40826	22.09332	21.17851	20.5223	19.69387	19.04968	18.52219	18.00506	17.58444	17.07561	16.70143	16.33618	15.942	15.56762	15.2733	15.03803	14.86903	14.61906	14.50862	14.68948	15.5748	17.39748	18.66042	21.80514	24.03464	27.86546	31.72406	34.27044	37.07249	39.8516	42.8944	45.83606	48.67824	50.52341	52.3743	52.75967	53.21803	53.79932	53.43058	52.61528	50.58343	47.76873	45.37737	43.32501	39.67414	36.59801	32.14505	29.41053	27.59556	26.31049	25.29252	24.20403	23.36816	22.63873 ...
21.83323	20.99349	20.32086	19.61346	19.06295	18.45141	18.01413	17.96982	17.4092	17.04	16.87913	16.34707	16.06646	16.22296	17.38345	19.70575	22.22763	25.17608	27.71339	32.18825	36.46582	39.81143	43.44165	46.77166	48.56834	51.16009	53.78492	54.95328	56.67086	57.56027	57.36035	56.25519	55.75773	53.26623	46.93318	46.07706	45.55405	43.1394	40.22616	36.8486	31.93811	28.47388	25.64025	23.95572	23.15334	22.34695	21.21537	20.86102	20.19663	19.68957	19.4619	19.00916	18.59381	18.29386	18.31064	18.23151	18.1232	17.69176	17.525	17.08795	16.54125	16.87633	17.93115	19.77579	22.61756	26.02386	28.80118	32.19228	36.62679	40.69577	45.2212	48.4221	52.84754	52.18338	50.89982	50.60509	49.72069	49.82207	52.36722	51.45284	50.47825	47.0839	43.70778	41.80868	39.85273	37.7563	36.05182	33.15018	30.95497	28.72325	26.82357	25.294	24.45086	24.115	23.80908	23.64779	22.97475	22.26919	21.24062	20.33497	19.80537	19.59011	18.77616	18.25109	18.24491	17.71654	17.16231	16.75321	16.56748	16.83126	18.12522	20.27662	23.17205	25.85759	29.17771	33.52034	37.42654	41.76351	45.28026	48.15117	50.16228	52.83761	56.18489	58.02718	59.08194	61.56661	56.01624	54.55493	53.69991	45.31693	43.33425	40.45205	37.37909	34.67029	32.12115	30.28022	28.51639	27.13131	26.09898	25.39383	24.74099	24.2245	23.83623	22.95347    21.85;
24.48624	23.86213	23.32072	22.84993	22.47732	22.13261	21.78697	21.33491	20.84222	20.20627	19.60821	19.01771	18.33729	17.88036	17.84213	18.50774	19.81034	21.43795	23.09986	25.75524	28.80767	32.03085	35.06855	37.33504	40.2402	42.9919	45.46627	47.95822	49.73574	50.64269	51.0408	50.89132	51.35075	51.73409	51.34577	49.88813	48.38498	47.01498	45.1551	42.29574	39.35067	36.79546	34.68937	33.13965	30.71292	26.85181	24.2402	22.26693	19.14806	17.4045	17.19942	16.64788	16.10561	15.82428	15.59689	15.3104	15.29088	15.006	14.50815	14.17211	13.80721	13.63363	13.75552	14.50967	15.68519	16.95922	18.1697	20.2357	22.14978	23.79774	25.53032	27.63381	29.49567	31.52557	33.15867	34.49729	34.92798	35.84307	36.86792	36.0123	35.50367	35.30342	34.90943	35.5882	34.6375	32.61069	31.9475	30.95332	29.22103	27.22545	25.65374	24.31626	23.15275	22.33343	21.52322	20.80288	20.189	19.60556	19.12791	18.68271	18.28309	17.89953	17.45099	17.05607	16.7091	16.39881	16.1566	15.89226	15.7043	15.66218	16.01748	16.91182	17.93352	19.70282	21.52634	24.14465	27.15443	29.73136	32.06314	34.3883	36.70657	38.87488	40.82219	42.47531	43.84239	44.76929	45.33445	45.74065	45.95034	45.84102	45.38582	44.40407	43.0733	41.88646	40.31165	38.44893	36.38873	34.10934	32.26721	30.65207	29.33749	28.16675	27.08671	26.13879 ...
25.26616	24.43989	23.72569	22.94975	22.3012	21.64549	21.06577	20.60964	20.21706	19.73956	19.36555	19.00896	18.61067	18.39147	18.4558	19.12751	20.21877	21.85345	23.27985	25.48815	27.82383	30.16035	32.36263	34.60582	36.45663	38.15546	39.77478	41.26844	42.69671	44.04099	44.94187	45.50856	45.69105	45.63556	44.04406	42.56426	41.81215	40.83441	39.47625	37.71681	35.56947	33.28725	31.25926	29.59937	28.38164	27.33898	26.4209	25.59041	24.89909	24.26644	23.72626	23.32112	22.85348	22.39947	22.08925	21.82284	21.62277	21.33538	21.10609	20.8289	20.4694	20.26841	20.31185	20.70605	21.49635	22.78881	24.18125	25.84836	28.05667	30.35178	33.12833	35.7145	38.49886	40.73327	41.03793	41.43323	41.9081	42.05797	43.10995	43.7765	43.88274	42.8759	41.63287	39.95343	38.70713	37.30842	36.00119	34.53599	32.95849	31.42511	29.98091	28.64765	27.61264	26.88941	26.42009	25.99113	25.60571	25.07568	24.46485	23.90406	23.3314	22.97265	22.53849	22.06138	21.74301	21.45615	21.07722	20.68869	20.44007	20.23741	20.40775	20.96012	21.96048	23.25047	24.73491	26.81936	29.1594	31.78605	34.38904	36.87811	39.04133	41.01345	43.27543	45.39024	46.99471	48.48972	48.87395	47.30261	47.20967	44.79512	42.35046	40.51372	38.52762	36.48909	34.57469	32.8367	31.33208	29.97857	28.845	27.96783	27.22443	26.65381	26.14007	25.65052    24.976;
28.17341	27.63805	27.13643	26.65155	26.22396	25.82413	25.46786	25.11428	24.78926	24.37229	23.98267	23.62879	23.1696	22.72129	22.36289	22.13318	22.12547	22.35249	22.80986	23.50249	24.50878	25.78957	27.32613	28.85029	30.39966	32.06707	33.73332	35.41865	37.03656	38.45222	39.59064	40.47208	41.13605	41.77052	42.30976	42.57402	42.52614	42.25032	41.87497	41.18253	40.19201	39.01675	37.73223	36.49126	35.3493	33.94999	32.28814	30.63872	28.9549	26.56619	23.42711	21.43085	20.1206	19.27736	18.68033	18.18044	17.81329	17.51719	17.09515	16.6675	16.26597	15.95561	15.74539	15.86803	16.31184	17.06979	17.89571	19.08553	20.48671	21.88847	23.31376	24.893	26.52195	28.16773	29.79977	31.19464	32.15486	32.9989	33.9069	34.32404	34.18393	33.99133	33.97133	34.05609	34.11595	33.1847	32.38339	31.66754	30.75379	29.41754	28.08023	26.85018	25.70601	24.80222	23.9577	23.19579	22.52958	21.91443	21.36728	20.893	20.46078	20.08831	19.65354	19.28147	18.91796	18.56967	18.28273	17.98071	17.72193	17.52335	17.48464	17.70159	18.23778	19.0067	20.16389	21.63168	23.60192	25.75623	27.78779	29.80313	31.83345	33.85132	35.72811	37.45413	38.95534	40.21406	41.15293	41.85818	42.38824	42.67641	42.6889	42.39956	41.75419	40.95378	40.02871	38.81895	37.52354	35.91316	34.39876	32.93214	31.6562	30.51859	29.41638	28.47492 ...
27.5816	26.78309	26.05158	25.3219	24.67121	24.07365	23.48226	22.93569	22.52028	22.04731	21.6218	21.25576	20.8557	20.55463	20.31276	20.31718	20.60219	21.30367	22.19127	23.38092	24.89045	26.5573	28.24263	29.94988	31.64635	33.17353	34.66767	36.04413	37.2665	38.36569	39.23204	39.85182	40.22846	40.42332	40.33187	39.73635	39.11833	38.54634	37.89989	37.09993	36.13408	34.9287	33.60107	32.3466	31.16765	30.13734	29.22005	28.35408	27.58124	26.88551	26.28625	25.76481	25.27727	24.79736	24.38668	24.07013	23.76904	23.49437	23.23417	22.99021	22.68838	22.42105	22.19688	22.11768	22.2423	22.61852	23.26789	24.08326	25.09439	26.266	27.56209	28.9445	30.34937	31.86558	33.03528	33.78142	34.35922	34.83392	35.2807	35.80884	36.1894	36.38831	36.31241	35.92931	35.43869	34.89162	34.26668	33.63577	32.95534	32.16994	31.38176	30.58774	29.83653	29.16521	28.62096	28.11438	27.70227	27.31196	26.91125	26.56101	26.15489	25.76912	25.39691	25.03113	24.6636	24.40131	24.0887	23.74463	23.48014	23.16448	22.94559	22.83463	22.89029	23.17104	23.61255	24.25001	25.14545	26.12076	27.20599	28.40311	29.58613	30.71969	31.79645	32.91052	33.95652	34.87439	35.72249	36.16189	36.33072	36.3676	35.96473	35.40984	34.78122	34.05218	33.25764	32.46043	31.69604	30.93413	30.2334	29.62611	29.0494	28.60053	28.1833	27.81466    27.488;
28.83264	28.66113	28.49162	28.31081	28.1533	27.97796	27.81029	27.64068	27.51079	27.30958	27.16464	27.04196	26.85439	26.68142	26.53257	26.3821	26.23797	26.06566	25.94111	25.82787	25.7464	25.70401	25.75142	25.82187	25.97379	26.20104	26.48339	26.8254	27.20934	27.62616	28.06692	28.5109	28.94732	29.37239	29.77906	30.15712	30.50587	30.81924	31.1191	31.3101	31.46386	31.59961	31.65075	31.6263	31.55482	31.44744	31.2606	30.96885	30.61026	30.35576	29.99327	29.53763	29.08744	28.64128	28.05047	27.43009	26.81257	26.2396	25.69623	25.17556	24.67458	24.27302	23.8633	23.52672	23.19562	22.9159	22.772	22.73061	22.78155	22.94491	23.24495	23.62621	24.06758	24.61514	25.247	25.8852	26.55626	27.21093	27.83979	28.43163	28.9199	29.36276	29.67012	29.89174	30.11274	30.26479	30.29453	30.20974	30.07887	29.82542	29.47114	29.02889	28.53582	28.06403	27.55855	27.08987	26.65795	26.23073	25.82757	25.50314	25.20067	24.91827	24.57035	24.28061	24.00773	23.73516	23.51116	23.259	23.04066	22.83826	22.65892	22.50166	22.38089	22.33448	22.39708	22.58793	22.90464	23.37556	24.00999	24.75189	25.62737	26.59526	27.59032	28.64207	29.74552	30.83614	31.91492	32.9205	33.81323	34.59186	35.16605	35.61715	35.86618	35.9251	35.82881	35.56523	35.24917	34.72682	34.18738	33.48567	32.77276	32.05151	31.35427	30.70591 ...
30.05024	29.45811	28.9318	28.39165	27.91788	27.44488	27.0143	26.58732	26.24171	25.85411	25.50725	25.23398	24.93463	24.66619	24.37537	24.14361	23.93943	23.81523	23.80676	23.94866	24.22953	24.64804	25.18138	25.83867	26.58049	27.42	28.3514	29.25844	30.18949	31.10735	31.93548	32.67512	33.3179	33.83428	34.25117	34.51682	34.57671	34.49469	34.34751	34.13545	33.82719	33.39998	32.88587	32.36588	31.78289	31.20545	30.62234	30.03483	29.50135	28.99642	28.55179	28.1417	27.75324	27.37545	27.04498	26.72855	26.45224	26.1807	25.94746	25.73162	25.50079	25.31149	25.13687	24.92829	24.76651	24.63839	24.60533	24.68605	24.87502	25.13885	25.52998	25.9947	26.53967	27.24263	28.00805	28.73396	29.39041	29.93426	30.41099	30.81915	31.18788	31.52896	31.83001	31.95107	31.98362	31.91586	31.74276	31.52941	31.28509	30.94766	30.6113	30.24447	29.88152	29.52047	29.18429	28.82524	28.52478	28.24803	27.97169	27.7591	27.50829	27.24556	27.02389	26.78529	26.54767	26.34065	26.11185	25.86097	25.68856	25.44957	25.25093	25.08723	24.91271	24.80023	24.72541	24.72835	24.8438	25.06185	25.34062	25.74165	26.22619	26.76892	27.31679	27.93227	28.53966	29.11574	29.67017	30.20893	30.66269	30.97093	31.16121	31.22629	31.16815	31.00727	30.76513	30.48691	30.18642	29.8562	29.54615	29.27161	28.95873	28.72902	28.48248	28.24623    28.056;
28.73	28.75	28.76	28.77	28.78	28.78	28.78	28.77	28.76	28.75	28.73	28.71	28.68	28.65	28.62	28.58	28.54	28.5	28.45	28.41	28.36	28.31	28.25	28.2	28.14	28.08	28.03	27.98	27.93	27.89	27.85	27.82	27.8	27.79	27.79	27.81	27.83	27.86	27.9	27.95	28.01	28.07	28.14	28.22	28.28	28.36	28.46	28.61	28.78	28.81	28.9	29	29.02	28.94	28.99	29.02	29.03	29.01	28.98	28.98	28.91	28.84	28.75	28.62	28.52	28.43	28.31	28.2	28.08	27.95	27.8	27.66	27.53	27.41	27.29	27.19	27.1	27.04	27	26.97	26.97	26.98	27	27.04	27.08	27.14	27.19	27.25	27.3	27.36	27.41	27.45	27.49	27.52	27.53	27.54	27.53	27.5	27.47	27.42	27.36	27.29	27.21	27.13	27.04	26.94	26.83	26.72	26.61	26.5	26.38	26.27	26.15	26.03	25.9	25.78	25.66	25.55	25.43	25.33	25.25	25.18	25.13	25.1	25.1	25.13	25.19	25.28	25.41	25.56	25.75	25.95	26.18	26.43	26.69	26.96	27.21	27.47	27.71	27.93	28.12	28.29	28.43	28.53...
28.61	28.65	28.67	28.67	28.64	28.6	28.55	28.48	28.4	28.31	28.21	28.1	27.99	27.87	27.75	27.63	27.5	27.37	27.24	27.1	26.97	26.85	26.73	26.62	26.53	26.46	26.42	26.4	26.42	26.46	26.54	26.65	26.79	26.97	27.17	27.39	27.64	27.9	28.17	28.44	28.69	28.93	29.16	29.37	29.55	29.69	29.8	29.88	29.93	29.94	29.93	29.89	29.84	29.77	29.68	29.59	29.48	29.37	29.25	29.13	29	28.87	28.74	28.61	28.47	28.34	28.21	28.07	27.94	27.82	27.7	27.6	27.52	27.45	27.4	27.39	27.4	27.44	27.51	27.61	27.72	27.87	28.02	28.2	28.4	28.6	28.82	29.02	29.2	29.38	29.54	29.68	29.79	29.88	29.95	29.99	30.01	30.01	29.99	29.95	29.9	29.84	29.77	29.7	29.61	29.52	29.42	29.32	29.22	29.11	29	28.89	28.77	28.65	28.54	28.42	28.3	28.2	28.1	28.01	27.94	27.9	27.88	27.86	27.88	27.95	28.04	28.17	28.32	28.5	28.72	28.96	29.21	29.46	29.71	29.94	30.14	30.31	30.45	30.56	30.63	30.68	30.71	30.71   30.7];

Msr_Time=3600.*[0 0.5	1	1.5	2	2.5	3	3.5	4	4.5	5	5.5	6	6.5	7	7.5	8	8.5	9	9.5	10	10.5	11	11.5	12	12.5	13	13.5	14	14.5	15	15.5	16	16.5	17	17.5	18	18.5	19	19.5	20	20.5	21	21.5	22	22.5	23	23.5	24	24.5	25	25.5	26	26.5	27	27.5	28	28.5	29	29.5	30	30.5	31	31.5	32	32.5	33	33.5	34	34.5	35	35.5	36	36.5	37	37.5	38	38.5	39	39.5	40	40.5	41	41.5	42	42.5	43	43.5	44	44.5	45	45.5	46	46.5	47	47.5	48	48.5	49	49.5	50	50.5	51	51.5	52	52.5	53	53.5	54	54.5	55	55.5	56	56.5	57	57.5	58	58.5	59	59.5	60	60.5	61	61.5	62	62.5	63	63.5	64	64.5	65	65.5	66	66.5	67	67.5	68	68.5	69	69.5	70	70.5	71	71.5	72	72.5	73	73.5	74	74.5	75	75.5	76	76.5	77	77.5	78	78.5	79	79.5	80	80.5	81	81.5	82	82.5	83	83.5	84	84.5	85	85.5	86	86.5	87	87.5	88	88.5	89	89.5	90	90.5	91	91.5	92	92.5	93	93.5	94	94.5	95	95.5	96	96.5	97	97.5	98	98.5	99	99.5 ...
100	100.5	101	101.5	102	102.5	103	103.5	104	104.5	105	105.5	106	106.5	107	107.5	108	108.5	109	109.5	110	110.5	111	111.5	112	112.5	113	113.5	114	114.5	115	115.5	116	116.5	117	117.5	118	118.5	119	119.5	120	120.5	121	121.5	122	122.5	123	123.5	124	124.5	125	125.5	126	126.5	127	127.5	128	128.5	129	129.5	130	130.5	131	131.5	132	132.5	133	133.5	134	134.5	135	135.5	136	136.5	137	137.5	138	138.5	139	139.5	140	140.5	141	141.5	142	142.5	143	143.5	144];
end

