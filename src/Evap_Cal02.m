function [Evap,EVAP,Trap]= Evap_Cal(TT,bx,DeltZ,LAI,LAI_act,TIME,RHOV,Ta,HR_a,U,Theta_LL,Ts,Rv,g,NL,NN,KT,Evaptranp_Cal,Coefficient_n,Coefficient_Alpha,Theta_r,Theta_s,DURTN,PME,PT_PM_0,hh,rwuef,J)
% [Evap,EVAP,trap,Srt]= Evap_Cal(AFTP_TIME,LAI,LAI_act,TIME,RHOV,Ta,HR_a,U,Theta_LL,Ts,Rv,g,NL,NN,KT,Evaptranp_Cal,Coefficient_n,Coefficient_Alpha,Theta_r,Theta_s,DURTN,PME,PT_PM_0,hh,rwuef,J);
% global RHOV_sur RHOV_A Resis_a Resis_s P_Va Velo_fric Theta_LL_sur  % RHOV_sur and Theta_L_sur should be stored at each time step.
% global z_ref z_srT z_srm VK_Const d0_disp U_wind MO Ta U Ts Zeta_MO Stab_m Stab_T       % U_wind is the mean wind speed at height z_ref (m¡¤s^-1), U is the wind speed at each time step.
% global Rv g HR_a NL NN Evap KT RHOV Theta_LL EVAP
% global Evaptranp_Cal DayNum t Ep DURTN  ETp Tp Tao LAI Tp_t Trap AFTP_TIME
% global H1 H2 H3 H4 alpha_h bx LR Lm fr RL0 Srt Elmn_Lnth DeltZ RL TIME rwuef hh
% global PT_PM_0 PT_PM_VEG PE_PM_SOIL T_act Theta_s J Resis_s1 Resis_s2 Resis_s3 Resis_s4 Resis_s5 Resis_a1
% global Rns Rns_SOIL RnL G_SOIL r_s_VEG r_s_SOIL r_a_VEG r_a_SOIL Rn_SOIL Rn  Rs Ra w w1 w2 ws Rs0 e0_Ts e_a_Ts e0_Ta e_a wt wc Srt_1 rl LAI_act rl_min
% global Es PME Kcb ET Theta_r Coefficient_n Coefficient_Alpha hh_v T TT
global Srt
%%%%%%% LAI and light extinction coefficient calculation %%%%%%%%%%%%%%%%%%
AFTP_TIME=TIME/86400+9;   %9 is the daynumber initial;
LAI_msr=[0	0	0	0	0	0	0	0	0.015	0.03	0.045	0.06	0.075	0.09	0.105	0.12	0.135	0.15	0.165	0.18	0.195	0.21	0.225	0.24	0.255	0.27	0.285	0.3	0.315	0.33	0.345	0.36	0.375	0.39	0.404761905	0.41952381	0.434285714	0.449047619	0.463809524	0.478571429	0.493333333	0.508095238	0.522857143	0.537619048	0.552380952	0.567142857	0.581904762	0.596666667	0.611428571	0.626190476	0.640952381	0.655714286	0.67047619	0.685238095	0.7	0.701923077	0.703846154	0.705769231	0.707692308	0.709615385	0.711538462	0.713461538	0.715384615	0.717307692	0.719230769	0.721153846	0.723076923	0.725	0.726923077	0.728846154	0.730769231	0.732692308	0.734615385	0.736538462	0.738461538	0.740384615	0.742307692	0.744230769	0.746153846	0.748076923	0.75	0.750625	0.75125	0.751875	0.7525	0.753125	0.75375	0.754375	0.755	0.755625	0.75625	0.756875	0.7575	0.758125	0.75875	0.759375	0.76	0.760625	0.76125	0.761875	0.7625	0.763125	0.76375	0.764375	0.765	0.765625	0.76625	0.766875	0.7675	0.768125	0.76875	0.769375	0.77	0.770625	0.77125	0.771875	0.7725	0.773125	0.77375	0.774375	0.775	0.775625	0.77625	0.776875	0.7775	0.778125	0.77875	0.779375	0.78	0.78875	0.7975	0.80625	0.815	0.82375	0.8325	0.84125	0.85	0.962763778	1.075527556	1.188291333	1.301055111	1.413818889	1.526582667	1.639346444	1.752110222	1.864874	1.97401464	2.08315528	2.19229592	2.30143656	2.4105772	2.51971784	2.62885848	2.73799912	2.84713976	2.9562804	3.001320524	3.046360647	3.091400771	3.136440895	3.181481018	3.226521142	3.271561265	3.316601389	3.361641513	3.406681636	3.45172176	3.501979467	3.552237173	3.60249488	3.652752587	3.703010293	3.753268	3.745658286	3.738048571	3.730438857	3.722829143	3.715219429	3.707609714	3.7	3.697288283	3.694576567	3.69186485	3.689153133	3.686441417	3.6837297	3.681017983	3.678306267	3.6356476	3.592988933	3.550330267	3.5076716	3.465012933	3.422354267	3.3796956	3.316985079	3.254274558	3.191564036	3.128853515	3.066142994	3.003432473	2.940721952	2.87801143	2.815300909	2.752590388	2.689879867	2.683550538	2.677221209	2.67089188	2.664562551	2.658233222	2.651903893	2.645574564	2.639245236	2.632915907	2.626586578	2.620257249	2.61392792	2.607598591	2.601269262	2.594939933	2.588610604	2.582281276	2.575951947	2.569622618	2.563293289	2.55696396	2.550634631	2.544305302	2.537975973	2.531646644	2.525317316	2.518987987	2.512658658];
    DayNum=fix(TIME/3600/24)+1;
    if DayNum>length(LAI_msr)
        DayNum=length(LAI_msr);
    end
    DayHour=TIME/3600/24-DayNum+1;
    if DayNum-1==0
        LAI(KT)=LAI_msr(DayNum);
    else
        LAI(KT)=(LAI_msr(DayNum)-LAI_msr(DayNum-1))*DayHour+LAI_msr(DayNum);
    end

% if AFTP_TIME<14
%     LAI(KT)=0; % emergance daynumber is 8
% elseif AFTP_TIME<22
%     LAI(KT)=(AFTP_TIME-14)*0.45/8; % emergance daynumber is 8
% else
%     LAI(KT)=-0.0021*AFTP_TIME^2+0.299*AFTP_TIME-5.1074;
% end
% if LAI(KT)<0
%     LAI(KT)=0;
% end
LAI(KT)=LAI(KT);
if LAI(KT)<=2
    LAI_act(KT)=LAI(KT);
elseif LAI(KT)<=4
    LAI_act(KT)=2;
else
    LAI_act(KT)=0.5*LAI(KT);
end
if TIME>=912*3600 && TIME<=3239*3600
LAI_act(KT)=0.1*LAI_act(KT);
end
Tao=0.6;  %light attenual coefficient

if Evaptranp_Cal==1

    % input data
    n(J)=Coefficient_n(J);
    Alpha(J)=Coefficient_Alpha(J);
    m(J)=1-1/n(J);
    AFTP_TIME=TIME/86400+27;   %27 is the daynumber initial;
    Theta_LL_sur1(KT)=Theta_LL(NL,2);
    Theta_LL_sur2(KT)=Theta_LL(NL-14,2);
    Theta_LL_sat(KT)=Theta_r(J)+(Theta_s(J)-Theta_r(J))/(1+abs(Alpha(J)*200)^n(J))^m(J);
    coef_e=0.9; % 0.8-1.0 Johns 1982, Kemp 1997
    coef_p=2.15;  %2-2.3
    Kcbmax=1.20;  %for maize 1.10, for wheat 1.07 (allen 2009;duchemin 2006)
    coef_kd=-0.7; %-0.84 for wheat
    Kcb(KT)=Kcbmax*(1-exp(coef_kd*LAI(KT)));
    if TIME<DURTN
        DayNum=fix(TIME/3600/24)+1;
        t=TIME-(DayNum-1)*86400;
        ETp=0.1.*PME(14:115);
        ET=0.1.*PT_PM_0(14:115);
        Ep(KT)=(exp(-1*(Tao*LAI(KT))))*ETp(DayNum);
        
        if hh(NN)>-1e5
            if (Theta_LL_sur1(KT)/Theta_LL_sat(KT))>((Ep(KT)/coef_e)^0.5)
                Es(KT)=Ep(KT);
            else
                Es(KT)=coef_e*(Theta_LL_sur1(KT)/Theta_LL_sat(KT))^coef_p;
            end
        else
            Es(KT)=coef_e*((Theta_LL_sur1(KT)+Theta_LL_sur2(KT))/2/Theta_LL_sat(KT))^coef_p;
        end
        % generate E and T function with time
        if t>0.264*24*3600 && t<0.736*24*3600
            
            Tp(KT)=Kcb(KT)*ET(DayNum); % Tao LAI set as constant
            Evap(KT)=(2.75*sin(2*pi()*t/3600/24-pi()/2)/86400)*Es(KT); % transfer to second value
            EVAP(KT,1)=Evap(KT);
            Tp_t(KT)=(2.75*sin(2*pi()*t/3600/24-pi()/2)/86400)*Tp(KT); % transfer to second value
            TP_t(KT,1)=Tp_t(KT);
        else
            Tp(KT)=Kcb(KT)*ET(DayNum); % Tao LAI set as constant
            %           Tp(KT)=(1-exp(-1*(Tao*LAI(KT))))*ET(DayNum); % Tao LAI set as constant
            Evap(KT)=(0.24/86400)*Es(KT); % transfer to second value
            EVAP(KT,1)=Evap(KT);
            Tp_t(KT)=(0.24/86400)*Tp(KT); % transfer to second value
            TP_t(KT,1)=Tp_t(KT);
        end
    else
        DayNum=fix(TIME/3600/24);
        t=TIME-(DayNum-1)*86400;
        ETp=0.1.*PME(14:115);
        ET=0.1.*PT_PM_0(14:115);
        Ep(KT)=(exp(-1*(Tao*LAI(KT))))*ETp(DayNum);
        %        Kcb(KT)=Kcbmax*(1-exp(coef_kd*LAI_act(KT)));
        if hh(NN)>-1e5
            if (Theta_LL_sur1(KT)/Theta_LL_sat(KT))>((Ep(KT)/coef_e)^0.5)
                Es(KT)=Ep(KT);
            else
                Es(KT)=coef_e*(Theta_LL_sur1(KT)/Theta_LL_sat(KT))^coef_p;
            end
        else
            Es(KT)=coef_e*((Theta_LL_sur1(KT)+Theta_LL_sur2(KT))/2/Theta_LL_sat(KT))^coef_p;
        end
        % generate E and T function with time
        if t>0.264*24*3600 && t<0.736*24*3600
            
            Tp(KT)=Kcb(KT)*ET(DayNum); % Tao LAI set as constant
            Evap(KT)=(2.75*sin(2*pi()*t/3600/24-pi()/2)/86400)*Es(KT); % transfer to second value
            EVAP(KT,1)=Evap(KT);
            Tp_t(KT)=(2.75*sin(2*pi()*t/3600/24-pi()/2)/86400)*Tp(KT); % transfer to second value
            TP_t(KT,1)=Tp_t(KT);
        else
            Tp(KT)=Kcb(KT)*ET(DayNum); % Tao LAI set as constant
            %           Tp(KT)=(1-exp(-1*(Tao*LAI(KT))))*ET(DayNum); % Tao LAI set as constant
            Evap(KT)=(0.24/86400)*Es(KT); % transfer to second value
            EVAP(KT,1)=Evap(KT);
            Tp_t(KT)=(0.24/86400)*Tp(KT); % transfer to second value
            TP_t(KT,1)=Tp_t(KT);
        end
    end
else
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
    Z=521;             % altitute of the location(m)
    as=0.25;           % regression constant, expressKTg the fraction of extraterrestrial radiation FAO56 pag50
    bs=0.5;
    alfa=0.23;         % albeo of vegetation set as 0.23
    z_m=10;            % observation height of wKTd speed; 10m
    Lz=240*pi()/180;   % latitude of Beijing time zone west of Greenwich
    Lm=252*pi()/180;    % latitude of Local time, west of Greenwich
    % albedo of soil calculation;
    Theta_LL_sur(KT)=Theta_LL(NL,2);
    if Theta_LL_sur(KT)<0.1
        alfa_s(KT)=0.25;
    elseif Theta_LL_sur(KT)<0.25
        alfa_s(KT)=0.35-Theta_LL_sur(KT);
    else
        alfa_s(KT)=0.1;
    end
    JN(KT)=fix(TIME/3600/24)+293;    % day number
    if JN(KT)>366
       JN(KT)=JN(KT)-366;
    end
    n=[8.1	8.6	0	8.8	0	9	7	9.2	5.6	0	2.5	8.8	9.6	7.8	7.3	7.7	9.2	9	7.4	0	8.5	0	5	9.1	5.9	8.7	3.3	0	8.3	8.4	7.9	4.6	0	0	0	8.4	6.2	2.9	8.5	6.8	3.2	0	0	0	2.7	8.4	7.7	8.2	7.7	8.2	8.3	7.2	7.1	4	0	0	2.2	0	0	0	6.8	0	0	5.8	3.9	8.3	8	4.7	0	0	0	6.5	8.6	8.2	8.1	3.4	5.5	6.1	4.5	0	7.6	1.9	7.6	7.1	8.6	8.2	7.8	5.6	8.6	7.7	8.1	7	0	0	7.7	7.6	8	9.2	8.3	8.6	8.3	6.6	7.1	5	5.6	0	0	0	0	4.4	0	0	0	3.6	0	0	8.5	4	2	8.6	0	0	0	0	4	4.3	8.7	3	3.9	0	2.4	3.7	1.2	0	8.1	9	9.1	9.1	7.9	9.2	10	0	0	5.8	0	4.6	3.4	5.2	0	8.7	8	7.8	9.6	4.5	8.6	8.5	8.8	0	8.9	10.4	10.3	4.4	9.5	3.2	7.8	0	8.7	0	1.9	9.9	9.5	4.8	10.6	10.4	10.9	10.8	7.8	11	7.8	11	10.3	0	0	0	0	0	3.2	9.8	9	10.6	10.3	0	0	9.2	6.1	11.5	10	0	0	0	0	0	5.5	12	12.4	12.4	11.6	2.2	0	0	0	9.2	9.9	12.1	11	3.5	4.5	2	0	5.3	6.5	0	7.7	0	2.4	11.5	11.2	9	11.5	3.4	8.7	11.2	0	1.5];
    N=[10.93701633	10.9034753	10.87016469	10.83709407	10.80427316	10.77171186	10.73942023	10.70740848	10.675687	10.64426632	10.61315713	10.58237029	10.55191677	10.52180771	10.49205435	10.46266811	10.43366048	10.40504308	10.37682764	10.34902597	10.32164997	10.2947116	10.26822291	10.24219596	10.21664286	10.19157573	10.16700671	10.14294792	10.11941145	10.09640934	10.0739536	10.05205613	10.03072873	10.00998311	9.989830838	9.970283311	9.951351769	9.933047254	9.915380594	9.898362384	9.882002964	9.866312401	9.851300468	9.836976625	9.823349998	9.81042936	9.798223113	9.786739272	9.775985443	9.765968807	9.756696108	9.748173632	9.740407195	9.733402131	9.727163276	9.721694959	9.717000992	9.713084659	9.709948706	9.707595342	9.706026226	9.705242465	9.705244613	9.70603267	9.707606078	9.709963725	9.71310395	9.717024544	9.721722754	9.727195294	9.73343835	9.74044759	9.748218175	9.756744769	9.756744825	9.766021613	9.776042303	9.786800148	9.798287964	9.810498142	9.823422668	9.837053135	9.85138077	9.866396443	9.882090693	9.898453747	9.915475535	9.933145715	9.951453692	9.970388636	9.989939503	10.01009506	10.03084389	10.05217444	10.074075	10.09653377	10.11953883	10.14307819	10.16713981	10.19171159	10.21678141	10.24233713	10.26836665	10.29485784	10.32179862	10.34917699	10.37698095	10.40519863	10.43381819	10.46282793	10.49221622	10.52197155	10.55208253	10.5825379	10.61332654	10.64443746	10.67585981	10.70758291	10.73959622	10.77188935	10.8044521	10.8372744	10.87034637	10.90365826	10.93720053	10.97096377	11.00493875	11.0391164	11.07348782	11.10804425	11.14277709	11.17767792	11.21273844	11.24795051	11.28330613	11.31879743	11.3544167	11.39015633	11.42600884	11.46196687	11.49802317	11.5341706	11.57040211	11.60671076	11.64308967	11.67953206	11.71603121	11.75258048	11.78917327	11.82580304	11.8624633	11.89914757	11.93584944	11.97256248	12.0092803	12.04599651	12.0827047	12.11939848	12.15607142	12.19271707	12.22932896	12.26590057	12.30242534	12.33889663	12.37530778	12.41165203	12.44792255	12.48411243	12.52021469	12.55622222	12.59212782	12.6279242	12.66360393	12.69915947	12.73458317	12.76986722	12.80500369	12.83998451	12.87480148	12.90944621	12.9439102	12.97818478	13.01226111	13.0461302	13.07978291	13.11320992	13.14640174	13.17934873	13.21204108	13.24446881	13.27662179	13.30848971	13.34006212	13.37132839	13.40227777	13.43289933	13.46318202	13.49311465	13.52268587	13.55188426	13.58069823	13.60911612	13.63712616	13.66471648	13.69187516	13.7185902	13.74484953	13.77064107	13.7959527	13.82077229	13.84508771	13.86888685	13.89215763	13.91488805	13.93706614	13.95868004	13.979718	14.00016838	14.0200197	14.03926062	14.05788001	14.07586694	14.09321068	14.10990077	14.125927	14.14127945	14.1559485	14.16992485	14.18319955	14.19576402	14.20761004	14.2187298	14.2291159	14.23876138];
    h_v=[0	0	0	0	0	0	0	0	0.003 	0.006 	0.009 	0.012 	0.015 	0.018 	0.021 	0.024 	0.027 	0.030 	0.033 	0.036 	0.040 	0.043 	0.046 	0.049 	0.052 	0.055 	0.058 	0.061 	0.064 	0.067 	0.070 	0.073 	0.076 	0.079 	0.079 	0.080 	0.080 	0.080 	0.080 	0.081 	0.081 	0.081 	0.081 	0.082 	0.082 	0.082 	0.083 	0.083 	0.083 	0.083 	0.084 	0.084 	0.084 	0.084 	0.085 	0.085 	0.085 	0.086 	0.086 	0.086 	0.086 	0.087 	0.087 	0.087 	0.087 	0.088 	0.088 	0.088 	0.088 	0.089 	0.089 	0.089 	0.090 	0.090 	0.090 	0.090 	0.091 	0.091 	0.091 	0.091 	0.092 	0.092 	0.092 	0.093 	0.093 	0.093 	0.093 	0.094 	0.094 	0.094 	0.094 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.095 	0.100 	0.104 	0.109 	0.113 	0.118 	0.122 	0.127 	0.131 	0.136 	0.148 	0.160 	0.171 	0.183 	0.195 	0.207 	0.219 	0.230 	0.242 	0.254 	0.262 	0.270 	0.279 	0.287 	0.295 	0.303 	0.311 	0.320 	0.328 	0.336 	0.356 	0.375 	0.395 	0.414 	0.434 	0.453 	0.473 	0.492 	0.502 	0.512 	0.523 	0.533 	0.543 	0.553 	0.564 	0.574 	0.584 	0.605 	0.626 	0.647 	0.667 	0.688 	0.709 	0.730 	0.731 	0.732 	0.732 	0.733 	0.734 	0.735 	0.735 	0.736 	0.737 	0.739 	0.740 	0.741 	0.742 	0.744 	0.745 	0.747 	0.750 	0.752 	0.755 	0.757 	0.760 	0.762 	0.765 	0.767 	0.770 	0.772 	0.773 	0.774 	0.775 	0.776 	0.777 	0.778 	0.780 	0.781 	0.782 	0.783 	0.784 	0.785 	0.786 	0.787 	0.788 	0.789 	0.790 	0.791 	0.792 	0.793 	0.795 	0.796 	0.797 	0.798 	0.799 	0.799 	0.799 	0.799];
    rl_min=[540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	540	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	2000	1858.736059	1736.111111	1628.664495	1533.742331	1449.275362	1373.626374	1305.483029	1243.781095	1187.648456	1136.363636	1089.324619	1046.025105	1006.036217	968.9922481	934.5794393	902.5270758	872.600349	844.5945946	818.3306056	793.6507937	107.8582435	104.7904192	101.8922853	99.15014164	96.55172414	94.08602151	91.74311927	89.5140665	87.39076155	85.36585366	83.43265793	81.58508159	79.81755986	78.125	76.50273224	74.94646681	73.45225603	72.01646091	70.63572149	69.30693069	68.02721088	66.79389313	65.60449859	64.45672192	63.34841629	62.27758007	61.24234471	60.24096386	59.27180356	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	58.33333333	61.53846154	65.11627907	69.13580247	315.7894737	338.028169	363.6363636	393.442623	714.2857143	1098.039216	1565.217391	2146.341463	2888.888889	3870.967742	5230.769231	7238.095238	10500	16727.27273];
%     DayNum=fix(TIME/3600/24)+1;
    n(KT)=n(DayNum);
    N(KT)=N(DayNum);
    % h_v(KT)=h_v(DayNum);
    %rl_min(KT)=139;
    
    DayHour=TIME/3600/24-DayNum+1;
    if DayNum-1==0
        hh_v(KT)=h_v(DayNum);
    else
        hh_v(KT)=(h_v(DayNum)-h_v(DayNum-1))*DayHour+h_v(DayNum);
    end
    rl_min(KT)=rl_min(DayNum);
    % 6-23 TO 7-31
    %Kcb=Mdata(:,15);
    
    % Calculation procedure
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
    
    %% RADIATION PARAMETERS CALCULATION
    % compute dr - KTverse distance to the sun
    % [rad]
    % FAO56 pag47 Eq23
    dr(KT) = 1+0.033*cos(2*pi()*JN(KT)/365);
    
    % compute delta - solar declKTation
    % [rad]
    % FAO56 pag47 Eq24
    delta(KT) = 0.409*sin(2*pi()*JN(KT)/365-1.39);
    
    % compute Sc - seasonnal correction of solar time
    % [hour]
    % FAO56 pag47 Eq32
    Sc = [];
    b(KT) = 2.0*pi()*(JN(KT)-81.0)/364.0;    % Eq 34
    Sc(KT) = 0.1645*sin(2*b(KT)) - 0.1255*cos(b(KT)) - 0.025*sin(b(KT));
    
    % compute w - solar time angle at the midpoKTt of the period (time)
    % [rad]
    % FAO56 pag48 Eq31
    w(KT)=pi()/12*((TIME/3600-fix(TIME/3600/24-0.001)*24-0.5+0.06667*(Lz-Lm)+Sc(KT))-12);
    % compute w1 - solar time angle at the beginning of the period (time)
    % [rad]
    % FAO56 pag47 Eq29
    tl = 1;  %  hourly data
    w1(KT) = (w(KT) - pi()*tl/24.0);
    
    % compute w2 - solar time angle at the end of the period (time + 1h)
    % [rad]
    % FAO56 pag47 Eq30
    w2(KT) = w(KT) + pi()*tl/24.0;
    
    % compute ws - sunset hour angle
    % [rad]
    % FAO56 pag47 Eq25
    ws(KT)=acos((-1)*tan(0.599)*tan(delta(KT)));  %for daily duration
    
    % compute Ra - extraterrestrial radiation
    % [MJ.m-2.hour-1]
    % FAO56 pag47 Eq28
    if w(KT)> -ws(KT) &&  w(KT) < ws(KT)
        Ra(KT)=12*60/pi()*Gsc*dr(KT)*((w2(KT)-w1(KT))*sin(0.599)*sin(delta(KT)) + cos(0.599)*cos(delta(KT))*(sin(w2(KT))-sin(w1(KT))));
    else
        Ra(KT)=0;
    end
    if Ra(KT)<0
        Ra(KT)=0;
    end
    % compute Rs0 - clear-sky solar (shortwave) radiation
    % [MJ.m-2.hour-1]
    % FAO56 pag51 Eq37
    Rs0(KT) = (0.75+2E-5*Z)*Ra(KT);
    %    Rs0_Watts = Rs0*24.0/0.08864
    % daylight hours N
%     N(KT)=24*ws(KT)/pi();
    
    % compute Rs - SHORTWAVE RADIATION
    % [MJ.m-2.hour-1]
    % FAO56 pag51 Eq37
    Rs(KT)=(as+bs*n(KT)/N(KT))*Ra(KT);
    
    % compute Rns - NET SHORTWAVE RADIATION
    % [MJ.m-2.day-1]
    % FAO56 pag51 Eq37
    % for each type of vegetation, crop and soil (albedo dependent)
    Rns(KT)= (1-alfa)*Rs(KT);
    Rns_SOIL(KT) = (1 - alfa_s(KT))*Rs(KT);
    % compute Rnl - NET LONGWAVE RADIATION
    % [MJ.m-2.hour-1]
    % FAO56 pag51 Eq37 and pag74 of hourly computKTg
    r_sunset=[];
    r_angle=[];
    R_i=[];
    if (ws(KT) - 0.52) <= w(KT) && w(KT)<= (ws(KT) - 0.10) %FAO56: (ws(KT) - 0.79) <= w(KT) <= (ws(KT) - 0.52)
        R_i = 1;
        if Rs0(KT) > 0
            if Rs(KT)/Rs0(KT) > 0.3
                r_sunset = Rs(KT)/Rs0(KT);
            else
                r_sunset = 0.3;
            end
        else
            r_sunset = 0.75;  % see FAO56 pag75
        end
    end
    if (ws(KT) - 0.10) < w(KT) || w(KT) <= (-ws(KT)+ 0.10)
        if R_i>0
            r_angle(KT)=r_sunset;
        else
            r_angle(KT)=0.75;  %see FAO56 pag75
        end
    else
        r_angle(KT)=Rs(KT)/Rs0(KT);
    end
    RnL(KT)=(sigma/24*((Ta(KT) + 273.16)^4)*(0.34-0.14*sqrt(e_a(KT)))*(1.35*r_angle(KT)-0.35));
    
    if RnL(KT)<0
        r_angle(KT)=0.8;
        RnL(KT)=(sigma/24*((Ta(KT) + 273.16)^4)*(0.34-0.14*sqrt(e_a(KT)))*(1.35*r_angle(KT)-0.35));
    end
    
    Rn(KT) = Rns(KT) - RnL(KT);  % net radiation for vegetation
    %    Rn_SOIL(KT) = Rns_SOIL(KT) - RnL(KT);  % net radiation for vegetation
    Rn_SOIL(KT) =(1 - alfa_s(KT))*Rn(KT)*exp(-1*(Tao*LAI(KT)));  % net radiation for soil
    % soil heat flux
%     Rn_SOIL(KT) =Rn(KT);  % net radiation for soil
    
    t=TIME-(fix(TIME/3600/24))*86400;
    if t>0.264*24*3600 && t<0.736*24*3600
        G(KT)=0.1*Rn(KT);
        G_SOIL(KT)=0.1*Rn_SOIL(KT);
%         Rn_SOIL(KT) =Rn_SOIL(KT) ;
    else
%         Rn_SOIL(KT) =Rn_SOIL(KT)-0.2 ;
        G(KT)=0.5*Rn(KT);
        G_SOIL(KT)=0.5*Rn_SOIL(KT);
    end
    
    %% SURFACE RESISTANCE PARAMETERS CALCULATION
    R_a=0.81;R_b=0.004*24*11.6;R_c=0.05;
    % R_fun(KT)=((R_b*Rns(KT)+R_c)/(R_a*(R_b*Rns(KT)+1)));
    rl(KT)=rl_min(KT)/((R_b*Rns(KT)+R_c)/(R_a*(R_b*Rns(KT)+1)));
    
    % r_s - SURFACE RESISTANCE
    % [s.m-1]
    % VEG: Dingman pag 208 (canopy conductance) (equivalent to FAO56 pag21 Eq5)
    r_s_VEG(KT) = rl(KT)/LAI_act(KT);
    
    % SOIL: equation 20 of van de Griend and Owe, 1994
    %Theta_LL_sur(KT)=Theta_LL(NL,2);
    
    r_s_SOIL(KT)=10.0*exp(0.3563*100.0*(0.28-Theta_LL_sur(KT)));   % 0.25 set as minmum soil moisture for potential evaporation
    %r_s_SOIL(i)=10.0*exp(0.3563*100.0*(fc(i)-por(i)));
    % correction wKTdspeed measurement and scalKTg at h+2m
    % [m.s-1]
    % FAO56 pag56 eq47
    
    % r_a - AERODYNAMIC RESISTANCE
    % [s.m-1]
    % FAO56 pag20 eq4- (d - zero displacement plane, z_0m - roughness length momentum transfer, z_0h - roughness length heat and vapour transfer, [m], FAO56 pag21 BOX4
    r_a_VEG(KT) = log((2-(2*hh_v(KT)/3))/(0.123*hh_v(KT)))*log((2-(2*hh_v(KT)/3))/(0.0123*hh_v(KT)))/((k^2)*U(KT))*100;
    % r_a of SOIL
    % Liu www.hydrol-earth-syst-sci.net/11/769/2007/
    % equation for neutral conditions (eq. 9)
    % only function of ws, it is assumed that roughness are the same for any type of soil

    RHOV_sur(KT)=RHOV(NN);
    Theta_LL_sur(KT)=Theta_LL(NL,2);
    
    P_Va(KT)=0.611*exp(17.27*Ta(KT)/(Ta(KT)+237.3))*HR_a(KT);  %The atmospheric vapor pressure (KPa)  (1000Pa=1000.1000.g.100^-1.cm^-1.s^-2)
    
    RHOV_A(KT)=P_Va(KT)*1e4/(Rv*(Ta(KT)+273.15));              %  g.cm^-3;  Rv-cm^2.s^-2.Cels^-1
    
    z_ref=200;          % cm The reference height of tempearature measurement (usually 2 m)
    d0_disp=0;          % cm The zero-plane displacement (=0 m)
    z_srT=0.1;          % cm The surface roughness for the heat flux (=0.001m)
    VK_Const=0.41;   % The von Karman constant (=0.41)
    z_srm=0.1;          % cm The surface roughness for momentum flux (=0.001m)
    U_wind=198.4597; % The mean wind speed at reference height.(cm.s^-1)
    
    MO(KT)=(Ta(KT)*U(KT)^2)/(g*(Ta(KT)-Ts(KT))*log(z_ref/z_srm));  % Wind speed should be in cm.s^-1, MO-cm;
    
    Zeta_MO(KT)=z_ref/MO(KT);
    
    if abs(Ta(KT)-Ts(KT))<=0.01
        Stab_m(KT)=0;
        Stab_T(KT)=0;
    elseif Ta(KT)<Ts(KT) || Zeta_MO(KT)<0
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
    
    % Resis_a(KT)=(log((z_ref-d0_disp+z_srT)/z_srT)+Stab_T(KT))/(VK_Const*Velo_fric(KT));     %(s.cm^-1)
    %
    % Resis_s(KT)=10*exp(35.63*(0.25-Theta_LL_sur(KT)))/100; %(-805+4140*(Theta_s(J)-Theta_LL_sur(KT)))/100;  % s.m^-1----->0.001s.cm^-1
    % %
    % % Evap(KT)=(RHOV_sur(KT)-RHOV_A(KT))/(Resis_s(KT)+Resis_a(KT));
    % % EVAP(KT,1)=Evap(KT);
    
     Resis_a(KT)=((log((z_ref-d0_disp+z_srT)/z_srT)+Stab_T(KT))/(VK_Const*Velo_fric(KT)))*100;     %(s.cm^-1)
    r_a_SOIL(KT) = log((2.0)/0.0058)*log(2.0/0.0058)/((k^2)*U(KT))*100;   %(s.m^-1)
    
    % PT/PE - Penman-Montheith
    % mm.day-1
    % FAO56 pag19 eq3
    % VEG

    PT_PM_VEG(KT) = (DELTA(KT)*(Rn(KT)-G(KT))+3600*ro_a(KT)*Cp*(e0_Ta(KT)-e_a(KT))/r_a_VEG(KT))/(lambdav*(DELTA(KT) + gama*(1+r_s_VEG(KT)/r_a_VEG(KT))))/3600;
    % reference et ET0
    %PT_PM_0(KT) = (0.408*DELTA(KT)*Rn(KT)+gama*900/(Ta(KT)+273)*(e0_Ta(KT)-e_a(KT))*u_2(KT))/(DELTA(KT) + gama*(1+0.34*u_2(KT)));
    %T_act(KT)=PT_PM_0(KT)*Kcb(KT);
    % for SOIL
    if LAI(KT)==0 || hh_v(KT)==0
        PT_PM_VEG(KT)=0;
    end
    PE_PM_SOIL(KT) = (DELTA(KT)*(Rn_SOIL(KT)-G_SOIL(KT))+3600*ro_a(KT)*Cp*(e0_Ta(KT)-e_a(KT))/r_a_SOIL(KT))/(lambdav*(DELTA(KT) + gama*(1+r_s_SOIL(KT)/r_a_SOIL(KT))))/3600;
    Evap(KT)=0.1*PE_PM_SOIL(KT); % transfer to second value
    EVAP(KT,1)=Evap(KT);
    Tp_t(KT)=0.1*PT_PM_VEG(KT); % transfer to second value
    TP_t(KT,1)=Tp_t(KT);
    
end
if rwuef==1
    % water stress function parameters
%     H1=-15;H2=-50;H4=-9000;H3L=-900;H3H=-500;  %% for maize 
%     H1=-1;H2=-5;H4=-16000;H3L=-900;H3H=-500;  %% for winter wheat    
%     if Tp_t(KT)<0.02/3600
%         H3=H3L;
%     elseif Tp_t(KT)>0.05/3600
%         H3=H3H;
%     else
%         H3=H3H+(H3L-H3H)/(0.03/3600)*(0.05/3600-Tp_t(KT));
%     end
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
            if hh(MN) >=H1,
                alpha_h(ML,ND) = 0;
            elseif  hh(MN) >=H2,
                alpha_h(ML,ND) = (H1-hh(MN))/(H1-H2);
            elseif  hh(MN) >=H3,
                alpha_h(ML,ND) = 1;
            elseif  hh(MN) >=H4,
                alpha_h(ML,ND) = (hh(MN)-H4)/(H3-H4);
            else
                alpha_h(ML,ND) = 0;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%% Root lenth distribution %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Lm=150;
%     RL0=2;   
    %%%%%%%%%%%%%%%%%%% crop stage specific root growth rate %%%%%%%%%%%%%%%
%     if TIME<=24*50*3600
%         r=1.78E-06;    % root growth rate cm/s
%         Lm=47;
%         RL0=2;
%         fr(KT)=RL0/(RL0+(Lm-RL0)*exp((-1)*(r*TIME)));
%         LR(KT)=Lm*fr(KT);
%     elseif TIME<=3095*3600
% %         r=2.96E-08;
% %         Lm=47;
% %         RL0=2;
% %         fr(KT)=RL0/(RL0+(Lm-RL0)*exp((-1)*(r*TIME)));
%         LR(KT)=47;
%     else
%         r=1.69E-07;
%         Lm=150;
%         RL0=47;
%         fr(KT)=RL0/(RL0+(Lm-RL0)*exp((-1)*(r*TIME)));
%         LR(KT)=Lm*fr(KT);
%     end


    if TIME<=3095*3600
        r=1.78E-06;    % root growth rate cm/s
        Lm=47;
        RL0=2;
        fr(KT)=RL0/(RL0+(Lm-RL0)*exp((-1)*(r*TIME)));
        LR(KT)=Lm*fr(KT);
    else
        r=6.69E-07;
        Lm=150;
        RL0=47;
        fr(KT)=RL0/(RL0+(Lm-RL0)*exp((-1)*(r*(TIME-3095*3600))));
        LR(KT)=Lm*fr(KT);
    end

%     fr(KT)=RL0/(RL0+(Lm-RL0)*exp((-1)*(r*TIME)));
%     LR(KT)=Lm*fr(KT);
    RL=300;
    Elmn_Lnth=0;
    
    if LR(KT)<=1
        for ML=1:NL-1      % ignore the surface root water uptake 1cm
            for ND=1:2
                MN=ML+ND-1;
                bx(ML,ND)=0;
            end
        end
    else
        for ML=1:NL
            Elmn_Lnth=Elmn_Lnth+DeltZ(ML);
            if Elmn_Lnth<RL-LR(KT)
                bx(ML)=0;
            elseif Elmn_Lnth>=RL-LR(KT) && Elmn_Lnth<RL-0.2*LR(KT)
                bx(ML)=2.0833*(1-(RL-Elmn_Lnth)/LR(KT))/LR(KT);
            else
                bx(ML)=1.66667/LR(KT);
            end
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