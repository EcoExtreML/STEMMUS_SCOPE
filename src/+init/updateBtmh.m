function Btmh = updateBtmh(VanGenuchten, SoilConstants, SoilVariables, i)

    if SoilConstants.SWCC==1   % VG soil water retention model
            Btmh = init.calcInitH(VanGenuchten.Theta_s(i), VanGenuchten.Theta_r(i), SoilConstants.BtmX, VanGenuchten.n(i), VanGenuchten.m(i), VanGenuchten.Alpha(i));
        else
            Btmh = SoilVariables.Phi_s(i)*(SoilConstants.BtmX/VanGenuchten.Theta_s(i))^(-1/SoilVariables.Lamda(i));
    end
end