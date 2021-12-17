global DELT IGBP_veg_long latitude longitude reference_height canopy_height sitename
fileFolder=fullfile('../input/'); %read sitename
dirOutput=dir(fullfile(fileFolder,'*.nc'));
%prepare input files
Path ='../input/';
%File=dir(fullfile(Path,'filename'));
full_path=strcat(Path,dirOutput.name);
sitefullname=dirOutput.name;
    sitename=sitefullname(1:6);
    startyear=sitefullname(8:11);
    endyear=sitefullname(13:16);
    startyear=str2double(startyear);
    endyear=str2double(endyear);
%ncFilePath='../input/';
%ncdisp(sitefullname,'/','full');

time1=ncread(full_path,'time');
t1=datenum(startyear,1,1,0,0,0);
DELT=time1(2);
Dur_tot=length(time1);
dt=time1(2)/3600/24;
t2=datenum(endyear,12,31,23,30,0);
T=t1:dt:t2;
TL=length(T);
T=T';
T=datestr(T,'yyyy-mm-dd HH:MM:SS');
T0=T(:,1:4);
T01=T0(:,1);
T02=T0(:,2);
T03=T0(:,3);
T04=T0(:,4);
T1=T(:,5:19);
T3=T1(1,:);
T4=T3(ones(TL,1),:);
T5=[T0,T4];
T6=datenum(T);
T7=datenum(T5);
T8=T6-T7;
time=T8;
T10=year(T);

RH=ncread(full_path,'RH');
RHL=length(RH);
RHa=reshape(RH,RHL,1);

Tair=ncread(full_path,'Tair');
TairL=length(Tair);
Taira=reshape(Tair,TairL,1)-273.15;

es= 6.107*10.^(Taira.*7.5./(237.3+Taira));
ea=es.*RHa./100;

SWdown=ncread(full_path,'SWdown');
SWdownL=length(SWdown);
SWdowna=reshape(SWdown,SWdownL,1);


LWdown=ncread(full_path,'LWdown');
LWdownL=length(LWdown);
LWdowna=reshape(LWdown,LWdownL,1);


VPD=ncread(full_path,'VPD');
VPDL=length(VPD);
VPDa=reshape(VPD,VPDL,1);


Qair=ncread(full_path,'Qair');
QairL=length(Qair);
Qaira=reshape(Qair,QairL,1);


Psurf=ncread(full_path,'Psurf');
PsurfL=length(Psurf);
Psurfa=reshape(Psurf,PsurfL,1);
Psurfa=Psurfa./100;


Precip=ncread(full_path,'Precip');
PrecipL=length(Precip);
Precipa=reshape(Precip,PrecipL,1);
Precipa=Precipa./10;


Wind=ncread(full_path,'Wind');
WindL=length(Wind);
Winda=reshape(Wind,WindL,1);


CO2air=ncread(full_path,'CO2air');
CO2airL=length(CO2air);
CO2aira=reshape(CO2air,CO2airL,1);
CO2aira=CO2aira.*44./22.4;


latitude=ncread(full_path,'latitude');
longitude=ncread(full_path,'longitude');
elevation=ncread(full_path,'elevation');

LAI=ncread(full_path,'LAI');
LAIL=length(LAI);
LAIa=reshape(LAI,LAIL,1);


LAI_alternative=ncread(full_path,'LAI_alternative');
LAI_alternativeL=length(LAI_alternative);
LAI_alternativea=reshape(LAI_alternative,LAI_alternativeL,1);

IGBP_veg_long=ncread(full_path,'IGBP_veg_long');
reference_height=ncread(full_path,'reference_height');
canopy_height=ncread(full_path,'canopy_height');
% save .dat files for SCOPE
%save ../input/LAI_alternative.dat -ascii LAI_alternative
save ../input/t_.dat -ascii time
save ../input/Ta_.dat -ascii Taira
save ../input/Rin_.dat -ascii SWdowna
save ../input/Rli_.dat -ascii LWdowna
%save ../input/VPDa.dat -ascii VPDa
%save ../input/Qaira.dat -ascii Qaira
save ../input/p_.dat -ascii Psurfa
%save ../input/Precipa.dat -ascii Precipa
save ../input/u_.dat -ascii Winda
%save ../input/RHa.dat -ascii RHa
save ../input/CO2_.dat -ascii CO2aira
%save ../input/latitude.dat -ascii latitude
%save ../input/longitude.dat -ascii longitude
%save ../input/reference_height.dat -ascii reference_height
%save ../input/canopy_height.dat -ascii canopy_height
%save ../input/elevation.dat -ascii elevation
save ../input/ea_.dat -ascii ea
save ../input/year_.dat -ascii T10
LAI=[time'; LAIa']';
save ../input/LAI_.dat -ascii LAI %save meteorological data for STEMMUS
Meteodata=[time';Taira';RHa';Winda';Psurfa';Precipa';SWdowna';LWdowna';VPDa';LAIa']'; 
save ../input/Mdata.txt -ascii Meteodata %save meteorological data for STEMMUS
%Lacationdata=[latitude;longitude;reference_height;canopy_height;elevation]';
%save ../input/Lacationdata.txt -ascii Lacationdata
clearvars -except DELT Dur_tot IGBP_veg_long latitude longitude reference_height canopy_height sitename