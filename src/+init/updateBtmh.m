function Btmh = updateBtmh(Genuchten, SoilConstants, Coefficients, i)

    if SoilConstants.SWCC==1   % VG soil water retention model
            Btmh = init.calcinitH(Genuchten.Theta_s(i), Genuchten.Theta_r(i), SoilConstants.BtmX, Genuchten.n(i), Genuchten.m(i), Genuchten.Alpha(i));
        else
            Btmh = Coefficients.Phi_s(i)*(SoilConstants.BtmX/Genuchten.Theta_s(i))^(-1/Coefficients.Lamda(i));
        end
end