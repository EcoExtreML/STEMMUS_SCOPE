function [ScopeParameters, xyt, canopy] = loadTimeSeries(ScopeParameters, leafbio, soil, canopy, meteo, constants, F, xyt, path_input, options, landcoverClass)

    %{
        This function loads time series data.

    %}

    t_file = char(F(6).FileName);
    year_file = char(F(7).FileName);
    Rin_file = char(F(8).FileName);
    Rli_file = char(F(9).FileName);
    p_file = char(F(10).FileName);
    Ta_file = char(F(11).FileName);
    ea_file = char(F(12).FileName);
    u_file = char(F(13).FileName);
    CO2_file = char(F(14).FileName);
    z_file = char(F(15).FileName);
    tts_file = char(F(16).FileName);
    LAI_file = char(F(17).FileName);
    hc_file = char(F(18).FileName);
    SMC_file = char(F(19).FileName);
    Vcmax_file = char(F(20).FileName);
    Cab_file = char(F(21).FileName);

    %% 1. Time and zenith angle
    xyt.t = load(fullfile(path_input, t_file));
    xyt.year = load(fullfile(path_input, year_file));
    t_ = xyt.t;

    DOY_ = floor(t_) + 1;
    time_ = 24 * (t_ - floor(t_));

    if ~isempty(tts_file)
        ScopeParameters.tts = load(fullfile(path_input, tts_file));
    else
        ttsR = equations.calczenithangle(DOY_, time_ - xyt.timezn, 0, 0, xyt.LON, xyt.LAT); % sun zenith angle in rad
        ScopeParameters.tts = min(85, ttsR / constants.deg2rad); % sun zenith angle in deg
    end

    %% 2. Radiation
    if ~isempty(Rin_file)
        ScopeParameters.Rin = load(fullfile(path_input, Rin_file));
    else
        ScopeParameters.Rin = ScopeParameters.Rin * ones(size(t_));
    end
    if ~isempty(Rli_file)
        ScopeParameters.Rli = load(fullfile(path_input, Rli_file));
    else
        ScopeParameters.Rli = ScopeParameters.Rli * ones(size(t_));
    end

    %% 3. Windspeed, air temperature, humidity and air pressure
    if ~isempty(u_file) % wind speed
        ScopeParameters.u = load(fullfile(path_input, u_file));
    else
        ScopeParameters.u = ScopeParameters.u * ones(size(t_));
    end

    if ~isempty(Ta_file) % air temperature
        ScopeParameters.Ta = load(fullfile(path_input, Ta_file));
    else
        ScopeParameters.Ta = ScopeParameters.Ta * ones(size(t_));
    end

    if ~isempty(ea_file) % air temperature
        ScopeParameters.ea = load(fullfile(path_input, ea_file));
    else
        ScopeParameters.ea = ScopeParameters.ea * ones(size(t_));
    end

    if ~isempty(p_file)
        ScopeParameters.p = load(fullfile(path_input, p_file));
    else
        ScopeParameters.p = ScopeParameters.p * ones(size(t_));
    end

    %% 4. Vegetation structure (measurement height, vegetation height and LAI)
    if ~isempty(z_file)
        ztable = load(fullfile(path_input, z_file));
        ScopeParameters.z = interp1(ztable(:, 1), ztable(:, 2), t_);
    else
        ScopeParameters.z = meteo.z * ones(size(t_));
    end
    if  ~isempty(LAI_file)
        LAItable = load(fullfile(path_input, LAI_file));
        ScopeParameters.LAI = LAItable(:, 2);
    else
        ScopeParameters.LAI = canopy.LAI * ones(size(time_));
    end
    if  ~isempty(hc_file)
        hctable = load(fullfile(path_input, hc_file));
        ScopeParameters.hc = interp1(hctable(:, 1), hctable(:, 2), t_);
        canopy.hc = ScopeParameters.hc;
        if options.calc_zo
            [ScopeParameters.zo, ScopeParameters.d] = equations.zo_and_d(soil, canopy);
        else
            ScopeParameters.zo = ones(size(t_)) * ScopeParameters.zo;
            ScopeParameters.d = ones(size(t_)) * ScopeParameters.d;
        end

    else
        ScopeParameters.hc = canopy.hc * ones(size(t_));
        ScopeParameters.zo = canopy.zo * ones(size(t_));
        ScopeParameters.d = canopy.d * ones(size(t_));
    end

    %% 5. Gas concentrations
    if ~isempty(CO2_file)
        Ca_ = load(fullfile(path_input, CO2_file)) * constants.Mair / constants.MCO2 / constants.rhoa; % conversion from mg m-3 to ppm
        % mg(CO2)/m-3 * g(air)/mol(air) * mol(CO2)/g(CO2) * m3(air)/kg(air) * 10^-3 g(CO2)/mg(CO2) * 10^-3 kg(air)/g(air) * 10^6 ppm
        jj = isnan(Ca_); % find data with good quality  Ca data
        Ca_(jj) = 380;
    else
        Ca_ = ones(length(t_), 1) * 380;
    end
    ScopeParameters.Ca = Ca_;

    %% 6. Soil Moisture Content
    if ~isempty(SMC_file)
        ScopeParameters.SMC = load(fullfile(path_input, SMC_file));
    end

    %% 7. Leaf Vcmo, Tparam, m, Type, Rdparam, and leafwidth parameters
    % where landcoverClass is an vector like ["forest"; "forest"; "forest"; "shrubland"; ...]
    landcovers = unique(landcoverClass, 'stable');
    for ii = 1:length(xyt.t)
        landcoverIndex = find(strcmp(landcoverClass(ii), landcovers));
        ScopeParameters.Vcmo(ii, 1) = ScopeParameters.lcVcmo(landcoverIndex, 1);
        ScopeParameters.Tparam(ii, :) = ScopeParameters.lcTparam(landcoverIndex, :);
        ScopeParameters.m(ii, 1) = ScopeParameters.lcm(landcoverIndex, 1);
        ScopeParameters.Type(ii, 1) = ScopeParameters.lcType(landcoverIndex, 1);
        ScopeParameters.Rdparam(ii, 1) = ScopeParameters.lcRdparam(landcoverIndex, 1);
        ScopeParameters.leafwidth(ii, 1) = ScopeParameters.lcleafwidth(landcoverIndex, 1);
    end
    ScopeParameters = rmfield(ScopeParameters, {'lcVcmo', 'lcTparam', 'lcm', 'lcType', 'lcRdparam', 'lcleafwidth'});

    if ~isempty(Cab_file)
        Cabtable = load(fullfile(path_input, Cab_file));
        ScopeParameters.Cab  = interp1(Cabtable(:, 1), Cabtable(:, 2), t_);
    else
        ScopeParameters.Cab = leafbio.Cab * ones(size(t_));
    end
end
