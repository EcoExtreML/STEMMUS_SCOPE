function Btmh = updateBtmh(Genuchten, SoilConstants, SoilVariables, i)

    if SoilConstants.SWCC==1   % VG soil water retention model
            Btmh = init.calcInitH(Genuchten.Theta_s(i), Genuchten.Theta_r(i), SoilConstants.BtmX, Genuchten.n(i), Genuchten.m(i), Genuchten.Alpha(i));
        else
            Btmh = SoilVariables.Phi_s(i)*(SoilConstants.BtmX/Genuchten.Theta_s(i))^(-1/SoilVariables.Lamda(i));
    end
end