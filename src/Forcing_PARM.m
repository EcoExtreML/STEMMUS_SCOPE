function Forcing_PARM
global Umax Umin tmax1 DayNum Hrmax Hrmin Tmax Tmin Um Ur DURTN 
global Rn TIMEOLD 
global Ta Ts U HR_a SH Rns Rnl TIME KT P_Va RHOV_A Rv TopPg h_SUR NBCT
global Ts_msr

    if TIMEOLD==KT 
        Ta(KT)=0;HR_a(KT)=0;Ts(KT)=0;U(KT)=0;SH(KT)=0;Rns(KT)=0;Rnl(KT)=0;Rn(KT)=0;TopPg(KT)=0;h_SUR(KT)=0;
    end
    if NBCT==1 && KT==1
        Ts(1)=0;
    end
        
    
    Tmax=[31.3	28.3	35.5	32.9	38.1	38.3	37.2	36.1	31.6	28.4	33.2	30.1	36.6	34	35	32.1	29.1	26.7	30.8	31.5	32	28.9	27.3	33.2	29.6	28.5	30.3	31.8	28.4	26.4	28.9	28.8	31	32.8	31.9	32	26.8	32.1	34.6	30.6	32.4	33	35	35.7	35.4	30.8	27.4	30.5	33.1	32.3	32.3	34.3	35.9	36.4	37.5	33.8	34.5	33.6	32.5	33.1	34.1	31.9	31.2	32	31.2	30.4	27	33.4	29.4	27.9	28.7	24.9	26.5	22.8	27.5	28.5	26	25.4	27	31.1	28.9	31.6	31.9	33.8	31.7	34	30.4	28.7	23.6	21.4	25.5	21.6	20.2	23.4	19.5	19.7	25.4	32.7	28.4	23.5	29	24.1];
    Tmin=[21.7	22.2	19.8	26.7	19.3	19	21.1	25.6	26.2	23.2	23.3	22.3	23.2	22	24	24.4	22.6	22.5	20.8	23.9	22.7	24	22.7	18.3	22	21.2	21.3	21.1	23.6	21.1	21.4	23.2	23.7	22.9	24.9	22	21.2	18.2	21.2	19.8	22.4	23.2	24	23.4	23.9	19.8	20.1	18.4	20.5	23.3	21.2	22.1	22.5	23.1	25.2	25.5	21.6	22.4	20.3	21.2	22.5	23.3	22.9	22.9	20.4	22.3	19.1	15.9	18	16.4	18	18.6	18	18.7	16.5	18.4	18.8	17.5	17.2	17.1	18.9	17.1	12.7	15.2	17.1	18.5	20.8	21.6	17.5	18.6	18.5	18.4	13.4	14.7	12.6	12.2	11.7	11.5	13.1	14.2	16.6	13.1];  
  
    
    %  Unit of windspeed (cm/s)
    Um=100.*[1.121926613	0.822746183	0.822746183	0.822746183	1.570697258	1.79508258	1.421107043	1.645492365	1.047131505	0.972336398	0.747951075	2.169058118	1.570697258	0.89754129	0.972336398	2.169058118	2.169058118	2.842214086	1.047131505	2.169058118	1.271516828	1.271516828	2.169058118	0.747951075	0.673155968	1.645492365	1.19672172	0.747951075	1.19672172	1.570697258	0.747951075	1.121926613	1.346311935	1.346311935	2.169058118	1.720287473	1.047131505	1.121926613	0.822746183	1.121926613	0.89754129	0.89754129	0.822746183	1.047131505	1.121926613	2.991804301	0.89754129	0.972336398	1.047131505	1.271516828	0.822746183	0.822746183	0.59836086	0.747951075	1.346311935	0.673155968	1.047131505	1.49590215	1.047131505	1.19672172	1.271516828	1.421107043	0.89754129	0.972336398	0.89754129	1.047131505	3.290984731	0.89754129	0.972336398	0.822746183	0.972336398	1.121926613	0.822746183	1.645492365	1.19672172	0.822746183	0.822746183	0.822746183	0.822746183	0.972336398	0.822746183	1.49590215	1.49590215	0.89754129	0.972336398	0.59836086	1.421107043	0.673155968	1.346311935	0.448770645	0.59836086	1.271516828	2.767418978	0.89754129	0.59836086	0.747951075	0.972336398	0.822746183	1.19672172	1.121926613	1.19672172	0.972336398];
    Hrmax=0.01.*[82	87	95	73	75	61	61	67	88	96	98	100	95	82	86	72	84	75	87	83	99	94	90	79	100	100	91	99	100	100	100	94	94	98	81	90	96	100	99	100	95	98	96	100	91	98	100	100	100	100	100	98	100	100	79	89	97	74	100	88	91	88	95	85	79	89	93	100	98	85	83	93	100	95	98	98	95	100	96	85	99	100	100	100	78	91	70	97	100	100	100	100	97	100	100	100	100	100	100	95	100	100];
    Hrmin=0.01.*[42	53	29	29	15	21	29	37	50	74	58	69	31	48	46	48	58	57	51	55	51	70	66	41	58	63	45	45	62	73	62	68	60	56	51	50	60	46	41	51	55	56	48	42	43	58	62	54	55	44	54	50	44	42	31	33	35	42	41	44	43	46	49	39	49	57	63	28	32	43	45	59	50	67	42	42	55	55	50	35	47	34	28	24	38	31	44	53	74	76	56	74	79	37	51	50	35	22	35	59	23	40];
    % Unit in cm/s
  if TIME<DURTN
    DayNum=fix(TIME/3600/24)+1;
    Tmax=Tmax(DayNum);
    Tmin=Tmin(DayNum);
    Tmax(KT)=Tmax;
    Tmin(KT)=Tmin;
    Ta(KT)=Ta(KT)+(Tmax(KT)+Tmin(KT))/2+(Tmax(KT)-Tmin(KT))/2*cos(2*pi()*((TIME-(DayNum-1)*86400)/3600-17)/24);
    % soil surface temperature

    %Tsmax=Tsmax(DayNum);
    %Tsmin=Tsmin(DayNum);
    %Tsmax(KT)=Tsmax;
    %Tsmin(KT)=Tsmin;
    %Ts(KT)=Ts(KT)+(Tsmax(KT)+Tsmin(KT))/2+(Tsmax(KT)-Tsmin(KT))/2*cos(2*pi()*((TIME-(DayNum-1)*86400)/3600-13)/24);
    
    % Humidity
    Hrmin(KT)=Hrmin(DayNum);
    Hrmax(KT)=Hrmax(DayNum);
    HR_a(KT)=(Hrmax(KT)+Hrmin(KT))/2+(Hrmax(KT)-Hrmin(KT))/2*cos(2*pi()*((TIME-(DayNum-1)*86400)/3600-6)/24);
    
    % wind Ur=Umax/Umin; according to the previous observations, set as 2/0.2=10;
    % Tmax set as 1500h;
    Um(KT)=Um(DayNum);
    tmax1 =15;    
    if Um(KT)<80
        Ur=2.5;
    elseif Um(KT)<200
        Ur=9;
    else
        Ur=15;
    end
   Umax(KT)=2*Ur*Um(KT)/(1+Ur);
%     Umin=21;
    U(KT)=Um(KT)+(Umax(KT)-Um(KT))*cos(2*pi()*((TIME-(DayNum-1)*86400)/3600-tmax1)/24);
   else 
    DayNum=fix(TIME/3600/24);
    Tmax=Tmax(DayNum);
    Tmin=Tmin(DayNum);
    Tmax(KT)=Tmax;
    Tmin(KT)=Tmin;
    Ta(KT)=Ta(KT)+(Tmax(KT)+Tmin(KT))/2+(Tmax(KT)-Tmin(KT))/2*cos(2*pi()*((TIME-(DayNum-1)*86400)/3600-17)/24);
% soil surface temperature

    %Tsmax=Tsmax(DayNum);
    %Tsmin=Tsmin(DayNum);
    %Tsmax(KT)=Tsmax;
    %Tsmin(KT)=Tsmin;
    %Ts(KT)=Ts(KT)+(Tsmax(KT)+Tsmin(KT))/2+(Tsmax(KT)-Tsmin(KT))/2*cos(2*pi()*((TIME-(DayNum-1)*86400)/3600-13)/24);
     
    % Humidity
    Hrmin(KT)=Hrmin(DayNum);
    Hrmax(KT)=Hrmax(DayNum);
    HR_a(KT)=(Hrmax(KT)+Hrmin(KT))/2+(Hrmax(KT)-Hrmin(KT))/2*cos(2*pi()*((TIME-(DayNum-1)*86400)/3600-6)/24);

    % wind Ur=Umax/Umin; according to the previous observations, set as 2/0.2=10;
    % Tmax set as 1500h;
 Um(KT)=Um(DayNum);
    tmax1 =15;    
    if Um(KT)<80
        Ur=2.5;
    elseif Um(KT)<200
        Ur=9;
    else
        Ur=15;
    end
    Umax(KT)=2*Ur*Um(KT)/(1+Ur);
    Umin(KT)=2*Um(KT)/(1+Ur);
%    Umin=21;
    U(KT)=Um(KT)+(Umax(KT)-Um(KT))*cos(2*pi()*((TIME-(DayNum-1)*86400)/3600-tmax1)/24);
   end
    if U(KT)<20
        U(KT)=20;
    end
    %for i=1:8
    %    Ts(KT)=Ts(KT)+Ts_a(i)*cos(i*TIME*Ts_w)+Ts_b(i)*sin(i*TIME*Ts_w);
    %end
    %Ts(KT)=Ts(KT)+Ts_a0;
    Ts(KT)=Ts_msr(KT);
%    U(KT)=U_msr(KT);
 
   TopPg(KT)=1013250*exp((-1)*9.80665*0.0289644*521/8.31432/(Ts(KT)+273.15));
    
%     for i=1:6
%         h_SUR(KT)=h_SUR(KT)+Hsur_a(i)*cos(i*TIME*Hsur_w)+Hsur_b(i)*sin(i*TIME*Hsur_w);
%     end
%     h_SUR(KT)=h_SUR(KT)+Hsur_a0;      
    
    P_Va(KT)=0.611*exp(17.27*Ta(KT)/(Ta(KT)+237.3))*HR_a(KT);  %The atmospheric vapor pressure (KPa)  (1000Pa=1000.1000.g.100^-1.cm^-1.s^-2)

    RHOV_A(KT)=P_Va(KT)*1e4/(Rv*(Ta(KT)+273.15)); 