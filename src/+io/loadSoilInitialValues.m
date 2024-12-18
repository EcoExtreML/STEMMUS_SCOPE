function [InitialValues, BtmX, BtmT, Tss] = loadSoilInitialValues(InputPath, TimeProperties, SoilProperties, ForcingData, ModelSettings)
    %{
        Producing initial soil moisture and soil temperature profile
    %}
    SaturatedMC = SoilProperties.SaturatedMC;
    fieldMC = SoilProperties.fieldMC;

    Dur_tot = TimeProperties.Dur_tot;
    Ta_msr = ForcingData.Ta_msr;

    % Get model settings
    Tot_Depth = ModelSettings.Tot_Depth;
    SWCC = ModelSettings.SWCC;

    % load initial soil moisture and soil temperature from ERA5
    load(fullfile(InputPath, "soil_init.mat"));
    % The following parameters are loaded:
    %   Tss
    %   InitT0
    %   InitT1
    %   InitT2
    %   InitT3
    %   InitT4
    %   InitT5
    %   InitT6
    %   InitX0
    %   InitX1
    %   InitX2
    %   InitX3
    %   InitX4
    %   InitX5
    %   InitX6
    %   BtmX
    BtmX = BtmX;
    Tss = Tss;

    % This input of soil layer thickness and initial depth will be revised
    % later via reading csv file. I read the initial soil depth variable
    % from .mat file.
    % ZSong (August 2024)
    if ~exist("InitND1", "var")
        InitND1 = 5;    % Unit of it is cm. These variables are used to indicated the depth corresponding to the measurement.
        InitND2 = 15;
        InitND3 = 60;
        InitND4 = 100;
        InitND5 = 200;
        InitND6 = 300;
    end
    if SWCC == 0
        InitT0 = -1.762;  % -1.75estimated soil surface temperature-1.762
        InitT1 = -0.662;
        InitT2 = 0.264;
        InitT3 = 0.905;
        InitT4 = 4.29;
        InitT5 = 3.657;
        InitT6 = 6.033;
        BtmT = 6.62;  % 9 8.1
        InitX0 = 0.088;
        InitX1 = 0.095; % Measured soil liquid moisture content
        InitX2 = 0.180; % 0.169
        InitX3 = 0.213; % 0.205
        InitX4 = 0.184; % 0.114
        InitX5 = 0.0845;
        InitX6 = 0.078;
        BtmX = 0.078; % 0.078 0.05;    % The initial moisture content at the bottom of the column.
    else
        if InitT0 < 0 || InitT1 < 0 || InitT2 < 0 || InitT3 < 0 || InitT4 < 0 || InitT5 < 0 || InitT6 < 0
            InitT0 = 0;
            InitT1 = 0;
            InitT2 = 0;
            InitT3 = 0;
            InitT4 = 0;
            InitT5 = 0;
            InitT6 = 0;
            Tss = InitT0;
        end
        if nanmean(Ta_msr) < 0
            BtmT = 0;  % 9 8.1
        else
           BtmT = 14.5; 
            % BtmT = nanmean(Ta_msr);
        end
        if InitX0 > SaturatedMC(1) || InitX1 > SaturatedMC(1) || InitX2 > SaturatedMC(2) || ...
            InitX3 > SaturatedMC(3) || InitX4 > SaturatedMC(4) || InitX5 > SaturatedMC(5) || InitX6 > SaturatedMC(6)
            InitX0 = fieldMC(1);  % 0.0793
            InitX1 = fieldMC(1); % Measured soil liquid moisture content
            InitX2 = fieldMC(2); % 0.182
            InitX3 = fieldMC(3);
            InitX4 = fieldMC(4); % 0.14335
            InitX5 = fieldMC(5);
            InitX6 = fieldMC(6);
            BtmX  = fieldMC(6);
        end
    end

    InitialValues.initX = [InitX0, InitX1, InitX2, InitX3, InitX4, InitX5, InitX6];
    InitialValues.initND = [InitND1, InitND2, InitND3, InitND4, InitND5, InitND6];
    InitialValues.initT = [InitT0, InitT1, InitT2, InitT3, InitT4, InitT5, InitT6];

end
