function StartInit

global InitND1 InitND2 InitND3 InitND4 InitND5 BtmT BtmX Btmh InitND6% Preset the measured depth to get the initial T, h by interpolation method.
global InitT0 InitT1 InitT2 InitT3 InitT4 InitT5 InitT6 Dmark
global T MN ML NL NN DeltZ Elmn_Lnth Tot_Depth InitLnth
global InitX0 InitX1 InitX2 InitX3 InitX4 InitX5 InitX6 Inith0 Inith1 Inith2 Inith3 Inith4 Inith5 Inith6
global h Theta_s Theta_r m n Alpha Theta_L Theta_LL hh TT P_g P_gg Ks h_frez hh_frez 
global XOLD XWRE NS J POR Thmrlefc IH IS Eqlspace FACc
global porosity SaturatedMC ResidualMC SaturatedK Coefficient_n Coefficient_Alpha
global NBCh NBCT NBCP NBChB NBCTB NBCPB BChB BCTB BCPB BCh BCT BCP BtmPg 
global DSTOR DSTOR0 RS NBChh DSTMAX IRPT1 IRPT2 Soilairefc XK XWILT 
global HCAP TCON SF TCA GA1 GA2 GB1 GB2 S1 S2 HCD TARG1 TARG2 GRAT VPER 
global TERM ZETA0 CON0 PS1 PS2 i KLT_Switch DVT_Switch KaT_Switch
global Kaa_Switch DVa_Switch KLa_Switch
global KfL_T Theta_II Theta_I Theta_UU Theta_U  L_f g T0 TT_CRIT XUOLD XIOLD ISFT TCON_s TCON_dry TCON_L RHo_bulk Imped TPS1 TPS2 FEHCAP TS1 TS2 TCON0 TCON_min Theta_qtz XSOC
global Lamda Phi_s SWCC XCAP ThermCond Gama_hh Theta_a Gama_h hm hd SAVEhh SAVEh
global COR CORh Theta_V Theta_g Se KL_h DTheta_LLh KfL_h DTheta_UUh hThmrl Tr Hystrs KIT RHOI RHOL Coef_Lamda fieldMC Theta_f Ta_msr IGBP_veg_long



%%% constant of init
global MSOC FOC FOS
Constant = constantOfInit(MSOC, FOC, FOS);
hd = Constant.hd;
hm = Constant.hm;
CHST = Constant.CHST;
Elmn_Lnth = Constant.Elmn_Lnth;
Dmark = Constant.Dmark;
Vol_qtz = Constant.Vol_qtz;
VPERSOC = Constant.VPERSOC;
FOSL = Constant.FOSL; %% check this var
Phi_S = Constant.Phi_S;
Phi_soc = Constant.Phi_soc;
Lamda_soc = Constant.Lamda_soc;
Theta_soc = Constant.Theta_soc;


ImpedF=[3 3 3 3 3 3 3];
Ksh(1:6)=[18/(3600*24) 18/(3600*24) 18/(3600*24) 18/(3600*24) 18/(3600*24) 18/(3600*24)];%[1.45*1e-4  1.45*1e-4 0.94*1e-4 0.94*1e-4 0.68*1e-4 0.68*1e-4];
BtmKsh=Ksh(6);
Ksh0=Ksh(1);
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
                XK(MN)=0.11; %0.11 This is for silt loam; For sand XK=0.025
                if SWCC==1   % VG soil water retention model
                Theta_s(MN)=SaturatedMC(J);
                Theta_r(MN)=ResidualMC(J);
                Theta_f(MN)=fieldMC(J);
                XK(MN)=ResidualMC(J)+0.02;
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
                IS(MN-1)=4;IS(5:8)=5;
                J=IS(MN-1);
                POR(MN-1)=porosity(J);
                Ks(MN-1)=SaturatedK(J);
                Theta_qtz(MN-1)=Vol_qtz(J);
                VPER(MN-1,1)=VPERS(J);
                VPER(MN-1,2)=VPERSL(J);
                VPER(MN-1,3)=VPERC(J);
                XSOC(MN-1)=VPERSOC(J);
                Imped(MN)=ImpedF(J);
                XK(MN-1)=0.11; %0.11 This is for silt loam; For sand XK=0.025
                if SWCC==1
                Theta_s(MN-1)=SaturatedMC(J);
                Theta_r(MN-1)=ResidualMC(J);
                Theta_f(MN-1)=fieldMC(J);
                XK(MN-1)=ResidualMC(J)+0.02;
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
                XK(MN-1)=0.11; %0.0550.11 This is for silt loam; For sand XK=0.025
                if SWCC==1
                Theta_s(MN-1)=SaturatedMC(J);
                Theta_r(MN-1)=ResidualMC(J);
                Theta_f(MN-1)=fieldMC(J);
                XK(MN-1)=ResidualMC(J)+0.02;
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
                XK(MN-1)=0.11; %0.0490.11 This is for silt loam; For sand XK=0.025
                if SWCC==1
                Theta_s(MN-1)=SaturatedMC(J);
                Theta_r(MN-1)=ResidualMC(J);
                Theta_f(MN-1)=fieldMC(J);
                XK(MN-1)=ResidualMC(J)+0.02;
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
                XK(MN-1)=0.11; %0.0450.11 This is for silt loam; For sand XK=0.025
                if SWCC==1
                Theta_s(MN-1)=SaturatedMC(J);
                Theta_r(MN-1)=ResidualMC(J);
                Theta_f(MN-1)=fieldMC(J);
                XK(MN-1)=ResidualMC(J)+0.02;
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
                XK(MN-1)=0.11; %0.0450.11 This is for silt loam; For sand XK=0.025
                if SWCC==1
                Theta_s(MN-1)=SaturatedMC(J);
                Theta_r(MN-1)=ResidualMC(J);
                Theta_f(MN-1)=fieldMC(J);
                XK(MN-1)=ResidualMC(J)+0.02;
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
    for MN=1:NN
        h(MN)=-95;
        T(MN)=22;
        TT(MN)=T(MN);
        IS(MN)=1;
        IH(MN)=1;
    end
end  
%%%%%%%%%%%%%%%%%% considering soil hetero effect modify date: 20170103 %%%%       
%%%%% Perform initial freezing temperature for each soil type. %%%%
L_f=3.34*1e5; %latent heat of freezing fusion J Kg-1
T0=273.15; % unit K
 ISFT=0;

for MN=1:NN
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
    h_frez(MN)=h_frez(MN);    
    hh_frez(MN)=h_frez(MN);    
    h(MN)=h(MN)-h_frez(MN);
    hh(MN)=h(MN);SAVEh(MN)=h(MN);SAVEhh(MN)=hh(MN);
    if abs(hh(MN))>=abs(hd)
        Gama_h(MN)=0;
        Gama_hh(MN)=Gama_h(MN);
    elseif abs(hh(MN))>=abs(hm)
        %                 Gama_h(MN)=1-log(abs(hh(MN)))/log(abs(hm));
        Gama_h(MN)=log(abs(hd)/abs(hh(MN)))/log(abs(hd)/abs(hm));
        Gama_hh(MN)=Gama_h(MN);
    else
        Gama_h(MN)=1;
        Gama_hh(MN)=Gama_h(MN);
    end

    if Thmrlefc==1         
        TT(MN)=T(MN);
    end
    if Soilairefc==1
        P_g(MN)=95197.850;
        P_gg(MN)=P_g(MN); 
    end
    if MN<NN
    XWRE(MN,1)=0;
    XWRE(MN,2)=0;
    end
%     XK(MN)=0.0425;
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

% According to hh value get the Theta_LL
% run SOIL2;   % For calculating Theta_LL,used in first Balance calculation.
[hh,COR,CORh,Theta_V,Theta_g,Se,KL_h,Theta_LL,DTheta_LLh,KfL_h,KfL_T,hh_frez,Theta_UU,DTheta_UUh,Theta_II]=SOIL2(hh,COR,hThmrl,NN,NL,TT,Tr,Hystrs,XWRE,Theta_s,IH,KIT,Theta_r,Alpha,n,m,Ks,Theta_L,h,Thmrlefc,POR,Theta_II,CORh,hh_frez,h_frez,SWCC,Theta_U,XCAP,Phi_s,RHOI,RHOL,Lamda,Imped,L_f,g,T0,TT_CRIT,KfL_h,KfL_T,KL_h,Theta_UU,Theta_LL,DTheta_LLh,DTheta_UUh,Se);
% [hh,COR,CORh,Theta_V,Theta_g,Se,KL_h,Theta_LL,DTheta_LLh,KfL_h,KfL_T,hh_frez,Theta_UU,DTheta_UUh,Theta_II,Gama_hh]=SOIL2(hh,COR,hThmrl,NN,NL,TT,Tr,Hystrs,XWRE,Theta_s,IH,KIT,Theta_r,Alpha,n,m,Ks,Theta_L,h,Thmrlefc,POR,Theta_II,CORh,hh_frez,h_frez,SWCC,Theta_U,XCAP,Phi_s,RHOI,RHOL,Lamda,Imped,L_f,g,T0,TT_CRIT,KfL_h,KfL_T,KL_h,Gama_hh,Theta_UU,Theta_LL,DTheta_LLh,DTheta_UUh,Se);
% [hh,COR,CORh,Theta_V,Theta_g,Se,KL_h,Theta_LL,DTheta_LLh,KfL_h,KfL_T,hh_frez,Theta_UU,DTheta_UUh,Theta_II]=SOIL2(hh,COR,hThmrl,NN,NL,TT,Tr,Hystrs,XWRE,Theta_s,IH,KIT,Theta_r,Alpha,n,m,Ks,Theta_L,h,Thmrlefc,POR,Theta_II,CORh,hh_frez,h_frez,SWCC,Theta_U,XCAP,Phi_s,RHOI,RHOL,Lamda,Imped,L_f,g,T0,TT_CRIT,KfL_h,KfL_T,KL_h,Theta_UU,Theta_LL,DTheta_LLh,DTheta_UUh,Se);
% [hh,COR,CORh,Theta_V,Theta_g,Se,KL_h,Theta_LL,DTheta_LLh,KfL_h,KfL_T,hh_frez,Theta_UU,DTheta_UUh,Theta_II]=SOIL2(hh,COR,hThmrl,NN,NL,TT,Tr,Hystrs,XWRE,Theta_s,IH,KIT,Theta_r,Alpha,n,m,Ks,Theta_L,h,Thmrlefc,POR,Theta_II,CORh,hh_frez,h_frez,SWCC,Theta_U,XCAP,Phi_s,RHOI,RHOL,Lamda,Imped,L_f,g,T0,TT_CRIT,KfL_h,KfL_T,KL_h);
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
BCh=-20/3600;
if strcmp(IGBP_veg_long(1:9)', 'Croplands')     %['Croplands']   
NBChB=1;    % Moisture Bottom B.C.: 1 --> Specified matric head (BChB); 2 --> Specified flux(BChB); 3 --> Zero matric head gradient (Gravitiy drainage);
else
NBChB=3;    % Moisture Bottom B.C.: 1 --> Specified matric head (BChB); 2 --> Specified flux(BChB); 3 --> Zero matric head gradient (Gravitiy drainage);
end
BChB=-9e-10; 
if Thmrlefc==1
    NBCT=1;  % Energy Surface B.C.: 1 --> Specified temperature (BCT); 2 --> Specified heat flux (BCT); 3 --> Atmospheric forcing;
    BCT= Ta_msr(1);  % surface temperature
    NBCTB=1;% Energy Bottom B.C.: 1 --> Specified temperature (BCTB); 2 --> Specified heat flux (BCTB); 3 --> Zero temperature gradient;
    if nanmean(Ta_msr)<0
        BCTB  = 0;  %9 8.1
    else
        BCTB  =  nanmean(Ta_msr);
    end
end
if Soilairefc==1
    NBCP=2; % Soil air pressure B.C.: 1 --> Ponded infiltration caused a specified pressure value; 
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
BtmPg=95197.850;     % Atmospheric pressure at the bottom (Pa), set fixed
                                     % with the value of mean atmospheric pressure;
DSTOR=0;                        % Depth of depression storage at end of current time step;
DSTOR0=DSTOR;              % Dept of depression storage at start of current time step;
RS=0;                             % Rate of surface runoff;
DSTMAX=0;                     % Depression storage capacity;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



