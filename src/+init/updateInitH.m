function initH = updateInitH(initX, VanGenuchten, SoilConstants, SoilVariables, i)
    % get model settings
    ModelSettings = io.getModelSettings();

    if ModelSettings.SWCC == 1   % VG soil water retention model
        initH = init.calcInitH(VanGenuchten.Theta_s(i), VanGenuchten.Theta_r(i), initX, VanGenuchten.n(i), VanGenuchten.m(i), VanGenuchten.Alpha(i));
    else
        initH = SoilVariables.Phi_s(i) * (InitX / VanGenuchten.Theta_s(i))^(-1 / SoilVariables.Lamda(i));
    end
end
