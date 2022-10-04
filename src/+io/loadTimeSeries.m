function [ScopeParameters,xyt,canopy]  = loadTimeSeries(ScopeParameters,leafbio,soil,canopy,meteo,constants,F,xyt,path_input,options)

    %{
        This function loads time series data.

    %}

    t_file              = char(F(6).FileName);
    year_file           = char(F(7).FileName);
    Rin_file            = char(F(8).FileName);
    Rli_file            = char(F(9).FileName); 
    p_file              = char(F(10).FileName); 
    Ta_file             = char(F(11).FileName); 
    ea_file             = char(F(12).FileName); 
    u_file              = char(F(13).FileName); 
    CO2_file            = char(F(14).FileName); 
    z_file              = char(F(15).FileName); 
    tts_file            = char(F(16).FileName);
    LAI_file            = char(F(17).FileName);
    hc_file             = char(F(18).FileName);
    SMC_file            = char(F(19).FileName);
    Vcmax_file          = char(F(20).FileName);
    Cab_file            = char(F(21).FileName);

    %% 1. Time and zenith angle
    xyt.t               = load(fullfile(path_input, t_file));
    xyt.year            = load(fullfile(path_input, year_file));
    t_                  = xyt.t;

    DOY_                = floor(t_)+1;
    time_               = 24*(t_-floor(t_));

    if ~isempty(tts_file)
        ScopeParameters(51).Val      = load(fullfile(path_input, tts_file));
    else
        ttsR            = equations.calczenithangle(DOY_,time_ - xyt.timezn ,0,0,xyt.LON,xyt.LAT);     %sun zenith angle in rad
        ScopeParameters(51).Val       = min(85,ttsR/constants.deg2rad);                         %sun zenith angle in deg
    end
    
    %% 2. Radiation 
    if ~isempty(Rin_file)
        ScopeParameters(30).Val           = load(fullfile(path_input, Rin_file));
    else 
        ScopeParameters(30).Val       = ScopeParameters(30).Val*ones(size(t_));
    end
    if ~isempty(Rli_file)
        ScopeParameters(32).Val           = load(fullfile(path_input, Rli_file));
    else
        ScopeParameters(32).Val       = ScopeParameters(32).Val*ones(size(t_));
    end

    %% 3. Windspeed, air temperature, humidity and air pressure
    if ~isempty(u_file)% wind speed
        ScopeParameters(35).Val           = load(fullfile(path_input, u_file)); 
    else
        ScopeParameters(35).Val           = ScopeParameters(35).Val*ones(size(t_));
    end

    if ~isempty(Ta_file)%air temperature
        ScopeParameters(31).Val           = load(fullfile(path_input, Ta_file));
    else
        ScopeParameters(31).Val           = ScopeParameters(31).Val*ones(size(t_));
    end

    if ~isempty(ea_file)%air temperature
        ScopeParameters(34).Val           = load(fullfile(path_input, ea_file));
    else
        ScopeParameters(34).Val           = ScopeParameters(34).Val*ones(size(t_));
    end

    if ~isempty(p_file)
        ScopeParameters(33).Val       = load(fullfile(path_input, p_file));
    else
        ScopeParameters(33).Val       = ScopeParameters(33).Val*ones(size(t_));
    end

    %% 4. Vegetation structure (measurement height, vegetation height and LAI)
    if ~isempty(z_file)
        ztable          = load(fullfile(path_input, z_file));
        ScopeParameters(29).Val       = interp1(ztable(:,1),ztable(:,2),t_);
    else
        ScopeParameters(29).Val       = meteo.z*ones(size(t_));
    end
    if  ~isempty(LAI_file)
        LAItable        = load(fullfile(path_input, LAI_file));
        ScopeParameters(22).Val       = LAItable(:,2);
    else
        ScopeParameters(22).Val          = canopy.LAI*ones(size(time_));
    end
    if  ~isempty(hc_file)
        hctable         = load(fullfile(path_input, hc_file));
        ScopeParameters(23).Val       = interp1(hctable(:,1),hctable(:,2),t_); 
        canopy.hc = ScopeParameters(23).Val;
        if options.calc_zo
            [ScopeParameters(24).Val ,ScopeParameters(25).Val ]  = equations.zo_and_d(soil,canopy);
        else
            ScopeParameters(24).Val   = ones(size(t_))*ScopeParameters(24).Val;
            ScopeParameters(25).Val   = ones(size(t_))*ScopeParameters(25).Val;
        end
        
    else
        ScopeParameters(23).Val        = canopy.hc*ones(size(t_)); 
        ScopeParameters(24).Val        = canopy.zo*ones(size(t_)); 
        ScopeParameters(25).Val        = canopy.d*ones(size(t_));
    end


    %% 5. Gas concentrations
    if ~isempty(CO2_file)
        Ca_          = load(fullfile(path_input, CO2_file))*constants.Mair/constants.MCO2/constants.rhoa; % conversion from mg m-3 to ppm
        % mg(CO2)/m-3 * g(air)/mol(air) * mol(CO2)/g(CO2) * m3(air)/kg(air) * 10^-3 g(CO2)/mg(CO2) * 10^-3 kg(air)/g(air) * 10^6 ppm  
        jj              = isnan(Ca_);                           %find data with good quality  Ca data
        Ca_(jj)      = 380;
    else
        Ca_ = ones(length(t_),1)* 380;
    end
    ScopeParameters(36).Val       = Ca_;

    %% 6. Soil Moisture Content
    if ~isempty(SMC_file)
        ScopeParameters(54).Val          = load(fullfile(path_input, SMC_file));
    end

    %% 7. Leaf biochemical parameters
    if ~isempty(Vcmax_file)
        Vcmaxtable      = load(fullfile(path_input, Vcmax_file));
        ScopeParameters(9).Val         = interp1(Vcmaxtable(:,1),Vcmaxtable(:,2),t_);
    else
        ScopeParameters(9).Val        = leafbio.Vcmo*ones(size(t_));
    end

    if ~isempty(Cab_file)
        Cabtable        = load(fullfile(path_input, Cab_file));
        ScopeParameters(1).Val         = interp1(Cabtable(:,1),Cabtable(:,2),t_);
    else
        ScopeParameters(1).Val        = leafbio.Cab*ones(size(t_));
    end
