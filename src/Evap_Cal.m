function Evap_Cal
global RHOV_sur RHOV_A Resis_a Resis_s P_Va Velo_fric Theta_LL_sur  % RHOV_sur and Theta_L_sur should be stored at each time step.
global z_ref z_srT z_srm VK_Const d0_disp U_wind MO Ta U Ts Zeta_MO Stab_m Stab_T       % U_wind is the mean wind speed at height z_ref (m¡¤s^-1), U is the wind speed at each time step.
global Rv g HR_a NL NN Evap KT RHOV Theta_LL EVAP

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

Resis_a(KT)=(log((z_ref-d0_disp+z_srT)/z_srT)+Stab_T(KT))/(VK_Const*Velo_fric(KT));     %(s.cm^-1) 

Resis_s(KT)=10*exp(35.63*(0.15-Theta_LL_sur(KT)))/100; %(-805+4140*(Theta_s(J)-Theta_LL_sur(KT)))/100;  % s.m^-1----->0.001s.cm^-1

Evap(KT)=(RHOV_sur(KT)-RHOV_A(KT))/(Resis_s(KT)+Resis_a(KT));
EVAP(KT,1)=Evap(KT);

