function EvapTransp_Cal
global PT_PM_0 PT_PM_VEG T_act PME
% Set constants
sigma = 4.903e-9; % Stefan Boltzmann constant MJ.m-2.day-1 FAO56 pag 74
lambdav = 2.45;    % latent heat of evaporation [MJ.kg-1] FAO56 pag 31
% Gieske 2003 pag 74 Eq33/Dingman 2002
% lambda=2.501-2.361E-3*t, with t temperature evaporative surface (?C)
% see script Lambda_function_t.py
Gsc = 0.082;      % solar constant [MJ.m-2.min-1] FAO56 pag 47 Eq28
eps = 0.622;       % ratio molecular weigth of vapour/dry air FAO56 p26 BOX6
R = 0.287;         % specific gas [kJ.kg-1.K-1]    FAO56 p26 box6
Cp = 1.013E-3;     % specific heat at cte pressure [MJ.kg-1.?C-1] FAO56 p26 box6
k = 0.41;          % karman's cte   []  FAO 56 Eq4
Z=521;             % altitute of the location(m)
as=0.25;           % regression constant, expressing the fraction of extraterrestrial radiation FAO56 pag50
bs=0.5;
alfa=0.23;         % albeo of vegetation set as 0.23
z_m=10;            % observation height of wind speed; 10m
% input meterology data
Mdata=xlsread('C:\Users\ÍõÔÆö­\Desktop\STEMMUS EXERCISE -I_O Optimize\Meterology data','sheet1','B5:AA5860');
Ta=Mdata(:,1);   % air temperature
RH=Mdata(:,2);   % relative humidity
Ws=Mdata(:,3);     % wind speed at 2m
Precip=Mdata(:,4)./18000;    % precipitation
Ts1=Mdata(:,5);  % soil temperature at 20cm
Ts2=Mdata(:,6);  % soil temperature at 40cm
Ts3=Mdata(:,7);  % soil temperature at 60cm
SMC1=Mdata(:,8);    % soil moisture content at 20cm
SMC2=Mdata(:,9);    % soil moisture content at 40cm
SMC3=Mdata(:,10);   % soil moisture content at 60cm
G1=Mdata(:,11);    % soil heat flux  1
G2=Mdata(:,12);    % heat heat flux  2
G3=Mdata(:,13);    % soil heat flux  3
Rn=Mdata(:,14);    % net rediation
LAI=Mdata(:,26);   % leaf area index
% Calculation procedure
for iN=1:tS+1
    %% AIR PARAMETERS CALCULATION
    % compute DELTA - SLOPE OF SATURATION VAPOUR PRESSURE CURVE
    % [kPa.?C-1]
    % FAO56 pag 37 Eq13
    DELTA(iN) = 4098*(0.6108*exp(17.27*Ta(iN)/(Ta(iN)+237.3)))/(Ta(iN)+237.3)^2;
    % ro_a - MEAN AIR DENSITY AT CTE PRESSURE
    % [kg.m-3]
    % FAO56 pag26 box6
    Pa=101.3*((293-0.0065*Z)/293)^5.26;
    ro_a(iN) = Pa/(R*1.01*(Tm(iN)+273.16));
    % compute e0_Ta - saturation vapour pressure at actual air temperature
    % [kPa]
    % FAO56 pag36 Eq11
    e0_Tm(iN) = 0.6108*exp(17.27*Tm(iN)/(Tm(iN)+237.3));
    
    % compute e_a - ACTUAL VAPOUR PRESSURE
    % [kPa]
    % FAO56 pag74 Eq54
    e_a(iN) = e0_Tm(iN)*RHa(iN)/100;
    % gama - PSYCHROMETRIC CONSTANT
    % [kPa.?C-1]
    % FAO56 pag31 eq8
    gama = 0.664742*1e-3*Pa;
    
    %% RADIATION PARAMETERS CALCULATION
    % compute dr - inverse distance to the sun
    % [rad]
    % FAO56 pag47 Eq23
    dr(iN) = 1+0.033*cos(2*pi()*JN(iN)/365);
    
    % compute delta - solar declination
    % [rad]
    % FAO56 pag47 Eq24
    delta(iN) = 0.409*sin(2*pi()*JN(iN)/365-1.39);   

    % compute compute ws - sunset hour angle
    % [rad]
    % FAO56 pag48 Eq31
    Ws(iN)=acos((-1)*tan(0.599)*tan(delta(iN)));
    
    % compute Ra - extraterrestrial radiation
    % [MJ.m-2.day-1]
    % FAO56 pag47 Eq28
    Ra(iN)=24*60/pi()*Gsc*dr(iN)*(Ws(iN)*sin(0.599)*sin(delta(iN))+cos(0.599)*cos(delta(iN))*sin(Ws(iN)));
    %Ra_Watts.append(Ra[j]*24/0.08864)
    % compute Rs0 - clear-sky solar (shortwave) radiation
    % [MJ.m-2.day-1]
    % FAO56 pag51 Eq37
    Rs0(iN) = (0.75+2E-5*Z)*Ra(iN);
    
    % compute Rs - SHORTWAVE RADIATION
    % [MJ.m-2.day-1]
    % FAO56 pag51 Eq37
    Rs(iN)=(as+bs*n(iN)/N(iN))*Ra(iN);
    
    % compute Rns - NET SHORTWAVE RADIATION
    % [MJ.m-2.day-1]
    % FAO56 pag51 Eq37
    % for each type of vegetation, crop and soil (albedo dependent)
    Rns(iN)= (1-alfa)*Rs(iN);
    % compute Rnl - NET LONGWAVE RADIATION
    % [MJ.m-2.day-1]
    % FAO56 pag51 Eq37 and pag74 of hourly computing
    Rnl(iN)=(sigma*(Tm(iN) + 273.16)^4*(0.34-0.14*sqrt(e_a(iN)))*(1.35*Rs(iN)/Rs0(iN)-0.35));
    Rn(iN) = Rns(iN) - Rnl(iN);
    %% SURFACE RESISTANCE PARAMETERS CALCULATION
    
    % r_s - SURFACE RESISTANCE
    % [s.m-1]
    % VEG: Dingman pag 208 (canopy conductance) (equivalent to FAO56 pag21 Eq5)
    r_s_VEG(iN) = rl(iN)/LAI_act(iN);
    
    % SOIL: equation 20 of van de Griend and Owe, 1994
    %Theta_LL_sur(KT)=Theta_LL(NL,2);
    % [m.s-1]
    % FAO56 pag56 eq47
    
    u_2(iN) = u_z_m(iN)*4.87/log(67.8*z_m-5.42);
    
    % r_a - AERODYNAMIC RESISTANCE
    % [s.m-1]
    % FAO56 pag20 eq4- (d - zero displacement plane, z_0m - roughness length momentum transfer, z_0h - roughness length heat and vapour transfer, [m], FAO56 pag21 BOX4
    r_a_VEG(iN) = log((2-(2*h_v(iN)/3))/(0.123*h_v(iN)))*log((2-(2*h_v(iN)/3))/(0.0123*h_v(iN)))/((k^2)*u_2(iN));
    % r_a of SOIL
    % Liu www.hydrol-earth-syst-sci.net/11/769/2007/
    % equation for neutral conditions (eq. 9)
    % only function of ws, it is assumed that roughness are the same for any type of soil
    % r_a_SOIL(iN) = log((2.0)/0.0058)*log(2.0/0.0058)/((k^2)*u_2(iN));
    
    % PT/PE - Penman-Montheith
    % mm.day-1
    % FAO56 pag19 eq3
    PT_PM_VEG(iN) = (DELTA(iN)*Rn(iN)+86400*ro_a(iN)*Cp*(e0_Tm(iN)-e_a(iN))/r_a_VEG(iN))/(lambdav*(DELTA(iN) + gama*(1+r_s_VEG(iN)/r_a_VEG(iN))));
    % reference et ET0
    PT_PM_0(iN) = (0.408*DELTA(iN)*Rn(iN)+gama*900/(Tm(iN)+273)*(e0_Tm(iN)-e_a(iN))*u_2(iN))/(DELTA(iN) + gama*(1+0.34*u_2(iN)));
    T_act(iN)=PT_PM_0(iN)*Kcb(iN);
    PME(iN)=DELTA(iN)*Rn(iN)/(lambdav*(DELTA(iN) + gama));
end
