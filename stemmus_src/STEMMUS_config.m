%% STEMMUS Constants--StartInit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% The time and domain information setting. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
STEMMUS=1;%% set constants
KIT=0;                      % KIT is used to count the number of iteration in a time step;
NIT=30;                     % Desirable number of iterations in a time step;
Nmsrmn=100*1000;%20896*10;       %Nmsrmn=2568*100;  Here, it is made as big as possible, in case a long simulation period containing many time step is defined.

DURTN=60*30*2*1096;%20896;     % Duration of simulation period;
KT=0;                        % Number of time steps;
TIME=0;                     % Time of simulation released;
HPUNIT=100;        %unit conversion from m to cm;

TEND=TIME+DURTN;     % Time to be reached at the end of simulation period;
Delt_t=10;%3600;                   % Duration of time step [Unit of second]
Delt_t0=Delt_t;           % Duration of last time step;
tS=DURTN/Delt_t;        % Is the tS(time step) needed to be added with 1?
% Cause the start of simulation period is from 0mins, while the input data start from 30mins.

xERR=0.02;                  % Maximum desirable change of moisture content;
hERR=0.1e08;               % Maximum desirable change of matric potential;
TERR=2;                      % Maximum desirable change of temperature;
PERR=5000;                  % Maximum desirable change of soil air pressure (Pa,kg.m^-1.s^-1);
uERR=0.02;                  % Maximum desirable change of total water content;
% Tot_Depth=3830;%500;           % Unit is cm. it should be usually bigger than 0.5m. Otherwise,
% the DeltZ would be reset in 50cm by hand;

Eqlspace=0;%0;                 % Indicator for deciding is the space step equal or not;
[DeltZ_R,NL,DeltZ,MML]=Dtrmn_Z(IP0STm);
Tot_Depth=sum(DeltZ);%500;           % Unit is cm. it should be usually bigger than 0.5m. Otherwise,
NN=NL+1;                    % Number of nodes;
mN=NN+1;
mL=NL+1;                    % Number of elements. Prevending the exceeds of size of arraies;
nD=2;
NS=1;                          % Number of soil types;
XElemnt=zeros(NN,1);
XElemnt1=zeros(NN,1);
XElemnt1(1)=0;
TDeltZ=flip(DeltZ);
for ML=2:NL
    XElemnt1(ML)=XElemnt1(ML-1)+TDeltZ(ML-1);
end
XElemnt1(NN)=Tot_Depth;
TOPELEV=[3840.000	3717.500	3645.161	3586.464	3560.000	3611.383	3520.358	3483.765	3454.116	3427.815	3397.764	3414.816	3397.583	3429.178	3385.020	3393.255	3810.000	3743.777	3821.000	3772.387	3665.000	3649.507	3567.249	3545.872	3502.934	3474.846	3566.573	3599.505	3559.742	3511.335	3459.323	3395.369	3394.994	3386.328	3861.316	3775.572	3662.498	3496.611	3431.786	3461.962	3409.241	3399.618	3395.802	3388.953
    ].*HPUNIT;   % elevation at the top surface, added by LY
XElemnt=XElemnt1;%TOPELEV(IP0STm)-
SAVE=zeros(3,3,3);        % Arraies for calculating boundary flux;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% global h_TE
% global W_Chg
% global l CKTN
% global RHOL SSUR RHO_bulk Rv g RDA
% global KL_h KL_T D_Ta
% global Theta_L Theta_LL Se h hh T TT Theta_V h_frez hh_frez T_CRIT TT_CRIT
% global W WW MU_W f0 L_WT
% global DhT
% global GWT Gamma0 MU_W0 MU1 b W0 Gamma_w
% global Chh ChT Khh KhT Kha Vvh VvT Chg
% global C1 C2 C3 C4 C5 C6 C7 C9
% global QL QL_D QL_disp RHS
% global HR RHOV_s RHOV DRHOV_sT DRHOVh DRHOVT
% global RHODA DRHODAt DRHODAz Xaa XaT Xah
% global D_Vg D_V D_A
% global k_g Sa V_A Alpha_Lg POR_C Eta
% global P_g P_gg Theta_g P_g0 Beta_g
% global MU_a fc Unit_C Hc UnitC
% global Cah CaT Caa Kah KaT Kaa Vah VaT Vaa Cag
% global Lambda1 Lambda2 Lambda3 c_L c_a c_V c_i L0
% global Lambda_eff c_unsat L LL Tr
% global CTh CTT CTa KTh KTT KTa VTT VTh VTa CTg CTT_PH CTT_LT CTT_g CTT_Lg EfTCON TETCON
% global Kcvh KcvT Kcva Ccvh CcvT Kcah KcaT Kcaa Ccah CcaT Ccaa
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Meteorological Forcing Information Variables
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% global MO Ta U Ts Zeta_MO        % U_wind is the mean wind speed at height z_ref (mï¿½ï¿½s^-1), U is the wind speed at each time step.
% global Precip SH HR_a UseTs_msrmn      % Notice that Evap and Precip have only one value for each time step. Precip needs to be measured in advance as the input.
% global Gsc Sigma_E
% global Rns Rnl
% global Tmax Tmin Hrmax Hrmin Um
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Variables information for soil air pressure propagation
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% global TopPg
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Fluxes information with different mechanisms
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% global QL_Dts QL_dispts QLts QV_Dts QV_Ats QV_dispts QVts QA_Dts QA_Ats QA_dispts QAts
% global QV_D QV_A QV_disp QA_D QA_A QA_disp QL_T QL_h
% global DEhBAR DRHOVhDz EtaBAR DRHOVTDz KLhBAR KLTBAR DTDBAR QV QVa QLH QLT DVH DVT QVH QVT QL_a Qa DPgDZ
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Variable information for updating the state variables
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% global hOLD TOLD P_gOLD J hOLD_frez
% global porosity SaturatedMC ResidualMC SaturatedK Coefficient_n Coefficient_Alpha
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Variables information for initialization subroutine
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% global InitND1 InitND2 InitND3 InitND4 InitND5 BtmT BtmX InitND6 %Preset the measured depth to get the initial T, h by interpolation method.
% global InitT0 InitT1 InitT2 InitT3 InitT4 InitT5 InitT6
% global InitX0 InitX1 InitX2 InitX3 InitX4 InitX5 InitX6
% global Thmrlefc hThmrl Hystrs Soilairefc Ratio_ice
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Effective Thermal conductivity and capacity variables
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% global EHCAP ThmrlCondCap DTheta_LLh ETCON CHK KLhBAR COR DhDZ DTDZ TQL QLH QLT DTDBAR IS IH XK XOLD XWRE ZETA KLTBAR
% % global EHCAP ThmrlCondCap Evaptranp_Cal SWCC ThermCond
% global  Ts_a0 Ts_a Ts_b Ts_w
% global  Pg_w Pg_a0 Pg_a Pg_b
% global Hsur_w Hsur_a0 Hsur_a Hsur_b Rn VPD_msr LAI_msr
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Variables information for boundary condition settings
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% global DVhSUM DVTSUM DVaSUM KahSUM KaTSUM KaaSUM  KLhhSUM KLTTSUM
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
% global alpha_h bx Srt rwuef Ts_msr Tb_msr Theta_U Theta_UU Theta_I Theta_II KfL_h RHOI KfL_T Tbtm r_a_SOIL Rn_SOIL EVAP XCAP SAVEKfL_h TimeHourly EVAP_msr TRAP_msr TimeSDaily
% global Ta_msr RH_msr Rn_msr WS_msr G_msr Pg_msr HourInput Rns_msr SH_msr LE_msr DRHOVZ DTDZ DhDZ Precip_msr LAI_msr LAIDate_msr DTheta_LLh SAVETheta_UU DTheta_UUh Beta_gBAR Alpha_LgBAR%SAVEDTheta_UUh
XK=zeros(1,mL);
XOLD=zeros(1,mL);
% KLTBAR=zeros(1,mL);
XWRE=zeros(mL,nD);
ZETA=zeros(mL,nD);
% QLH=zeros(mL,1);            % Soil moisture mass flux (kg¡¤m^-2¡¤s^-1);
% QLT=zeros(mL,1);            % Soil moisture mass flux (kg¡¤m^-2¡¤s^-1);
TQL=zeros(mL,1);
% DhDZ=zeros(1,mL);
% DTDZ=zeros(1,mL);
COR=zeros(1,mL);
% KLhBAR=zeros(1,mL);
% DTDBAR=zeros(1,mL);
IS=zeros(1,mL);
IH=zeros(1,mL);
CHK=zeros(1,mL);
% DTheta_LLh=zeros(mL,nD);
ETCON=zeros(mL,nD);
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
CORh=zeros(mN,1);
Phi_s=zeros(mN,1);
Lamda=zeros(mN,1);
Theta_s_min=zeros(mN,1);
hOLD_frez=zeros(mN,1);             % The freeze depression head at the start of current time step;
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
FEHCAP=zeros(mL,nD);        % Effective heat capacity;
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
Beta_gBAR=zeros(mL,nD);       % The simplified coefficient for the soil air pressure linearization equation;
Alpha_LgBAR=zeros(mL,nD);       % The simplified coefficient for the soil air pressure linearization equation;
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
Precip=zeros(Nmsrmn*10,1);    % Precipitation(m.s^-1);
Ta=zeros(Nmsrmn*10,1);         % Air temperature;
Ts=zeros(Nmsrmn*10,1);         % Surface temperature;
U=zeros(Nmsrmn*10,1);          % Wind speed (m.s^-1);
HR_a=zeros(Nmsrmn*10,1);      % Air relative humidity;
Rns=zeros(Nmsrmn*10,1);        % Net shortwave radiation(Wï¿½ï¿½m^-2);
Rnl=zeros(Nmsrmn*10,1);        % Net longwave radiation(Wï¿½ï¿½m^-2);
Rn=zeros(Nmsrmn*10,1);         % Net radiation
h_SUR=zeros(Nmsrmn*10,1);    % Observed matric potential at surface;
SH=zeros(Nmsrmn*10,1);         % Sensible heat (Wï¿½ï¿½m^-2);
MO=zeros(Nmsrmn*10,1);         % Monin-Obukhov's stability parameter (MO Length);
Zeta_MO=zeros(Nmsrmn*10,1); % Atmospheric stability parameter;
TopPg=zeros(Nmsrmn*10,1);     % Atmospheric pressure above the surface as the boundary condition (Pa);
Tp_t=zeros(Nmsrmn*10,1);      % potential transpiration
Evap=zeros(Nmsrmn*10,1);      % soil evaporation
Tbtm=zeros(Nmsrmn*10,1);      % bottom soil temperature
r_a_SOIL=zeros(Nmsrmn*10,1);  % soil aerodynamic resistance
Rn_SOIL=zeros(Nmsrmn*10,1);   % radaition at the soil surface
EVAP=zeros(Nmsrmn*10,1);      % Soil evaporation
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% The indicators needs to be set before the running of this program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
J=1;                                   % Indicator denotes the index of soil type for choosing soil physical parameters;       %
rwuef=1;                        % Indicator for root water uptake process
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
SatrK=[0.21957e-6 6.0185e-6];  % Saturatued soil hydraulic conductivity
Alfa=[1.0973 3.24]./100;       % Coefficient in VG model
Coefn=[1.56 1.34];             % Coefficient in VG model
if IP0STm==1 || IP0STm==7 || IP0STm==11 || IP0STm==14 || IP0STm==15 || IP0STm==31 || IP0STm==41 || IP0STm==42 || IP0STm==43 || IP0STm==44
    SaturatedK=SatrK(1)*ones(1,6);%[2.67*1e-3  1.79*1e-3 1.14*1e-3 4.57*1e-4 2.72*1e-4];      %[2.3*1e-4  2.3*1e-4 0.94*1e-4 0.94*1e-4 0.68*1e-4] 0.18*1e-4Saturation hydraulic conductivity (cm.s^-1);
    SaturatedMC=[0.43]*ones(1,6);                              % 0.42 0.55 Saturated water content;
    Coefficient_n=Coefn(1)*ones(1,6);                            %1.2839 1.3519 1.2139 Coefficient in VG model;
    Coefficient_Alpha=Alfa(1)*ones(1,6);                   % 0.02958 0.007383 Coefficient in VG model;
    ResidualMC=[0.058]*ones(1,6);                               %0.037 0.017 0.078 The residual water content of soil;
    porosity=[0.47]*ones(1,6);                                      % Soil porosity;
else
    SaturatedK=SatrK(2)*ones(1,6);%[2.67*1e-3  1.79*1e-3 1.14*1e-3 4.57*1e-4 2.72*1e-4];      %[2.3*1e-4  2.3*1e-4 0.94*1e-4 0.94*1e-4 0.68*1e-4] 0.18*1e-4Saturation hydraulic conductivity (cm.s^-1);
    SaturatedMC=[0.43]*ones(1,6);                              % 0.42 0.55 Saturated water content;
    Coefficient_n=Coefn(2)*ones(1,6);                            %1.2839 1.3519 1.2139 Coefficient in VG model;
    Coefficient_Alpha=Alfa(2)*ones(1,6);                   % 0.02958 0.007383 Coefficient in VG model;
    ResidualMC=[0.058]*ones(1,6);                               %0.037 0.017 0.078 The residual water content of soil;
    porosity=[0.47]*ones(1,6);                                      % Soil porosity;
end

CKTN=(50+2.575*20);                                     % Constant used in calculating viscosity factor for hydraulic conductivity
l=0.5;                                                           % Coefficient in VG model;
g=981;                                                          % Gravity acceleration (cm.s^-2);
RHOL=1;                                                        % Water density (g.cm^-3);
RHOI=0.92;                                                 % Ice density (g.cm^-3);
SSUR=10^5;                                                  % Surface area for loam,for sand 10^2 (cm^-1);
Rv=461.5*1e4;                                               % (cm^2.s^-2.Cels^-1)Gas constant for vapor (original J.kg^-1.Cels^-1);
RDA=287.1*1e4;                                             % (cm^2.s^-2.Cels^-1)Gas constant for dry air (original J.kg^-1.Cels^-1);
RHO_bulk=1.37; %1.25;                                             % Bulk density of sand (g.cm^-3);
fc=0.02;                                                        % The fraction of clay,for loam,0.036; for sand,0.02;
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
P_g0=682675;%951978.50;               % The mean atmospheric pressure (Should be given in new simulation period subroutine.)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input for producing initial soil moisture and soil temperature profile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InitT0= 0.20505;  % estimated soil surface temperature
InitT1=	0.3014;
InitT2=	0.080;
InitT3=	0.0178;
InitT4=	1.7464;
InitT5=	4.6873;%;
InitT6=	5.0214;
BtmT=5.434;  %9 8.1
InitX0=	0.079;  %0.0793
InitX1=	0.083; % Measured soil liquid moisture content
InitX2=	0.233; %0.182
InitX3=	0.2328;
InitX4= 0.2327; %0.14335
InitX5=	0.233;
InitX6=	0.233;
BtmX= 0.2336;%0.05;    % The initial moisture content at the bottom of the column.
% % end

InitND1=2;    % Unit of it is cm. These variables are used to indicated the depth corresponding to the measurement.
InitND2=5;
InitND3=12;
InitND4=22;
InitND5=50;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  The measured soil moisture and tempeature data here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Msrmn_Fitting
    load('InputDaily.mat');
    EVAP_msr=Inputdata(:,3).*100; %m/s-->cm/s
    Precip_msr=Inputdata(:,2).*100; %m/s-->cm/s;
    TRAP_msr=0;%Inputdata(:,4)./100; %m/s-->cm/s;
    TimeSDaily=Inputdata(:,1);
end
% function StartInit11(IP0STm)
%% StartInit

SWCC=1;
h0_frez=zeros(NN+1,1);
hh0_frez=zeros(NN+1,1);
Tt0=zeros(NN+1,1);
TT0=zeros(NN+1,1);
h0=zeros(NN+1,1);
hh0=zeros(NN+1,1);
hd=-1e7;hm=-9899;
% SWCC=0;    % indicator for choose the soil water characteristic curve, =0, Clapp and Hornberger; =1, Van Gen;
CHST=0;
Elmn_Lnth=0;
Dmark=0;
FOS=[0.388 0.441 0.443 0.447 0.656 0.656];  % fraction of sand
FOC=[0.094 0.09 0.10 0.106 0.03 0.03];  % fraction of clay
FOSL=1-FOC-FOS;
Vol_qtz=FOS;
MSOC=[0.138 0.084 0.054 0.018 0.01 0.01]; % mass fraction of soil organic matter
VPERSOC=MSOC.*2700./((MSOC.*2700)+(1-MSOC).*1300);  % fraction of soil organic matter

Theta_s_ch=[0.5 0.45 0.41 0.43 0.41 0.41];
Phi_S=[-17.9 -17 -17 -19 -10 -10];
Coef_Lamda=1./[3.98 4.178 4.3 4.4 3.4 3.4]; %
Phi_soc=-0.0103;Lamda_soc=2.7;Theta_soc=0.6;
ImpedF=[3 3 3 3 3 3 3];
for JJ=1:6
    POR(JJ)=porosity(JJ);
    Theta_s(JJ)=SaturatedMC(JJ);
    Theta_r(JJ)=ResidualMC(JJ);
    n(JJ)=Coefficient_n(JJ);
    Ks(JJ)=SaturatedK(JJ);
    Alpha(JJ)=Coefficient_Alpha(JJ);
    m(JJ)=1-1/n(JJ);
    %     XK(JJ)=0.09; %0.11 This is for silt loam; For sand XK=0.025
    XK(JJ)=0.025; %0.11 This is for silt loam; For sand XK=0.025
    XWILT(JJ)=Theta_r(JJ)+(Theta_s(JJ)-Theta_r(JJ))/(1+abs(Alpha(JJ)*(-1.5e4))^n(JJ))^m(JJ);
    XCAP(JJ)=Theta_r(JJ)+(Theta_s(JJ)-Theta_r(JJ))/(1+abs(Alpha(JJ)*(-336))^n(JJ))^m(JJ);
    VPERS(JJ)=FOS(JJ)*(1-POR(JJ));
    VPERSL(JJ)=FOSL(JJ)*(1-POR(JJ));
    VPERC(JJ)=FOC(JJ)*(1-POR(JJ));
    if SWCC==0
        if CHST==0
            Phi_s(JJ)=Phi_S(JJ);
            Lamda(JJ)=Coef_Lamda(JJ);
        end
        Theta_s(JJ)=Theta_s_ch(JJ);
    end
end
Ksh(1:6)=[2.21*1e-4  2.21*1e-4 4.37*1e-4 0.36*1e-4 4.15*1e-4 4.15*1e-4];%[1.45*1e-4  1.45*1e-4 0.94*1e-4 0.94*1e-4 0.68*1e-4 0.68*1e-4];
BtmKsh=Ksh(6);
Ksh0=Ksh(1);Eqlspace=0;
if ~Eqlspace
    Inith0=-(((Theta_s(J)-Theta_r(J))/(InitX0-Theta_r(J)))^(1/m(J))-1)^(1/n(J))/Alpha(J);
    Inith1=-(((Theta_s(J)-Theta_r(J))/(InitX1-Theta_r(J)))^(1/m(J))-1)^(1/n(J))/Alpha(J);
    Inith2=-(((Theta_s(J)-Theta_r(J))/(InitX2-Theta_r(J)))^(1/m(J))-1)^(1/n(J))/Alpha(J);
    Inith3=-(((Theta_s(J)-Theta_r(J))/(InitX3-Theta_r(J)))^(1/m(J))-1)^(1/n(J))/Alpha(J);
    Inith4=-(((Theta_s(J)-Theta_r(J))/(InitX4-Theta_r(J)))^(1/m(J))-1)^(1/n(J))/Alpha(J);
    Inith5=-(((Theta_s(J)-Theta_r(J))/(InitX5-Theta_r(J)))^(1/m(J))-1)^(1/n(J))/Alpha(J);
    Inith6=-(((Theta_s(J)-Theta_r(J))/(InitX6-Theta_r(J)))^(1/m(J))-1)^(1/n(J))/Alpha(J);
    Btmh=-(((Theta_s(J)-Theta_r(J))/(BtmX-Theta_r(J)))^(1/m(J))-1)^(1/n(J))/Alpha(J);

    if Btmh==-inf
        Btmh=-1e7;
    end
    %%%%%%%%%%%%%%%%%% considering soil hetero effect modify date: 20170103 %%%%
    for ML=1:NL
        Elmn_Lnth=Elmn_Lnth+DeltZ(ML);
        InitLnth(ML)=Tot_Depth-Elmn_Lnth;
        if abs(InitLnth(ML)-InitND5)<1e-10
            for MN=1:(ML+1)
                IS(MN)=6;   %%%%%% Index of soil type %%%%%%%
                J=IS(MN);
                POR(MN)=porosity(J);
                Ks(MN)=SaturatedK(J);
                Theta_qtz(MN)=Vol_qtz(J);
                VPER(MN,1)=VPERS(J);
                VPER(MN,2)=VPERSL(J);
                VPER(MN,3)=VPERC(J);
                XSOC(MN)=VPERSOC(J);
                Imped(MN)=ImpedF(J);
                XK(MN)=0.025; %0.11 This is for silt loam; For sand XK=0.025
                if SWCC==1   % VG soil water retention model
                    Theta_s(MN)=SaturatedMC(J);
                    Theta_r(MN)=ResidualMC(J);
                    n(MN)=Coefficient_n(J);
                    m(MN)=1-1/n(MN);
                    Alpha(MN)=Coefficient_Alpha(J);
                    XWILT(MN)=Theta_r(MN)+(Theta_s(MN)-Theta_r(MN))/(1+abs(Alpha(MN)*(-1.5e4))^n(MN))^m(MN);
                    XCAP(MN)=Theta_r(MN)+(Theta_s(MN)-Theta_r(MN))/(1+abs(Alpha(MN)*(-336))^n(MN))^m(MN);
                    Inith5=-(((Theta_s(MN)-Theta_r(MN))/(InitX5-Theta_r(MN)))^(1/m(MN))-1)^(1/n(MN))/Alpha(MN);
                    Btmh=-(((Theta_s(MN)-Theta_r(MN))/(BtmX-Theta_r(MN)))^(1/m(MN))-1)^(1/n(MN))/Alpha(MN);
                else
                    Theta_s(MN)=Theta_s_ch(J);
                    if CHST==0  % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use
                        Phi_s(MN)=Phi_S(J);
                        Lamda(MN)=Coef_Lamda(J);
                        Theta_s(MN)=Theta_s_ch(J);
                    else
                        Phi_s(MN)=-0.01*10^(1.88-0.0131*VPER(MN,1)/(1-POR(MN))*100);
                        Lamda(MN)=(2.91+0.159*VPER(MN,3)/(1-POR(MN))*100);
                        Phi_s(MN)=(Phi_s(MN)*(1-XSOC(MN))+XSOC(MN)*Phi_soc)*100;
                        Lamda(MN)=1/(Lamda(MN)*(1-XSOC(MN))+XSOC(MN)*Lamda_soc);
                        Theta_s_min(MN)=0.489-0.00126*VPER(MN,1)/(1-POR(MN))*100;
                        Theta_s(MN)=Theta_s_min(MN)*(1-XSOC(MN))+XSOC(MN)*Theta_soc;
                        Theta_s(MN)=Theta_s_min(MN);

                    end
                    Theta_r(MN)=ResidualMC(J);
                    XWILT(MN)=Theta_s(MN)*((-1.5e4)/Phi_s(MN))^(-1*Lamda(MN));
                    Inith5=Phi_s(MN)*(InitX5/Theta_s(MN))^(-1/Lamda(MN));
                    Btmh=Phi_s(MN)*(BtmX/Theta_s(MN))^(-1/Lamda(MN));
                end
                T(MN)=BtmT+(MN-1)*(InitT5-BtmT)/ML;
                h(MN)=(Btmh+(MN-1)*(Inith5-Btmh)/ML);
                IH(MN)=1;   %%%%%% Index of wetting history of soil which would be assumed as dry at the first with the value of 1 %%%%%%%
            end
            Dmark=ML+2;
        end
        if abs(InitLnth(ML)-InitND4)<1e-10
            for MN=Dmark:(ML+1)
                IS(MN-1)=5;%IS(5:8)=6;
                J=IS(MN-1);
                POR(MN-1)=porosity(J);
                Ks(MN-1)=SaturatedK(J);
                Theta_qtz(MN-1)=Vol_qtz(J);
                VPER(MN-1,1)=VPERS(J);
                VPER(MN-1,2)=VPERSL(J);
                VPER(MN-1,3)=VPERC(J);
                XSOC(MN-1)=VPERSOC(J);
                Imped(MN)=ImpedF(J);
                XK(MN-1)=0.025; %0.11 This is for silt loam; For sand XK=0.025
                if SWCC==1
                    Theta_s(MN-1)=SaturatedMC(J);
                    Theta_r(MN-1)=ResidualMC(J);
                    n(MN-1)=Coefficient_n(J);
                    m(MN-1)=1-1/n(MN-1);
                    Alpha(MN-1)=Coefficient_Alpha(J);
                    XWILT(MN-1)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-1.5e4))^n(MN-1))^m(MN-1);
                    Inith4=-(((Theta_s(MN-1)-Theta_r(MN-1))/(InitX4-Theta_r(MN-1)))^(1/m(MN-1))-1)^(1/n(MN-1))/Alpha(MN-1);
                else
                    Theta_s(MN-1)=Theta_s_ch(J);
                    if CHST==0  % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use
                        Phi_s(MN-1)=Phi_S(J);
                        Lamda(MN-1)=Coef_Lamda(J);
                    else
                        Phi_s(MN-1)=-0.01*10^(1.88-0.0131*VPER(MN-1,1)/(1-POR(MN-1))*100);
                        Lamda(MN-1)=(2.91+0.159*VPER(MN-1,3)/(1-POR(MN-1))*100);
                        Phi_s(MN-1)=(Phi_s(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Phi_soc)*100;
                        Lamda(MN-1)=1/(Lamda(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Lamda_soc);
                        Theta_s_min(MN-1)=0.489-0.00126*VPER(MN-1,1)/(1-POR(MN-1))*100;
                        Theta_s(MN-1)=Theta_s_min(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Theta_soc;
                        Theta_s(MN-1)=Theta_s_min(MN-1);

                    end
                    Theta_r(MN-1)=ResidualMC(J);
                    XWILT(MN-1)=Theta_s(MN-1)*((-1.5e4)/Phi_s(MN-1))^(-1*Lamda(MN-1));
                    Inith4=Phi_s(MN-1)*(InitX4/Theta_s(MN-1))^(-1/Lamda(MN-1));
                end
                T(MN)=InitT5+(MN-Dmark+1)*(InitT4-InitT5)/(ML+2-Dmark);
                h(MN)=(Inith5+(MN-Dmark+1)*(Inith4-Inith5)/(ML+2-Dmark));
                IH(MN-1)=1;
            end
            Dmark=ML+2;
    end
    if abs(InitLnth(ML)-InitND3)<1e-10
        for MN=Dmark:(ML+1)
            IS(MN-1)=4;
            J=IS(MN-1);
            POR(MN-1)=porosity(J);
            Ks(MN-1)=SaturatedK(J);
            Theta_qtz(MN-1)=Vol_qtz(J);
            VPER(MN-1,1)=VPERS(J);
            VPER(MN-1,2)=VPERSL(J);
            VPER(MN-1,3)=VPERC(J);
            XSOC(MN-1)=VPERSOC(J);
            Imped(MN)=ImpedF(J);
            XK(MN-1)=0.045; %0.0550.11 This is for silt loam; For sand XK=0.025
            if SWCC==1
                Theta_s(MN-1)=SaturatedMC(J);
                Theta_r(MN-1)=ResidualMC(J);
                n(MN-1)=Coefficient_n(J);
                m(MN-1)=1-1/n(MN-1);
                Alpha(MN-1)=Coefficient_Alpha(J);
                XWILT(MN-1)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-1.5e4))^n(MN-1))^m(MN-1);
                XCAP(MN)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-336))^n(MN-1))^m(MN-1);
                Inith3=-(((Theta_s(MN-1)-Theta_r(MN-1))/(InitX3-Theta_r(MN-1)))^(1/m(MN-1))-1)^(1/n(MN-1))/Alpha(MN-1);
            else
                Theta_s(MN-1)=Theta_s_ch(J);
                Theta_r(MN-1)=ResidualMC(J);
                if CHST==0  % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use
                    Phi_s(MN-1)=Phi_S(J);
                    Lamda(MN-1)=Coef_Lamda(J);
                else
                    Phi_s(MN-1)=-0.01*10^(1.88-0.0131*VPER(MN-1,1)/(1-POR(MN-1))*100);
                    Lamda(MN-1)=(2.91+0.159*VPER(MN-1,3)/(1-POR(MN-1))*100);
                    Phi_s(MN-1)=(Phi_s(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Phi_soc)*100;
                    Lamda(MN-1)=1/(Lamda(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Lamda_soc);
                    Theta_s_min(MN-1)=0.489-0.00126*VPER(MN-1,1)/(1-POR(MN-1))*100;
                    Theta_s(MN-1)=Theta_s_min(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Theta_soc;
                    Theta_s(MN-1)=0.41;
                end
                XWILT(MN-1)=Theta_s(MN-1)*((-1.5e4)/Phi_s(MN-1))^(-1*Lamda(MN-1));
                Inith3=Phi_s(MN-1)*(InitX3/Theta_s(MN-1))^(-1/Lamda(MN-1));
            end
            T(MN)=InitT4+(MN-Dmark+1)*(InitT3-InitT4)/(ML+2-Dmark);
            h(MN)=(Inith4+(MN-Dmark+1)*(Inith3-Inith4)/(ML+2-Dmark));
            IH(MN-1)=1;
        end
        Dmark=ML+2;
    end
    if abs(InitLnth(ML)-InitND2)<1e-10
        for MN=Dmark:(ML+1)
            IS(MN-1)=3;
            J=IS(MN-1);
            POR(MN-1)=porosity(J);
            Ks(MN-1)=SaturatedK(J);
            Theta_qtz(MN-1)=Vol_qtz(J);
            VPER(MN-1,1)=VPERS(J);
            VPER(MN-1,2)=VPERSL(J);
            VPER(MN-1,3)=VPERC(J);
            XSOC(MN-1)=VPERSOC(J);
            Imped(MN)=ImpedF(J);
            XK(MN-1)=0.045; %0.0490.11 This is for silt loam; For sand XK=0.025
            if SWCC==1
                Theta_s(MN-1)=SaturatedMC(J);
                Theta_r(MN-1)=ResidualMC(J);
                n(MN-1)=Coefficient_n(J);
                m(MN-1)=1-1/n(MN-1);
                Alpha(MN-1)=Coefficient_Alpha(J);
                XWILT(MN-1)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-1.5e4))^n(MN-1))^m(MN-1);
                XCAP(MN)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-336))^n(MN-1))^m(MN-1);
                Inith2=-(((Theta_s(MN-1)-Theta_r(MN-1))/(InitX2-Theta_r(MN-1)))^(1/m(MN-1))-1)^(1/n(MN-1))/Alpha(MN-1);
            else
                Theta_s(MN-1)=Theta_s_ch(J);
                if CHST==0  % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use
                    Phi_s(MN-1)=Phi_S(J);
                    Lamda(MN-1)=Coef_Lamda(J);
                else
                    Phi_s(MN-1)=-0.01*10^(1.88-0.0131*VPER(MN-1,1)/(1-POR(MN-1))*100);
                    Lamda(MN-1)=(2.91+0.159*VPER(MN-1,3)/(1-POR(MN-1))*100);
                    Phi_s(MN-1)=(Phi_s(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Phi_soc)*100;
                    Lamda(MN-1)=1/(Lamda(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Lamda_soc);
                    Theta_s_min(MN-1)=0.489-0.00126*VPER(MN-1,1)/(1-POR(MN-1))*100;
                    Theta_s(MN-1)=Theta_s_min(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*0.45;
                    Theta_s(MN-1)=0.41;
                end
                Theta_r(MN-1)=ResidualMC(J);
                XWILT(MN-1)=Theta_s(MN-1)*((-1.5e4)/Phi_s(MN-1))^(-1*Lamda(MN-1));
                Inith2=Phi_s(MN-1)*(InitX2/Theta_s(MN-1))^(-1/Lamda(MN-1));
            end
            T(MN)=InitT3+(MN-Dmark+1)*(InitT2-InitT3)/(ML+2-Dmark);
            h(MN)=(Inith3+(MN-Dmark+1)*(Inith2-Inith3)/(ML+2-Dmark));
            IH(MN-1)=1;
        end
        Dmark=ML+2;
    end
    if abs(InitLnth(ML)-InitND1)<1e-10
        for MN=Dmark:(ML+1)
            IS(MN-1)=2;
            J=IS(MN-1);
            POR(MN-1)=porosity(J);
            Ks(MN-1)=SaturatedK(J);
            Theta_qtz(MN-1)=Vol_qtz(J);
            VPER(MN-1,1)=VPERS(J);
            VPER(MN-1,2)=VPERSL(J);
            VPER(MN-1,3)=VPERC(J);
            XSOC(MN-1)=VPERSOC(J);
            Imped(MN)=ImpedF(J);
            XK(MN-1)=0.045; %0.0450.11 This is for silt loam; For sand XK=0.025
            if SWCC==1
                Theta_s(MN-1)=SaturatedMC(J);
                Theta_r(MN-1)=ResidualMC(J);
                n(MN-1)=Coefficient_n(J);
                m(MN-1)=1-1/n(MN-1);
                Alpha(MN-1)=Coefficient_Alpha(J);
                XWILT(MN-1)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-1.5e4))^n(MN-1))^m(MN-1);
                XCAP(MN)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-336))^n(MN-1))^m(MN-1);
                Inith1=-(((Theta_s(MN-1)-Theta_r(MN-1))/(InitX1-Theta_r(MN-1)))^(1/m(MN-1))-1)^(1/n(MN-1))/Alpha(MN-1);
            else
                Theta_r(MN-1)=ResidualMC(J);
                Theta_s(MN-1)=Theta_s_ch(J);
                if CHST==0  % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use
                    Phi_s(MN-1)=Phi_S(J);
                    Lamda(MN-1)=Coef_Lamda(J);
                else
                    Phi_s(MN-1)=-0.01*10^(1.88-0.0131*VPER(MN-1,1)/(1-POR(MN-1))*100);
                    Lamda(MN-1)=(2.91+0.159*VPER(MN-1,3)/(1-POR(MN-1))*100);
                    Phi_s(MN-1)=(Phi_s(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Phi_soc)*100;
                    Lamda(MN-1)=1/(Lamda(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Lamda_soc);
                    Theta_s_min(MN-1)=0.489-0.00126*VPER(MN-1,1)/(1-POR(MN-1))*100;
                    Theta_s(MN-1)=Theta_s_min(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*0.6;

                end
                XWILT(MN-1)=Theta_s(MN-1)*((-1.5e4)/Phi_s(MN-1))^(-1*Lamda(MN-1));
                Inith1=Phi_s(MN-1)*(InitX1/Theta_s(MN-1))^(-1/Lamda(MN-1));
            end
            T(MN)=InitT2+(MN-Dmark+1)*(InitT1-InitT2)/(ML+2-Dmark);
            h(MN)=(Inith2+(MN-Dmark+1)*(Inith1-Inith2)/(ML+2-Dmark));
            IH(MN-1)=1;
        end
        Dmark=ML+2;
    end
    if abs(InitLnth(ML))<1e-10
        for MN=Dmark:(NL+1)
            IS(MN-1)=1;
            J=IS(MN-1);
            POR(MN-1)=porosity(J);
            Ks(MN-1)=SaturatedK(J);
            Theta_qtz(MN-1)=Vol_qtz(J);
            VPER(MN-1,1)=VPERS(J);
            VPER(MN-1,2)=VPERSL(J);
            VPER(MN-1,3)=VPERC(J);
            XSOC(MN-1)=VPERSOC(J);
            Imped(MN)=ImpedF(J);
            XK(MN-1)=0.05; %0.0450.11 This is for silt loam; For sand XK=0.025
            if SWCC==1
                Theta_s(MN-1)=SaturatedMC(J);
                Theta_r(MN-1)=ResidualMC(J);
                n(MN-1)=Coefficient_n(J);
                m(MN-1)=1-1/n(MN-1);
                Alpha(MN-1)=Coefficient_Alpha(J);
                XWILT(MN-1)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-1.5e4))^n(MN-1))^m(MN-1);
                XCAP(MN)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-336))^n(MN-1))^m(MN-1);
                Inith0=-(((Theta_s(MN-1)-Theta_r(MN-1))/(InitX0-Theta_r(MN-1)))^(1/m(MN-1))-1)^(1/n(MN-1))/Alpha(MN-1);
            else
                Theta_s(MN-1)=Theta_s_ch(J);
                if CHST==0  % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use
                    Phi_s(MN-1)=Phi_S(J);
                    Lamda(MN-1)=Coef_Lamda(J);
                else
                    Phi_s(MN-1)=-0.01*10^(1.88-0.0131*VPER(MN-1,1)/(1-POR(MN-1))*100);   %unit m
                    Lamda(MN-1)=(2.91+0.159*VPER(MN-1,3)/(1-POR(MN-1))*100);
                    Phi_s(MN-1)=(Phi_s(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Phi_soc)*100;
                    Lamda(MN-1)=1/(Lamda(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Lamda_soc);
                    Theta_s_min(MN-1)=0.489-0.00126*VPER(MN-1,1)/(1-POR(MN-1))*100;
                    Theta_s(MN-1)=Theta_s_min(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*0.7;

                end
                Theta_r(MN-1)=ResidualMC(J);
                XWILT(MN-1)=Theta_s(MN-1)*((-1.5e4)/Phi_s(MN-1))^(-1*Lamda(MN-1));
                Inith0=Phi_s(MN-1)*(InitX0/Theta_s(MN-1))^(-1/Lamda(MN-1));
            end
            T(MN)=InitT1+(MN-Dmark+1)*(InitT0-InitT1)/(NL+2-Dmark);
            h(MN)=(Inith1+(MN-Dmark+1)*(Inith0-Inith1)/(ML+2-Dmark));
            IH(MN-1)=1;
        end
    end
    end
else
    for ML=1:NL
        Elmn_Lnth=Elmn_Lnth+DeltZ(ML);
        InitLnth(ML)=Tot_Depth-Elmn_Lnth;
        if abs(InitLnth(ML)-InitND5)<1e-10
            for MN=1:(ML+1)
                IS(MN)=6;   %%%%%% Index of soil type %%%%%%%
                J=IS(MN);
                POR(MN)=porosity(J);
                Ks(MN)=SaturatedK(J);
                Theta_qtz(MN)=Vol_qtz(J);
                VPER(MN,1)=VPERS(J);
                VPER(MN,2)=VPERSL(J);
                VPER(MN,3)=VPERC(J);
                XSOC(MN)=VPERSOC(J);
                Imped(MN)=ImpedF(J);
                XK(MN)=0.025; %0.11 This is for silt loam; For sand XK=0.025
                if SWCC==1   % VG soil water retention model
                    Theta_s(MN)=SaturatedMC(J);
                    Theta_r(MN)=ResidualMC(J);
                    n(MN)=Coefficient_n(J);
                    m(MN)=1-1/n(MN);
                    Alpha(MN)=Coefficient_Alpha(J);
                    XWILT(MN)=Theta_r(MN)+(Theta_s(MN)-Theta_r(MN))/(1+abs(Alpha(MN)*(-1.5e4))^n(MN))^m(MN);
                    XCAP(MN)=Theta_r(MN)+(Theta_s(MN)-Theta_r(MN))/(1+abs(Alpha(MN)*(-336))^n(MN))^m(MN);
                    Inith5=-(((Theta_s(MN)-Theta_r(MN))/(InitX5-Theta_r(MN)))^(1/m(MN))-1)^(1/n(MN))/Alpha(MN);
                    Btmh=-(((Theta_s(MN)-Theta_r(MN))/(BtmX-Theta_r(MN)))^(1/m(MN))-1)^(1/n(MN))/Alpha(MN);
                else
                    Theta_s(MN)=Theta_s_ch(J);
                    if CHST==0  % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use
                        Phi_s(MN)=Phi_S(J);
                        Lamda(MN)=Coef_Lamda(J);
                        Theta_s(MN)=Theta_s_ch(J);
                    else
                        Phi_s(MN)=-0.01*10^(1.88-0.0131*VPER(MN,1)/(1-POR(MN))*100);
                        Lamda(MN)=(2.91+0.159*VPER(MN,3)/(1-POR(MN))*100);
                        Phi_s(MN)=(Phi_s(MN)*(1-XSOC(MN))+XSOC(MN)*Phi_soc)*100;
                        Lamda(MN)=1/(Lamda(MN)*(1-XSOC(MN))+XSOC(MN)*Lamda_soc);
                        Theta_s_min(MN)=0.489-0.00126*VPER(MN,1)/(1-POR(MN))*100;
                        Theta_s(MN)=Theta_s_min(MN)*(1-XSOC(MN))+XSOC(MN)*Theta_soc;
                        Theta_s(MN)=Theta_s_min(MN);

                    end
                    Theta_r(MN)=ResidualMC(J);
                    XWILT(MN)=Theta_s(MN)*((-1.5e4)/Phi_s(MN))^(-1*Lamda(MN));
                    Inith5=Phi_s(MN)*(InitX5/Theta_s(MN))^(-1/Lamda(MN));
                    Btmh=Phi_s(MN)*(BtmX/Theta_s(MN))^(-1/Lamda(MN));
                end
                T(MN)=BtmT+(MN-1)*(InitT5-BtmT)/ML;
                h(MN)=(Btmh+(MN-1)*(Inith5-Btmh)/ML);
                IH(MN)=1;   %%%%%% Index of wetting history of soil which would be assumed as dry at the first with the value of 1 %%%%%%%
            end
            Dmark=ML+2;
        end
        if abs(InitLnth(ML)-InitND4)<1e-10
            for MN=Dmark:(ML+1)
                IS(MN-1)=5;%IS(5:8)=6;
                J=IS(MN-1);
                POR(MN-1)=porosity(J);
                Ks(MN-1)=SaturatedK(J);
                Theta_qtz(MN-1)=Vol_qtz(J);
                VPER(MN-1,1)=VPERS(J);
                VPER(MN-1,2)=VPERSL(J);
                VPER(MN-1,3)=VPERC(J);
                XSOC(MN-1)=VPERSOC(J);
                Imped(MN)=ImpedF(J);
                XK(MN-1)=0.025; %0.11 This is for silt loam; For sand XK=0.025
                if SWCC==1
                    Theta_s(MN-1)=SaturatedMC(J);
                    Theta_r(MN-1)=ResidualMC(J);
                    n(MN-1)=Coefficient_n(J);
                    m(MN-1)=1-1/n(MN-1);
                    Alpha(MN-1)=Coefficient_Alpha(J);
                    XWILT(MN-1)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-1.5e4))^n(MN-1))^m(MN-1);
                    Inith4=-(((Theta_s(MN-1)-Theta_r(MN-1))/(InitX4-Theta_r(MN-1)))^(1/m(MN-1))-1)^(1/n(MN-1))/Alpha(MN-1);
                else
                    Theta_s(MN-1)=Theta_s_ch(J);
                    if CHST==0  % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use
                        Phi_s(MN-1)=Phi_S(J);
                        Lamda(MN-1)=Coef_Lamda(J);
                    else
                        Phi_s(MN-1)=-0.01*10^(1.88-0.0131*VPER(MN-1,1)/(1-POR(MN-1))*100);
                        Lamda(MN-1)=(2.91+0.159*VPER(MN-1,3)/(1-POR(MN-1))*100);
                        Phi_s(MN-1)=(Phi_s(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Phi_soc)*100;
                        Lamda(MN-1)=1/(Lamda(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Lamda_soc);
                        Theta_s_min(MN-1)=0.489-0.00126*VPER(MN-1,1)/(1-POR(MN-1))*100;
                        Theta_s(MN-1)=Theta_s_min(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Theta_soc;
                        Theta_s(MN-1)=Theta_s_min(MN-1);

                    end
                    Theta_r(MN-1)=ResidualMC(J);
                    XWILT(MN-1)=Theta_s(MN-1)*((-1.5e4)/Phi_s(MN-1))^(-1*Lamda(MN-1));
                    Inith4=Phi_s(MN-1)*(InitX4/Theta_s(MN-1))^(-1/Lamda(MN-1));
                end
                T(MN)=InitT5+(MN-Dmark+1)*(InitT4-InitT5)/(ML+2-Dmark);
                h(MN)=(Inith5+(MN-Dmark+1)*(Inith4-Inith5)/(ML+2-Dmark));
                IH(MN-1)=1;
            end
            Dmark=ML+2;
    end
    if abs(InitLnth(ML)-InitND3)<1e-10
        for MN=Dmark:(ML+1)
            IS(MN-1)=4;
            J=IS(MN-1);
            POR(MN-1)=porosity(J);
            Ks(MN-1)=SaturatedK(J);
            Theta_qtz(MN-1)=Vol_qtz(J);
            VPER(MN-1,1)=VPERS(J);
            VPER(MN-1,2)=VPERSL(J);
            VPER(MN-1,3)=VPERC(J);
            XSOC(MN-1)=VPERSOC(J);
            Imped(MN)=ImpedF(J);
            XK(MN-1)=0.045; %0.0550.11 This is for silt loam; For sand XK=0.025
            if SWCC==1
                Theta_s(MN-1)=SaturatedMC(J);
                Theta_r(MN-1)=ResidualMC(J);
                n(MN-1)=Coefficient_n(J);
                m(MN-1)=1-1/n(MN-1);
                Alpha(MN-1)=Coefficient_Alpha(J);
                XWILT(MN-1)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-1.5e4))^n(MN-1))^m(MN-1);
                XCAP(MN)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-336))^n(MN-1))^m(MN-1);
                Inith3=-(((Theta_s(MN-1)-Theta_r(MN-1))/(InitX3-Theta_r(MN-1)))^(1/m(MN-1))-1)^(1/n(MN-1))/Alpha(MN-1);
            else
                Theta_s(MN-1)=Theta_s_ch(J);
                Theta_r(MN-1)=ResidualMC(J);
                if CHST==0  % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use
                    Phi_s(MN-1)=Phi_S(J);
                    Lamda(MN-1)=Coef_Lamda(J);
                else
                    Phi_s(MN-1)=-0.01*10^(1.88-0.0131*VPER(MN-1,1)/(1-POR(MN-1))*100);
                    Lamda(MN-1)=(2.91+0.159*VPER(MN-1,3)/(1-POR(MN-1))*100);
                    Phi_s(MN-1)=(Phi_s(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Phi_soc)*100;
                    Lamda(MN-1)=1/(Lamda(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Lamda_soc);
                    Theta_s_min(MN-1)=0.489-0.00126*VPER(MN-1,1)/(1-POR(MN-1))*100;
                    Theta_s(MN-1)=Theta_s_min(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Theta_soc;
                    Theta_s(MN-1)=0.41;
                end
                XWILT(MN-1)=Theta_s(MN-1)*((-1.5e4)/Phi_s(MN-1))^(-1*Lamda(MN-1));
                Inith3=Phi_s(MN-1)*(InitX3/Theta_s(MN-1))^(-1/Lamda(MN-1));
            end
            T(MN)=InitT4+(MN-Dmark+1)*(InitT3-InitT4)/(ML+2-Dmark);
            h(MN)=(Inith4+(MN-Dmark+1)*(Inith3-Inith4)/(ML+2-Dmark));
            IH(MN-1)=1;
        end
        Dmark=ML+2;
    end
    if abs(InitLnth(ML)-InitND2)<1e-10
        for MN=Dmark:(ML+1)
            IS(MN-1)=3;
            J=IS(MN-1);
            POR(MN-1)=porosity(J);
            Ks(MN-1)=SaturatedK(J);
            Theta_qtz(MN-1)=Vol_qtz(J);
            VPER(MN-1,1)=VPERS(J);
            VPER(MN-1,2)=VPERSL(J);
            VPER(MN-1,3)=VPERC(J);
            XSOC(MN-1)=VPERSOC(J);
            Imped(MN)=ImpedF(J);
            XK(MN-1)=0.045; %0.0490.11 This is for silt loam; For sand XK=0.025
            if SWCC==1
                Theta_s(MN-1)=SaturatedMC(J);
                Theta_r(MN-1)=ResidualMC(J);
                n(MN-1)=Coefficient_n(J);
                m(MN-1)=1-1/n(MN-1);
                Alpha(MN-1)=Coefficient_Alpha(J);
                XWILT(MN-1)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-1.5e4))^n(MN-1))^m(MN-1);
                XCAP(MN)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-336))^n(MN-1))^m(MN-1);
                Inith2=-(((Theta_s(MN-1)-Theta_r(MN-1))/(InitX2-Theta_r(MN-1)))^(1/m(MN-1))-1)^(1/n(MN-1))/Alpha(MN-1);
            else
                Theta_s(MN-1)=Theta_s_ch(J);
                if CHST==0  % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use
                    Phi_s(MN-1)=Phi_S(J);
                    Lamda(MN-1)=Coef_Lamda(J);
                else
                    Phi_s(MN-1)=-0.01*10^(1.88-0.0131*VPER(MN-1,1)/(1-POR(MN-1))*100);
                    Lamda(MN-1)=(2.91+0.159*VPER(MN-1,3)/(1-POR(MN-1))*100);
                    Phi_s(MN-1)=(Phi_s(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Phi_soc)*100;
                    Lamda(MN-1)=1/(Lamda(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Lamda_soc);
                    Theta_s_min(MN-1)=0.489-0.00126*VPER(MN-1,1)/(1-POR(MN-1))*100;
                    Theta_s(MN-1)=Theta_s_min(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*0.45;
                    Theta_s(MN-1)=0.41;
                end
                Theta_r(MN-1)=ResidualMC(J);
                XWILT(MN-1)=Theta_s(MN-1)*((-1.5e4)/Phi_s(MN-1))^(-1*Lamda(MN-1));
                Inith2=Phi_s(MN-1)*(InitX2/Theta_s(MN-1))^(-1/Lamda(MN-1));
            end
            T(MN)=InitT3+(MN-Dmark+1)*(InitT2-InitT3)/(ML+2-Dmark);
            h(MN)=(Inith3+(MN-Dmark+1)*(Inith2-Inith3)/(ML+2-Dmark));
            IH(MN-1)=1;
        end
        Dmark=ML+2;
    end
    if abs(InitLnth(ML)-InitND1)<1e-10
        for MN=Dmark:(ML+1)
            IS(MN-1)=2;
            J=IS(MN-1);
            POR(MN-1)=porosity(J);
            Ks(MN-1)=SaturatedK(J);
            Theta_qtz(MN-1)=Vol_qtz(J);
            VPER(MN-1,1)=VPERS(J);
            VPER(MN-1,2)=VPERSL(J);
            VPER(MN-1,3)=VPERC(J);
            XSOC(MN-1)=VPERSOC(J);
            Imped(MN)=ImpedF(J);
            XK(MN-1)=0.045; %0.0450.11 This is for silt loam; For sand XK=0.025
            if SWCC==1
                Theta_s(MN-1)=SaturatedMC(J);
                Theta_r(MN-1)=ResidualMC(J);
                n(MN-1)=Coefficient_n(J);
                m(MN-1)=1-1/n(MN-1);
                Alpha(MN-1)=Coefficient_Alpha(J);
                XWILT(MN-1)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-1.5e4))^n(MN-1))^m(MN-1);
                XCAP(MN)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-336))^n(MN-1))^m(MN-1);
                Inith1=-(((Theta_s(MN-1)-Theta_r(MN-1))/(InitX1-Theta_r(MN-1)))^(1/m(MN-1))-1)^(1/n(MN-1))/Alpha(MN-1);
            else
                Theta_r(MN-1)=ResidualMC(J);
                Theta_s(MN-1)=Theta_s_ch(J);
                if CHST==0  % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use
                    Phi_s(MN-1)=Phi_S(J);
                    Lamda(MN-1)=Coef_Lamda(J);
                else
                    Phi_s(MN-1)=-0.01*10^(1.88-0.0131*VPER(MN-1,1)/(1-POR(MN-1))*100);
                    Lamda(MN-1)=(2.91+0.159*VPER(MN-1,3)/(1-POR(MN-1))*100);
                    Phi_s(MN-1)=(Phi_s(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Phi_soc)*100;
                    Lamda(MN-1)=1/(Lamda(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Lamda_soc);
                    Theta_s_min(MN-1)=0.489-0.00126*VPER(MN-1,1)/(1-POR(MN-1))*100;
                    Theta_s(MN-1)=Theta_s_min(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*0.6;

                end
                XWILT(MN-1)=Theta_s(MN-1)*((-1.5e4)/Phi_s(MN-1))^(-1*Lamda(MN-1));
                Inith1=Phi_s(MN-1)*(InitX1/Theta_s(MN-1))^(-1/Lamda(MN-1));
            end
            T(MN)=InitT2+(MN-Dmark+1)*(InitT1-InitT2)/(ML+2-Dmark);
            h(MN)=(Inith2+(MN-Dmark+1)*(Inith1-Inith2)/(ML+2-Dmark));
            IH(MN-1)=1;
        end
        Dmark=ML+2;
    end
    if abs(InitLnth(ML))<1e-10
        for MN=Dmark:(NL+1)
            IS(MN-1)=1;
            J=IS(MN-1);
            POR(MN-1)=porosity(J);
            Ks(MN-1)=SaturatedK(J);
            Theta_qtz(MN-1)=Vol_qtz(J);
            VPER(MN-1,1)=VPERS(J);
            VPER(MN-1,2)=VPERSL(J);
            VPER(MN-1,3)=VPERC(J);
            XSOC(MN-1)=VPERSOC(J);
            Imped(MN)=ImpedF(J);
            XK(MN-1)=0.05; %0.0450.11 This is for silt loam; For sand XK=0.025
            if SWCC==1
                Theta_s(MN-1)=SaturatedMC(J);
                Theta_r(MN-1)=ResidualMC(J);
                n(MN-1)=Coefficient_n(J);
                m(MN-1)=1-1/n(MN-1);
                Alpha(MN-1)=Coefficient_Alpha(J);
                XWILT(MN-1)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-1.5e4))^n(MN-1))^m(MN-1);
                XCAP(MN)=Theta_r(MN-1)+(Theta_s(MN-1)-Theta_r(MN-1))/(1+abs(Alpha(MN-1)*(-336))^n(MN-1))^m(MN-1);
                Inith0=-(((Theta_s(MN-1)-Theta_r(MN-1))/(InitX0-Theta_r(MN-1)))^(1/m(MN-1))-1)^(1/n(MN-1))/Alpha(MN-1);
            else
                Theta_s(MN-1)=Theta_s_ch(J);
                if CHST==0  % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use
                    Phi_s(MN-1)=Phi_S(J);
                    Lamda(MN-1)=Coef_Lamda(J);
                else
                    Phi_s(MN-1)=-0.01*10^(1.88-0.0131*VPER(MN-1,1)/(1-POR(MN-1))*100);   %unit m
                    Lamda(MN-1)=(2.91+0.159*VPER(MN-1,3)/(1-POR(MN-1))*100);
                    Phi_s(MN-1)=(Phi_s(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Phi_soc)*100;
                    Lamda(MN-1)=1/(Lamda(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*Lamda_soc);
                    Theta_s_min(MN-1)=0.489-0.00126*VPER(MN-1,1)/(1-POR(MN-1))*100;
                    Theta_s(MN-1)=Theta_s_min(MN-1)*(1-XSOC(MN-1))+XSOC(MN-1)*0.7;

                end
                Theta_r(MN-1)=ResidualMC(J);
                XWILT(MN-1)=Theta_s(MN-1)*((-1.5e4)/Phi_s(MN-1))^(-1*Lamda(MN-1));
                Inith0=Phi_s(MN-1)*(InitX0/Theta_s(MN-1))^(-1/Lamda(MN-1));
            end
            T(MN)=InitT1+(MN-Dmark+1)*(InitT0-InitT1)/(NL+2-Dmark);
            h(MN)=(Inith1+(MN-Dmark+1)*(Inith0-Inith1)/(ML+2-Dmark));
            IH(MN-1)=1;
        end
    end
    end
end
%%%%%%%%%%%%%%%%%% considering soil hetero effect modify date: 20170103 %%%%
%%%%% Perform initial freezing temperature for each soil type. %%%%
L_f=3.34*1e5; %latent heat of freezing fusion J Kg-1
T0=273.15; % unit K
ISFT=0;
if KTN==1
    InitHeadTop=[-22.25	-18	-17.333	-17	-18	-18	-22.065	-18	-18	-21.378	-7.367	-7.424	-10.16	-13.333	-15.956	-10.7621	-17.3	-16.668	-17.5	-18	-20	-18	-18	-18	-18	-23.772	-18	-18	-15.087	-24.091	-8.706	-8.181	-14.378	-10.538	-18.65	-24.2	-15.602	-17.121	-15.301	-23.778	-17.39	-13.39	-13.79	-9.004
        ].*100;  % initial soil surface matric head, added by LY
    InitHeadBot=[16.05	20.3	20.967	21.3	20.3	20.3	16.235	20.3	20.3	41.922	30.933	30.876	28.14	24.967	22.344	52.5379	2	21.632	20.8	20.3	18.3	20.3	20.3	20.3	20.3	14.528	20.3	20.3	23.213	14.209	29.594	30.119	48.922	27.762	19.65	14.1	22.698	21.179	22.999	14.522	20.91	24.91	24.51	29.296
        ].*100; % initial soil bottom matric head, added by LY
    h(NN-1)=InitHeadTop(IP0STm);h(NN)=InitHeadTop(IP0STm);h(1)=InitHeadBot(IP0STm);XElemnt1=max(XElemnt);
    for MN=2:NN-1
        h(MN)=h(MN-1)-DeltZ(MN-1)/XElemnt1*(h(1)-h(NN-1));%(h(1)+(MN-1)*(h(NN)-h(1))/(NN-1));
    end

    for MN=1:NN
        if h(MN)<=-1E-6
            if T(MN)<=0
                h_frez(MN)=L_f*1e4*(T(MN))/g/T0;
            else
                h_frez(MN)=0;
            end
            if SWCC==1
                if h_frez(MN)<=h(MN)+1e-6
                    h_frez(MN)=h(MN)+1e-6;
                else
                    h_frez(MN)=h_frez(MN);
                end
            else
                if h_frez(MN)<=h(MN)-Phi_s(J)
                    h_frez(MN)=h(MN)-Phi_s(J);
                else
                    h_frez(MN)=h_frez(MN);
                end
            end
        else
            h_frez(MN)=0;
        end
        h_frez(MN)=h_frez(MN);
        hh_frez(MN)=h_frez(MN);
        h(MN)=h(MN)-h_frez(MN);
        hh(MN)=h(MN);SAVEh(MN)=h(MN);SAVEhh(MN)=hh(MN);
        h0(MN)=h(MN);
        hh0(MN)=hh(MN);
        if abs(hh(MN))>=abs(hd)
            Gama_h(MN)=0;
            Gama_hh(MN)=Gama_h(MN);
        elseif abs(hh(MN))>=abs(hm)
            Gama_h(MN)=log(abs(hd)/abs(hh(MN)))/log(abs(hd)/abs(hm));
            Gama_hh(MN)=Gama_h(MN);
        else
            Gama_h(MN)=1;
            Gama_hh(MN)=Gama_h(MN);
        end

        if Thmrlefc==1
            TT(MN)=T(MN);
        end
        Tt0(MN)=T(MN); SAVETT(MN)=TT(MN);
        TT0(MN)=TT(MN);
        if Soilairefc==1
            P_g(MN)=67197.850;
            P_gg(MN)=P_g(MN);
        end
        if MN<NN
            XWRE(MN,1)=0;
            XWRE(MN,2)=0;
        end
        %     XK(MN)=0.0425;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HCAP(1)=0.998*4.182;HCAP(2)=0.0003*4.182;HCAP(3)=0.46*4.182;HCAP(4)=0.46*4.182;HCAP(5)=0.6*4.182;HCAP(6)=0.45*4.182; %HCAP(3)=2.66;HCAP(4)=2.66;HCAP(5)=1.3;% ZENG origial HCAP(3)=0.46*4.182;HCAP(4)=0.46*4.182;HCAP(5)=0.6*4.182;    % J cm^-3 Cels^-1  /  g.cm-3---> J g-1 Cels-1;                     %
TCON(1)=1.37e-3*4.182;TCON(2)=6e-5*4.182;TCON(3)=2.1e-2*4.182;TCON(4)=7e-3*4.182;TCON(5)=6e-4*4.182;TCON(6)=5.2e-3*4.182;%TCON(3)=8.8e-2;TCON(4)=2.9e-2;TCON(5)=2.5e-3;% ZENG origial TCON(3)=2.1e-2*4.182;TCON(4)=7e-3*4.182;TCON(5)=6e-4*4.182; % J cm^-1 s^-1 Cels^-1;                %
SF(1)=0;SF(2)=0;SF(3)=0.125;SF(4)=0.125;SF(5)=0.5;SF(6)=0.125;                                                                                          %
TCA=6e-5*4.182;GA1=0.035;GA2=0.013;                                                                                                           %
% VPER(1)=0.25;VPER(2)=0.23;VPER(3)=0.01;% for sand VPER(1)=0.65;VPER(2)=0;VPER(3)=0;   %  For Silt Loam; % VPER(1)=0.16;VPER(2)=0.33;VPER(3)=0.05;  VPER(1)=0.41;VPER(2)=0.06;%

%%%%% Perform initial thermal calculations for each soil type. %%%%                                                                             %
for J=1:NL   %--------------> Sum over all phases of dry porous media to find the dry heat capacity                                             %
    S1(J)=POR(J)*TCA;  %-------> and the sums in the dry thermal conductivity;                                                                     %
    S2(J)=POR(J);                                                                                                                                  %
    HCD(J)=0;
    VPERCD(J,1)=VPER(J,1)*(1-XSOC(J));
    VPERCD(J,2)=(VPER(J,2)+VPER(J,3))*(1-XSOC(J));
    VPERCD(J,3)=XSOC(J)*(1-POR(J));%
    for i=3:5                                                                                                                                   %
        TARG1=TCON(i)/TCA-1;                                                                                                                    %
        GRAT=0.667/(1+TARG1*SF(i))+0.333/(1+TARG1*(1-2*SF(i)));                                                                                 %
        S1(J)=S1(J)+GRAT*TCON(i)*VPERCD(J,i-2);                                                                                                           %
        S2(J)=S2(J)+GRAT*VPERCD(J,i-2);                                                                                                                   %
        HCD(J)=HCD(J)+HCAP(i)*VPERCD(J,i-2);                                                                                                        %
    end                                                                                                                                         %
    ZETA0(J)=1/S2(J);                                                                                                                              %
    CON0(J)=1.25*S1(J)/S2(J);                                                                                                                         %
    PS1(J)=0;                                                                                                                                   %
    PS2(J)=0;                                                                                                                                   %
    for i=3:5                                                                                                                                   %
        TARG2=TCON(i)/TCON(1)-1;                                                                                                                %
        GRAT=0.667/(1+TARG2*SF(i))+0.333/(1+TARG2*(1-2*SF(i)));                                                                                 %
        TERM=GRAT*VPERCD(J,i-2);                                                                                                                    %
        PS1(J)=PS1(J)+TERM*TCON(i);                                                                                                             %
        PS2(J)=PS2(J)+TERM;                                                                                                                     %
    end                                                                                                                                         %
    GB1(J)=0.298/POR(J);                                                                                                                        %
    GB2(J)=(GA1-GA2)/XWILT(J)+GB1(J);
    %%%%%%%% Johansen thermal conductivity method %%%%%%%
    RHo_bulk(J)=(1-Theta_s(J))*2.7*1000;         % Unit g.cm^-3
    TCON_dry(J)=(0.135*RHo_bulk(J)+64.7)/(2700-0.947*RHo_bulk(J));   % Unit W m-1 K-1 ==> J cm^-1 s^-1 Cels^-1
    %%%%%%%% organic thermal conductivity method %%%%%%%
    TCON_Soc=0.05; %RHo_SOC=130;
    TCON_dry(J)=TCON_dry(J)*(1-XSOC(J))+XSOC(J)*TCON_Soc;
    % %%%%%%%%%%%%%%%%
    TCON_qtz=7.7;TCON_o=2.0;TCON_L=0.57;%Theta_qtz(J)=0.47;     % thermal conductivities of soil quartz, other soil particles and water; unit  W m-1 K-1
    TCON_s(J)=TCON_qtz^(Theta_qtz(J))*TCON_o^(1-Theta_qtz(J)); % Johansen solid soil thermal conductivity Unit W m-1 K-1
    TCON_sa=7.7;Theta_sa(J)=VPER(J,1)/(1-POR(J));TCON_slt=2.74;Theta_slt(J)=VPER(J,2)/(1-POR(J));TCON_cl=1.93;Theta_cl(J)=VPER(J,3)/(1-POR(J)); % thermal conductivities of soil sand, silt and clay, unit  W m-1 K-1
    SF_sa=0.182;SF_slt=0.0534;SF_cl=0.00775;
    TCON_min(J)=(TCON_sa^(Theta_sa(J))*TCON_slt^(Theta_slt(J))*TCON_cl^(Theta_cl(J)))/100;
    SF_min(J)=SF_sa*Theta_sa(J)+SF_slt*Theta_slt(J)+SF_cl*Theta_cl(J);
    TS1(J)=POR(J)*TCA;  %-------> and the sums in the dry thermal conductivity;                                                                     %
    TS2(J)=POR(J);                                                                                                                                  %                                                                                                                                 %                                                                                                                              %
    TTARG1(J)=TCON_min(J)/TCA-1;                                                                                                                    %
    TGRAT(J)=0.667/(1+TTARG1(J)*SF_min(J))+0.333/(1+TTARG1(J)*(1-2*SF_min(J)));                                                                                 %
    TS1(J)=TS1(J)+TGRAT(J)*TCON_min(J)*(1-POR(J));                                                                                                           %
    TS2(J)=TS2(J)+TGRAT(J)*(1-POR(J));                                                                                                                   %                                                                                                                    %
    TZETA0(J)=1/TS2(J);                                                                                                                              %
    TCON0(J)=1.25*TS1(J)/TS2(J);      % dry thermal conductivity                                                                                                                     %
    TPS1(J)=0;                                                                                                                                   %
    TPS2(J)=0;                                                                                                                                   %                                                                                                                   %
    TTARG2(J)=TCON_min(J)/TCON(1)-1;                                                                                                                %
    TGRAT(J)=0.667/(1+TTARG2(J)*SF_min(J))+0.333/(1+TTARG2(J)*(1-2*SF_min(J)));                                                                                 %
    TTERM(J)=TGRAT(J)*(1-POR(J));                                                                                                                    %
    TPS1(J)=TPS1(J)+TTERM(J)*TCON_min(J);                                                                                                             %
    TPS2(J)=TPS2(J)+TTERM(J);
    %%%%%%%%%%%%%%%%%% Farouki thermal parameter method %%%%%%%%%%%
    if ThermCond==4
        FEHCAP(J)=(2.128*Theta_sa(J)+2.385*Theta_cl(J))/(Theta_sa(J)+Theta_cl(J))*1e6;  %J m-3 K-1
        FEHCAP(J)=FEHCAP(J)*(1-XSOC(J))+XSOC(J)*2.5*1e6;  % organic effect J m-3 K-1
        TCON_s(J)=(8.8*Theta_sa(J)+2.92*Theta_cl(J))/(Theta_sa(J)+Theta_cl(J)); %  W m-1 K-1
        TCON_s(J)=TCON_s(J)*(1-XSOC(J))+XSOC(J)*0.25;  % consider organic effect W m-1 K-1
    end
end                                                                                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if KTN==1
    % According to hh value get the Theta_LL
    % run SOIL2;   % For calculating Theta_LL,used in first Balance calculation.
    [hh,COR,CORh,Theta_V,Theta_g,Se,KL_h,Theta_LL,DTheta_LLh,KfL_h,KfL_T,hh_frez,Theta_UU,DTheta_UUh,Theta_II]=SOIL2(hh,COR,hThmrl,NN,NL,TT,Tr,Hystrs,XWRE,Theta_s,IH,KIT,Theta_r,Alpha,n,m,Ks,Theta_L,h,Thmrlefc,POR,Theta_II,CORh,hh_frez,h_frez,SWCC,Theta_U,XCAP,Phi_s,RHOI,RHOL,Lamda,Imped,L_f,g,T0,TT_CRIT,KfL_h,KfL_T,KL_h,Theta_UU,Theta_LL,DTheta_LLh,DTheta_UUh,Se);
    for MN=1:NN
        hh0_frez(MN)=hh_frez(MN);
        h0_frez(MN)=h_frez(MN);
    end
    for ML=1:NL
        Theta_L(ML,1)=Theta_LL(ML,1);
        Theta_L(ML,2)=Theta_LL(ML,2);
        XOLD(ML)=(Theta_L(ML,1)+Theta_L(ML,2))/2;
        Theta_U(ML,1)=Theta_UU(ML,1);
        Theta_U(ML,2)=Theta_UU(ML,2);
        XUOLD(ML)=(Theta_U(ML,1)+Theta_U(ML,2))/2;
        Theta_I(ML,1)=Theta_II(ML,1);
        Theta_I(ML,2)=Theta_II(ML,2);
        XIOLD(ML)=(Theta_I(ML,1)+Theta_I(ML,2))/2;
    end
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% The boundary condition information settings.%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IRPT1=0;
IRPT2=0;
NBCh=3;      % Moisture Surface B.C.: 1 --> Specified matric head(BCh); 2 --> Specified flux(BCh); 3 --> Atmospheric forcing;
BCh=-0/3600;
NBChB=2;    % Moisture Bottom B.C.: 1 --> Specified matric head (BChB); 2 --> Specified flux(BChB); 3 --> Zero matric head gradient (Gravitiy drainage);
BChB=0;
if Thmrlefc==1
    NBCT=1;  % Energy Surface B.C.: 1 --> Specified temperature (BCT); 2 --> Specified heat flux (BCT); 3 --> Atmospheric forcing;
    BCT=-4.3255;  % surface temperature
    NBCTB=1;% Energy Bottom B.C.: 1 --> Specified temperature (BCTB); 2 --> Specified heat flux (BCTB); 3 --> Zero temperature gradient;
    BCTB=5.434;
end
if Soilairefc==1
    NBCP=3; % Soil air pressure B.C.: 1 --> Ponded infiltration caused a specified pressure value;
    % 2 --> The soil air pressure is allowed to escape after beyond the threshold value;
    % 3 --> The atmospheric forcing;
    BCP=0;
    NBCPB=2;  % Soil air Bottom B.C.: 1 --> Bounded bottom with specified air pressure; 2 --> Soil air is allowed to escape from bottom;
    BCPB=0;
end

if NBCh~=1
    NBChh=2;                    % Assume the NBChh=2 firstly;
end

FACc=0;                         % Used in MeteoDataCHG for check is FAC changed?
BtmPg=67197.850;     % Atmospheric pressure at the bottom (Pa), set fixed
% with the value of mean atmospheric pressure;
DSTOR=0;                        % Depth of depression storage at end of current time step;
DSTOR0=DSTOR;              % Dept of depression storage at start of current time step;
RS=0;                             % Rate of surface runoff;
DSTMAX=0;                     % Depression storage capacity;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%