% function Constants
global DeltZ Delt_t ML NS mL mN nD NL NN SAVE Tot_Depth Tmin
global xERR hERR TERR PERR tS uERR
global KT TIME Delt_t0 DURTN TEND NIT KIT Nmsrmn Eqlspace h_SUR Msrmn_Fitting  
global Msr_Mois Msr_Temp Msr_Time Tp_t Evap EPCT SAVEDTheta_LLT SAVEDTheta_LLh SAVEDTheta_UUh
global Ksoil Rl SMC Ztot DeltZ_R Theta_o rroot frac bbx wfrac RWUtot RWUtott RWUtottt Rls Tatot LR PSItot sfactortot LAI_msr R_depth RTB VPD_msr Tss Tsss SUMTIME Tsur FOC FOS FOSL MSOC Coef_Lamda fieldMC DELT Dur_tot Precipp fmax sitename
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% The time and domain information setting. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KIT=0;                      % KIT is used to count the number of iteration in a time step; 
NIT=30;                     % Desirable number of iterations in a time step;               
Nmsrmn=Dur_tot*10;       %Nmsrmn=140256*100;  Here, it is made as big as possible, in case a long simulation period containing many time step is defined. 
SUMTIME=0;                                                                                    
DURTN=DELT*Dur_tot;     % Duration of simulation period;                                  
KT=0;                        % Number of time steps;                                           
TIME=0*DELT;                     % Time of simulation released;                                  

                                                                                    
TEND=TIME+DURTN;     % Time to be reached at the end of simulation period;          
Delt_t=DELT;                   % Duration of time step [Unit of second]                       
Delt_t0=Delt_t;           % Duration of last time step;                                  
tS=DURTN/Delt_t;        % Is the tS(time step) needed to be added with 1? 
                                % Cause the start of simulation period is from 0mins, while the input data start from 30mins.
                                                                                    
xERR=0.02;                  % Maximum desirable change of moisture content;                  
hERR=0.1e08;               % Maximum desirable change of matric potential;                
TERR=2;                      % Maximum desirable change of temperature;                
PERR=5000;                  % Maximum desirable change of soil air pressure (Pa,kg.m^-1.s^-1);
uERR=0.02;                  % Maximum desirable change of total water content;                                                                    
Tot_Depth=500;           % Unit is cm. it should be usually bigger than 0.5m. Otherwise, 
                                 % the DeltZ would be reset in 50cm by hand;                                  
R_depth=300; %                                                                               
Eqlspace=0;                 % Indicator for deciding is the space step equal or not;       
NL=100;
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
global Theta_L Theta_LL Se h hh T TT Theta_V h_frez hh_frez T_CRIT TT_CRIT
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
global Lambda1 Lambda2 Lambda3 c_L c_a c_V c_i L0
global Lambda_eff c_unsat L LL Tr 
global CTh CTT CTa KTh KTT KTa VTT VTh VTa CTg CTT_PH CTT_LT CTT_g CTT_Lg EfTCON TETCON
global Kcvh KcvT Kcva Ccvh CcvT Kcah KcaT Kcaa Ccah CcaT Ccaa

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meteorological Forcing Information Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global MO Ta U Ts Zeta_MO        % U_wind is the mean wind speed at height z_ref (mï¿½ï¿½s^-1), U is the wind speed at each time step.
global Precip SH HR_a UseTs_msrmn      % Notice that Evap and Precip have only one value for each time step. Precip needs to be measured in advance as the input.
global Gsc Sigma_E 
global Rns Rnl 
global Tmax Tmin Hrmax Hrmin Um     
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
global DEhBAR DRHOVhDz EtaBAR DRHOVTDz KLhBAR KLTBAR DTDBAR QV QVa QLH QLT DVH DVT QVH QVT QL_a Qa DPgDZ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variable information for updating the state variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global hOLD TOLD P_gOLD J 
global porosity SaturatedMC ResidualMC  Coefficient_n Coefficient_Alpha
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables information for initialization subroutine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global InitND1 InitND2 InitND3 InitND4 InitND5 BtmT BtmX InitND6 %Preset the measured depth to get the initial T, h by interpolation method.
global InitT0 InitT1 InitT2 InitT3 InitT4 InitT5 InitT6
global InitX0 InitX1 InitX2 InitX3 InitX4 InitX5 InitX6
global Thmrlefc hThmrl Hystrs Soilairefc Ratio_ice

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Effective Thermal conductivity and capacity variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global EHCAP ThmrlCondCap Evaptranp_Cal SWCC ThermCond
global  Ts_a0 Ts_a Ts_b Ts_w 
global  Pg_w Pg_a0 Pg_a Pg_b 
global Hsur_w Hsur_a0 Hsur_a Hsur_b Rn VPD_msr LAI_msr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables information for boundary condition settings
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
global alpha_h bx Srt rwuef Ts_msr Tb_msr Theta_U Theta_UU Theta_I Theta_II KfL_h RHOI KfL_T Tbtm r_a_SOIL Rn_SOIL EVAP XCAP SAVEKfL_h
global Ta_msr RH_msr Rn_msr WS_msr G_msr Pg_msr HourInput Rns_msr SH_msr LE_msr DRHOVZ DTDZ DhDZ Precip_msr LAI_msr DTheta_LLh SAVETheta_UU DTheta_UUh EVAPO %SAVEDTheta_UUh
alpha_h=zeros(mL,nD);      %root water uptake
bx=zeros(mL,nD);SAVEKfL_h=zeros(mL,nD);
Srt=zeros(mL,nD);DhDZ=zeros(mL,1);DTDZ=zeros(mL,1);DRHOVZ=zeros(mL,1); DTheta_LLh=zeros(mL,nD);DTheta_UUh=zeros(mL,nD);SAVETheta_UU=zeros(mL,nD);SAVEDTheta_UUh=zeros(mL,nD);SAVEDTheta_LLh=zeros(mL,nD);SAVEDTheta_LLT=zeros(mL,nD);
Ratio_ice=zeros(mL,nD);
KL_h=zeros(mL,nD);       % The hydraulic conductivity(mï¿½ï¿½s^-1); 
KfL_h=zeros(mL,nD);       % The hydraulic conductivity considering ice blockking effect(mï¿½ï¿½s^-1); 
KfL_T=zeros(mL,nD);       % The depression temperature controlled by ice(m^2ï¿½ï¿½Cels^-1ï¿½ï¿½s^-1); 
KL_T=zeros(mL,nD);       % The conductivity controlled by thermal gradient(m^2ï¿½ï¿½Cels^-1ï¿½ï¿½s^-1); 
D_Ta=zeros(mL,nD);      % The thermal dispersivity for soil water (m^2ï¿½ï¿½Cels^-1ï¿½ï¿½s^-1); 
Theta_L=zeros(mL,nD);   % The soil moisture at the start of current time step;  
Theta_LL=zeros(mL,nD);  % The soil moisture at the end of current time step;      
Theta_U=zeros(mL,nD);   % The total soil moisture(water+ice) at the start of current time step;  
Theta_UU=zeros(mL,nD);  % The total soil moisture at the end of current time step;      
Theta_I=zeros(mL,nD);   % The soil ice water content at the start of current time step;  
Theta_II=zeros(mL,nD);  % The soil ice water content at the end of current time step;      
Se=zeros(mL,nD);           % The saturation degree of soil moisture;  
h=zeros(mN,1);              % The matric head at the start of current time step;
hh=zeros(mN,1);             % The matric head at the end of current time step;
h_frez=zeros(mN,1);             % The freeze depression head at the start of current time step;
hh_frez=zeros(mN,1);             % The freeze depression head at the end of current time step;
XCAP=zeros(mN,1);
T=zeros(mN,1);              % The soil temperature at the start of current time step; 
TT=zeros(mN,1);             % The soil temperature at the end of current time step;   
T_CRIT=zeros(mN,1);              % The soil ice critical temperature at the start of current time step; 
TT_CRIT=zeros(mN,1);              % The soil ice critical temperature at the start of current time step; 
EPCT=zeros(mN,1);
Theta_V=zeros(mL,nD);    % Volumetric gas content;  
W=zeros(mL,nD);             % Differential heat of wetting at the start of current time step(Jï¿½ï¿½kg^-1);  
WW=zeros(mL,nD);          % Differential heat of wetting at the end of current time step(Jï¿½ï¿½kg^-1);
                                    % Integral heat of wetting in individual time step(Jï¿½ï¿½m^-2); %%%%%%%%%%%%%%% Notice: the formulation of this in 'CondL_Tdisp' is not a sure. %%%%%%%%%%%%%%
MU_W=zeros(mL,nD);        % Visocity of water(kgï¿½ï¿½m^?6?1ï¿½ï¿½s^?6?1);
f0=zeros(mL,nD);              % Tortusity factor [Millington and Quirk (1961)];                   kg.m^2.s^-2.m^-2.kg.m^-3       
L_WT=zeros(mL,nD);         % Liquid dispersion factor in Thermal dispersivity(kgï¿½ï¿½m^-1ï¿½ï¿½s^-1)=-------------------------- m^2 (1.5548e-013 m^2);
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
QL=zeros(mL,nD);            % Soil moisture mass flux (kgï¿½ï¿½m^-2ï¿½ï¿½s^-1);
QL_D=zeros(mL,nD);         % Convective moisturemass flux (kgï¿½ï¿½m^-2ï¿½ï¿½s^-1);
QL_disp=zeros(mL,nD);     % Dispersive moisture mass flux (kgï¿½ï¿½m^-2ï¿½ï¿½s^-1);
QL_h=zeros(mL,nD);     % potential driven moisture mass flux (kgï¿½ï¿½m^-2ï¿½ï¿½s^-1);
QL_T=zeros(mL,nD);     % temperature driven moisture mass flux (kgï¿½ï¿½m^-2ï¿½ï¿½s^-1);
HR=zeros(mN,1);             % The relative humidity in soil pores, used for calculatin the vapor density;
RHOV_s=zeros(mN,1);      % Saturated vapor density in soil pores (kgï¿½ï¿½m^-3);
RHOV=zeros(mN,1);         % Vapor density in soil pores (kgï¿½ï¿½m^-3);
DRHOV_sT=zeros(mN,1);   % Derivative of saturated vapor density with respect to temperature;
DRHOVh=zeros(mN,1);      % Derivative of vapor density with respect to matric head;
DRHOVT=zeros(mN,1);      % Derivative of vapor density with respect to temperature;
RHODA=zeros(mN,1);        % Dry air density in soil pores(kgï¿½ï¿½m^-3);
DRHODAt=zeros(mN,1);     % Derivative of dry air density with respect to time;
DRHODAz=zeros(mN,1);     % Derivative of dry air density with respect to distance;
Xaa=zeros(mN,1);            % Coefficients of derivative of dry air density with respect to temperature and matric head;
XaT=zeros(mN,1);            % Coefficients of derivative of dry air density with respect to temperature and matric head;
Xah=zeros(mN,1);            % Coefficients of derivative of dry air density with respect to temperature and matric head;
D_Vg=zeros(mL,1);           % Gas phase longitudinal dispersion coefficient (m^2ï¿½ï¿½s^-1);
D_V=zeros(mL,nD);           % Molecular diffusivity of water vapor in soil(m^2ï¿½ï¿½s^-1);
D_A=zeros(mN,1);            % Diffusivity of water vapor in air (m^2ï¿½ï¿½s^-1);
k_g=zeros(mL,nD);           % Intrinsic air permeability (m^2);
Sa=zeros(mL,nD);            % Saturation degree of gas in soil pores;
V_A=zeros(mL,nD);           % Soil air velocity (mï¿½ï¿½s^-1);
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
CTT_PH=zeros(mL,nD);         % Storage coefficient in energy conservation equation related to phase change;
CTT_Lg=zeros(mL,nD);         % Storage coefficient in energy conservation equation related to liquid and gas;
CTT_g=zeros(mL,nD);          % Storage coefficient in energy conservation equation related to air;
CTT_LT=zeros(mL,nD);          % Storage coefficient in energy conservation equation related to liquid and temperature;
EfTCON=zeros(mL,nD);          % Effective heat conductivity Johansen method;  
TETCON=zeros(mL,nD);          % Effective heat conductivity Johansen method;  
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
Rns=zeros(Nmsrmn,1);        % Net shortwave radiation(Wï¿½ï¿½m^-2);
Rnl=zeros(Nmsrmn,1);        % Net longwave radiation(Wï¿½ï¿½m^-2);
Rn=zeros(Nmsrmn,1);
h_SUR=zeros(Nmsrmn,1);    % Observed matric potential at surface;
SH=zeros(Nmsrmn,1);         % Sensible heat (Wï¿½ï¿½m^-2);
MO=zeros(Nmsrmn,1);         % Monin-Obukhov's stability parameter (MO Length);
Zeta_MO=zeros(Nmsrmn,1); % Atmospheric stability parameter;
TopPg=zeros(Nmsrmn,1);     % Atmospheric pressure above the surface as the boundary condition (Pa);
Tp_t=zeros(Nmsrmn/10,1);
Evap=zeros(Nmsrmn/10,1);
Tbtm=zeros(Nmsrmn/10,1);
r_a_SOIL=zeros(Nmsrmn/10,1);
Rn_SOIL=zeros(Nmsrmn/10,1);
EVAP=zeros(Nmsrmn/10,1);
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
% QV=zeros(mL,1);               % Diffusive vapor mass flux;
DRHOVhDz=zeros(mL,1);
% DhDZ=zeros(mL,1);
EtaBAR=zeros(mL,1);
% D_Vg=zeros(mL,1);
DRHOVTDz=zeros(mL,1);
% DTDZ=zeros(mL,1);
KLhBAR=zeros(mL,1);
DEhBAR=zeros(mL,1);
KLTBAR=zeros(mL,1); 
DTDBAR=zeros(mL,1);
QLH=zeros(mL,1);
QLT=zeros(mL,1);
DVH=zeros(mL,1);
DVT=zeros(mL,1);
QVH=zeros(mL,1);
QVT=zeros(mL,1);
QV=zeros(mL,1);QVa=zeros(mL,1);Qa=zeros(mL,1);DPgDZ=zeros(mL,1);
QL_a=zeros(mL,1);
Ksoil=zeros(ML,1);
%Rl=zeros(ML,1);
SMC=zeros(ML,1);
bbx=zeros(ML,1);
%DeltZ_R=zeros(ML,1);
%Theta_o=ones(ML,1);
%Theta_s=ones(ML,1);
%Theta_r=ones(ML,1);
frac=zeros(ML,1);
wfrac=zeros(ML,1);
RWUtot=zeros(ML,Nmsrmn/10);
RWUtott=zeros(1,Nmsrmn/10);
RWUtottt=zeros(1,Nmsrmn/10);
EVAPO=zeros(1,Nmsrmn/10);
Rls=zeros(ML,Nmsrmn/10);
Tatot=zeros(Nmsrmn/10,1);
LR=0;
PSItot=zeros(Nmsrmn/10,1);
sfactortot=zeros(Nmsrmn/10,1);
Tsur=zeros(Nmsrmn/10,1);
Ztot=zeros(ML,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% The indicators needs to be set before the running of this program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
J=1;                                   % Indicator denotes the index of soil type for choosing soil physical parameters;       %
rwuef=1;
HourInput=1;
SWCC=1;                          % indicator for choose the soil water characteristic curve, =0, Clapp and Hornberger; =1, Van Gen;
Evaptranp_Cal=3;                 % Indicator denotes the method of estimating evapotranspiration; 
                                   % Value of 1 means the ETind method, otherwise, ETdir method; 
UseTs_msrmn=1;                  % Value of 1 means the measurement Ts would be used; Otherwise, 0;                      %
Msrmn_Fitting=1;                  % Value of 1 means the measurement data is used to fit the simulations; 
Hystrs=0;                            % If the value of Hystrs is 1, then the hysteresis is considered, otherwise 0;          %
Thmrlefc=1;                         % Consider the isothermal water flow if the value is 0, otherwise 1;                    %
Soilairefc=0;                         % The dry air transport is considered with the value of 1,otherwise 0;                  %
hThmrl=1;                            % Value of 1, the special calculation of water capacity is used, otherwise 0;           %
h_TE=0;                               % Value of 1 means that the temperature dependence                                      %
                                          % of matric head would be considered.Otherwise,0;                                       %   
W_Chg=1;                            % Value of 0 means that the heat of wetting would                                       %
                                          % be calculated by Milly's methodï¿½ï¿½Otherwise,1. The                                     %  
                                          % method of Lyle Prunty would be used;                                                  %
ThmrlCondCap=1; %1;            % The indicator for choosing Milly's effective thermal capacity and conductivity         %
                                          % formulation to verify the vapor and heat transport in extremly dry soil.              % 
% ThmrlCond=1;      % The indicator for choosing effective thermal conductivity methods, 1= de vries method;2= Jonhansen methods
ThermCond=1;      % The indicator for choosing effective thermal conductivity methods, 1= de vries method;2= Jonhansen methods;3= Simplified de vries method(Tian 2016);4= Farouki methods
% SWCC=1;            % indicator for choose the soil water characteristic curve, =0, Clapp and Hornberger; =1, Van Gen;
CHST=0;            % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use
ISOC=1;            % Indicator of considering soil organic matter effect or not. ISOC=1, yes; ISOC=0 no
%%%%% 172   27%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run soilpropertyread %load soil property
CKTN=(50+2.575*20);                                     % Constant used in calculating viscosity factor for hydraulic conductivity
l=0.5;                                                           % Coefficient in VG model;
g=981;                                                          % Gravity acceleration (cm.s^-2);
RHOL=1;                                                        % Water density (g.cm^-3);
RHOI=0.92;                                                 % Ice density (g.cm^-3);
SSUR=10^5;                                                  % Surface area for loam,for sand 10^2 (cm^-1);
Rv=461.5*1e4;                                               % (cm^2.s^-2.Cels^-1)Gas constant for vapor (original J.kg^-1.Cels^-1);
RDA=287.1*1e4;                                             % (cm^2.s^-2.Cels^-1)Gas constant for dry air (original J.kg^-1.Cels^-1);
RHO_bulk=1.25;                                              % Bulk density of sand (g.cm^-3);
fc=0.022;                                                        % The fraction of clay,for loam,0.036; for sand,0.02;
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
c_L=4.186;                        % Specific heat capacity of liquid water (Jï¿½ï¿½g^-1ï¿½ï¿½Cels^-1) %%%%%%%%% Notice the original unit is 4186kg^-1
c_V=1.870;                        % Specific heat capacity of vapor (Jï¿½ï¿½g^-1ï¿½ï¿½Cels^-1)
c_a=1.005;
%c_a=1.005;                        % 0.0003*4.186; %Specific heat capacity of dry air (Jï¿½ï¿½g^-1ï¿½ï¿½Cels^-1)
c_i=2.0455;                        % Specific heat capacity of ice (Jï¿½ï¿½g^-1ï¿½ï¿½Cels^-1)
Gsc=1360;                         % The solar constant (1360 Wï¿½ï¿½m^-2)
Sigma_E=4.90*10^(-9);       % The stefan-Boltzman constant.(=4.90*10^(-9) MJï¿½ï¿½m^-2ï¿½ï¿½Cels^-4ï¿½ï¿½d^-1)
P_g0=95197.850;%951978.50;               % The mean atmospheric pressure (Should be given in new simulation period subroutine.)
rroot=1.5*1e-3; 
RTB=1000;                    %initial root total biomass (g m-2)
Precipp=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input for producing initial soil moisture and soil temperature profile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Mdata=textread([InputPath, 'Mdata.txt']);
Ta_msr=Mdata(:,2)';
for jj=1:Dur_tot
if Ta_msr(jj)<-100
Ta_msr(jj)=NaN;
end
end
RH_msr=Mdata(:,3)';
WS_msr=Mdata(:,4)';
Pg_msr=Mdata(:,5)';
Rn_msr=Mdata(:,7)';
Rns_msr=Mdata(:,7)';
VPD_msr=Mdata(:,9)';
LAI_msr=Mdata(:,10)';
G_msr=Mdata(:,7)'*0.15;
Ts_msr=Mdata(:,2)';
Precip_msr=Mdata(:,6)'*10*DELT;
Tmin=min(Ts_msr);
Precip_msr=Precip_msr.*(1-fmax.*exp(-0.5*0.5*Tot_Depth/100));
% load initial soil moisture and soil temperature from ERA5
Initial_path=dir(fullfile(InitialConditionPath,[sitename,'*.nc']));
InitND1=5;    % Unit of it is cm. These variables are used to indicated the depth corresponding to the measurement.
InitND2=15;
InitND3=60;
InitND4=100;
InitND5=200;
InitND6=300;
if SWCC==0  
InitT0=	-1.762;  %-1.75estimated soil surface temperature-1.762
InitT1=	-0.662;
InitT2=	0.264;
InitT3=	0.905;
InitT4=	4.29;
InitT5=	3.657;%;
InitT6=	6.033;
BtmT=6.62;  %9 8.1
InitX0=	0.088;  
InitX1=	0.095; % Measured soil liquid moisture content
InitX2=	0.180; %0.169
InitX3=	0.213; %0.205
InitX4=	0.184; %0.114
InitX5=	0.0845;
InitX6=	0.078;
BtmX=0.078;%0.078 0.05;    % The initial moisture content at the bottom of the column.
else
      InitT0=   ncread([InitialConditionPath,Initial_path(1).name],'skt')-273.15;  %-1.75estimated soil surface temperature-1.762
      InitT1=	ncread([InitialConditionPath,Initial_path(2).name],'stl1')-273.15;
      InitT2=	ncread([InitialConditionPath,Initial_path(3).name],'stl2')-273.15;
      InitT3=	ncread([InitialConditionPath,Initial_path(4).name],'stl3')-273.15;
      InitT4=	ncread([InitialConditionPath,Initial_path(5).name],'stl4')-273.15;
      InitT5=	ncread([InitialConditionPath,Initial_path(5).name],'stl4')-273.15;
      InitT6=	ncread([InitialConditionPath,Initial_path(5).name],'stl4')-273.15;
      Tss = InitT0;
    if InitT0 < 0 || InitT1 < 0 || InitT2 < 0 || InitT3 < 0 || InitT4 < 0 || InitT5 < 0 || InitT6 < 0 
      InitT0=   0;
      InitT1=	0;
      InitT2=	0;
      InitT3=	0;
      InitT4=	0;
      InitT5=	0;
      InitT6=	0;
      Tss = InitT0;
    end
if nanmean(Ta_msr)<0
    BtmT  = 0;  %9 8.1
else
    BtmT  =  nanmean(Ta_msr);
end
InitX0=	ncread([InitialConditionPath,Initial_path(6).name],'swvl1');  %0.0793
InitX1=	ncread([InitialConditionPath,Initial_path(6).name],'swvl1'); % Measured soil liquid moisture content
InitX2=	ncread([InitialConditionPath,Initial_path(7).name],'swvl2'); %0.182
InitX3=	ncread([InitialConditionPath,Initial_path(8).name],'swvl3');
InitX4= ncread([InitialConditionPath,Initial_path(9).name],'swvl4'); %0.14335
InitX5=	ncread([InitialConditionPath,Initial_path(9).name],'swvl4');
InitX6=	ncread([InitialConditionPath,Initial_path(9).name],'swvl4');
BtmX  = ncread([InitialConditionPath,Initial_path(9).name],'swvl4');%0.05;    % The initial moisture content at the bottom of the column.
if InitX0 > SaturatedMC(1) || InitX1 > SaturatedMC(1) ||InitX2 > SaturatedMC(2) ||...
InitX3 > SaturatedMC(3) || InitX4 > SaturatedMC(4) || InitX5 > SaturatedMC(5) || InitX6 > SaturatedMC(6)
InitX0=	fieldMC(1);  %0.0793
InitX1=	fieldMC(1); % Measured soil liquid moisture content
InitX2=	fieldMC(2); %0.182
InitX3=	fieldMC(3);
InitX4= fieldMC(4); %0.14335
InitX5=	fieldMC(5);
InitX6=	fieldMC(6);
BtmX  = fieldMC(6);    
end
end