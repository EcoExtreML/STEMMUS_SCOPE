function Btmh = updateBtmh(VanGenuchten, SoilVariables, i, ModelSettings)

    if ModelSettings.SWCC == 1   % VG soil water retention model
        Btmh = init.calcInitH(VanGenuchten.Theta_s(i), VanGenuchten.Theta_r(i), SoilVariables.BtmX, VanGenuchten.n(i), VanGenuchten.m(i), VanGenuchten.Alpha(i));
    else
        Btmh = SoilVariables.Phi_s(i) * (SoilVariables.BtmX / VanGenuchten.Theta_s(i))^(-1 / SoilVariables.Lamda(i));
    end
end
