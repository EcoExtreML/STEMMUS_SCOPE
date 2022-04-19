global SaturatedK SaturatedMC ResidualMC Coefficient_n Coefficient_Alpha porosity FOC FOS FOSL MSOC Coef_Lamda fieldMC latitude longitude fmax theta_s0 Ks0 sitename
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
if sitename(1:2)==['ID'] % Soil data missing at ID-Pag site, we use anothor location information here.
   latitude=-1;
   longitude=112;
end
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
   if abs(lati(i)-latitude)<=0.0042
      break
   end
end
 for j=1:43200
      if abs(long(j)-longitude)<=0.0042
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
lat=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl1_alpha.nc'],'latitude');
lon=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl1_alpha.nc'],'longitude');
% read data
for i=1:17924
   if abs(lat(i)-latitude)<=0.0042
      break
   end
end
 for j=1:43200
      if abs(lon(j)-longitude)<=0.0042
         break
      end
end
% 0cm
alpha0=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl1_alpha.nc'],'alpha_0cm',[j,i],[1,1]);
n0=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl1_n.nc'],'n_0cm',[j,i],[1,1]);
theta_s0=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl1_thetas.nc'],'thetas_0cm',[j,i],[1,1]);
theta_r0=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl1_thetar.nc'],'thetar_0cm',[j,i],[1,1]);
Ks0=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl1_Ks.nc'],'Ks_0cm',[j,i],[1,1]);
% 5cm
alpha5=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl2_alpha.nc'],'alpha_5cm',[j,i],[1,1]);
n5=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl2_n.nc'],'n_5cm',[j,i],[1,1]);
theta_s5=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl2_thetas.nc'],'thetas_5cm',[j,i],[1,1]);
theta_r5=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl2_thetar.nc'],'thetar_5cm',[j,i],[1,1]);
Ks5=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl2_Ks.nc'],'Ks_5cm',[j,i],[1,1]);
% 15cm
alpha15=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl3_alpha.nc'],'alpha_15cm',[j,i],[1,1]);
n15=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl3_n.nc'],'n_15cm',[j,i],[1,1]);
theta_s15=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl3_thetas.nc'],'thetas_15cm',[j,i],[1,1]);
theta_r15=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl3_thetar.nc'],'thetar_15cm',[j,i],[1,1]);
Ks15=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl3_Ks.nc'],'Ks_15cm',[j,i],[1,1]);
% 30cm
alpha30=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl4_alpha.nc'],'alpha_30cm',[j,i],[1,1]);
n30=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl4_n.nc'],'n_30cm',[j,i],[1,1]);
theta_s30=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl4_thetas.nc'],'thetas_30cm',[j,i],[1,1]);
theta_r30=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl4_thetar.nc'],'thetar_30cm',[j,i],[1,1]);
Ks30=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl4_Ks.nc'],'Ks_30cm',[j,i],[1,1]);
% 60cm
alpha60=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl5_alpha.nc'],'alpha_60cm',[j,i],[1,1]);
n60=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl5_n.nc'],'n_60cm',[j,i],[1,1]);
theta_s60=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl5_thetas.nc'],'thetas_60cm',[j,i],[1,1]);
theta_r60=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl5_thetar.nc'],'thetar_60cm',[j,i],[1,1]);
Ks60=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl5_Ks.nc'],'Ks_60cm',[j,i],[1,1]);
% 100cm
alpha100=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl6_alpha.nc'],'alpha_100cm',[j,i],[1,1]);
n100=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl6_n.nc'],'n_100cm',[j,i],[1,1]);
theta_s100=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl6_thetas.nc'],'thetas_100cm',[j,i],[1,1]);
theta_r100=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl6_thetar.nc'],'thetar_100cm',[j,i],[1,1]);
Ks100=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl6_Ks.nc'],'Ks_100cm',[j,i],[1,1]);
% 200cm
alpha200=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl7_alpha.nc'],'alpha_200cm',[j,i],[1,1]);
n200=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl7_n.nc'],'n_200cm',[j,i],[1,1]);
theta_s200=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl7_thetas.nc'],'thetas_200cm',[j,i],[1,1]);
theta_r200=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl7_thetar.nc'],'thetar_200cm',[j,i],[1,1]);
Ks200=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl7_Ks.nc'],'Ks_200cm',[j,i],[1,1]);

 %% load maximum fractional saturated area
 FMAX=ncread([SoilPropertyPath,'surfdata.nc'],'FMAX');
 if longitude>=0
     j = fix(longitude/0.5);
     l = mod(longitude,0.5);
       if l<0.25
          j=j+1;
       else
          j=j;
       end
 else
     j = fix((longitude+360)/0.5);
     l = mod((longitude+360),0.5);
       if l<0.25
          j=j+1;
       else
          j=j;
       end
 end

     i = fix((latitude+90)/0.5);
     k = mod((latitude+90),0.5);
       if k<0.25
          i=i+1;
       else
          i=i;
       end

fmax=FMAX(j,i);
% soil property
SaturatedK=[Ks0/(3600*24) Ks5/(3600*24) Ks30/(3600*24) Ks60/(3600*24) Ks100/(3600*24) Ks200/(3600*24)];%[2.67*1e-3  1.79*1e-3 1.14*1e-3 4.57*1e-4 2.72*1e-4];      %[2.3*1e-4  2.3*1e-4 0.94*1e-4 0.94*1e-4 0.68*1e-4] 0.18*1e-4Saturation hydraulic conductivity (cm.s^-1);
SaturatedMC=[theta_s0 theta_s5 theta_s30 theta_s60 theta_s100 theta_s200];                              % 0.42 0.55 Saturated water content;
ResidualMC=[theta_r0 theta_r5 theta_r30 theta_r60 theta_r100 theta_r200];                               %0.037 0.017 0.078 The residual water content of soil;
Coefficient_n=[n0 n5 n30 n60 n100 n200];                            %1.2839 1.3519 1.2139 Coefficient in VG model;
Coefficient_Alpha=[alpha0 alpha5 alpha30 alpha60 alpha100 alpha200];                   % 0.02958 0.007383 Coefficient in VG model;
porosity=[theta_s0 theta_s5 theta_s30 theta_s60 theta_s100 theta_s200];                                      % Soil porosity;
fieldMC=(1./(((341.09.*Coefficient_Alpha).^(Coefficient_n)+1).^(1-1./Coefficient_n))).*(SaturatedMC-ResidualMC)+ResidualMC; 