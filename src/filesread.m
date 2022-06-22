%%%%%%% Set paths %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global SoilPropertyPath InputPath OutputPath ForcingPath ForcingFileName DurationSize
global CFG

%% CFG is a path to a config file
if isempty(CFG)
    CFG = '../config_file_crib.txt';
end

%% Read the CFG file. Due to using MATLAB compiler, we cannot use run(CFG)
disp (['Reading config from ',CFG])
[SoilPropertyPath, InputPath, OutputPath, ForcingPath, ForcingFileName, DurationSize, InitialConditionPath] = io.read_config(CFG);

%%%%%%% Prepare input files. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DELT IGBP_veg_long latitude longitude reference_height canopy_height sitename

% Add the forcing name to forcing path
ForcingFilePath=fullfile(ForcingPath, ForcingFileName);
%prepare input files
sitefullname=dir(ForcingFilePath).name; %read sitename
    sitename=sitefullname(1:6);
    startyear=sitefullname(8:11);
    endyear=sitefullname(13:16);
    startyear=str2double(startyear);
    endyear=str2double(endyear);
%ncdisp(sitefullname,'/','full');

% Read time values from forcing file
time1=ncread(ForcingFilePath,'time');
t1=datenum(startyear,1,1,0,0,0);
DELT=time1(2);

%get  time length of forcing file
time_length=length(time1);

%Set the end time of the main loop in STEMMUS_SCOPE.m
%using config file or time length of forcing file
if isnan(DurationSize)
    Dur_tot=time_length;
else
    if (DurationSize>time_length)
        Dur_tot=time_length;
    else
        Dur_tot=DurationSize;
    end
end

latitude=ncread(ForcingFilePath,'latitude');
longitude=ncread(ForcingFilePath,'longitude');
elevation=ncread(ForcingFilePath,'elevation');
IGBP_veg_long=ncread(ForcingFilePath,'IGBP_veg_long');
reference_height=ncread(ForcingFilePath,'reference_height');
canopy_height=ncread(ForcingFilePath,'canopy_height');

clearvars -except SoilPropertyPath InputPath OutputPath InitialConditionPath DELT Dur_tot IGBP_veg_long latitude longitude reference_height canopy_height sitename