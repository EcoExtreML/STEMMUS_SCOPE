function [dunnianRunoff, Precip_msr] = updateDunnianRunoff(ForcingData, groundWaterDepth)
    % Dunnian runoff = Direct water input from precipitation + return flow
    % (a) direct water input from precipitation when soil is fully saturated (depth to water table = 0)
    % (b) Return flow (from groundwater exfiltration) calculated in MODFLOW and added to Dunnian runoff (through BMI)
    % here approach (a) is implemented
    wat_Dep = groundWaterDepth / 100; % (m);
    if wat_Dep <= 0.01
        dunnianRunoff = ForcingData.Precip_msr;
        Precip_msr = ForcingData.Precip_msr .* 0;		
    else
        dunnianRunoff = zeros(size(ForcingData.Precip_msr));
        Precip_msr = ForcingData.Precip_msr;		
    end

end
