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

    %%%%%%%%%% Adjust precipitation to get applied infiltration after removing: (1) saturation excess runoff   %%%%%%%%%%
    %%%%%%%%%%           (2) infiltration excess runoff (updated in +soilmoisture/calculateBoundaryConditions) %%%%%%%%%%
    % Note: Code changes are related to the issue: https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/232
    % Note: Adjusting the precipitation after the canopy interception is not implemented yet.

    % (1) Saturation excess runoff (Dunnian runoff)
    if ~GroundwaterSettings.GroundwaterCoupling  % Groundwater Coupling is not activated
        % Concept is adopted from the CLM model (see issue 232 in GitHub for more explanation)
        % Check also the CLM documents (https://doi.org/10.5065/D6N877R0, https://doi.org/10.1029/2005JD006111)
        wat_Dep = Tot_Depth / 100; % (m)
        fover = 0.5; % decay factor (fixed to 0.5 m-1)
        fmax = SoilProperties.fmax; % potential maximum value of fsat
        fsat = (fmax .* exp(-0.5 * fover * wat_Dep)); % fraction of saturated area (unitless)
        ForcingData.runoffDunnian = Precip_msr .* fsat; % Dunnian runoff (saturation excess runoff, in cm/sec)
    end

    % replace negative values
    for jj = 1:Dur_tot
        if ForcingData.Ta_msr(jj) < -100
            ForcingData.Ta_msr(jj) = NaN;
        end
    end

    % Outputs to be used by other functions
    ForcingData.Tmin = min(ForcingData.Ta_msr);
    ForcingData.Precip_msr = Precip_msr;
end
