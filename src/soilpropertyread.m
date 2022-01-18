global SaturatedK SaturatedMC ResidualMC Coefficient_n Coefficient_Alpha porosity FOC FOS FOSL MSOC Coef_Lamda fieldMC latitude longitude
% the path SoilPropertyPath is set in filereads.m
dirOutput=dir([SoilPropertyPath, 'Hydraul_Param_SoilGrids_Schaap_sl7.nc']);
%ncdisp([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl1.nc'],'/','full');
%ncdisp([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl2.nc'],'/','full');
%ncdisp([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl3.nc'],'/','full');
%ncdisp([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl4.nc'],'/','full');
%ncdisp([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl5.nc'],'/','full');
%ncdisp([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl6.nc'],'/','full');
%ncdisp([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl7.nc'],'/','full');
%ncdisp([SoilPropertyPath,'CLAY1.nc','/','full');
%% load soil property
lat=ncread([SoilPropertyPath,'CLAY1.nc'],'lat');
lon=ncread([SoilPropertyPath,'CLAY1.nc'],'lon');
for i=1:16800
    if abs(lat(i)-latitude)<0.0085
    break
    end
end
 for j=1:43200
        if abs(lon(j)-longitude)<0.0085
        break
        end
 end
depth1=ncread([SoilPropertyPath,'CLAY1.nc'],'depth');
depth2=ncread([SoilPropertyPath,'CLAY2.nc'],'depth');
depth3=ncread([SoilPropertyPath,'POR.nc'],'depth');
CLAY1=ncread([SoilPropertyPath,'CLAY1.nc'],'CLAY',[j,i,1],[1,1,4]);
CLAY2=ncread([SoilPropertyPath,'CLAY2.nc'],'CLAY',[j,i,1],[1,1,4]);
SAND1=ncread([SoilPropertyPath,'SAND1.nc'],'SAND',[j,i,1],[1,1,4]);
SAND2=ncread([SoilPropertyPath,'SAND2.nc'],'SAND',[j,i,1],[1,1,4]);
SILT1=ncread([SoilPropertyPath,'SILT1.nc'],'SILT',[j,i,1],[1,1,4]);
SILT2=ncread([SoilPropertyPath,'SILT2.nc'],'SILT',[j,i,1],[1,1,4]);
OC1=ncread([SoilPropertyPath,'OC1.nc'],'OC',[j,i,1],[1,1,4]);
OC2=ncread([SoilPropertyPath,'OC2.nc'],'OC',[j,i,1],[1,1,4]);

FOC=[CLAY1(1) CLAY1(3) CLAY2(1) CLAY2(2) CLAY2(3) CLAY2(4)]/100; %fraction of clay
FOS=[SAND1(1) SAND1(3) SAND2(1) SAND2(2) SAND2(3) SAND2(4)]/100; %fraction of sand
%FOSL=1-FOC-FOS; %fraction of silt
MSOC=double([OC1(1) OC1(3) OC2(1) OC2(2) OC2(3) OC2(4)])./10000;  %mass fraction of soil organic matter
%% load lamda
lati=ncread([SoilPropertyPath,'lambda/lambda_l1.nc'],'lat');
long=ncread([SoilPropertyPath,'lambda/lambda_l1.nc'],'lon');
for i=1:21600
    if abs(lati(i)-latitude)<0.0085
    break
    end
end
 for j=1:43200
        if abs(long(j)-longitude)<0.0085
        break
        end
 end
lambda1=ncread([SoilPropertyPath,'lambda/lambda_l1.nc'],'lambda',[j,i],[1,1]);
lambda2=ncread([SoilPropertyPath,'lambda/lambda_l2.nc'],'lambda',[j,i],[1,1]); 
lambda3=ncread([SoilPropertyPath,'lambda/lambda_l3.nc'],'lambda',[j,i],[1,1]); 
lambda4=ncread([SoilPropertyPath,'lambda/lambda_l4.nc'],'lambda',[j,i],[1,1]); 
lambda5=ncread([SoilPropertyPath,'lambda/lambda_l5.nc'],'lambda',[j,i],[1,1]); 
lambda6=ncread([SoilPropertyPath,'lambda/lambda_l6.nc'],'lambda',[j,i],[1,1]);
lambda7=ncread([SoilPropertyPath,'lambda/lambda_l7.nc'],'lambda',[j,i],[1,1]);
lambda8=ncread([SoilPropertyPath,'lambda/lambda_l8.nc'],'lambda',[j,i],[1,1]);
Coef_Lamda=[lambda1 lambda3 lambda5 lambda6 lambda7 lambda8];
%% load soil hydrulic parameters
lat=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl7.nc'],'latitude');
lon=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl7.nc'],'longitude');
% 0cm
alpha_fit_0cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl1.nc'],'alpha_fit_0cm');
n_fit_0cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl1.nc'],'n_fit_0cm');
mean_theta_s_0cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl1.nc'],'mean_theta_s_0cm');
mean_theta_r_0cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl1.nc'],'mean_theta_r_0cm');
mean_L_0cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl1.nc'],'mean_L_0cm');
mean_Ks_0cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl1.nc'],'mean_Ks_0cm');
var_scaling_0cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl1.nc'],'var_scaling_0cm');
valid_subpixels_0cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl1.nc'],'valid_subpixels_0cm');
% 5cm
alpha_fit_5cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl2.nc'],'alpha_fit_5cm');
n_fit_5cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl2.nc'],'n_fit_5cm');
mean_theta_s_5cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl2.nc'],'mean_theta_s_5cm');
mean_theta_r_5cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl2.nc'],'mean_theta_r_5cm');
mean_L_5cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl2.nc'],'mean_L_5cm');
mean_Ks_5cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl2.nc'],'mean_Ks_5cm');
var_scaling_5cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl2.nc'],'var_scaling_5cm');
valid_subpixels_5cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl2.nc'],'valid_subpixels_5cm');
% 15cm
alpha_fit_15cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl3.nc'],'alpha_fit_15cm');
n_fit_15cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl3.nc'],'n_fit_15cm');
mean_theta_s_15cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl3.nc'],'mean_theta_s_15cm');
mean_theta_r_15cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl3.nc'],'mean_theta_r_15cm');
mean_L_15cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl3.nc'],'mean_L_15cm');
mean_Ks_15cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl3.nc'],'mean_Ks_15cm');
var_scaling_15cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl3.nc'],'var_scaling_15cm');
valid_subpixels_15cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl3.nc'],'valid_subpixels_15cm');
% 30cm
alpha_fit_30cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl4.nc'],'alpha_fit_30cm');
n_fit_30cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl4.nc'],'n_fit_30cm');
mean_theta_s_30cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl4.nc'],'mean_theta_s_30cm');
mean_theta_r_30cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl4.nc'],'mean_theta_r_30cm');
mean_L_30cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl4.nc'],'mean_L_30cm');
mean_Ks_30cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl4.nc'],'mean_Ks_30cm');
var_scaling_30cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl4.nc'],'var_scaling_30cm');
valid_subpixels_30cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl4.nc'],'valid_subpixels_30cm');
% 60cm
alpha_fit_60cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl5.nc'],'alpha_fit_60cm');
n_fit_60cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl5.nc'],'n_fit_60cm');
mean_theta_s_60cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl5.nc'],'mean_theta_s_60cm');
mean_theta_r_60cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl5.nc'],'mean_theta_r_60cm');
mean_L_60cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl5.nc'],'mean_L_60cm');
mean_Ks_60cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl5.nc'],'mean_Ks_60cm');
var_scaling_60cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl5.nc'],'var_scaling_60cm');
valid_subpixels_60cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl5.nc'],'valid_subpixels_60cm');
% 100cm
alpha_fit_100cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl6.nc'],'alpha_fit_100cm');
n_fit_100cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl6.nc'],'n_fit_100cm');
mean_theta_s_100cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl6.nc'],'mean_theta_s_100cm');
mean_theta_r_100cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl6.nc'],'mean_theta_r_100cm');
mean_L_100cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl6.nc'],'mean_L_100cm');
mean_Ks_100cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl6.nc'],'mean_Ks_100cm');
var_scaling_100cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl6.nc'],'var_scaling_100cm');
valid_subpixels_100cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl6.nc'],'valid_subpixels_100cm');
% 200cm
alpha_fit_200cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl7.nc'],'alpha_fit_200cm');
n_fit_200cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl7.nc'],'n_fit_200cm');
mean_theta_s_200cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl7.nc'],'mean_theta_s_200cm');
mean_theta_r_200cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl7.nc'],'mean_theta_r_200cm');
mean_L_200cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl7.nc'],'mean_L_200cm');
mean_Ks_200cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl7.nc'],'mean_Ks_200cm');
var_scaling_200cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl7.nc'],'var_scaling_200cm');
valid_subpixels_200cm=ncread([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl7.nc'],'valid_subpixels_200cm');
% read data
for i=1:600
    if abs(lat(i)-latitude)<0.25
    break
    end
end
 for j=1:1440
        if abs(lon(j)-longitude)<0.25
        break
        end
 end
 % 0cm
 alpha0=alpha_fit_0cm(j,i);
 n0=n_fit_0cm(j,i);
 theta_s0=mean_theta_s_0cm(j,i);
 theta_r0=mean_theta_r_0cm(j,i);
 Ks0=mean_Ks_0cm(j,i);
 % 5cm
 alpha5=alpha_fit_5cm(j,i);
 n5=n_fit_5cm(j,i);
 theta_s5=mean_theta_s_5cm(j,i);
 theta_r5=mean_theta_r_5cm(j,i);
 Ks5=mean_Ks_5cm(j,i);
 % 15cm
 alpha15=alpha_fit_15cm(j,i);
 n15=n_fit_15cm(j,i);
 theta_s15=mean_theta_s_15cm(j,i);
 theta_r15=mean_theta_r_15cm(j,i);
 Ks15=mean_Ks_15cm(j,i);
 % 30cm
 alpha30=alpha_fit_30cm(j,i);
 n30=n_fit_30cm(j,i);
 theta_s30=mean_theta_s_30cm(j,i);
 theta_r30=mean_theta_r_30cm(j,i);
 Ks30=mean_Ks_30cm(j,i);
 % 60cm
 alpha60=alpha_fit_60cm(j,i);
 n60=n_fit_60cm(j,i);
 theta_s60=mean_theta_s_60cm(j,i);
 theta_r60=mean_theta_r_60cm(j,i);
 Ks60=mean_Ks_60cm(j,i);
 % 100cm
 alpha100=alpha_fit_100cm(j,i);
 n100=n_fit_100cm(j,i);
 theta_s100=mean_theta_s_100cm(j,i);
 theta_r100=mean_theta_r_100cm(j,i);
 Ks100=mean_Ks_100cm(j,i);
 % 200cm
 alpha200=alpha_fit_200cm(j,i);
 n200=n_fit_200cm(j,i);
 theta_s200=mean_theta_s_200cm(j,i);
 theta_r200=mean_theta_r_200cm(j,i);
 Ks200=mean_Ks_200cm(j,i);
% soil property
SaturatedK=[Ks0/(3600*24) Ks5/(3600*24) Ks30/(3600*24) Ks60/(3600*24) Ks100/(3600*24) Ks200/(3600*24)];%[2.67*1e-3  1.79*1e-3 1.14*1e-3 4.57*1e-4 2.72*1e-4];      %[2.3*1e-4  2.3*1e-4 0.94*1e-4 0.94*1e-4 0.68*1e-4] 0.18*1e-4Saturation hydraulic conductivity (cm.s^-1);
SaturatedMC=[theta_s0 theta_s5 theta_s30 theta_s60 theta_s100 theta_s200];                              % 0.42 0.55 Saturated water content;
ResidualMC=[theta_r0 theta_r5 theta_r30 theta_r60 theta_r100 theta_r200];                               %0.037 0.017 0.078 The residual water content of soil;
Coefficient_n=[n0 n5 n30 n60 n100 n200];                            %1.2839 1.3519 1.2139 Coefficient in VG model;
Coefficient_Alpha=[alpha0 alpha5 alpha30 alpha60 alpha100 alpha200];                   % 0.02958 0.007383 Coefficient in VG model;
porosity=[theta_s0 theta_s5 theta_s30 theta_s60 theta_s100 theta_s200];                                      % Soil porosity;
fieldMC=(1./(((341.09.*Coefficient_Alpha).^(Coefficient_n)+1).^(1-1./Coefficient_n))).*(SaturatedMC-ResidualMC)+ResidualMC;   
