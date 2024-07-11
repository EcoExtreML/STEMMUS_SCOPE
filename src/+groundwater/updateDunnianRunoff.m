function [dunnianRunoff, update_Precip_msr] = updateDunnianRunoff(Precip_msr, groundWaterDepth)
    % Dunnian runoff = Direct water input from precipitation + return flow
    % (a) direct water input from precipitation when soil is fully saturated (depth to water table = 0)
    % (b) Return flow (from groundwater exfiltration) calculated in MODFLOW and added to Dunnian runoff (through BMI)
    % here approach (a) is implemented
    wat_Dep = groundWaterDepth / 100; % (m);

    dunnianRunoff = zeros(size(Precip_msr));
    update_Precip_msr = Precip_msr;

    if wat_Dep <= 0.01
        dunnianRunoff = Precip_msr;
        update_Precip_msr = zeros(size(Precip_msr));
    end

end
