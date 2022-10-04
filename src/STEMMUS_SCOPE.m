 %% STEMMUS-SCOPE.m (script)

%     STEMMUS-SCOPE is a model for Integrated modeling of canopy photosynthesis, fluorescence, 
%     and the transfer of energy, mass, and momentum in the soil–plant–atmosphere continuum 
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
%%

%% 0. globals
run filesread %get paths and prepare input files
run Constants %input soil parameters
global i tS KT Delt_t TEND TIME MN NN NL ML ND hOLD TOLD h hh T TT P_gOLD P_g P_gg Delt_t0 g
global KIT NIT TimeStep Processing
global SUMTIME hhh TTT P_ggg Theta_LLL DSTOR Thmrlefc CHK Theta_LL Theta_L Theta_UUU Theta_UU Theta_U Theta_III Theta_II Theta_I
global NBCh AVAIL Evap DSTOR0 EXCESS QMT RS BCh hN hSAVE NBChh DSTMAX Soilairefc Trap sumTRAP_dir sumEVAP_dir
global TSAVE IRPT1 IRPT2 AVAIL0 TIMEOLD TIMELAST SRT ALPHA BX alpha_h bx Srt KfL_hh KL_hh Chhh ChTT Khhh KhTT CTTT CTT_PH CTT_LT CTT_g CTT_Lg CCTT_PH CCTT_LT CCTT_g CCTT_Lg C_unsat c_unsat
global QL QL_h QL_T QV Qa KL_h Chh ChT Khh KhT SAVEDSTOR TRAP_ind TRAP_dir SAVEhh SAVEhhh Resis_a KfL_h KfL_T TTT_CRIT TT_CRIT T_CRIT TOLD_CRIT
global h_frez hh_frez hhh_frez hOLD_frez ISFT L_f T0 CTT EPCT EPCTT DTheta_LLh DTheta_LLT DTheta_UUh CKT CKTT DDTheta_LLh DDTheta_LLT DDTheta_UUh Lambda_Eff Lambda_eff EfTCON TTETCON TETCON NBCTB Tbtms Cor_TIME DDhDZ DhDZ DDTDZ DTDZ DDRHOVZ DRHOVZ
global DDEhBAR DEhBAR DDRHOVhDz DRHOVhDz EEtaBAR EtaBAR DD_Vg D_Vg DDRHOVTDz DRHOVTDz KKLhBAR KLhBAR KKLTBAR KLTBAR DDTDBAR DTDBAR QVV QLL CChh SAVEDTheta_LLT SAVEDTheta_LLh SAVEDTheta_UUh DSAVEDTheta_LLT DSAVEDTheta_LLh DSAVEDTheta_UUh
global  QVT QVH QVTT QVHH SSa Sa HRA HR QVAA QVa QLH QLT QLHH QLTT DVH DVHH DVT DVTT SSe Se QAA QAa QL_TT QL_HH QLAA QL_a DPgDZ DDPgDZ k_g kk_g VV_A V_A Theta_r Theta_s m n Alpha SAVETheta_UU  Gama_hh Theta_a Gama_h hm hd
global SAVEKfL_h KCHK FCHK TKCHK hCHK TSAVEhh SAVEhh_frez Precip SAVETT INDICATOR thermal
global Theta_g MU_a DeltZ Alpha_Lg
global Beta_g KaT_Switch
global D_V D_A fc Eta nD POR  
global ThmrlCondCap ZETA XK DVT_Switch 
global MU_W Ks RHOL
global Lambda1 Lambda2 Lambda3 RHO_bulk
global RHODA RHOV c_a c_V c_L
global ETCON EHCAP
global Xaa XaT Xah RDA Rv KL_T
global DRHOVT DRHOVh DRHODAt DRHODAz
global hThmrl Tr COR IS Hystrs XWRE
global Theta_V IH CORh XCAP Phi_s RHOI Lamda
global W WW D_Ta SSUR
global W_Chg SWCC Imped Ratio_ice ThermCond Beta_gBAR Alpha_LgBAR 
global KLT_Switch xERR hERR TERR NBChB NBCT uERR
global L TCON_dry TPS1 TPS2 TCON0 XSOC TCON_s
global HCAP SF TCA GA1 GA2 GB1 GB2 HCD ZETA0 CON0 PS1 PS2 XWILT FEHCAP QMTT QMBB Evapo trap RnSOIL PrecipO
global constants
global RWU EVAP theta_s0 Ks0
global HR Precip Precipp Tss frac sfactortot sfactor fluxes lEstot lEctot NoTime DELT IGBP_veg_long latitude longitude reference_height canopy_height sitename Dur_tot Tmin fmax

%% 1. define constants
[constants] = io.define_constants();
[Rl] = Initial_root_biomass(RTB,DeltZ_R,rroot,ML);
%% 2. simulation options
path_input = InputPath;          % path of all inputs
path_of_code                = cd;
run set_parameter_filenames; 

if length(parameter_file)>1, useXLSX = 0; else useXLSX = 1; end

if ~useXLSX
    run([path_input parameter_file{1}])
    
    options.calc_ebal           = N(1);    % calculate the energy balance (default). If 0, then only SAIL is executed!
    options.calc_vert_profiles  = N(2);    % calculate vertical profiles of fluxes
    options.calc_fluor          = N(3);    % calculate chlorophyll fluorescence in observation direction
    options.calc_planck         = N(4);    % calculate spectrum of thermal radiation
    options.calc_directional    = N(5);    % calculate BRDF and directional temperature
    options.calc_xanthophyllabs = N(6);    % include simulation of reflectance dependence on de-epoxydation state
    options.calc_PSI            = N(7);    % 0: optipar 2017 file with only one fluorescence spectrum vs 1: Franck et al spectra for PSI and PSII
    options.rt_thermal          = N(8);    % 1: use given values under 10 (default). 2: use values from fluspect and soil at 2400 nm for the TIR range
    options.calc_zo             = N(9);
    options.soilspectrum        = N(10);    %0: use soil spectrum from a file, 1: simulate soil spectrum with the BSM model
    options.soil_heat_method    = N(11);    % 0: calculated from specific heat and conductivity (default), 1: empiricaly calibrated, 2: G as constant fraction of soil net radiation
    options.Fluorescence_model  = N(12);     %0: empirical, with sustained NPQ (fit to Flexas' data); 1: empirical, with sigmoid for Kn; 2: Magnani 2012 model
    options.calc_rss_rbs        = N(13);    % 0: calculated from specific heat and conductivity (default), 1: empiricaly calibrated, 2: G as constant fraction of soil net radiation
    options.apply_T_corr        = N(14);    % correct Vcmax and rate constants for temperature in biochemical.m
    options.verify              = N(15);
    options.save_headers        = N(16);    % write headers in output files
    options.makeplots           = N(17);
    options.simulation          = N(18);    % 0: individual runs (specify all input in a this file)
    % 1: time series (uses text files with meteo input as time series)
    % 2: Lookup-Table (specify the values to be included)
    % 3: Lookup-Table with random input (specify the ranges of values)
else
    options = io.readStructFromExcel([path_input char(parameter_file)], 'options', 3, 1);
end

if options.simulation>2 || options.simulation<0, fprintf('\n simulation option should be between 0 and 2 \r'); return, end

%% 3. file names
if ~useXLSX
    run([path_input parameter_file{2}])
else
    [dummy,X]                       = xlsread([path_input char(parameter_file)],'filenames');
    j = find(~strcmp(X(:,2),{''}));
    X = X(j,(1:end));
end

F = struct('FileID',{'Simulation_Name','soil_file','leaf_file','atmos_file'...
    'Dataset_dir','t_file','year_file','Rin_file','Rli_file'...
    ,'p_file','Ta_file','ea_file','u_file','CO2_file','z_file','tts_file'...
    ,'LAI_file','hc_file','SMC_file','Vcmax_file','Cab_file','LIDF_file'});
for i = 1:length(F)
    k = find(strcmp(F(i).FileID,strtok(X(:,1))));
    if ~isempty(k)
        F(i).FileName = strtok(X(k,2));
    end
end

%% 4. input data

if ~useXLSX
    X                           = textread([path_input parameter_file{3}],'%s'); %#ok<DTXTRD>
    N                           = str2double(X);
else
    [N,X]                       = xlsread([path_input char(parameter_file)],'inputdata', '');
    X                           = X(9:end,1);
end
ScopeParameters = io.assignvarnames();
[ScopeParameters,options] = load_parameters(ScopeParameters,options,useXLSX,X,F,N);

% Define the location information
ScopeParameters(48).Val=latitude; %latitude
ScopeParameters(49).Val=longitude; %longitude
ScopeParameters(62).Val=latitude; %latitude of BSM model
ScopeParameters(63).Val=longitude; %longitude of BSM model
ScopeParameters(29).Val=reference_height;   %reference height
ScopeParameters(23).Val=canopy_height;  %canopy height
ScopeParameters(55).Val=mean(Ta_msr); %calculate mean air temperature

% calculate the time zone based on longitude
[ScopeParameters] = calc_timezone(ScopeParameters,longitude);

%Input T parameters for different vegetation type
[ScopeParameters] = vege_type(ScopeParameters,sitename,IGBP_veg_long);

%% 5. Declare paths
path_input      = InputPath;          % path of all inputs
path_output     = OutputPath;
%% 6. Numerical parameters (iteration stops etc)
iter.maxit           = 100;                          %                   maximum number of iterations
iter.maxEBer         = 5;                            %[W m-2]            maximum accepted error in energy bal.
iter.Wc              = 1;                         %                   Weight coefficient for iterative calculation of Tc

%% 7. Load spectral data for leaf and soil
load([path_input,'fluspect_parameters/',char(F(3).FileName)]);
rsfile      = load([path_input,'soil_spectrum/',char(F(2).FileName)]);        % file with soil reflectance spectra

%% 8. Load directional data from a file
directional = struct;
if options.calc_directional
    anglesfile          = load([path_input,'directional/brdf_angles2.dat']); %     Multiple observation angles in case of BRDF calculation
    directional.tto     = anglesfile(:,1);              % [deg]             Observation zenith Angles for calcbrdf
    directional.psi     = anglesfile(:,2);              % [deg]             Observation zenith Angles for calcbrdf
    directional.noa     = length(directional.tto);      %                   Number of Observation Angles
end

%% 9. Define canopy structure
canopy.nlayers  = 30;
nl              = canopy.nlayers;
canopy.x        = (-1/nl : -1/nl : -1)';         % a column vector
canopy.xl       = [0; canopy.x];                 % add top level
canopy.nlincl   = 13;
canopy.nlazi    = 36;
canopy.litab    = [ 5:10:75 81:2:89 ]';   % a column, never change the angles unless 'ladgen' is also adapted
canopy.lazitab  = ( 5:10:355 );           % a row

%% 10. Define spectral regions
[spectral] = io.define_bands();

wlS  = spectral.wlS;    % SCOPE 1.40 definition
wlP  = spectral.wlP;    % PROSPECT (fluspect) range
wlT  = spectral.wlT;    % Thermal range
wlF  = spectral.wlF;    % Fluorescence range

I01  = find(wlS<min(wlF));   % zero-fill ranges for fluorescence
I02  = find(wlS>max(wlF));
N01  = length(I01);
N02  = length(I02);

nwlP = length(wlP);
nwlT = length(wlT);

nwlS = length(wlS);

spectral.IwlP = 1 : nwlP;
spectral.IwlT = nwlP+1 : nwlP+nwlT;
spectral.IwlF = (640:850)-399;

[rho,tau,rs] = deal(zeros(nwlP + nwlT,1));

%% 11. load time series data
if options.simulation == 1
    vi = ones(length(ScopeParameters),1);
    [soil,leafbio,canopy,meteo,angles,xyt]  = io.select_input(ScopeParameters,vi,canopy,options);
    [ScopeParameters,xyt,canopy]  = io.load_timeseries(ScopeParameters,leafbio,soil,canopy,meteo,constants,F,xyt,path_input,options);
else
    soil = struct;
end

%% 12. preparations
if options.simulation==1
    diff_tmin           =   abs(xyt.t-xyt.startDOY);
    diff_tmax           =   abs(xyt.t-xyt.endDOY);
    I_tmin              =   find(min(diff_tmin)==diff_tmin);
    I_tmax              =   find(min(diff_tmax)==diff_tmax);
    if options.soil_heat_method<2
        meteo.Ta = Ta_msr(1);
        soil.Tsold = meteo.Ta*ones(12,2);
    end
end

nvars = length(ScopeParameters);
vmax = ones(nvars,1);
for i = 1:nvars
    vmax(i) = length(ScopeParameters(i).Val);
end
vmax([14,27],1) = 1; % these are Tparam and LIDFb
vi      = ones(nvars,1);
switch options.simulation
    case 0, telmax = max(vmax);  [xyt.t,xyt.year]= deal(zeros(telmax,1));
    case 1, telmax = size(xyt.t,1);
    case 2, telmax  = prod(double(vmax)); [xyt.t,xyt.year]= deal(zeros(telmax,1));
end
[rad,thermal,fluxes] = io.initialize_output_structures(spectral);
atmfile     = [path_input 'radiationdata/' char(F(4).FileName(1))];
atmo.M      = helpers.aggreg(atmfile,spectral.SCOPEspec);

%% 13. create output files
[Output_dir, f, fnames] = io.create_output_files_binary(parameter_file, sitename, path_of_code, path_input, path_output, spectral, options);
run StartInit;   % Initialize Temperature, Matric potential and soil air pressure.


%% 14. Run the model
fprintf('\n The calculations start now \r')
calculate = 1;
TIMEOLD=0;SAVEhh_frez=zeros(NN+1,1);FCHK=zeros(1,NN);KCHK=zeros(1,NN);hCHK=zeros(1,NN);
TIMELAST=0;
SAVEtS=tS; kk=0;   %DELT=Delt_t; 
for i = 1:1:Dur_tot
    KT=KT+1;                         % Counting Number of timesteps
    if KT>1 && Delt_t>(TEND-TIME)
        Delt_t=TEND-TIME;           % If Delt_t is changed due to excessive change of state variables, the judgement of the last time step is excuted.
    end
    TIME=TIME+Delt_t;               % The time elapsed since start of simulation
    TimeStep(KT,1)=Delt_t;
    SUMTIME(KT,1)=TIME;
    Processing=TIME/TEND;
    NoTime(KT)=fix(SUMTIME(KT)/DELT);
    if NoTime(KT)==0
        k=1;
    else
    k=NoTime(KT);
    end
     %%%%% Updating the state variables. %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    L_f=0; %latent heat of freezing fusion J Kg-1
    T0=273.15; TT_CRIT(MN)=T0;% unit K
    if IRPT1==0 && IRPT2==0 && ISFT==0
         for MN=1:NN
            hOLD_frez(MN)=h_frez(MN);
            h_frez(MN)=hh_frez(MN);
            %hhh_frez(MN,KT)=hh_frez(MN);
            TOLD_CRIT(MN)=T_CRIT(MN);
            T_CRIT(MN)=TT_CRIT(MN);
            %TTT_CRIT(MN,KT)=TT_CRIT(MN);
            
            hOLD(MN)=h(MN);
            h(MN)=hh(MN);
            %hhh(MN,KT)=hh(MN);
            %KfL_hh(MN,KT)=KfL_h(MN,2);
            %KL_hh(MN,KT)=KL_h(MN,2);
            %Chhh(MN,KT)=Chh(MN,2);
            %ChTT(MN,KT)=ChT(MN,2);
            %Khhh(MN,KT)=Khh(MN,2);
            %KhTT(MN,KT)=KhT(MN,2);
            %CTTT(MN,KT)=CTT(MN,2);
            %EPCTT(MN,KT)=EPCT(MN);
            %C_unsat(MN,KT)=c_unsat(MN,2);
            %CCTT_PH(MN,KT)=CTT_PH(MN,2);
            %CCTT_Lg(MN,KT)=CTT_Lg(MN,2);
            %CCTT_g(MN,KT)=CTT_g(MN,2);
            %CCTT_LT(MN,KT)=CTT_LT(MN,2);
            %Lambda_Eff(MN,KT)=Lambda_eff(MN,2);
            %EfTCON(MN,KT)=EfTCON(MN,2);
            %TTETCON(MN,KT)=TETCON(MN,2);
            DDhDZ(MN,KT)=DhDZ(MN);
            %DDTDZ(MN,KT)=DTDZ(MN);
            %DDRHOVZ(MN,KT)=DRHOVZ(MN);
            %TKCHK(MN,KT)=KCHK(MN);
            if Thmrlefc==1
                TOLD(MN)=T(MN);
                T(MN)=TT(MN);
                TTT(MN,KT)=TT(MN);
            end
            if Soilairefc==1
                P_gOLD(MN)=P_g(MN);
                P_g(MN)=P_gg(MN);
                %P_ggg(MN,KT)=P_gg(MN);
            end
            if rwuef==1
                SRT(MN,KT)=Srt(MN,1);
                %ALPHA(MN,KT)=alpha_h(MN,1);
                %BX(MN,KT)=bx(MN,1);
            end
         end
    if options.simulation == 1, vi(vmax>1) = k; end
    if options.simulation == 0, vi(vmax==telmax) = k; end
    [soil,leafbio,canopy,meteo,angles,xyt] = io.select_input(ScopeParameters,vi,canopy,options,xyt,soil);
    if options.simulation ~=1
        fprintf('simulation %i ', k );
        fprintf('of %i \n', telmax);
    else
        calculate = 1;
    end
    
    if calculate
        
        iter.counter = 0;
        
        LIDF_file            = char(F(22).FileName);
        if  ~isempty(LIDF_file)
            canopy.lidf     = dlmread([path_input,'leafangles/',LIDF_file],'',3,0);
        else
            canopy.lidf     = equations.leafangles(canopy.LIDFa,canopy.LIDFb);    % This is 'ladgen' in the original SAIL model,
        end
        
        leafbio.emis        = 1-leafbio.rho_thermal-leafbio.tau_thermal; 
        
        if options.calc_PSI
            fversion = @fluspect_B_CX;
        else
            fversion = @fluspect_B_CX_PSI_PSII_combined;
        end
        leafbio.V2Z = 0;
        leafopt  = fversion(spectral,leafbio,optipar);
        leafbio.V2Z = 1;
        leafoptZ = fversion(spectral,leafbio,optipar);
        
        IwlP     = spectral.IwlP;
        IwlT     = spectral.IwlT;
        
        rho(IwlP)  = leafopt.refl;
        tau(IwlP)  = leafopt.tran;
        rlast    = rho(nwlP);
        tlast    = tau(nwlP);
        
        if options.soilspectrum == 0
            rs(IwlP) = rsfile(:,soil.spectrum+1);
        else
            soilemp.SMC   = 25;        % empirical parameter (fixed)
            soilemp.film  = 0.015;     % empirical parameter (fixed)
            rs(IwlP) = BSM(soil,optipar,soilemp);
        end
        rslast   = rs(nwlP);
        
        switch options.rt_thermal
            case 0
                rho(IwlT) = ones(nwlT,1) * leafbio.rho_thermal;
                tau(IwlT) = ones(nwlT,1) * leafbio.tau_thermal;
                rs(IwlT)  = ones(nwlT,1) * soil.rs_thermal;
            case 1
                rho(IwlT) = ones(nwlT,1) * rlast;
                tau(IwlT) = ones(nwlT,1) * tlast;
                rs(IwlT)  = ones(nwlT,1) * rslast;
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
        
        soil.Ts     = meteo.Ta * ones(2,1);       % initial soil surface temperature
        
        if length(F(4).FileName)>1 && options.simulation==0
            atmfile     = [path_input 'radiationdata/' char(F(4).FileName(k))];
            atmo.M      = helpers.aggreg(atmfile,spectral.SCOPEspec);
        end
        atmo.Ta     = meteo.Ta;
        
        [rad,gap,profiles]   = RTMo(spectral,atmo,soil,leafopt,canopy,angles,meteo,rad,options);
        
        switch options.calc_ebal
            case 1
                [iter,fluxes,rad,thermal,profiles,soil,RWU,frac]                          ...
                    = ebal(iter,options,spectral,rad,gap,                       ...
                    leafopt,angles,meteo,soil,canopy,leafbio,xyt,k,profiles,Delt_t);
                if options.calc_fluor
                    if options.calc_vert_profiles
                        [rad,profiles] = RTMf(spectral,rad,soil,leafopt,canopy,gap,angles,profiles);
                    else
                        [rad] = RTMf(spectral,rad,soil,leafopt,canopy,gap,angles,profiles);
                    end
                end
                if options.calc_xanthophyllabs
                    [rad] = RTMz(spectral,rad,soil,leafopt,canopy,gap,angles,profiles);
                end
                
                if options.calc_planck
                    rad         = RTMt_planck(spectral,rad,soil,leafopt,canopy,gap,angles,thermal.Tcu,thermal.Tch,thermal.Ts(2),thermal.Ts(1),1);
                end
                
                if options.calc_directional
                    directional = calc_brdf(options,directional,spectral,angles,rad,atmo,soil,leafopt,canopy,meteo,profiles,thermal);
                end
                
            otherwise
                Fc              = (1-gap.Ps(1:end-1))'/nl;      %           Matrix containing values for Ps of canopy
                fluxes.aPAR     = canopy.LAI*(Fc*rad.Pnh        + equations.meanleaf(canopy,rad.Pnu    , 'angles_and_layers',gap.Ps));% net PAR leaves
                fluxes.aPAR_Cab = canopy.LAI*(Fc*rad.Pnh_Cab    + equations.meanleaf(canopy,rad.Pnu_Cab, 'angles_and_layers',gap.Ps));% net PAR leaves
                [fluxes.aPAR_Wm2,fluxes.aPAR_Cab_eta] = deal(canopy.LAI*(Fc*rad.Rnh_PAR    + equations.meanleaf(canopy,rad.Rnu_PAR, 'angles_and_layers',gap.Ps)));% net PAR leaves
                if options.calc_fluor
                    profiles.etah = ones(nl,1);
                    profiles.etau = ones(13,36,nl);
                    if options.calc_vert_profiles
                        [rad,profiles] = RTMf(spectral,rad,soil,leafopt,canopy,gap,angles,profiles);
                    else
                        [rad] = RTMf(spectral,rad,soil,leafopt,canopy,gap,angles,profiles);
                    end
                end
        end
        if options.calc_fluor % total emitted fluorescence irradiance (excluding leaf and canopy re-absorption and scattering)
            if options.calc_PSI
                rad.Femtot = 1E3*(leafbio.fqe(2)* optipar.phiII(spectral.IwlF) * fluxes.aPAR_Cab_eta +leafbio.fqe(1)* optipar.phiI(spectral.IwlF)  * fluxes.aPAR_Cab);
            else
                rad.Femtot = 1E3*leafbio.fqe* optipar.phi(spectral.IwlF) * fluxes.aPAR_Cab_eta;
            end
        end           
    end
    if options.simulation==2 && telmax>1, vi  = helpers.count(nvars,vi,vmax,1); end
     if KT==1 
        if isreal(fluxes.Actot)&&isreal(thermal.Tsave)&&isreal(fluxes.lEstot)&&isreal(fluxes.lEctot)
           Acc=fluxes.Actot;
           lEstot =fluxes.lEstot;
           lEctot =fluxes.lEctot;
           Tss=thermal.Tsave; 
        else
           Acc=0;
           lEstot =0;
           lEctot =0;
           Tss=Ta_msr(KT); 
        end
    elseif NoTime(KT)>NoTime(KT-1)
        if isreal(fluxes.Actot)&&isreal(thermal.Tsave)&&isreal(fluxes.lEstot)&&isreal(fluxes.lEctot)
           Acc=fluxes.Actot;
           lEstot =fluxes.lEstot;
           lEctot =fluxes.lEctot;
           Tss=thermal.Tsave; 
        else
           Acc=0;
           lEstot =0;
           lEctot =0;
           Tss=Ta_msr(KT); 
        end
    end
 
    sfactortot(KT)=sfactor;
    DSTOR0=DSTOR; 
    
      if KT>1
          run SOIL1
      end
        
      for ML=1:NL
            %QVV(ML,KT)=QV(ML);
            %QLL(ML,KT)=QL(ML,1);
            %DDEhBAR(ML,KT)=DEhBAR(ML);
            %DDRHOVhDz(ML,KT)=DRHOVhDz(ML);
            DDhDZ(ML,KT)=DhDZ(ML);
            %EEtaBAR(ML,KT)=EtaBAR(ML);
            %DD_Vg(ML,KT)=D_Vg(ML);
            %DDRHOVTDz(ML,KT)=DRHOVTDz(ML);
            %DDTDZ(ML,KT)=DTDZ(ML);
            %DDPgDZ(ML,KT)=DPgDZ(ML);
            %KKLhBAR(ML,KT)=KLhBAR(ML);
            %KKLTBAR(ML,KT)=KLTBAR(ML);
            %DDTDBAR(ML,KT)=DTDBAR(ML);
            %QVAA(ML,KT)=QVa(ML);
            %QAA(ML,KT)=Qa(ML);
            if ~Soilairefc
                %QLHH(ML,KT)=QLH(ML);
                %QLTT(ML,KT)=QLT(ML);
            else
                %QLHH(ML,KT)=QL_h(ML);
                %QLTT(ML,KT)=QL_T(ML);
                %QLAA(ML,KT)=QL_a(ML);
            end
            %DVHH(ML,KT)=DVH(ML);
            %DVTT(ML,KT)=DVT(ML);
            %SSe(ML,KT)=Se(ML,1);
            %SSa(ML,KT)=Sa(ML,1);
            %DSAVEDTheta_LLh(ML,KT)=SAVEDTheta_LLh(ML,1);
            %DSAVEDTheta_LLT(ML,KT)=SAVEDTheta_LLT(ML,1);
            %DSAVEDTheta_UUh(ML,KT)=SAVEDTheta_UUh(ML,1);

            %QVHH(ML,KT)=QVH(ML);
            %QVTT(ML,KT)=QVT(ML);
            %DDTheta_LLh(ML,KT)=DTheta_LLh(ML,1);
            %CChh(ML,KT)=Chh(ML,1);
            %kk_g(ML,KT)=k_g(ML,1);
            %VV_A(ML,KT)=V_A(ML);
      end
    end
    if Delt_t~=Delt_t0
        for MN=1:NN
            hh(MN)=h(MN)+(h(MN)-hOLD(MN))*Delt_t/Delt_t0;
            TT(MN)=T(MN)+(T(MN)-TOLD(MN))*Delt_t/Delt_t0;
        end
    end
    hSAVE=hh(NN);
    TSAVE=TT(NN);
    if NBCh==1
        hN=BCh;
        hh(NN)=hN;
        hSAVE=hN;
    elseif NBCh==2
        if NBChh~=2
            if BCh<0
                hN=DSTOR0;
                hh(NN)=hN;
                hSAVE=hN;
            else
                hN=-1e6;
                hh(NN)=hN;
                hSAVE=hN;
            end
        end
    else
        if NBChh~=2
            hN=DSTOR0;
            hh(NN)=hN;
            hSAVE=hN;
        end
    end
    run Forcing_PARM
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for KIT=1:NIT   % Start the iteration procedure in a time step.
        [TT_CRIT,hh_frez]=HT_frez(hh,T0,g,L_f,TT,NN,hd,Tmin);
        [hh,COR,CORh,Theta_V,Theta_g,Se,KL_h,Theta_LL,DTheta_LLh,KfL_h,KfL_T,hh_frez,Theta_UU,DTheta_UUh,Theta_II]=SOIL2(hh,COR,hThmrl,NN,NL,TT,Tr,Hystrs,XWRE,Theta_s,IH,KIT,Theta_r,Alpha,n,m,Ks,Theta_L,h,Thmrlefc,POR,Theta_II,CORh,hh_frez,h_frez,SWCC,Theta_U,XCAP,Phi_s,RHOI,RHOL,Lamda,Imped,L_f,g,T0,TT_CRIT,KfL_h,KfL_T,KL_h,Theta_UU,Theta_LL,DTheta_LLh,DTheta_UUh,Se);
        [KL_T]=CondL_T(NL);
        [RHOV,DRHOVh,DRHOVT]=Density_V(TT,hh,g,Rv,NN);
        [W,WW,MU_W,D_Ta]=CondL_Tdisp(POR,Theta_LL,Theta_L,SSUR,RHO_bulk,RHOL,TT,Theta_s,h,hh,W_Chg,NL,nD,Delt_t,Theta_g,KLT_Switch);
        [L]= Latent(TT,NN);
        [Xaa,XaT,Xah,DRHODAt,DRHODAz,RHODA]=Density_DA(T,RDA,P_g,Rv,DeltZ,h,hh,TT,P_gg,Delt_t,NL,NN,DRHOVT,DRHOVh,RHOV);
        [c_unsat,Lambda_eff,ZETA,ETCON,EHCAP,TETCON,EfTCON]=CondT_coeff(Theta_LL,Lambda1,Lambda2,Lambda3,RHO_bulk,Theta_g,RHODA,RHOV,c_a,c_V,c_L,NL,nD,ThmrlCondCap,ThermCond,HCAP,SF,TCA,GA1,GA2,GB1,GB2,HCD,ZETA0,CON0,PS1,PS2,XWILT,XK,TT,POR,DRHOVT,L,D_A,Theta_V,Theta_II,TCON_dry,Theta_s,XSOC,TPS1,TPS2,TCON0,TCON_s,FEHCAP,RHOI,RHOL,c_unsat,Lambda_eff,ETCON,EHCAP,TETCON,EfTCON,ZETA);
        [k_g]=Condg_k_g(POR,NL,m,Theta_g,g,MU_W,Ks,RHOL,SWCC,Imped,Ratio_ice,Soilairefc,MN);
        [D_V,Eta,D_A]=CondV_DE(Theta_LL,TT,fc,Theta_s,NL,nD,Theta_g,POR,ThmrlCondCap,ZETA,XK,DVT_Switch,Theta_UU);
        [D_Vg,V_A,Beta_g,DPgDZ,Beta_gBAR,Alpha_LgBAR]=CondV_DVg(P_gg,Theta_g,Sa,V_A,k_g,MU_a,DeltZ,Alpha_Lg,KaT_Switch,Theta_s,Se,NL,DPgDZ,Beta_gBAR,Alpha_LgBAR,Beta_g);
        run h_sub;
        if NBCh==1
            DSTOR=0;
            RS=0;
        elseif NBCh==2
            AVAIL=-BCh;
            EXCESS=(AVAIL+QMT(KT))*Delt_t;
            if abs(EXCESS/Delt_t)<=1e-10,EXCESS=0;end
            DSTOR=min(EXCESS,DSTMAX);
            RS=(EXCESS-DSTOR)/Delt_t;
        else
            AVAIL=AVAIL0-Evap(KT);
            EXCESS=(AVAIL+QMT(KT))*Delt_t;
            if abs(EXCESS/Delt_t)<=1e-10,EXCESS=0;end
            DSTOR=min(EXCESS,DSTMAX);
            RS(KT)=(EXCESS-DSTOR)/Delt_t;
        end
        
        if Soilairefc==1
            run Air_sub;
        end
        
        if Thmrlefc==1
            run Enrgy_sub;
        end
        
        if max(CHK)<0.1 %&& max(FCHK)<0.001 %&& max(hCHK)<0.001 %&& min(KCHK)>0.001
            break
        end
        hSAVE=hh(NN);
        TSAVE=TT(NN);
    end
    TIMEOLD=KT;
    KIT;
    KIT=0;
    [TT_CRIT,hh_frez]=HT_frez(hh,T0,g,L_f,TT,NN,hd,Tmin);
    [hh,COR,CORh,Theta_V,Theta_g,Se,KL_h,Theta_LL,DTheta_LLh,KfL_h,KfL_T,hh_frez,Theta_UU,DTheta_UUh,Theta_II]=SOIL2(hh,COR,hThmrl,NN,NL,TT,Tr,Hystrs,XWRE,Theta_s,IH,KIT,Theta_r,Alpha,n,m,Ks,Theta_L,h,Thmrlefc,POR,Theta_II,CORh,hh_frez,h_frez,SWCC,Theta_U,XCAP,Phi_s,RHOI,RHOL,Lamda,Imped,L_f,g,T0,TT_CRIT,KfL_h,KfL_T,KL_h,Theta_UU,Theta_LL,DTheta_LLh,DTheta_UUh,Se);

    SAVEtS=tS;
    if IRPT1==0 && IRPT2==0
        if KT        % In case last time step is not convergent and needs to be repeated.
            MN=0;
            for ML=1:NL
                for ND=1:2
                    MN=ML+ND-1;
                    Theta_LLL(ML,ND,KT)=Theta_LL(ML,ND);
                    Theta_L(ML,ND)=Theta_LL(ML,ND);
                    Theta_UUU(ML,ND,KT)=Theta_UU(ML,ND);
                    Theta_U(ML,ND)=Theta_UU(ML,ND);
                    Theta_III(ML,ND,KT)=Theta_II(ML,ND);
                    Theta_I(ML,ND)=Theta_II(ML,ND);
                    %DDTheta_LLh(ML,KT)=DTheta_LLh(ML,2);
                    %DDTheta_LLT(ML,KT)=DTheta_LLT(ML,2);
                    %DDTheta_UUh(ML,KT)=DTheta_UUh(ML,2);
                end
            end
            run ObservationPoints
        end
        if (TEND-TIME)<1E-3
            for MN=1:NN
                hOLD(MN)=h(MN);
                h(MN)=hh(MN);
                %hhh(MN,KT)=hh(MN);
                %HRA(MN,KT)=HR(MN);               
                if Thmrlefc==1
                    TOLD(MN)=T(MN);
                    T(MN)=TT(MN);
                    TTT(MN,KT)=TT(MN);
                    TOLD_CRIT(MN)=T_CRIT(MN);
                    T_CRIT(MN)=TT_CRIT(MN);
                    %TTT_CRIT(MN,KT)=TT_CRIT(MN);
                    hOLD_frez(MN)=h_frez(MN);
                    h_frez(MN)=hh_frez(MN);
                    %hhh_frez(MN,KT)=hh_frez(MN);
                end
                if Soilairefc==1
                    P_gOLD(MN)=P_g(MN);
                    P_g(MN)=P_gg(MN);
                    %P_ggg(MN,KT)=P_gg(MN);
                end
            end
            %break
        end
    end
    if KT>0
        for MN=1:NN
            %QL(MN,KT)=QL(MN);
            %QL_HH(MN,KT)=QL_h(MN);
            %QL_TT(MN,KT)=QL_T(MN);
            %QV(MN,KT)=QV(MN);
            %SAVEhhh(MN,KT)=SAVEhh(MN);
        end
        %SAVEDSTOR(KT)=DSTOR;
    end
    kk=k;
    n_col = io.output_data_binary(f, k, xyt, rad, canopy, ScopeParameters, vi, vmax, options, fluxes, meteo, iter, thermal, spectral, gap, profiles, Sim_Theta_U, Sim_Temp, Trap, Evap);
end
fprintf('\n The calculations end now \r')
if options.verify
    io.output_verification(Output_dir)
end

%% soil layer information
%% Ztot is defined as a global variable in Initial_root_biomass.m
%% TODO avoid global variables
SoilLayer.thickness = DeltZ_R;
SoilLayer.depth = Ztot';

io.bin_to_csv(fnames, V, vmax, n_col, k, options, SoilLayer)
save([Output_dir,'output.mat'])
%if options.makeplots
%  plot.plots(Output_dir)
%end  

