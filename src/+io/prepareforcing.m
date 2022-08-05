function [FilePaths, SiteProperties, timeStep, totalDuration] = prepareforcing(configPath)
%{ 
This function is used to read forcing data and site properties.

Input:
    configPath: A string of path of config file.

Output:
    FilePaths: A structure containing paths of soilProperty, input, output,
        and initial condition.
    SiteProperties： A structure containing site properties variables.
    timeStep: Time interval in seconds, normal is 1800 s in STEMMUS-SCOPE.
    totalDuration: The total number of time steps.
%}
%% Read the configPath file. Due to using MATLAB compiler, we cannot use run(CFG)
disp (['Reading config from ',configPath])
[FilePaths.soilProperty, FilePaths.input, FilePaths.output, ...
    forcingPath, forcingFileName, durationSize, ...
    FilePaths.initialCondition] = io.read_config(configPath);
%%
% Add the forcing name to forcing path
ForcingFilePath=fullfile(forcingPath, forcingFileName);
%prepare input files
sitefullname=dir(ForcingFilePath).name; %read sitename
    SiteProperties.siteName=sitefullname(1:6);
    startyear=sitefullname(8:11);
    endyear=sitefullname(13:16);
    startyear=str2double(startyear);
    endyear=str2double(endyear);
    
% Read time values from forcing file
time1=ncread(ForcingFilePath,'time');
t1=datenum(startyear,1,1,0,0,0);
timeStep=time1(2);

%get  time length of forcing file
time_length=length(time1);

%Set the end time of the main loop in STEMMUS_SCOPE.m
%using config file or time length of forcing file
if isnan(durationSize)
    totalDuration=time_length;
else
    if (durationSize>time_length)
        totalDuration=time_length;
    else
        totalDuration=durationSize;
    end
end

dt=time1(2)/3600/24;
t2=datenum(endyear,12,31,23,30,0);
T=t1:dt:t2;
TL=length(T);
T=T';
T=datestr(T,'yyyy-mm-dd HH:MM:SS');
T0=T(:,1:4);
T1=T(:,5:19);
T3=T1(1,:);
T4=T3(ones(TL,1),:);
T5=[T0,T4];
T6=datenum(T);
T7=datenum(T5);
T8=T6-T7;
time=T8;
T10=year(T);

RH=ncread(ForcingFilePath,'RH');            % Unit: %
RHL=length(RH);
RHa=reshape(RH,RHL,1);

Tair=ncread(ForcingFilePath,'Tair');        % Unit: K
TairL=length(Tair);
Taira=reshape(Tair,TairL,1)-273.15;         % Unit: degree C

es= 6.107*10.^(Taira.*7.5./(237.3+Taira));  % Unit: hPa
ea=es.*RHa./100;

SWdown=ncread(ForcingFilePath,'SWdown');    % Unit: W/m2
SWdownL=length(SWdown);
SWdowna=reshape(SWdown,SWdownL,1);


LWdown=ncread(ForcingFilePath,'LWdown');    % Unit: W/m2
LWdownL=length(LWdown);
LWdowna=reshape(LWdown,LWdownL,1);


VPD=ncread(ForcingFilePath,'VPD');          % Unit: hPa
VPDL=length(VPD);
VPDa=reshape(VPD,VPDL,1);


% Qair=ncread(ForcingFilePath,'Qair');
% QairL=length(Qair);
% Qaira=reshape(Qair,QairL,1);


Psurf=ncread(ForcingFilePath,'Psurf');      % Unit: Pa
PsurfL=length(Psurf);
Psurfa=reshape(Psurf,PsurfL,1);
Psurfa=Psurfa./100;                         % Unit: hPa


Precip=ncread(ForcingFilePath,'Precip');    % Unit: mm/s
PrecipL=length(Precip);
Precipa=reshape(Precip,PrecipL,1);
Precipa=Precipa./10;                        % Unit: cm/s


Wind=ncread(ForcingFilePath,'Wind');        % Unit: m/s
WindL=length(Wind);
Winda=reshape(Wind,WindL,1);


CO2air=ncread(ForcingFilePath,'CO2air');    % Unit: ppm
CO2airL=length(CO2air);
CO2aira=reshape(CO2air,CO2airL,1);
CO2aira=CO2aira.*44./22.4;                  % Unit: mg/m3


SiteProperties.latitude=ncread(ForcingFilePath,'latitude');
SiteProperties.longitude=ncread(ForcingFilePath,'longitude');
SiteProperties.elevation=ncread(ForcingFilePath,'elevation');

LAI=ncread(ForcingFilePath,'LAI');
LAIL=length(LAI);
LAIa=reshape(LAI,LAIL,1);
LAIa(LAIa<0.01)=0.01;

% LAI_alternative=ncread(ForcingFilePath,'LAI_alternative');
% LAI_alternativeL=length(LAI_alternative);
% LAI_alternativea=reshape(LAI_alternative,LAI_alternativeL,1);

SiteProperties.igbpVegLong=ncread(ForcingFilePath,'IGBP_veg_long');
SiteProperties.referenceHeight=ncread(ForcingFilePath,'reference_height');
SiteProperties.canopyHeight=ncread(ForcingFilePath,'canopy_height');

save([FilePaths.input, 't_.dat'], '-ascii', 'time')
save([FilePaths.input, 'Ta_.dat'], '-ascii', 'Taira')
save([FilePaths.input, 'Rin_.dat'], '-ascii', 'SWdowna')
save([FilePaths.input, 'Rli_.dat'], '-ascii', 'LWdowna')
%save([FilePaths.input, 'VPDa.dat'], '-ascii', 'VPDa')
%save([FilePaths.input, 'Qaira.dat'], '-ascii', 'Qaira')
save([FilePaths.input, 'p_.dat'], '-ascii', 'Psurfa')
%save([FilePaths.input, 'Precipa.dat'], '-ascii', 'Precipa') 
save([FilePaths.input, 'u_.dat'], '-ascii', 'Winda')
%save([FilePaths.input, 'RHa.dat'], '-ascii', 'RHa') 
save([FilePaths.input, 'CO2_.dat'], '-ascii', 'CO2aira') 
%save([FilePaths.input, 'latitude.dat'], '-ascii', 'latitude')
%save([FilePaths.input, 'longitude.dat'], '-ascii', 'longitude')
%save([FilePaths.input, 'reference_height.dat'], '-ascii', 'reference_height')
%save([FilePaths.input, 'canopy_height.dat'], '-ascii', 'canopy_height')
%save([FilePaths.input, 'elevation.dat'], '-ascii', 'elevation')
save([FilePaths.input, 'ea_.dat'], '-ascii', 'ea')
save([FilePaths.input, 'year_.dat'], '-ascii', 'T10')
LAI=[time'; LAIa']';
save([FilePaths.input, 'LAI_.dat'], '-ascii', 'LAI') %save meteorological data for STEMMUS
Meteodata=[time';Taira';RHa';Winda';Psurfa';Precipa';SWdowna';LWdowna';VPDa';LAIa']'; 
save([FilePaths.input, 'Mdata.txt'], '-ascii', 'Meteodata') %save meteorological data for STEMMUS
end