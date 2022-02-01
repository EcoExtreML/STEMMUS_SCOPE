function [Rn_SOIL,Evap,EVAP,Trap,r_a_SOIL,Resis_a,Srt]= Evap_Cal(DeltZ,TIME,RHOV,Ta,HR_a,U,Theta_LL,Ts,Rv,g,NL,NN,KT,hh,rwuef,Theta_UU,Rn,T,TT,Gvc,Rns,Srt)
global LAI rl_min RWU lEstot lEctot Tss RWUtot RWUtott RWUtottt EVAPO

%%%%%%% LAI and light extinction coefficient calculation %%%%%%%%%%%%%%%%%%
%%%%%%% LAI and light extinction coefficient calculation %%%%%%%%%%%%%%%%%%
Tao=0.56;  %light attenual coefficient

LAI(KT)=Gvc(KT); %0.9;

if LAI(KT)<=0.01
    LAI(KT)=0.01;
end
%     LAI(KT)=1.2;
if LAI(KT)<=2
    LAI_act(KT)=LAI(KT);
elseif LAI(KT)<=4
    LAI_act(KT)=2;
else
    LAI_act(KT)=0.5*LAI(KT);
end
% LAI(KT)=0;
Gvc(KT)=1-exp(-1*(Tao*LAI(KT)));    

% Set constants
    sigma = 4.903e-9; % Stefan Boltzmann constant MJ.m-2.day-1 FAO56 pag 74
    lambdav = 2.45;    % latent heat of evaporation [MJ.kg-1] FAO56 pag 31
    % Gieske 2003 pag 74 Eq33/DKTgman 2002
    % lambda=2.501-2.361E-3*t, with t temperature evaporative surface (?C)
    % see script Lambda_function_t.py
    Gsc = 0.082;      % solar constant [MJ.m-2.mKT-1] FAO56 pag 47 Eq28
    eps = 0.622;       % ratio molecular weigth of vapour/dry air FAO56 p26 BOX6
    R = 0.287;         % specific gas [kJ.kg-1.K-1]    FAO56 p26 box6
    Cp = 1.013E-3;     % specific heat at cte pressure [MJ.kg-1.?C-1] FAO56 p26 box6
    k = 0.41;          % karman's cte   []  FAO 56 Eq4
    Z=3421;             % altitute of the location(m)
    as=0.25;           % regression constant, expressKTg the fraction of extraterrestrial radiation FAO56 pag50
    bs=0.5;
    alfa=0.23;         % albeo of vegetation set as 0.23
    z_m=10;            % observation height of wKTd speed; 10m
    Lz=240*pi()/180;   % latitude of Beijing time zone west of Greenwich
    Lm=252*pi()/180;    % latitude of Local time, west of Greenwich
    % albedo of soil calculation;
    Theta_LL_sur(KT)=Theta_LL(NL,2);
    Theta_UU_sur(KT)=Theta_UU(NL,2);
    
    if Theta_LL_sur(KT)<0.1
        alfa_s(KT)=0.25;
    elseif Theta_LL_sur(KT)<0.25
        alfa_s(KT)=0.35-Theta_LL_sur(KT);
    else
        alfa_s(KT)=0.1;
    end
    %% AIR PARAMETERS CALCULATION
    % compute DELTA - SLOPE OF SATURATION VAPOUR PRESSURE CURVE
    % [kPa.?C-1]
    % FAO56 pag 37 Eq13
    DELTA(KT) = 4098*(0.6108*exp(17.27*Ta(KT)/(Ta(KT)+237.3)))/(Ta(KT)+237.3)^2;
    % ro_a - MEAN AIR DENSITY AT CTE PRESSURE
    % [kg.m-3]
    % FAO56 pag26 box6
    Pa=101.3*((293-0.0065*Z)/293)^5.26;
    ro_a(KT) = Pa/(R*1.01*(Ta(KT)+273.16));
    % compute e0_Ta - saturation vapour pressure at actual air temperature
    % [kPa]
    % FAO56 pag36 Eq11
    e0_Ta(KT) = 0.6108*exp(17.27*Ta(KT)/(Ta(KT)+237.3));
    e0_Ts(KT) = 0.6108*exp(17.27*Ts(KT)/(Ts(KT)+237.3));
    % compute e_a - ACTUAL VAPOUR PRESSURE
    % [kPa]
    % FAO56 pag74 Eq54
    e_a(KT) = e0_Ta(KT)*HR_a(KT);
    e_a_Ts(KT) = e0_Ts(KT)*HR_a(KT);
    
    % gama - PSYCHROMETRIC CONSTANT
    % [kPa.?C-1]
    % FAO56 pag31 eq8
    gama = 0.664742*1e-3*Pa;
    
    hh_v(KT)=0.12;
    rl_min(KT)=100;
    %     Rn(KT) =Rn_msr(KT);
    if TIME<=1800*3600
    Rn_SOIL(KT) =Rn(KT)*0.68;  % exp(-1*(Tao*LAI(KT)))net radiation for soil
    else
       Rn_SOIL(KT) =Rn(KT)*0.68;
    end
    %% SURFACE RESISTANCE PARAMETERS CALCULATION
    R_a=0.81;R_b=0.004*24*11.6;R_c=0.05;
    rl(KT)=rl_min(KT)/((R_b*Rn(KT)+R_c)/(R_a*(R_b*Rn(KT)+1)));
    
    % r_s - SURFACE RESISTANCE
    % [s.m-1]
    % VEG: Dingman pag 208 (canopy conductance) (equivalent to FAO56 pag21 Eq5)
    r_s_VEG(KT) = rl(KT)/LAI_act(KT);
    
    % SOIL: equation 20 of van de Griend and Owe, 1994
    
        
    if KT<=1047
    r_s_SOIL(KT)=10.0*exp(0.3563*100.0*(0.2050-Theta_LL_sur(KT)));   % 0.25 set as minmum soil moisture for potential evaporation
    elseif KT<=4300
         r_s_SOIL(KT)=10.0*exp(0.3563*100.0*(0.205-Theta_LL_sur(KT)));   % 0.25 set as minmum soil moisture for potential evaporation
    else 
         r_s_SOIL(KT)=10.0*exp(0.3563*100.0*(0.205-Theta_LL_sur(KT)));   % 0.25 set as minmum soil moisture for potential evaporation
    end   
    % r_a - AERODYNAMIC RESISTANCE
    % [s.m-1]
    % FAO56 pag20 eq4- (d - zero displacement plane, z_0m - roughness length momentum transfer, z_0h - roughness length heat and vapour transfer, [m], FAO56 pag21 BOX4
    r_a_VEG(KT) = log((2-(2*hh_v(KT)/3))/(0.123*hh_v(KT)))*log((2-(2*hh_v(KT)/3))/(0.0123*hh_v(KT)))/((k^2)*U(KT))*100;  % s m-1
    % r_a of SOIL
    % Liu www.hydrol-earth-syst-sci.net/11/769/2007/
    % equation for neutral conditions (eq. 9)
    % only function of ws, it is assumed that roughness are the same for any type of soil
    
    RHOV_sur(KT)=RHOV(NN);
    %     Theta_LL_sur(KT)=Theta_LL(NL,2);
    %
    %     Theta_UU_sur(KT)=Theta_UU(NL,2);
    P_Va(KT)=0.611*exp(17.27*Ta(KT)/(Ta(KT)+237.3))*HR_a(KT);  %The atmospheric vapor pressure (KPa)  (1000Pa=1000.1000.g.100^-1.cm^-1.s^-2)
    
    RHOV_A(KT)=P_Va(KT)*1e4/(Rv*(Ta(KT)+273.15));              %  g.cm^-3;  Rv-cm^2.s^-2.Cels^-1
    
    z_ref=200;          % cm The reference height of tempearature measurement (usually 2 m)
    d0_disp=0;          % cm The zero-plane displacement (=0 m)
    z_srT=0.1;          % cm The surface roughness for the heat flux (=0.001m) 0.01m
    VK_Const=0.41;   % The von Karman constant (=0.41)
    z_srm=0.1;          % cm The surface roughness for momentum flux (=0.001m) 0.01m
    U_wind=198.4597; % The mean wind speed at reference height.(cm.s^-1)
    
    MO(KT)=(Ta(KT)*U(KT)^2)/(g*(Ta(KT)-T(NN))*log(z_ref/z_srm));  % Wind speed should be in cm.s^-1, MO-cm;
    
    Zeta_MO(KT)=z_ref/MO(KT);
    
    if abs(Ta(KT)-T(NN))<=0.01
        Stab_m(KT)=0;
        Stab_T(KT)=0;
    elseif Zeta_MO(KT)<0    %Ta(KT)<T(NN) ||
        Stab_T(KT)=-2*log((1+sqrt(1-16*Zeta_MO(KT)))/2);
        Stab_m(KT)=-2*log((1+(1-16*Zeta_MO(KT))^0.25)/2)+Stab_T(KT)/2+2*atan((1-16*Zeta_MO(KT))^0.25)-pi/2;
    else
        if Zeta_MO(KT)>1
            Stab_T(KT)=5;
            Stab_m(KT)=5;
        else
            Stab_T(KT)=5*Zeta_MO(KT);
            Stab_m(KT)=5*Zeta_MO(KT);
        end
    end
    
    Velo_fric(KT)=U(KT)*VK_Const/(log((z_ref-d0_disp+z_srm)/z_srm)+Stab_m(KT));
    
    Resis_a(KT)=(log((z_ref-d0_disp+z_srT)/z_srT)+Stab_T(KT))/(VK_Const*Velo_fric(KT));     %(s.cm^-1)
    
    Resis_s(KT)=10*exp(35.63*(0.205-Theta_LL_sur(KT)))/100; %(-805+4140*(Theta_s(J)-Theta_LL_sur(KT)))/100;  % s.m^-1----->0.001s.cm^-1

    r_a_SOIL(KT) = log((2.0)/0.001)*log(2.0/0.001)/((k^2)*U(KT))*100;   %(s.m^-1) ORIGINAL Zom=0.0058
    Evapo(KT)=(RHOV_sur(KT)-RHOV_A(KT))/(Resis_s(KT)+r_a_SOIL(KT)/100);
   
    % PT/PE - Penman-Montheith
    % mm.day-1
    % FAO56 pag19 eq3
    % VEG
    PT_PM_VEG(KT) = (DELTA(KT)*(Rn(KT))+3600*ro_a(KT)*Cp*(e0_Ta(KT)-e_a(KT))/r_a_VEG(KT))/(lambdav*(DELTA(KT) + gama*(1+r_s_VEG(KT)/r_a_VEG(KT))))/3600;

    if LAI(KT)==0 || hh_v(KT)==0
        PT_PM_VEG(KT)=0;
    end
    PE_PM_SOIL(KT) = (DELTA(KT)*(Rn_SOIL(KT))+3600*ro_a(KT)*Cp*(e0_Ta(KT)-e_a(KT))/r_a_SOIL(KT))/(lambdav*(DELTA(KT) + gama*(1+r_s_SOIL(KT)/r_a_SOIL(KT))))/3600;
    Evap(KT)=0.1*PE_PM_SOIL(KT); % transfer to second value-G_SOIL(KT)
%     Evap(KT)=LE_msr(KT);
    EVAP(KT,1)=Evap(KT);
    Tp_t(KT)=0.1*PT_PM_VEG(KT); %transfer to second value
    TP_t(KT,1)=Tp_t(KT);

if rwuef==1
    if KT<=3288+1103
        H1=0;H2=-31;H4=-8000;H3L=-600;H3H=-300;
        if Tp_t(KT)<0.02/3600
            H3=H3L;
        elseif Tp_t(KT)>0.05/3600
            H3=H3H;
        else
            H3=H3H+(H3L-H3H)/(0.03/3600)*(0.05/3600-Tp_t(KT));
        end
    else
        H1=-1;H2=-5;H4=-16000;H3L=-600;H3H=-300;
        if Tp_t(KT)<0.02/3600
            H3=H3L;
        elseif Tp_t(KT)>0.05/3600
            H3=H3H;
        else
            H3=H3H+(H3L-H3H)/(0.03/3600)*(0.05/3600-Tp_t(KT));
        end
    end
    % piecewise linear reduction function
    MN=0;
    for ML=1:NL
        for ND=1:2
            MN=ML+ND-1;
            if hh(MN) >=H1
                alpha_h(ML,ND) = 0;
            elseif  hh(MN) >=H2
                alpha_h(ML,ND) = (H1-hh(MN))/(H1-H2);
            elseif  hh(MN) >=H3
                alpha_h(ML,ND) = 1;
            elseif  hh(MN) >=H4
                alpha_h(ML,ND) = (hh(MN)-H4)/(H3-H4);
            else
                alpha_h(ML,ND) = 0;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%% Root lenth distribution %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    Elmn_Lnth=0;
    RL=sum(DeltZ);
    Elmn_Lnth(1)=0;
    RB=0.9;
    LR=log(0.01)/log(RB);
    RY=1-RB^(LR);
    
    if LR<=1
        for ML=1:NL-1      % ignore the surface root water uptake 1cm
            for ND=1:2
                MN=ML+ND-1;
                bx(ML,ND)=0;
            end
        end
    else
        FRY=zeros(NL,1);bx=zeros(NL,2);
        for ML=2:NL
            Elmn_Lnth(ML)=Elmn_Lnth(ML-1)+DeltZ(ML-1);
            if Elmn_Lnth<RL-LR      %(KT)
                %                 bx(ML)=0;
                FRY(ML)=1;
                %             elseif Elmn_Lnth>=RL-LR(KT) && Elmn_Lnth<RL-0.2*LR(KT)
                %                 bx(ML)=2.0833*(1-(RL-Elmn_Lnth)/LR(KT))/LR(KT);
            else
                FRY(ML)=(1-RB^(RL-Elmn_Lnth(ML)))/RY;
            end
        end
        for ML=1:NL-1
            bx(ML)=FRY(ML)-FRY(ML+1);
            if bx(ML)<0
                bx(ML)=0;
            end
            bx(NL)=FRY(NL);
        end
        for ML=1:NL
            for ND=1:2
                MN=ML+ND-1;
                bx(ML,ND)=bx(MN);
            end
        end
    end
    %root zone water uptake
    Trap_1(KT)=0;
    for ML=1:NL
        for ND=1:2
            MN=ML+ND-1;
            Srt_1(ML,ND)=alpha_h(ML,ND)*bx(ML,ND)*Tp_t(KT);
            if TT(ML)<0
                Srt_1(ML:NL,ND)=0;
            end
        end
        Trap_1(KT)=Trap_1(KT)+(Srt_1(ML,1)+Srt_1(ML,2))/2*DeltZ(ML);   % root water uptake integration by DeltZ;
    end

    %     % consideration of water compensation effect
    if Tp_t(KT)==0
        Trap(KT)=0;
    else
        wt(KT)=Trap_1(KT)/Tp_t(KT);
        wc=1; % compensation coefficient
        Trap(KT)=0;
        if wt(KT)<wc
            for ML=1:NL
                for ND=1:2
                    MN=ML+ND-1;
                    Srt(ML,ND)=alpha_h(ML,ND)*bx(ML,ND)*Tp_t(KT)/wc;
                    if TT(ML)<0
                        Srt(ML:NL,ND)=0;
                    end
                end
                Trap(KT)=Trap(KT)+(Srt(ML,1)+Srt(ML,2))/2*DeltZ(ML);   % root water uptake integration by DeltZ;
            end
        else
            for ML=1:NL
                for ND=1:2
                    MN=ML+ND-1;
                    Srt(ML,ND)=alpha_h(ML,ND)*bx(ML,ND)*Tp_t(KT)/wt(KT);
                end
                Trap(KT)=Trap(KT)+(Srt(ML,1)+Srt(ML,2))/2*DeltZ(ML);   % root water uptake integration by DeltZ;
            end
        end
    end
end
if (lEctot<1000 && lEstot<800 && lEctot>-300 && lEstot>-300 && any(TT>5))
    lambda1      = (2.501-0.002361*Ta(KT))*1E6;
    lambda2      = (2.501-0.002361*Tss)*1E6;
    Evap(KT)=lEstot/lambda2*0.1; % transfer to second value unit: cm s-1
    EVAP(KT,1)=Evap(KT);
    Tp_t(KT)=lEctot/lambda1*0.1; % transfer to second value  
    Srt1=RWU*100./DeltZ';
else 
    Evap(KT)=0; % transfer to second value unit: cm s-1
    EVAP(KT,1)=Evap(KT);
    Tp_t(KT)=0; % transfer to second value 
    Srt1=0./DeltZ'; 
end
RWUtot(:,KT)=RWU;
RWUtott=sum(RWUtot);
RWUtottt=RWUtott*3600*1000;
EVAPO(KT)=Evap(KT);
 for ML=1:NL
                for ND=1:2
                    MN=ML+ND-1;
                    Srt(ML,ND)=Srt1(ML,1);
                end
 end
                Trap(KT)=0;
                Trap(KT)=Tp_t(KT);   % root water uptake integration by DeltZ;

  
end