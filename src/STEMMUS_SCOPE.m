%% STEMMUS-SCOPE.m (script)

%     STEMMUS-SCOPE is a model for Integrated modeling of canopy photosynthesis, fluorescence,
%     and the transfer of energy, mass, and momentum in the soil-plant-atmosphere continuum
%
%     Version: 1.0.1
%
%     Copyright (C) 2021  Yunfei Wang, Lianyu Yu, Yijian Zeng, Christiaan Van der Tol, Bob Su
%     Contact: y.wang-3@utwente.nl; l.yu@utwente.nl; y.zeng@utwente.nl; c.vandertol@utwente.nl; z.su@utwente.nl
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% 0. globals
% We replaced the filereads (old) script with a function named prepareForcingData, see issue %86,
% but there still global variables here, because we not sure which
% progresses related to these global variables.

% Load in required Octave packages if STEMMUS-SCOPE is being run in Octave:
if exist('OCTAVE_VERSION', 'builtin') ~= 0
    pkg load statistics;
end

% Read the configPath file. Due to using MATLAB compiler, we cannot use run(CFG)
global CFG
if isempty(CFG)
    CFG = '../config_file_crib.txt';
end
disp (['Reading config from ', CFG]);
global InputPath OutputPath InitialConditionPath
[InputPath, OutputPath, InitialConditionPath] = io.read_config(CFG);

% Prepare forcing and soil data
global IGBP_veg_long latitude longitude reference_height canopy_height sitename DELT Dur_tot
[SiteProperties, SoilProperties, TimeProperties] = io.prepareInputData(InputPath);
IGBP_veg_long        = SiteProperties.IGBP_veg_long;
latitude             = SiteProperties.latitude;
longitude            = SiteProperties.longitude;
reference_height     = SiteProperties.reference_height;
canopy_height        = SiteProperties.canopy_height;
sitename             = SiteProperties.sitename;

DELT = TimeProperties.DELT;
Dur_tot = TimeProperties.Dur_tot;

global SaturatedMC ResidualMC fieldMC fmax theta_s0 Ks0
SaturatedMC = SoilProperties.SaturatedMC;
ResidualMC = SoilProperties.ResidualMC;
fieldMC = SoilProperties.fieldMC;
fmax = SoilProperties.fmax;
theta_s0 = SoilProperties.theta_s0;
Ks0 = SoilProperties.Ks0;

%%
run Constants; % input soil parameters
global i tS KT Delt_t TEND TIME MN NN ML ND hOLD TOLD h hh T TT P_gOLD P_g P_gg Delt_t0
global KIT NIT TimeStep Processing
global SUMTIME hhh TTT P_ggg Theta_LLL Thmrlefc CHK Theta_LL Theta_L Theta_UUU Theta_UU Theta_U Theta_III Theta_II Theta_I
global AVAIL Evap EXCESS QMT hN hSAVE Soilairefc Trap sumTRAP_dir sumEVAP_dir
global TSAVE AVAIL0 TIMEOLD TIMELAST SRT ALPHA BX alpha_h bx Srt KfL_hh KL_hh Chhh ChTT Khhh KhTT CTTT CTT_PH CTT_LT CTT_g CTT_Lg CCTT_PH CCTT_LT CCTT_g CCTT_Lg C_unsat c_unsat
global QL QL_h QL_T QV Qa KL_h Chh ChT Khh KhT SAVEDSTOR TRAP_ind TRAP_dir SAVEhhh Resis_a KfL_h KfL_T TTT_CRIT TT_CRIT T_CRIT TOLD_CRIT
global h_frez hhh_frez hOLD_frez L_f T0 CTT EPCT EPCTT DTheta_LLh DTheta_LLT DTheta_UUh CKT CKTT DDTheta_LLh DDTheta_LLT DDTheta_UUh Lambda_Eff Lambda_eff EfTCON TTETCON TETCON Tbtms Cor_TIME DDhDZ DhDZ DDTDZ DTDZ DDRHOVZ DRHOVZ
global DDEhBAR DEhBAR DDRHOVhDz DRHOVhDz EEtaBAR EtaBAR DD_Vg D_Vg DDRHOVTDz DRHOVTDz KKLhBAR KLhBAR KKLTBAR KLTBAR DDTDBAR DTDBAR QVV QLL CChh SAVEDTheta_LLT SAVEDTheta_LLh SAVEDTheta_UUh DSAVEDTheta_LLT DSAVEDTheta_LLh DSAVEDTheta_UUh
global  QVT QVH QVTT QVHH SSa Sa HRA HR QVAA QVa QLH QLT QLHH QLTT DVH DVHH DVT DVTT SSe Se QAA QAa QL_TT QL_HH QLAA QL_a DPgDZ DDPgDZ k_g kk_g VV_A V_A SAVETheta_UU Theta_a
global SAVEKfL_h KCHK FCHK TKCHK hCHK TSAVEhh SAVEhh_frez Precip SAVETT INDICATOR thermal
global Theta_g DeltZ Alpha_Lg Beta_g D_V D_A fc Eta nD ThmrlCondCap ZETA
global MU_W Ks RHODA RHOV ETCON EHCAP
global Xaa XaT Xah KL_T DRHOVT DRHOVh DRHODAt DRHODAz hThmrl Tr Hystrs
global Theta_V W WW D_Ta SSUR W_Chg SWCC Ratio_ice ThermCond Beta_gBAR Alpha_LgBAR
global xERR hERR TERR uERR L QMTT QMBB Evapo trap RnSOIL PrecipO Constants
global RWU EVAP theta_s0 Ks0 HR Precip Precipp Tss frac sfactortot sfactor fluxes lEstot lEctot NoTime Tmin

%% 1. define Constants
[Constants] = io.define_constants();
global g RHOL RHOI Rv RDA MU_a Lambda1 Lambda2 Lambda3 c_a c_V c_L
g = Constants.g;
RHOL = Constants.RHOL;
RHOI = Constants.RHOI;
Rv = Constants.Rv;
RDA = Constants.RDA;
MU_a = Constants.MU_a;
Lambda1 = Constants.Lambda1;
Lambda2 = Constants.Lambda2;
Lambda3 = Constants.Lambda3;
c_L = Constants.c_L;
c_V = Constants.c_V;
c_a = Constants.c_a;

% used in other scripts not here!
global GWT c_i Gamma0 Gamma_w
GWT = Constants.GWT; % used in CondL_T
Gamma0 = Constants.Gamma0; % used in other scripts!
Gamma_w = Constants.Gamma_w; % used in other scripts!
c_i = Constants.c_i; % used in EnrgyPARM!
RHO_bulk = Constants.RHO_bulk; % TODO: issue: used in CondL_Tdisp, and CondT_coeff and defined as RHo_bulk in thermal conectivity !

[Rl] = Initial_root_biomass(RTB, DeltZ_R, rroot, ML);

%% 2. simulation options
path_input = InputPath;          % path of all inputs
path_of_code = cd;

useXLSX = 1;      % set it to 1 or 0, the current stemmus-scope does not support useXLSX=0
if useXLSX == 0
    % parameter_file             = { 'setoptions.m', 'filenames.m', 'inputdata.txt'};
    % Read parameter file which is 'input_data.xlsx' and return it as options.
    %     options = io.setOptions(parameter_file,path_input);
    warning("the current stemmus-scope does not support useXLSX=0");
else
    parameter_file = {'input_data.xlsx'};
    options = io.readStructFromExcel([path_input char(parameter_file)], 'options', 2, 1);
end

if options.simulation > 2 || options.simulation < 0
    fprintf('\n simulation option should be between 0 and 2 \r');
    return
end

%% 3. file names
% the current stemmus-scope does not support useXLSX=0
if useXLSX == 0
    run([path_input parameter_file{2}]);
else
    [dummy, X] = xlsread([path_input char(parameter_file)], 'filenames');
    j = find(~strcmp(X(:, 2), {''}));
    X = X(j, 1:end);
end

F = struct('FileID', {'Simulation_Name', 'soil_file', 'leaf_file', 'atmos_file'...
                      'Dataset_dir', 't_file', 'year_file', 'Rin_file', 'Rli_file' ...
                      , 'p_file', 'Ta_file', 'ea_file', 'u_file', 'CO2_file', 'z_file', 'tts_file' ...
                      , 'LAI_file', 'hc_file', 'SMC_file', 'Vcmax_file', 'Cab_file', 'LIDF_file'});
for i = 1:length(F)
    k = find(strcmp(F(i).FileID, strtok(X(:, 1))));
    if ~isempty(k)
        F(i).FileName = strtok(X(k, 2));
    end
end

%% 4. input data
% the current stemmus-scope does not support useXLSX=0
if useXLSX == 0
    X                           = textread([path_input parameter_file{3}], '%s'); %%ok<DTXTRD>
    N                           = str2double(X);
else
    [N, X]                       = xlsread([path_input char(parameter_file)], 'inputdata', '');
    X                           = X(9:end, 1);
end

% Create a structure holding Scope parameters
[ScopeParameters, options] = parameters.loadParameters(options, useXLSX, X, F, N);

% Define the location information
ScopeParameters.LAT = SiteProperties.latitude; % latitude
ScopeParameters.LON = SiteProperties.longitude; % longitude
ScopeParameters.BSMlat = SiteProperties.latitude; % latitude of BSM model
ScopeParameters.BSMlon = SiteProperties.longitude; % longitude of BSM model
ScopeParameters.z =  SiteProperties.reference_height;   % reference height
ScopeParameters.hc =  SiteProperties.canopy_height;  % canopy height
ScopeParameters.Tyear = mean(Ta_msr); % calculate mean air temperature; Ta_msr is defined in Constant.m

% calculate the time zone based on longitude
ScopeParameters.timezn = helpers.calculateTimeZone(SiteProperties.longitude);

% Input T parameters for different vegetation type
[ScopeParameters] = parameters.setTempParameters(ScopeParameters, SiteProperties.sitename, SiteProperties.IGBP_veg_long);

%% 5. Declare paths
path_input      = InputPath;          % path of all inputs
path_output     = OutputPath;
%% 6. Numerical parameters (iteration stops etc)
iter.maxit           = 100;                          %                   maximum number of iterations
iter.maxEBer         = 5;                            % [W m-2]            maximum accepted error in energy bal.
iter.Wc              = 1;                         %                   Weight coefficient for iterative calculation of Tc

%% 7. Load spectral data for leaf and soil
load([path_input, 'fluspect_parameters/', char(F(3).FileName)]);
rsfile      = load([path_input, 'soil_spectrum/', char(F(2).FileName)]);        % file with soil reflectance spectra

%% 8. Load directional data from a file
directional = struct;
if options.calc_directional
    anglesfile          = load([path_input, 'directional/brdf_angles2.dat']); %     Multiple observation angles in case of BRDF calculation
    directional.tto     = anglesfile(:, 1);              % [deg]             Observation zenith Angles for calcbrdf
    directional.psi     = anglesfile(:, 2);              % [deg]             Observation zenith Angles for calcbrdf
    directional.noa     = length(directional.tto);      %                   Number of Observation Angles
end

%% 9. Define canopy structure
canopy.nlayers  = 30;
nl              = canopy.nlayers;
canopy.x        = (-1 / nl:-1 / nl:-1)';         % a column vector
canopy.xl       = [0; canopy.x];                 % add top level
canopy.nlincl   = 13;
canopy.nlazi    = 36;
canopy.litab    = [5:10:75 81:2:89]';   % a column, never change the angles unless 'ladgen' is also adapted
canopy.lazitab  = (5:10:355);           % a row

%% 10. Define spectral regions
[spectral] = io.define_bands();

wlS  = spectral.wlS;    % SCOPE 1.40 definition
wlP  = spectral.wlP;    % PROSPECT (fluspect) range
wlT  = spectral.wlT;    % Thermal range
wlF  = spectral.wlF;    % Fluorescence range

I01  = find(wlS < min(wlF));   % zero-fill ranges for fluorescence
I02  = find(wlS > max(wlF));
N01  = length(I01);
N02  = length(I02);

nwlP = length(wlP);
nwlT = length(wlT);

nwlS = length(wlS);

spectral.IwlP = 1:nwlP;
spectral.IwlT = nwlP + 1:nwlP + nwlT;
spectral.IwlF = (640:850) - 399;

[rho, tau, rs] = deal(zeros(nwlP + nwlT, 1));

%% 11. load time series data
ScopeParametersNames = fieldnames(ScopeParameters);
if options.simulation == 1
    vi = ones(length(ScopeParametersNames), 1);
    [soil, leafbio, canopy, meteo, angles, xyt]  = io.select_input(ScopeParameters, vi, canopy, options);
    [ScopeParameters, xyt, canopy]  = io.loadTimeSeries(ScopeParameters, leafbio, soil, canopy, meteo, Constants, F, xyt, path_input, options);
else
    soil = struct;
end

%% 12. preparations
if options.simulation == 1
    diff_tmin           =   abs(xyt.t - xyt.startDOY);
    diff_tmax           =   abs(xyt.t - xyt.endDOY);
    I_tmin              =   find(min(diff_tmin) == diff_tmin);
    I_tmax              =   find(min(diff_tmax) == diff_tmax);
    if options.soil_heat_method < 2
        meteo.Ta = Ta_msr(1);
        soil.Tsold = meteo.Ta * ones(12, 2);
    end
end
ScopeParametersNames = fieldnames(ScopeParameters);
nvars = length(ScopeParametersNames);
vmax = ones(nvars, 1);
for i = 1:nvars
    name = ScopeParametersNames{i};
    vmax(i) = length(ScopeParameters.(name));
end
vmax([14, 27], 1) = 1; % these are Tparam and LIDFb
vi      = ones(nvars, 1);
switch options.simulation
    case 0
        telmax = max(vmax);
        [xyt.t, xyt.year] = deal(zeros(telmax, 1));
    case 1
        telmax = size(xyt.t, 1);
    case 2
        telmax  = prod(double(vmax));
        [xyt.t, xyt.year] = deal(zeros(telmax, 1));
end
[rad, thermal, fluxes] = io.initialize_output_structures(spectral);
atmfile     = [path_input 'radiationdata/' char(F(4).FileName(1))];
atmo.M      = helpers.aggreg(atmfile, spectral.SCOPEspec);

%% 13. create output files and
%% Initialize Temperature, Matric potential and soil air pressure.
[Output_dir, fnames] = io.create_output_files_binary(parameter_file, sitename, path_of_code, path_input, path_output, spectral, options);

% these extra vars are set in script Constants.m
% used in init.applySoilHeteroEffect in StartInit.m
global Tot_Depth BtmX BtmT J Eqlspace
global InitX0 InitX1 InitX2 InitX3 InitX4 InitX5 InitX6
global InitND1 InitND2 InitND3 InitND4 InitND5 InitND6
global InitT0 InitT1 InitT2 InitT3 InitT4 InitT5 InitT6

SoilConstants.SWCC = SWCC;
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
SoilConstants.g = g;
SoilConstants.Eqlspace = Eqlspace;
SoilConstants.ThermCond = ThermCond;

SoilConstants.InitialValues.initX = [InitX0, InitX1, InitX2, InitX3, InitX4, InitX5, InitX6];
SoilConstants.InitialValues.initND = [InitND1, InitND2, InitND3, InitND4, InitND5, InitND6];
SoilConstants.InitialValues.initT = [InitT0, InitT1, InitT2, InitT3, InitT4, InitT5, InitT6];

% these are defined in script Constants.m
% these are used in SOIL2 inside StartInit.m
SoilConstants.Theta_L = Theta_L;
SoilConstants.Theta_LL = Theta_LL;
SoilConstants.Theta_V = Theta_V;
SoilConstants.Theta_g = Theta_g;
SoilConstants.Se = Se;
SoilConstants.KL_h = KL_h;
SoilConstants.DTheta_LLh = DTheta_LLh;
SoilConstants.KfL_T = KfL_T;
SoilConstants.Theta_II = Theta_II;
SoilConstants.Theta_I = Theta_I;
SoilConstants.Theta_UU = Theta_UU;
SoilConstants.Theta_U = Theta_U;
SoilConstants.T0 = T0;
SoilConstants.TT_CRIT = TT_CRIT;
SoilConstants.KfL_h = KfL_h;
SoilConstants.DTheta_UUh = DTheta_UUh;
SoilConstants.hThmrl = hThmrl;
SoilConstants.Tr = Tr;
SoilConstants.Hystrs = Hystrs;
SoilConstants.KIT = KIT;
SoilConstants.RHOI = RHOI;
SoilConstants.RHOL = RHOL;

% this is defined in Constants.m, see issue 96!
% used in init.setBoundaryCondition
SoilConstants.Ta_msr = Ta_msr;

[SoilConstants, SoilVariables, VanGenuchten, ThermalConductivity] = StartInit(SoilConstants, SoilProperties, SiteProperties);

%% get variables that are defined global and are used by other scripts
global hm hd hh_frez XWRE POR IH IS XK XWILT KLT_Switch DVT_Switch KaT_Switch
global ISFT Imped XSOC Lamda Phi_s XCAP Gama_hh Gama_h SAVEhh COR CORh
global Theta_s Theta_r Theta_f m n Alpha
global HCAP SF TCA GA1 GA2 GB1 GB2 HCD ZETA0 CON0 PS1 PS2 FEHCAP
global TCON_dry TPS1 TPS2 TCON0 TCON_s RHO_bulk XOLD

hm = SoilConstants.hm;
hd = SoilConstants.hd;
hh_frez = SoilVariables.hh_frez;
XWRE = SoilVariables.XWRE;
POR = SoilVariables.POR;
IH = SoilVariables.IH;
IS = SoilVariables.IS;
XK = SoilVariables.XK;
XWILT = SoilVariables.XWILT;
KLT_Switch = SoilVariables.KLT_Switch;
DVT_Switch = SoilVariables.DVT_Switch;
KaT_Switch = SoilVariables.KaT_Switch;
ISFT = SoilVariables.ISFT;
Imped = SoilVariables.Imped;
XSOC = SoilVariables.XSOC;
Lamda = SoilVariables.Lamda;
Phi_s = SoilVariables.Phi_s;
XCAP = SoilVariables.XCAP;
Gama_hh = SoilVariables.Gama_hh;
Gama_h = SoilVariables.Gama_h;
SAVEhh = SoilVariables.SAVEhh;
COR = SoilVariables.COR;
CORh = SoilVariables.CORh;
Theta_s = VanGenuchten.Theta_s;
Theta_r = VanGenuchten.Theta_r;
Theta_f = VanGenuchten.Theta_f;
Alpha = VanGenuchten.Alpha;
n = VanGenuchten.n;
m = VanGenuchten.m;
HCAP = ThermalConductivity.HCAP;
SF = ThermalConductivity.SF;
TCA = ThermalConductivity.TCA;
GA1 = ThermalConductivity.GA1;
GA2 = ThermalConductivity.GA2;
GB1 = ThermalConductivity.GB1;
GB2 = ThermalConductivity.GB2;
HCD = ThermalConductivity.HCD;
ZETA0 = ThermalConductivity.ZETA0;
CON0 = ThermalConductivity.CON0;
PS1 = ThermalConductivity.PS1;
PS2 = ThermalConductivity.PS2;
TCON_s = ThermalConductivity.TCON_s;
TCON_dry = ThermalConductivity.TCON_dry;
RHo_bulk = ThermalConductivity.RHo_bulk;
TPS1 = ThermalConductivity.TPS1;
TPS2 = ThermalConductivity.TPS2;
FEHCAP = ThermalConductivity.FEHCAP;
TCON0 = ThermalConductivity.TCON0;
XOLD = SoilVariables.XOLD; % used in SOIL1

%% these vars are defined as global at the begining of this script
%% because they are both input and output of StartInit
KfL_T = SoilConstants.KfL_T;
Theta_II = SoilConstants.Theta_II;
Theta_I = SoilConstants.Theta_I;
Theta_UU = SoilConstants.Theta_UU;
Theta_U = SoilConstants.Theta_U;
T = SoilVariables.T;
h = SoilVariables.h;
TT = SoilVariables.TT;
hh = SoilVariables.hh;
Ks = SoilVariables.Ks;
h_frez = SoilVariables.h_frez;
Theta_L = SoilVariables.Theta_L;
Theta_LL = SoilVariables.Theta_LL;
SWCC = SoilConstants.SWCC;
Theta_V = SoilVariables.Theta_V;
Theta_g = SoilVariables.Theta_g;
Se = SoilVariables.Se;
KL_h = SoilVariables.KL_h;
DTheta_LLh = SoilVariables.DTheta_LLh;
KfL_h = SoilVariables.KfL_h;
DTheta_UUh = SoilVariables.DTheta_UUh;

%% The boundary condition information settings
BoundaryCondition = init.setBoundaryCondition(SoilVariables, SoilConstants, IGBP_veg_long);

%% get global vars
global NBCh NBCT NBChB NBCTB BCh DSTOR DSTOR0 RS NBChh DSTMAX IRPT1 IRPT2
global NBCP BChB BCTB BCPB BCT BCP BtmPg

NBCh = BoundaryCondition.NBCh;
NBCT = BoundaryCondition.NBCT;
NBChB = BoundaryCondition.NBChB;
NBCTB = BoundaryCondition.NBCTB;
BCh = BoundaryCondition.BCh;
DSTOR = BoundaryCondition.DSTOR;
DSTOR0 = BoundaryCondition.DSTOR0;
RS = BoundaryCondition.RS;
NBChh = BoundaryCondition.NBChh;
DSTMAX = BoundaryCondition.DSTMAX;
IRPT1 = BoundaryCondition.IRPT1;
IRPT2 = BoundaryCondition.IRPT2;
NBCP = BoundaryCondition.NBCP;
BChB = BoundaryCondition.BChB;
BCTB = BoundaryCondition.BCTB;
BCPB = BoundaryCondition.BCPB;
BCT = BoundaryCondition.BCT;
BCP = BoundaryCondition.BCP;
BtmPg = BoundaryCondition.BtmPg;

%% 14. Run the model
disp('The calculations start now');
calculate = 1;
TIMEOLD = 0;
SAVEhh_frez = zeros(NN + 1, 1);
FCHK = zeros(1, NN);
KCHK = zeros(1, NN);
hCHK = zeros(1, NN);
TIMELAST = 0;
SAVEtS = tS;
kk = 0;   % DELT=Delt_t;
for i = 1:1:Dur_tot
    KT = KT + 1;                         % Counting Number of timesteps
    if KT > 1 && Delt_t > (TEND - TIME)
        Delt_t = TEND - TIME;           % If Delt_t is changed due to excessive change of state variables, the judgement of the last time step is excuted.
    end
    TIME = TIME + Delt_t;               % The time elapsed since start of simulation
    TimeStep(KT, 1) = Delt_t;
    SUMTIME(KT, 1) = TIME;
    Processing = TIME / TEND;
    NoTime(KT) = fix(SUMTIME(KT) / DELT);
    if NoTime(KT) == 0
        k = 1;
    else
        k = NoTime(KT);
    end
    %%%%% Updating the state variables. %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    L_f = 0; % latent heat of freezing fusion J Kg-1
    T0 = 273.15;
    TT_CRIT(NN) = T0; % unit K
    if IRPT1 == 0 && IRPT2 == 0 && ISFT == 0
        for MN = 1:NN
            hOLD_frez(MN) = h_frez(MN);
            h_frez(MN) = hh_frez(MN);
            % hhh_frez(MN,KT)=hh_frez(MN);
            TOLD_CRIT(MN) = T_CRIT(MN);
            T_CRIT(MN) = TT_CRIT(MN);
            % TTT_CRIT(MN,KT)=TT_CRIT(MN);

            hOLD(MN) = h(MN);
            h(MN) = hh(MN);
            % hhh(MN,KT)=hh(MN);
            % KfL_hh(MN,KT)=KfL_h(MN,2);
            % KL_hh(MN,KT)=KL_h(MN,2);
            % Chhh(MN,KT)=Chh(MN,2);
            % ChTT(MN,KT)=ChT(MN,2);
            % Khhh(MN,KT)=Khh(MN,2);
            % KhTT(MN,KT)=KhT(MN,2);
            % CTTT(MN,KT)=CTT(MN,2);
            % EPCTT(MN,KT)=EPCT(MN);
            % C_unsat(MN,KT)=c_unsat(MN,2);
            % CCTT_PH(MN,KT)=CTT_PH(MN,2);
            % CCTT_Lg(MN,KT)=CTT_Lg(MN,2);
            % CCTT_g(MN,KT)=CTT_g(MN,2);
            % CCTT_LT(MN,KT)=CTT_LT(MN,2);
            % Lambda_Eff(MN,KT)=Lambda_eff(MN,2);
            % EfTCON(MN,KT)=EfTCON(MN,2);
            % TTETCON(MN,KT)=TETCON(MN,2);
            DDhDZ(MN, KT) = DhDZ(MN);
            % DDTDZ(MN,KT)=DTDZ(MN);
            % DDRHOVZ(MN,KT)=DRHOVZ(MN);
            % TKCHK(MN,KT)=KCHK(MN);
            if Thmrlefc == 1
                TOLD(MN) = T(MN);
                T(MN) = TT(MN);
                TTT(MN, KT) = TT(MN);
            end
            if Soilairefc == 1
                P_gOLD(MN) = P_g(MN);
                P_g(MN) = P_gg(MN);
                % P_ggg(MN,KT)=P_gg(MN);
            end
            if rwuef == 1
                SRT(MN, KT) = Srt(MN, 1);
                % ALPHA(MN,KT)=alpha_h(MN,1);
                % BX(MN,KT)=bx(MN,1);
            end
        end
        if options.simulation == 1
            vi(vmax > 1) = k;
        end
        if options.simulation == 0
            vi(vmax == telmax) = k;
        end
        [soil, leafbio, canopy, meteo, angles, xyt] = io.select_input(ScopeParameters, vi, canopy, options, xyt, soil);
        if options.simulation ~= 1
            fprintf('simulation %i ', k);
            fprintf('of %i \n', telmax);
        else
            calculate = 1;
        end

        if calculate

            iter.counter = 0;

            LIDF_file            = char(F(22).FileName);
            if  ~isempty(LIDF_file)
                canopy.lidf     = dlmread([path_input, 'leafangles/', LIDF_file], '', 3, 0);
            else
                canopy.lidf     = equations.leafangles(canopy.LIDFa, canopy.LIDFb);    % This is 'ladgen' in the original SAIL model,
            end

            leafbio.emis        = 1 - leafbio.rho_thermal - leafbio.tau_thermal;

            if options.calc_PSI
                fversion = @fluspect_B_CX;
            else
                fversion = @fluspect_B_CX_PSI_PSII_combined;
            end
            leafbio.V2Z = 0;
            leafopt  = fversion(spectral, leafbio, optipar);
            leafbio.V2Z = 1;
            leafoptZ = fversion(spectral, leafbio, optipar);

            IwlP     = spectral.IwlP;
            IwlT     = spectral.IwlT;

            rho(IwlP)  = leafopt.refl;
            tau(IwlP)  = leafopt.tran;
            rlast    = rho(nwlP);
            tlast    = tau(nwlP);

            if options.soilspectrum == 0
                rs(IwlP) = rsfile(:, soil.spectrum + 1);
            else
                soilemp.SMC   = 25;        % empirical parameter (fixed)
                soilemp.film  = 0.015;     % empirical parameter (fixed)
                rs(IwlP) = BSM(soil, optipar, soilemp);
            end
            rslast   = rs(nwlP);

            switch options.rt_thermal
                case 0
                    rho(IwlT) = ones(nwlT, 1) * leafbio.rho_thermal;
                    tau(IwlT) = ones(nwlT, 1) * leafbio.tau_thermal;
                    rs(IwlT)  = ones(nwlT, 1) * soil.rs_thermal;
                case 1
                    rho(IwlT) = ones(nwlT, 1) * rlast;
                    tau(IwlT) = ones(nwlT, 1) * tlast;
                    rs(IwlT)  = ones(nwlT, 1) * rslast;
            end
            leafopt.refl = rho;     % extended wavelength ranges are stored in structures
            leafopt.tran = tau;

            reflZ = leafopt.refl;
            tranZ = leafopt.tran;
            reflZ(1:300) = leafoptZ.refl(1:300);
            tranZ(1:300) = leafoptZ.tran(1:300);
            leafopt.reflZ = reflZ;
            leafopt.tranZ = tranZ;

            soil.refl    = rs;

            soil.Ts     = meteo.Ta * ones(2, 1);       % initial soil surface temperature

            if length(F(4).FileName) > 1 && options.simulation == 0
                atmfile     = [path_input 'radiationdata/' char(F(4).FileName(k))];
                atmo.M      = helpers.aggreg(atmfile, spectral.SCOPEspec);
            end
            atmo.Ta     = meteo.Ta;

            [rad, gap, profiles]   = RTMo(spectral, atmo, soil, leafopt, canopy, angles, meteo, rad, options);

            switch options.calc_ebal
                case 1
                    [iter, fluxes, rad, thermal, profiles, soil, RWU, frac]                          ...
                        = ebal(iter, options, spectral, rad, gap,                       ...
                               leafopt, angles, meteo, soil, canopy, leafbio, xyt, k, profiles, Delt_t);
                    if options.calc_fluor
                        if options.calc_vert_profiles
                            [rad, profiles] = RTMf(spectral, rad, soil, leafopt, canopy, gap, angles, profiles);
                        else
                            [rad] = RTMf(spectral, rad, soil, leafopt, canopy, gap, angles, profiles);
                        end
                    end
                    if options.calc_xanthophyllabs
                        [rad] = RTMz(spectral, rad, soil, leafopt, canopy, gap, angles, profiles);
                    end

                    if options.calc_planck
                        rad         = RTMt_planck(spectral, rad, soil, leafopt, canopy, gap, angles, thermal.Tcu, thermal.Tch, thermal.Ts(2), thermal.Ts(1), 1);
                    end

                    if options.calc_directional
                        directional = calc_brdf(options, directional, spectral, angles, rad, atmo, soil, leafopt, canopy, meteo, profiles, thermal);
                    end

                otherwise
                    Fc              = (1 - gap.Ps(1:end - 1))' / nl;      %           Matrix containing values for Ps of canopy
                    fluxes.aPAR     = canopy.LAI * (Fc * rad.Pnh        + equations.meanleaf(canopy, rad.Pnu, 'angles_and_layers', gap.Ps)); % net PAR leaves
                    fluxes.aPAR_Cab = canopy.LAI * (Fc * rad.Pnh_Cab    + equations.meanleaf(canopy, rad.Pnu_Cab, 'angles_and_layers', gap.Ps)); % net PAR leaves
                    [fluxes.aPAR_Wm2, fluxes.aPAR_Cab_eta] = deal(canopy.LAI * (Fc * rad.Rnh_PAR    + equations.meanleaf(canopy, rad.Rnu_PAR, 'angles_and_layers', gap.Ps))); % net PAR leaves
                    if options.calc_fluor
                        profiles.etah = ones(nl, 1);
                        profiles.etau = ones(13, 36, nl);
                        if options.calc_vert_profiles
                            [rad, profiles] = RTMf(spectral, rad, soil, leafopt, canopy, gap, angles, profiles);
                        else
                            [rad] = RTMf(spectral, rad, soil, leafopt, canopy, gap, angles, profiles);
                        end
                    end
            end
            if options.calc_fluor % total emitted fluorescence irradiance (excluding leaf and canopy re-absorption and scattering)
                if options.calc_PSI
                    rad.Femtot = 1E3 * (leafbio.fqe(2) * optipar.phiII(spectral.IwlF) * fluxes.aPAR_Cab_eta + leafbio.fqe(1) * optipar.phiI(spectral.IwlF)  * fluxes.aPAR_Cab);
                else
                    rad.Femtot = 1E3 * leafbio.fqe * optipar.phi(spectral.IwlF) * fluxes.aPAR_Cab_eta;
                end
            end
        end
        if options.simulation == 2 && telmax > 1
            vi  = helpers.count(nvars, vi, vmax, 1);
        end
        if KT == 1
            if isreal(fluxes.Actot) && isreal(thermal.Tsave) && isreal(fluxes.lEstot) && isreal(fluxes.lEctot)
                Acc = fluxes.Actot;
                lEstot = fluxes.lEstot;
                lEctot = fluxes.lEctot;
                Tss = thermal.Tsave;
            else
                Acc = 0;
                lEstot = 0;
                lEctot = 0;
                Tss = Ta_msr(KT);
            end
        elseif NoTime(KT) > NoTime(KT - 1)
            if isreal(fluxes.Actot) && isreal(thermal.Tsave) && isreal(fluxes.lEstot) && isreal(fluxes.lEctot)
                Acc = fluxes.Actot;
                lEstot = fluxes.lEstot;
                lEctot = fluxes.lEctot;
                Tss = thermal.Tsave;
            else
                Acc = 0;
                lEstot = 0;
                lEctot = 0;
                Tss = Ta_msr(KT);
            end
        end

        sfactortot(KT) = sfactor;
        DSTOR0 = DSTOR;

        if KT > 1
            run SOIL1;
        end

        for ML = 1:NL
            % QVV(ML,KT)=QV(ML);
            % QLL(ML,KT)=QL(ML,1);
            % DDEhBAR(ML,KT)=DEhBAR(ML);
            % DDRHOVhDz(ML,KT)=DRHOVhDz(ML);
            DDhDZ(ML, KT) = DhDZ(ML);
            % EEtaBAR(ML,KT)=EtaBAR(ML);
            % DD_Vg(ML,KT)=D_Vg(ML);
            % DDRHOVTDz(ML,KT)=DRHOVTDz(ML);
            % DDTDZ(ML,KT)=DTDZ(ML);
            % DDPgDZ(ML,KT)=DPgDZ(ML);
            % KKLhBAR(ML,KT)=KLhBAR(ML);
            % KKLTBAR(ML,KT)=KLTBAR(ML);
            % DDTDBAR(ML,KT)=DTDBAR(ML);
            % QVAA(ML,KT)=QVa(ML);
            % QAA(ML,KT)=Qa(ML);
            if ~Soilairefc
                % QLHH(ML,KT)=QLH(ML);
                % QLTT(ML,KT)=QLT(ML);
            else
                % QLHH(ML,KT)=QL_h(ML);
                % QLTT(ML,KT)=QL_T(ML);
                % QLAA(ML,KT)=QL_a(ML);
            end
            % DVHH(ML,KT)=DVH(ML);
            % DVTT(ML,KT)=DVT(ML);
            % SSe(ML,KT)=Se(ML,1);
            % SSa(ML,KT)=Sa(ML,1);
            % DSAVEDTheta_LLh(ML,KT)=SAVEDTheta_LLh(ML,1);
            % DSAVEDTheta_LLT(ML,KT)=SAVEDTheta_LLT(ML,1);
            % DSAVEDTheta_UUh(ML,KT)=SAVEDTheta_UUh(ML,1);

            % QVHH(ML,KT)=QVH(ML);
            % QVTT(ML,KT)=QVT(ML);
            % DDTheta_LLh(ML,KT)=DTheta_LLh(ML,1);
            % CChh(ML,KT)=Chh(ML,1);
            % kk_g(ML,KT)=k_g(ML,1);
            % VV_A(ML,KT)=V_A(ML);
        end
    end
    if Delt_t ~= Delt_t0
        for MN = 1:NN
            hh(MN) = h(MN) + (h(MN) - hOLD(MN)) * Delt_t / Delt_t0;
            TT(MN) = T(MN) + (T(MN) - TOLD(MN)) * Delt_t / Delt_t0;
        end
    end
    hSAVE = hh(NN);
    TSAVE = TT(NN);
    if NBCh == 1
        hN = BCh;
        hh(NN) = hN;
        hSAVE = hN;
    elseif NBCh == 2
        if NBChh ~= 2
            if BCh < 0
                hN = DSTOR0;
                hh(NN) = hN;
                hSAVE = hN;
            else
                hN = -1e6;
                hh(NN) = hN;
                hSAVE = hN;
            end
        end
    else
        if NBChh ~= 2
            hN = DSTOR0;
            hh(NN) = hN;
            hSAVE = hN;
        end
    end
    run Forcing_PARM;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for KIT = 1:NIT   % Start the iteration procedure in a time step.
        [TT_CRIT, hh_frez] = HT_frez(hh, T0, g, L_f, TT, NN, hd, Tmin);
        [hh, COR, CORh, Theta_V, Theta_g, Se, KL_h, Theta_LL, DTheta_LLh, KfL_h, KfL_T, hh_frez, Theta_UU, DTheta_UUh, Theta_II] = SOIL2(SoilConstants, SoilVariables, hh, COR, hThmrl, NN, NL, TT, Tr, Hystrs, XWRE, Theta_s, IH, KIT, Theta_r, Alpha, n, m, Ks, Theta_L, h, Thmrlefc, POR, Theta_II, CORh, hh_frez, h_frez, SWCC, Theta_U, XCAP, Phi_s, RHOI, RHOL, Lamda, Imped, L_f, g, T0, TT_CRIT, KfL_h, KfL_T, KL_h, Theta_UU, Theta_LL, DTheta_LLh, DTheta_UUh, Se);
        [KL_T] = CondL_T(NL);
        [RHOV, DRHOVh, DRHOVT] = Density_V(TT, hh, g, Rv, NN);
        [W, WW, MU_W, D_Ta] = CondL_Tdisp(Constants, POR, Theta_LL, Theta_L, SSUR, RHOL, TT, Theta_s, h, hh, W_Chg, NL, nD, Delt_t, Theta_g, KLT_Switch);
        [L] = Latent(TT, NN);
        [Xaa, XaT, Xah, DRHODAt, DRHODAz, RHODA] = Density_DA(T, RDA, P_g, Rv, DeltZ, h, hh, TT, P_gg, Delt_t, NL, NN, DRHOVT, DRHOVh, RHOV);
        [c_unsat, Lambda_eff, ZETA, ETCON, EHCAP, TETCON, EfTCON] = CondT_coeff(Theta_LL, Lambda1, Lambda2, Lambda3, RHO_bulk, Theta_g, RHODA, RHOV, c_a, c_V, c_L, NL, nD, ThmrlCondCap, ThermCond, HCAP, SF, TCA, GA1, GA2, GB1, GB2, HCD, ZETA0, CON0, PS1, PS2, XWILT, XK, TT, POR, DRHOVT, L, D_A, Theta_V, Theta_II, TCON_dry, Theta_s, XSOC, TPS1, TPS2, TCON0, TCON_s, FEHCAP, RHOI, RHOL, c_unsat, Lambda_eff, ETCON, EHCAP, TETCON, EfTCON, ZETA);
        [k_g] = Condg_k_g(POR, NL, m, Theta_g, g, MU_W, Ks, RHOL, SWCC, Imped, Ratio_ice, Soilairefc, MN);
        [D_V, Eta, D_A] = CondV_DE(Theta_LL, TT, fc, Theta_s, NL, nD, Theta_g, POR, ThmrlCondCap, ZETA, XK, DVT_Switch, Theta_UU);
        [D_Vg, V_A, Beta_g, DPgDZ, Beta_gBAR, Alpha_LgBAR] = CondV_DVg(P_gg, Theta_g, Sa, V_A, k_g, MU_a, DeltZ, Alpha_Lg, KaT_Switch, Theta_s, Se, NL, DPgDZ, Beta_gBAR, Alpha_LgBAR, Beta_g);
        run h_sub;
        if NBCh == 1
            DSTOR = 0;
            RS = 0;
        elseif NBCh == 2
            AVAIL = -BCh;
            EXCESS = (AVAIL + QMT(KT)) * Delt_t;
            if abs(EXCESS / Delt_t) <= 1e-10
                EXCESS = 0;
            end
            DSTOR = min(EXCESS, DSTMAX);
            RS = (EXCESS - DSTOR) / Delt_t;
        else
            AVAIL = AVAIL0 - Evap(KT);
            EXCESS = (AVAIL + QMT(KT)) * Delt_t;
            if abs(EXCESS / Delt_t) <= 1e-10
                EXCESS = 0;
            end
            DSTOR = min(EXCESS, DSTMAX);
            RS(KT) = (EXCESS - DSTOR) / Delt_t;
        end

        if Soilairefc == 1
            run Air_sub;
        end

        if Thmrlefc == 1
            run Enrgy_sub;
        end

        if max(CHK) < 0.1 % && max(FCHK)<0.001 %&& max(hCHK)<0.001 %&& min(KCHK)>0.001
            break
        end
        hSAVE = hh(NN);
        TSAVE = TT(NN);
    end
    TIMEOLD = KT;
    KIT;
    KIT = 0;
    [TT_CRIT, hh_frez] = HT_frez(hh, T0, g, L_f, TT, NN, hd, Tmin);
    [hh, COR, CORh, Theta_V, Theta_g, Se, KL_h, Theta_LL, DTheta_LLh, KfL_h, KfL_T, hh_frez, Theta_UU, DTheta_UUh, Theta_II] = SOIL2(SoilConstants, SoilVariables, hh, COR, hThmrl, NN, NL, TT, Tr, Hystrs, XWRE, Theta_s, IH, KIT, Theta_r, Alpha, n, m, Ks, Theta_L, h, Thmrlefc, POR, Theta_II, CORh, hh_frez, h_frez, SWCC, Theta_U, XCAP, Phi_s, RHOI, RHOL, Lamda, Imped, L_f, g, T0, TT_CRIT, KfL_h, KfL_T, KL_h, Theta_UU, Theta_LL, DTheta_LLh, DTheta_UUh, Se);

    SAVEtS = tS;
    if IRPT1 == 0 && IRPT2 == 0
        if KT        % In case last time step is not convergent and needs to be repeated.
            MN = 0;
            for ML = 1:NL
                for ND = 1:2
                    MN = ML + ND - 1;
                    Theta_LLL(ML, ND, KT) = Theta_LL(ML, ND);
                    Theta_L(ML, ND) = Theta_LL(ML, ND);
                    Theta_UUU(ML, ND, KT) = Theta_UU(ML, ND);
                    Theta_U(ML, ND) = Theta_UU(ML, ND);
                    Theta_III(ML, ND, KT) = Theta_II(ML, ND);
                    Theta_I(ML, ND) = Theta_II(ML, ND);
                    % DDTheta_LLh(ML,KT)=DTheta_LLh(ML,2);
                    % DDTheta_LLT(ML,KT)=DTheta_LLT(ML,2);
                    % DDTheta_UUh(ML,KT)=DTheta_UUh(ML,2);
                end
            end
            run ObservationPoints;
        end
        if (TEND - TIME) < 1E-3
            for MN = 1:NN
                hOLD(MN) = h(MN);
                h(MN) = hh(MN);
                % hhh(MN,KT)=hh(MN);
                % HRA(MN,KT)=HR(MN);
                if Thmrlefc == 1
                    TOLD(MN) = T(MN);
                    T(MN) = TT(MN);
                    TTT(MN, KT) = TT(MN);
                    TOLD_CRIT(MN) = T_CRIT(MN);
                    T_CRIT(MN) = TT_CRIT(MN);
                    % TTT_CRIT(MN,KT)=TT_CRIT(MN);
                    hOLD_frez(MN) = h_frez(MN);
                    h_frez(MN) = hh_frez(MN);
                    % hhh_frez(MN,KT)=hh_frez(MN);
                end
                if Soilairefc == 1
                    P_gOLD(MN) = P_g(MN);
                    P_g(MN) = P_gg(MN);
                    % P_ggg(MN,KT)=P_gg(MN);
                end
            end
            % break
        end
    end
    if KT > 0
        for MN = 1:NN
            % QL(MN,KT)=QL(MN);
            % QL_HH(MN,KT)=QL_h(MN);
            % QL_TT(MN,KT)=QL_T(MN);
            % QV(MN,KT)=QV(MN);
            % SAVEhhh(MN,KT)=SAVEhh(MN);
        end
        % SAVEDSTOR(KT)=DSTOR;
    end
    kk = k;

    % Open files for writing
    file_ids = structfun(@(x) fopen(x, 'a'), fnames, 'UniformOutput', false);
    n_col = io.output_data_binary(file_ids, k, xyt, rad, canopy, ScopeParameters, vi, vmax, options, fluxes, meteo, iter, thermal, spectral, gap, profiles, Sim_Theta_U, Sim_Temp, Trap, Evap);
    fclose("all");
end

disp('The calculations end now');
if options.verify
    io.output_verification(Output_dir);
end

%% soil layer information
%% Ztot is defined as a global variable in Initial_root_biomass.m
%% TODO avoid global variables
SoilLayer.thickness = DeltZ_R;
SoilLayer.depth = Ztot';

io.bin_to_csv(fnames, n_col, k, options, SoilLayer);
save([Output_dir, 'output.mat']);
% if options.makeplots
%  plot.plots(Output_dir)
% end
