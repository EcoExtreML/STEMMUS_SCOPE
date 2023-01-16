function Inith = updateInith(initX, Genuchten, SoilConstants, SoilVariables, i)
    if SoilConstants.SWCC==1   % VG soil water retention model
            Inith = init.calcInitH(Genuchten.Theta_s(i), Genuchten.Theta_r(i), initX, Genuchten.n(i), Genuchten.m(i), Genuchten.Alpha(i));
        else
            Inith = SoilVariables.Phi_s(i)*(InitX/Genuchten.Theta_s(i))^(-1/SoilVariables.Lamda(i));
    end
end