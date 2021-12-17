function [PSIs,rsss,rrr,rxx] = calc_rsoil(Rl,DeltZ,Ztot,Ks,Theta_s,Theta_r,Theta_LL,Theta_o,bbx)
DeltZ=DeltZ';
n=1.5;
m=1-1/n;
l=0.5;
a=1.66;
SMC=Theta_LL(:,1);
Se  = (SMC-Theta_r*Theta_o)./(Theta_s-Theta_r);
Ksoil=Ks*Se.^l.*(1-(1-Se.^(1./m).^m)).^2;
PSIs=-(Se.^(-1./m)-1).^(1/n)/a.*bbx;
rsss          = 1./Ksoil./Rl./DeltZ/2/pi.*log((pi*Rl).^(-0.5)/(0.5*1e-3)).*bbx; % KL_h is the hydraulic conductivity, m s-1;VR is the root length density, m m-3;Ks is saturation conductivty;
rxx           = 2*1e12*Ztot/0.5/0.22./Rl/100.*bbx; % Delta_z*j is the depth of the layer
rrr           = 1.2*1e11*(Theta_s./SMC)./Rl./(DeltZ/100).*bbx;
%%% RADIAL --> Flow --> Krad*dP*row = [kg/m2 root s] or Krad*dP*row*RAI [kg/m2 ground s]
%Krad = 5*10^-8; %% % [1/s] %%  radial conductivity root Amenu and Kumar 2008
%Krad = 15*1e-8 ;%% [m /Pa s] radial conductivity root  -- North, G.B., Peterson, C.A. (2005) in Vascular transport in plants, Water
%%% Krad = 10^-9 - 7*10^-7 ;%% [m /MPa s] radial conductivity root Mendel et a 2002 WRR,   Huang and Nobel, 1994
%Krad = 0.3 - 20 *10^-8 ;%% [m /MPa s] radial conductivity root  Steudle and Peterson 1998
%Krad = 5 - 13 *10^-8 ;%% [m /MPa s] radial conductivity root  Bramley et al 2009 
%Krad = 2*10^-11 - 10^-9; %% % [1/s] %%  radial conductivity Schneider et al 2010
%Krad = 2*10^-9; %% % [1/s] %%  Javaux et al 2010
%Krad = 2*10^-7 -- 2*10^-5 [m /Mpa s] %% Draye et  al 2010 
%Krad= 0.5--2*10^-7  [m /Mpa s] %% Doussan et  al 2006
%Krad= 10^-9--10^-7  [m /Mpa s] %% Doussan et  al 1998 

%%%  AXIAL --> Flow = Kax/dL*dP*row ;; [kg / s]   
% Kax/dL*dP*row/(rroot*dL) ;; [kg/m^2 root /s] 
% Kax/dL*dP*row/(rroot*dL)*RAI ;; [kg/m^2 ground /s] 
%%% Kax = 0.2 ; % mm2/s   Root Axial  % Amenu and Kumar 2008
%%% Kax = 5*10^-11 - 4.2*10^-10 ;%% [m4 /MPa s] axial conductivity root Mendel et a 2002 WRR,   
%%% Kax = 2-6*10^-9 ;%% [m3 /MPa s] Bramley et al 2009 
%%% Kax = 2*10^-12 - 5*10^-9  ;%% [m4 /MPa s] Pierret et al 2006  
%%% Kax = 1*10^-12 - 1*10^-9  ;%% [m3 / s] Schneider et al 2010
%%%% Kax =5^10^-13-5*10^-12; %% % [m3 /s] %%  Javaux et al 2010
%Kax= 5*10^-11 -- 5*10^-9 [m4 /Mpa s] %% Draye et  al 2010 
%Kax= 5*10^-11 -- 1*10^-8 [m4 /Mpa s] %% Doussan et  al 2006 