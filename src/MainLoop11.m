function [dMOD,QqS,DW,ThOLD,THH,TTOLD,TTTt,ThOLD_frez,THH_frez,RrNSTM,RrOGSTM,TIME]=MainLoop11(IP0STm,KTNn,TTIME,TTEND,HPILR1N,HPILR0,RrNG,BOTm,SYSTG,SSSTG,ThOLDtm1,THHtm1,TTOLDtm1,TTTttm1,ThOLD_freztm1,THH_freztm1)

KTN=KTNn; % 
STEMMUS_config; % set the constants and initial conditions for STEMMUS

CPLD=0; % setting the coupled water and heat transfer; CPLD=1, water and heat transfer are coupled; =0, water and heat transfer are independent
HPUNIT=100; % constant for the unit conversion
%% set constants for GW
NLAY=5;
NPILR=44;
ITERQ3D=1;
IGRID=1;
Q3DF=1;
RELAXF=0.8;
ADAPTF=1;
%%
if KT+1==0
    KT=0;
else
    KT=KT;
end

[KPILLAR]=KPILR_Cal(BOTm.*HPUNIT,XElemnt,IP0STm);
%% save the curve of soil water content at the start of the time
Shh=zeros(NN,1);STheta_LL=zeros(NN,1);STheta_L=zeros(NN,1);
Sh=zeros(NN,1);
Ts_Min=0;Ts_Max=80;%TIME=3600;

%% run StartInit;   % Initialize Temperature, Matric potential and soil air pressure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TIMEOLD=0;%Delt_t=1;
TIMELAST=0;TIME=TTIME*3600*24;
TEND1=(TTIME+TTEND)*3600*24;%TSEC0;

SGWTIME(KTN,1)=TIME;
SAVEhh_frez=zeros(NN+1,1);FCHK=zeros(1,NN);KCHK=zeros(1,NN);hCHK=zeros(1,NN);
SAVEtS=tS;
L_f=3.34*1e5; %latent heat of freezing fusion J Kg-1
T0=273.15; % unit K
if KTN==1
    h=h0;
    hh=hh0;
    Sh(1:1:NN)=hh(NN:-1:1);
    h_frez=h0_frez;
    hh_frez=hh0_frez;
    T=Tt0;
    TT=TT0;
else
    h(1:NN)=ThOLDtm1(1:NN);
    hh(1:NN)=THHtm1(1:NN);
    Sh(1:1:NN)=hh(NN:-1:1);
    T(1:NN)=TTOLDtm1(1:NN);
    TT(1:NN)=TTTttm1(1:NN);
    h_frez(1:NN)=ThOLD_freztm1(1:NN);
    hh_frez(1:NN)=THH_freztm1(1:NN);
end
[TT_CRIT,~]=HT_frez(hh,T0,g,L_f,TT,NN,hd);
[T_CRIT,~]=HT_frez(h,T0,g,L_f,T,NN,hd);

[hh,COR,CORh,Theta_V,Theta_g,Se,KL_h,Theta_LL,DTheta_LLh,KfL_h,KfL_T,hh_frez,Theta_UU,DTheta_UUh,Theta_II]=SOIL2(hh,COR,hThmrl,NN,NL,TT,Tr,Hystrs,XWRE,Theta_s,IH,KIT,Theta_r,Alpha,n,m,Ks,Theta_L,h,Thmrlefc,POR,Theta_II,CORh,hh_frez,h_frez,SWCC,Theta_U,XCAP,Phi_s,RHOI,RHOL,Lamda,Imped,L_f,g,T0,TT_CRIT,KfL_h,KfL_T,KL_h,Theta_UU,Theta_LL,DTheta_LLh,DTheta_UUh,Se);

STheta_L(2:1:NN)=Theta_LL(NN-1:-1:1,1);
STheta_L(1)=Theta_LL(NL,2);

THETA0=STheta_L;
QS=zeros(NN,1);
Theta_L=Theta_LL;
Theta_U=Theta_UU;

[ZTB0G,ICTRL0]=FINDTABLE(IP0STm,Sh,XElemnt,NN); % find the phreatic surface in the STEMMUS soil columns, added by LY

for i=1:1:17789000                         % Notice here: In this code, the 'i' is strictly used for timestep loop and the arraies index of meteorological forcing data.
    KT=KT+1;                          % Counting Number of timesteps
    if KT<=0,KT=1;end
    if KT>1 && Delt_t>(TEND1-TIME)
        Delt_t=TEND1-TIME;           % If Delt_t is changed due to excessive change of state variables, the judgement of the last time step is excuted.
    end
    TIME=TIME+Delt_t;               % The time elapsed since start of simulation
    TimeStep(KTN,1)=Delt_t;
    TimeStp(KT,1)=Delt_t;
    SUMTIME(KT,1)=TIME;
    Processing=TIME/TEND1;
    %%%%% Updating the state variables. %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% find the bottom layer of soil column %%%%%%%%%%%%%%%%%%%%%
    [HPILLAR,IBOT]=TIME_INTERPOLATION(TEND1,TTIME*86400,IP0STm,BOTm.*HPUNIT,HPILR1N*HPUNIT,HPILR0*HPUNIT,TIME,TTEND*86400,XElemnt,NN,Q3DF,ADAPTF);
    hBOT=HPILLAR;  % Bottom water heads
    IBOTM(KT)=IBOT; %  index of bottom soil layer
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    if IRPT1==0 && IRPT2==0 && ISFT==0
        for MN=1:NN
            hOLD_frez(MN)=h_frez(MN);
            h_frez(MN)=hh_frez(MN);
            hhh_frez(MN,KT)=hh_frez(MN);
            TOLD_CRIT(MN)=T_CRIT(MN);
            T_CRIT(MN)=TT_CRIT(MN);
            TTT_CRIT(MN,KT)=TT_CRIT(MN);

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
        DSTOR0=DSTOR;

        if KT>1
            [XOLD,EX,XWRE]=SOIL1_SPAT(Theta_L,Theta_LL,NL,IH,Theta_s,XK,XOLD);
            %             run SOIL1
        end
    end

    if Delt_t~=Delt_t0
        for MN=1:NN
            hh(MN)=h(MN)+(h(MN)-hOLD(MN))*Delt_t/Delt_t0;
            TT(MN)=T(MN)+(T(MN)-TOLD(MN))*Delt_t/Delt_t0;
            if hh(MN)>max(h(MN),hOLD(MN))
                hh(MN)=max(h(MN),hOLD(MN));
            elseif hh(MN)>min(h(MN),hOLD(MN))
                hh(MN)=min(h(MN),hOLD(MN));
            end
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
        [TT_CRIT,hh_frez]=HT_frez(hh,T0,g,L_f,TT,NN,hd);
        [hh,COR,CORh,Theta_V,Theta_g,Se,KL_h,Theta_LL,DTheta_LLh,KfL_h,KfL_T,hh_frez,Theta_UU,DTheta_UUh,Theta_II]=SOIL2(hh,COR,hThmrl,NN,NL,TT,Tr,Hystrs,XWRE,Theta_s,IH,KIT,Theta_r,Alpha,n,m,Ks,Theta_L,h,Thmrlefc,POR,Theta_II,CORh,hh_frez,h_frez,SWCC,Theta_U,XCAP,Phi_s,RHOI,RHOL,Lamda,Imped,L_f,g,T0,TT_CRIT,KfL_h,KfL_T,KL_h,Theta_UU,Theta_LL,DTheta_LLh,DTheta_UUh,Se);
        [KL_T]=CondL_T(NL);
        [RHOV,DRHOVh,DRHOVT]=Density_V(TT,hh,g,Rv,NN);
        [W,WW,MU_W,D_Ta]=CondL_Tdisp(POR,Theta_LL,Theta_L,SSUR,RHO_bulk,RHOL,TT,Theta_s,h,hh,W_Chg,NL,nD,Delt_t,Theta_g,KLT_Switch);
        if CPLD==1
            [L]= Latent(TT,NN);
            [Xaa,XaT,Xah,DRHODAt,DRHODAz,RHODA]=Density_DA(T,RDA,P_g,Rv,DeltZ,h,hh,TT,P_gg,Delt_t,NL,NN,DRHOVT,DRHOVh,RHOV);
            [c_unsat,Lambda_eff,ZETA,ETCON,EHCAP,TETCON,EfTCON]=CondT_coeff(Theta_LL,Lambda1,Lambda2,Lambda3,RHO_bulk,Theta_g,RHODA,RHOV,c_a,c_V,c_L,NL,nD,ThmrlCondCap,ThermCond,HCAP,SF,TCA,GA1,GA2,GB1,GB2,HCD,ZETA0,CON0,PS1,PS2,XWILT,XK,TT,POR,DRHOVT,L,D_A,Theta_V,Theta_II,TCON_dry,Theta_s,XSOC,TPS1,TPS2,TCON0,TCON_s,FEHCAP,RHOI,RHOL,c_unsat,Lambda_eff,ETCON,EHCAP,TETCON,EfTCON,ZETA);
            [k_g]=Condg_k_g(POR,NL,m,Theta_g,g,MU_W,Ks,RHOL,SWCC,Imped,Ratio_ice,Soilairefc,MN);
            [D_V,Eta,D_A]=CondV_DE(Theta_LL,TT,fc,Theta_s,NL,nD,Theta_g,POR,ThmrlCondCap,ZETA,XK,DVT_Switch,Theta_UU);
            [D_Vg,V_A,Beta_g,DPgDZ,Beta_gBAR,Alpha_LgBAR]=CondV_DVg(P_gg,Theta_g,Sa,V_A,k_g,MU_a,DeltZ,Alpha_Lg,KaT_Switch,Theta_s,Se,NL,DPgDZ,Beta_gBAR,Alpha_LgBAR,Beta_g);
            run h_sub;
        else
            [BCh,SAVEhh,SAVETT,TQL,CHK,CHK1,h_frez,hh_frez,KL_h,QLH,QLT,Chh,QL,Theta_LL,Theta_L,Theta_UU,Theta_U,Theta_II,DTheta_LLh,DTheta_UUh,AVAIL0,RHS,Rn_SOIL,Evap,EVAP,...
                Trap,r_a_SOIL,Resis_a,Srt,Precip,TT,T,hh,h,QMT]=Diff_Moisture_Heat(DTheta_UUh,Theta_U,hh_frez,h_frez,hBOT,IBOT,L_f,SAVE,RHS,Precip,...
                NBCTB,NBCT,BCT,BCTB,Delt_t,EVAP,r_a_SOIL,Tbtm,Rn_SOIL,KL_h,DeltZ,Ta,HR_a,U,Ts,Rv,g,rwuef,Theta_UU,Rn,Gvc,Rns,Srt,...
                Precip_msr,SUMTIME,NBCh,NBChB,BCh,BChB,KT,DSTOR0,NBChh,TIME,h_SUR,Theta_L,hh,h,T,m,n,Theta_r,Theta_s,Alpha,XElemnt,NN,Theta_LL,...
                Lambda1,Lambda2,Lambda3,RHO_bulk,Theta_g,RHODA,RHOV,c_a,c_V,c_L,NL,nD,ThmrlCondCap,ThermCond,HCAP,SF,TCA,GA1,GA2,GB1,GB2,HCD,ZETA0,CON0,...
                PS1,PS2,XWILT,XK,TT,POR,DRHOVT,D_A,Theta_V,Theta_II,TCON_dry,XSOC,TPS1,TPS2,TCON0,TCON_s,RHOI,RHOL,c_unsat,Lambda_eff,ETCON,EHCAP,FEHCAP,TETCON,EfTCON,ZETA,...
                KfL_h,DTheta_LLh,NaN,KL_T,Chh,IP0STm,EVAP_PT,TRAP_PT,BOTm,Sh);
        end
        if NBCh==1
            DSTOR=0;
            RS=0;
        elseif NBCh==2
            AVAIL=-BCh;
            EXCESS=(AVAIL+QMT(KT))*Delt_t;
            if abs(EXCESS/Delt_t)<=1e-10,EXCESS=0;end
            DSTOR=min(EXCESS,DSTMAX);
            if mean(hh(NN-30:NN))>=-9E-1
                if DSTOR<0
                    DSTOR=0;
                end
                if EXCESS<0
                    EXCESS=0;
                end
            end
            RS=(EXCESS-DSTOR)/Delt_t;
        else
            AVAIL=AVAIL0-Evap(KT);
            EXCESS=(AVAIL+QMT(KT))*Delt_t;
            if abs(EXCESS/Delt_t)<=1e-10,EXCESS=0;end
            DSTOR=0;
            RS(KT)=0;
        end
        if CPLD==1
            if Soilairefc==1
                run Air_sub;
            end

            if Thmrlefc==1
                run Enrgy_sub;
            end
        end

        if max(CHK)<0.005 && max(CHK1)<0.01           %&& max(FCHK)<0.001 %&& max(hCHK)<0.001 %&& min(KCHK)>0.001
            break
        end
        hSAVE=hh(NN);
        TSAVE=TT(NN);
    end
    TIMEOLD=KT;
    KIT;
    KIT=0;
    [TT_CRIT,hh_frez]=HT_frez(hh,T0,g,L_f,TT,NN,hd);
    [hh,COR,CORh,Theta_V,Theta_g,Se,KL_h,Theta_LL,DTheta_LLh,KfL_h,KfL_T,hh_frez,Theta_UU,DTheta_UUh,Theta_II]=SOIL2(hh,COR,hThmrl,NN,NL,TT,Tr,Hystrs,XWRE,Theta_s,IH,KIT,Theta_r,Alpha,n,m,Ks,Theta_L,h,Thmrlefc,POR,Theta_II,CORh,hh_frez,h_frez,SWCC,Theta_U,XCAP,Phi_s,RHOI,RHOL,Lamda,Imped,L_f,g,T0,TT_CRIT,KfL_h,KfL_T,KL_h,Theta_UU,Theta_LL,DTheta_LLh,DTheta_UUh,Se);
    [KT,TIME,Delt_t,tS,NBChh,IRPT1,IRPT2,Delt_t0]=TimestepCHK(Delt_t0,NBCh,BCh,NBChh,DSTOR,DSTOR0,EXCESS,QMT,Precip,Evap,hh,IRPT1,NN,SAVEhh,SAVETT,TT_CRIT,T0,TT,T,EPCT,h,T_CRIT,xERR,hERR,TERR,Theta_LL,Theta_L,Theta_UU,Theta_U,KT,TIME,Delt_t,NL,Thmrlefc,NBChB,NBCT,NBCTB,tS,uERR);
    if Delt_t<1e-10
        save('202105021a.mat')
    end
    SAVEtS=tS;Delt_t1=0;
    if IRPT1==0 && IRPT2==0
        %% calculate the water flux
        if KT<=1
            QS(:)=QS(:)+TQL(:).*(Delt_t/86400);
        else
            Delt_t1=SUMTIME(KT)-SUMTIME(KT-1);
            QS(:)=QS(:)+TQL(:).*(Delt_t1/86400);
        end

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
                    DDTheta_LLh(ML,KT)=DTheta_LLh(ML,2);
                    DDTheta_UUh(ML,KT)=DTheta_UUh(ML,2);
                end
            end
            run ObservationPoints
        end

        RrNSTM=0;
        RrOGSTM=0;

        if (TEND1-TIME)<1E-3
            NumN=100;IP0STmN=1;
            ThOLD=zeros(NumN,IP0STmN);
            THH=zeros(NumN,IP0STmN);TTOLD=zeros(NumN,IP0STmN);TTTt=zeros(NumN,IP0STmN);ThOLD_frez=zeros(NumN,IP0STmN);
            THH_frez=zeros(NumN,IP0STmN);
            % save the curve of soil water content at the end of the time
            Shh(1:1:NN)=hh(NN:-1:1);
            STheta_LL(2:1:NN)=Theta_LL(NL:-1:1,1);
            STheta_L(2:1:NN)=Theta_L(NL:-1:1,1);
            STheta_LL(1)=Theta_LL(NL,2);STheta_L(1)=Theta_L(NL,2);

            [dMOD,QqS,DW,RrNSTM,RrOGSTM,ZTB1G]=HYDRUS1RECHARGE(TEND1/86400,TTIME,ITERQ3D,IP0STm,IGRID,Q3DF,THETA0,ICTRL0,STheta_LL,TIME/86400,...
                QS,Delt_t/86400,TTEND,ZTB0G,Shh,KPILLAR,BOTm.*HPUNIT,RrNG,SYSTG,SSSTG,XElemnt,KTN);

            if abs(RrNSTM)>100 || isnan(RrNSTM) || isinf(RrNSTM)
                RrNSTM=0;
                RrOGSTM=0;
                save('20210608A.mat');
            end
            THH(1:NN+1,1)=hh(1:NN+1);
            ThOLD(1:NN+1,1)=h(1:NN+1);
            TTTt(1:NN+1,1)=TT(1:NN+1);
            TTOLD(1:NN+1,1)=TOLD(1:NN+1);
            THH_frez(1:NN+1,1)=hh_frez(1:NN+1);
            ThOLD_frez(1:NN+1,1)=hOLD_frez(1:NN+1);

            save('stemmus202201.mat');
            clear -global i NN L IBOT hBOT XElemnt hhh hh h hOLD
            return
        end
    end
end
end