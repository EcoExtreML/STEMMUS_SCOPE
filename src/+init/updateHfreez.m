function h_frez = updateHfreez(i, LatentHeatOfFreezing, SoilVariables)
    % get Constants
    Constants = io.define_constants();

    T = SoilVariables.T;
    h_frez = SoilVariables.h_frez;
    h = SoilVariables.h;
    Phi_s = SoilVariables.Phi_s;

    % get model settings
    ModelSettings = io.getModelSettings();

    if T(i) <= 0
        h_frez(i) = LatentHeatOfFreezing * 1e4 * (T(i)) / Constants.g / ModelSettings.T0;
    else
        h_frez(i) = 0;
    end
    if ModelSettings.SWCC == 1
        if h_frez(i) <= h(i) + 1e-6
            h_frez(i) = h(i) + 1e-6;
        else
            h_frez(i) = h_frez(i);
        end
    else
        if h_frez(i) <= h(i) - Phi_s(ModelSettings.J)
            h_frez(i) = h(i) - Phi_s(ModelSettings.J);
        else
            h_frez(i) = h_frez(i);
        end
    end

end
