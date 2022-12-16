function Genuchten = setGenuchtenParameters(SoilProperties)

    %{
        Update/define parameters of van Genuchten model.
        van Genuchten model Van Genuchten MTh, Leij FJ, Yates SR (1991) The RETC code
        for quantifying the hydraulic functions of unsaturated soils.
        EPA/600/2-91/065. In: Kerr RS (ed) Environmental Research Laboratory. US
        Environmental Protection Agency, Ada, OK, p 83

    %}

    Genuchten.Theta_s = SoilProperties.SaturatedMC;
    Genuchten.Theta_r = SoilProperties.ResidualMC;
    Genuchten.Theta_f = SoilProperties.fieldMC;
    Genuchten.Alpha = SoilProperties.Coefficient_Alpha;
    Genuchten.n = SoilProperties.Coefficient_n;
    Genuchten.m = 1-1./Genuchten.n;

end 