function [runoffDunnian, update_Precip_msr] = updateDunnianRunoff(Precip_msr, groundWaterDepth)
    % Dunnian runoff = Direct water input from precipitation + return flow
    % (a) direct water input from precipitation when soil is fully saturated (depth to water table = 0)
    % (b) Return flow (from groundwater exfiltration) calculated in MODFLOW and added to Dunnian runoff (through BMI)
    % here approach (a) is implemented
    runoffDunnian = zeros(size(Precip_msr));
    update_Precip_msr = Precip_msr;

    if groundWaterDepth <= 1.0
        runoffDunnian = Precip_msr;
        update_Precip_msr = zeros(size(Precip_msr));
    end

end
