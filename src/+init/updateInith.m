function Inith = updateInith(SWCC, initX, Genuchten, Coefficients, i)
    if SWCC==1   % VG soil water retention model
            Inith = equations.calc_initH_values(Genuchten.Theta_s(i), Genuchten.Theta_r(i), initX, Genuchten.n(i), Genuchten.m(i), Genuchten.Alpha(i));
        else
            Inith = Coefficients.Phi_s(i)*(InitX/Genuchten.Theta_s(i))^(-1/Coefficients.Lamda(i));
    end
end