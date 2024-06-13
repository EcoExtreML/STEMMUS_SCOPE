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
	%%%%%%%%%%                                                                  (2) infiltration excess runoff %%%%%%%%%%
    % Note: Adjusting the precipitation after the canopy interception is not implemented yet.
    
    % (1) Saturation excess runoff (Dunnian runoff)	
    if ~GroundwaterSettings.GroundwaterCoupling  % Groundwater Coupling is not activated          
    % Concept is adopted from the CLM model (see issue 232 in GitHub for more explanation)
    % Check also the CLM documents (https://doi.org/10.5065/D6N877R0, https://doi.org/10.1029/2005JD006111)
        wat_Dep = Tot_Depth / 100; % (m)
        fover = 0.5; % decay factor (fixed to 0.5 m-1)
        fmax = SoilProperties.fmax; % potential maximum value of fsat
        fsat = (fmax .* exp(-0.5 * fover * wat_Dep)); % fraction of saturated area (unitless), note: the division by 100 is a unit conversion from 'cm' to 'm'		
        R_Dunn = Precip_msr .* fsat; % Dunnian runoff (saturation excess runoff, in c/sec)	
        Precip_msr = Precip_msr .* (1 - fsat); % applied infiltration after removing Dunnian runoff	

	else % Groundwater Coupling is activated
    % Different approach (not CLM). Dunnian runoff = Direct water input from precipitation + return flow
	% (a) direct water input from precipitation when soil is fully saturated (depth to water table = 0)
        wat_Dep = GroundwaterSettings.gw_Dep / 100; % (m);
	    if wat_Dep <= 0.01
            R_Dunn = Precip_msr;
            Precip_msr = Precip_msr .* 0;
        else
            R_Dunn = zeros(size(Precip_msr));		
        end
	% (b) Return flow (from groundwater exfiltration) is added to the Dunnian runoff (through BMI)
    end

    % (2) Infiltration excess runoff (Hortonian runoff) calculated in soilmoisture/calculateBoundaryCondition

    % replace negative values
    for jj = 1:Dur_tot
        if ForcingData.Ta_msr(jj) < -100
            ForcingData.Ta_msr(jj) = NaN;
        end
    end

    ForcingData.Tmin = min(ForcingData.Ta_msr);
    ForcingData.Precip_msr = Precip_msr .* 10 * DELT; % unit conversion from cm/sec to mm/30mins
	ForcingData.R_Dunn = R_Dunn;
end
