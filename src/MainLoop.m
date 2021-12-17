%%%%%%%%%%%%%%%%%%%%%%% Preprocessing part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1.Allocate the required variables
% 2.Set the necessary parameters
% 3.Set the initial values
% 4.Read the observation data
% 5.Read the input data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clearvars -except TRAP_ind EVAP_ind Sim_Temp_ind Sim_Theta_ind;
close all;
run Constants
global HR U Precip G Rn LAI Ta1 Ts1 h_v rl_min HR_a Ts Ta
Mdata=xlsread('C:\Users\ÍõÔÆö­\Desktop\STEMMUS EXERCISE -I_O Optimize\Meterology data','sheet1','B5:AC5860');
Ta1=Mdata(:,1);   % air temperature
HR=Mdata(:,2)./100;   % relative humidity
U=Mdata(:,3);     % wind speed at 2m
Precipi=Mdata(:,4);    % precipitation
Ts1=Mdata(:,5);  % soil temperature at 20cm
Ts2=Mdata(:,6);  % soil temperature at 40cm
Ts3=Mdata(:,7);  % soil temperature at 60cm
SMC1=Mdata(:,8);    % soil moisture content at 20cm
SMC2=Mdata(:,9);    % soil moisture content at 40cm
SMC3=Mdata(:,10);   % soil moisture content at 60cm
G1=Mdata(:,11:13);    % soil heat flux 
Rn=Mdata(:,14);    % net rediation
LAI=Mdata(:,26);   % leaf area index
h_v=Mdata(:,27);   % canopy height
rl_min=Mdata(:,28);   % minimum soil resistance
Precip=Precipi./18000;
G=ones(5856,1);
G=nanmean(G1')';
HR_a=HR;
Ta=Ta1;
Ts=Ts1;
%P_Va(KT)=0.611*exp(17.27*Ta(KT)/(Ta(KT)+237.3))*HR_a(KT);
if Evaptranp_Cal==1
    run EvapTransp_Cal;
end
% function MainLoop
global i tS KT Delt_t TEND TIME MN NN NL ML ND hOLD TOLD h hh T TT P_gOLD P_g P_gg Delt_t0
global KIT NIT TimeStep Processing
global SUMTIME hhh TTT P_ggg Theta_LLL DSTOR Thmrlefc CHK Theta_LL Theta_L
global NBCh AVAIL Evap DSTOR0 EXCESS QMT RS BCh hN hSAVE NBChh DSTMAX Soilairefc Trap sumTRAP_dir sumEVAP_dir
global TSAVE IRPT1 IRPT2 AVAIL0 TIMEOLD TIMELAST SRT ALPHA BX alpha_h bx Srt L
global QL QL_h QL_T QV Qa KL_h Chh ChT Khh KhT
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
global Theta_V DTheta_LLh IH 
global W WW D_Ta SSUR
global W_Chg
global KLT_Switch Theta_r Alpha n CKTN trap Evapo

%%%%%%%%%%%%%%%%%%%%%%% Main Processing part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run StartInit;   % Initialize Temperature, Matric potential and soil air pressure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TIMEOLD=0;
TIMELAST=0;
for i=1:tS+1                          % Notice here: In this code, the 'i' is strictly used for timestep loop and the arraies index of meteorological forcing data.
    KT=KT+1  % Counting Number of timesteps
    if KT>1 && Delt_t>(TEND-TIME)
        Delt_t=TEND-TIME;           % If Delt_t is changed due to excessive change of state variables, the judgement of the last time step is excuted.
    end
    TIME=TIME+Delt_t;               % The time elapsed since start of simulation
    TimeStep(KT,1)=Delt_t;
    SUMTIME(KT,1)=TIME;
    Processing=TIME/TEND
    %%%%%% Updating the state variables. %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if TIME>=322*1800 && TIME<=341*1800    %7-13 9-10 p=52mm
        NBChh=1;
    elseif TIME>=1217*1800 && TIME<=1218*1800  %8-1 16-18 p=60mm
        NBChh=1;
    elseif TIME>=1933*1800 && TIME<=1960*1800  %8-1 16-18 p=60mm
        NBChh=1;
    elseif TIME>=2032*1800 && TIME<=2034*1800  %8-15 16-17 p=67mm
        NBChh=1;
    elseif TIME>=2058*1800 && TIME<=2061*1800  %8-15 16-17 p=67mm
        NBChh=1;
    elseif TIME>=2127*2131 && TIME<=2135*1800  %8-15 16-17 p=67mm
        NBChh=1;
    elseif TIME>=2248*1800 && TIME<=2248*1800  %8-15 16-17 p=67mm
        NBChh=1;
    elseif TIME>=2251*1800 && TIME<=2251*1800  %8-15 16-17 p=67mm
        NBChh=1;
    elseif TIME>=2316*1800 && TIME<=2322*1800  %8-15 16-17 p=67mm
        NBChh=1;
    elseif TIME>=2751*1800 && TIME<=2775*1800  %9-8 14-18 p=93.11mm
        NBChh=1;
    elseif TIME>=3057*1800 && TIME<=3059*1800  %9-8 14-18 p=93.11mm
        NBChh=1;
    elseif TIME>=4345*1800 && TIME<=4352*1800  %9-8 14-18 p=93.11mm
        NBChh=1;
    else
        NBChh=2;
    end
    if IRPT1==0 && IRPT2==0
        for MN=1:NN
            hOLD(MN)=h(MN);
            h(MN)=hh(MN);
            hhh(MN,KT)=hh(MN);
%              KL_h(MN,KT)=KL_h(MN,2);
%            Chh(MN,KT)=Chh(MN,2);
%             ChT(MN,KT)=ChT(MN,2);
%             Khh(MN,KT)=Khh(MN,2);
%             KhT(MN,KT)=KhT(MN,2);
            
            if Thmrlefc==1
                TOLD(MN)=T(MN);
                T(MN)=TT(MN);
                TTT(MN,KT)=TT(MN);
            end
            if Soilairefc==1
                P_gOLD(MN)=P_g(MN);
                P_g(MN)=P_gg(MN);
                P_ggg(MN,KT)=P_gg(MN);
            end
            if rwuef==1
                SRT(MN,KT)=Srt(MN,1);
                ALPHA(MN,KT)=alpha_h(MN,1);
                BX(MN,KT)=bx(MN,1);
            end
        end
        DSTOR0=DSTOR;
        if KT>1
            run SOIL1
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
    % run Forcing_PARM
%Ts(KT)=Ts1(KT);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for KIT=1:NIT   % Start the iteration procedure in a time step.
        [hh,COR,J,Theta_V,Theta_g,Se,KL_h,Theta_LL,DTheta_LLh]=SOIL2(hh,COR,hThmrl,NN,NL,TT,Tr,IS,Hystrs,XWRE,Theta_s,IH,KIT,Theta_r,Alpha,n,m,Ks,Theta_L,h,Thmrlefc,CKTN,POR,J);
        [KL_T]=CondL_T(NL);
        [RHOV,DRHOVh,DRHOVT]=Density_V(TT,hh,g,Rv,NN);
        [W,WW,MU_W,D_Ta]=CondL_Tdisp(POR,Theta_LL,Theta_L,SSUR,RHO_bulk,RHOL,TT,Theta_s,h,hh,W_Chg,NL,nD,J,Delt_t,Theta_g,KLT_Switch);
        [L]=Latent(TT,NN);
        [Xaa,XaT,Xah,DRHODAt,DRHODAz,RHODA]=Density_DA(T,RDA,P_g,Rv,DeltZ,h,hh,TT,P_gg,Delt_t,NL,NN,DRHOVT,DRHOVh,RHOV);
        [c_unsat,Lambda_eff]=CondT_coeff(Theta_LL,Lambda1,Lambda2,Lambda3,RHO_bulk,Theta_g,RHODA,RHOV,c_a,c_V,c_L,NL,nD,ThmrlCondCap,ETCON,EHCAP);
        [k_g]=Condg_k_g(POR,NL,J,m,Theta_g,g,MU_W,Ks,RHOL);
        [D_V,Eta,D_A]=CondV_DE(Theta_LL,TT,fc,Theta_s,NL,nD,J,Theta_g,POR,ThmrlCondCap,ZETA,XK,DVT_Switch);
        [D_Vg,V_A,Beta_g]=CondV_DVg(P_gg,Theta_g,Sa,V_A,k_g,MU_a,DeltZ,Alpha_Lg,KaT_Switch,Theta_s,Se,NL,J);
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
            DSTOR=0;
            RS=0;
        end
        
        if Soilairefc==1
            run Air_sub;
        end
        
        if Thmrlefc==1
            run Enrgy_sub;
        end
        
        if max(CHK)<0.001 
            break
        end
        hSAVE=hh(NN);
        TSAVE=TT(NN);
    end
    TIMEOLD=KT;
    KIT
    KIT=0;
    [hh,COR,J,Theta_V,Theta_g,Se,KL_h,Theta_LL,DTheta_LLh]=SOIL2(hh,COR,hThmrl,NN,NL,TT,Tr,IS,Hystrs,XWRE,Theta_s,IH,KIT,Theta_r,Alpha,n,m,Ks,Theta_L,h,Thmrlefc,CKTN,POR,J);
    
    if IRPT1==0 && IRPT2==0
        if KT        % In case last time step is not convergent and needs to be repeated.
            MN=0;
            for ML=1:NL
                for ND=1:2
                    MN=ML+ND-1;
                    Theta_LLL(ML,ND,KT)=Theta_LL(ML,ND);
                    Theta_L(ML,ND)=Theta_LL(ML,ND);
                    
                end
            end
            run ObservationPoints
        end
        if (TEND-TIME)<1E-3
            for MN=1:NN
                hOLD(MN)=h(MN);
                h(MN)=hh(MN);
                hhh(MN,KT)=hh(MN);
                if Thmrlefc==1
                    TOLD(MN)=T(MN);
                    T(MN)=TT(MN);
                    TTT(MN,KT)=TT(MN);
                end
                if Soilairefc==1
                    P_gOLD(MN)=P_g(MN);
                    P_g(MN)=P_gg(MN);
                    P_ggg(MN,KT)=P_gg(MN);
                end
            end
            break
        end
    end
    for MN=1:NN
        QL(MN,KT)=QL(MN);
        QL_h(MN,KT)=QL_h(MN);
        QL_T(MN,KT)=QL_T(MN);
        Qa(MN,KT)=Qa(MN);
        QV(MN,KT)=QV(MN);
    end
end
% run PlotResults
%%%%%%%%%%%%%%%%%%%% postprocessing part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% plot the figures of simulation output soil moisture/temperature, 
%%%% soil evaporation, plant transpiration simulated with two different 
%%%% ET method (indirect ET method & direct ET method)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Evaptranp_Cal==1   % save the variables for ETind scenario
    Sim_Theta_ind=Sim_Theta;
    Sim_Temp_ind=Sim_Temp;
    TRAP=36000.*trap;
    TRAP_ind=TRAP';
    EVAP=36000.*Evapo;
    EVAP_ind=EVAP';
    disp ('Convergence Achieved for ETind scenario. Please switch to ETdir scenario and run again.')
else
    TRAP=18000.*trap;
    TRAP_dir=TRAP';
    EVAP=18000.*Evapo;
    EVAP_dir=EVAP';
    for i=1:KT/48
        sumTRAP_ind(i)=0; %#ok<*SAGROW>
        sumEVAP_ind(i)=0;
        sumTRAP_dir(i)=0;
        sumEVAP_dir(i)=0;
        for j=(i-1)*48+1:i*48
            sumTRAP_ind(i)=TRAP_ind(j)+sumTRAP_ind(i);
            sumEVAP_ind(i)=EVAP_ind(j)+sumEVAP_ind(i);
            sumTRAP_dir(i)=TRAP(j)+sumTRAP_dir(i);
            sumEVAP_dir(i)=EVAP(j)+sumEVAP_dir(i);
        end
    end
    run PlotResults1
end
