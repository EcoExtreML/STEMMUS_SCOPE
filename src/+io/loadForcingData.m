function [ForcingData] = loadForcingData(InputPath, TimeProperties, SoilProperties, Tot_Depth, GroundwaterSettings)
    %{
    %}
    DELT = TimeProperties.DELT;
    Dur_tot = TimeProperties.Dur_tot;

    fID = fopen([InputPath, 'Mdata.txt']);
    Mdata = textscan(fID, "");
    fclose(fID);

    ForcingData.Ta_msr = Mdata{:, 2};
    ForcingData.RH_msr = Mdata{:, 3};
    ForcingData.WS_msr = Mdata{:, 4};
    ForcingData.Pg_msr = Mdata{:, 5};
    ForcingData.Rn_msr = Mdata{:, 7};
    ForcingData.Rns_msr = Mdata{:, 7};
    ForcingData.VPD_msr = Mdata{:, 9};
    ForcingData.LAI_msr = Mdata{:, 10};
    ForcingData.G_msr = Mdata{:, 7} * 0.15;
    Precip_msr = Mdata{:, 6}; % (cm/sec)

    %%%%%%%%%% Adjust precipitation to get applied infiltration after removing: (a) saturation excess runoff, (b) infiltration excess runoff %%%%%%%%%%
    %          Note: Adjusting the precipitation after the canopy interception is not implemented yet.
    %          (a) Saturation excess runoff (Dunnian runoff)
    %          Concept is adopted from the CLM model (see issue 232 in GitHub for more explanation)
    %          Check also the CLM documents (https://doi.org/10.1029/2005JD006111, https://doi.org/10.5065/D6N877R0)

    if GroundwaterSettings.GroundwaterCoupling == 1
        gw_Dep = GroundwaterSettings.gw_Dep; % water table depth, calculated from MODFLOW inputs
        wat_Dep = gw_Dep / 100; % (m)
    else
        wat_Dep = Tot_Depth / 100; % (m)
    end

    fover = 0.5; % decay factor (fixed to 0.5 m-1)
    fmax = SoilProperties.fmax; % potential maximum value of fsat
    fsat = (fmax .* exp(-0.5 * fover * wat_Dep)); % fraction of saturated area (unitless), note: the division by 100 is a unit conversion from 'cm' to 'm'

    Precip_msr = Precip_msr .* (1 - fsat); % applied infiltration after removing Dunnian runoff
    R_Dunn = Precip_msr .* fsat; % Dunnian runoff (saturation excess runoff, in c/sec)

    % (b) Infiltration excess runoff (Hortonian runoff)
    Ks0 = SoilProperties.Ks0 / (3600 * 24); % saturated vertical hydraulic conductivity. unit conversion from cm/day to cm/sec
    % Note: Ks0 is not adjusted by the fsat as in the CLM model (see issue 232 in GitHub for more explanation)
    Precip_msr = min(Precip_msr, Ks0); % applied infiltration after removing Hortonian runoff

    R_Hort = zeros(size(Precip_msr));
    for i = 1:length(R_Hort)
        if Precip_msr(i) > Ks0
            R_Hort(i) = Precip_msr(i) - Ks0;
        else
            R_Hort(i) = 0;
        end
    end

    % replace negative values
    for jj = 1:Dur_tot
        if ForcingData.Ta_msr(jj) < -100
            ForcingData.Ta_msr(jj) = NaN;
        end
    end

    ForcingData.Tmin = min(ForcingData.Ta_msr);
    ForcingData.Precip_msr = Precip_msr * 10 * DELT; % unit conversion from cm/sec to mm/30mins
    ForcingData.R_Dunn = R_Dunn;
    ForcingData.R_Hort = R_Hort;
end
