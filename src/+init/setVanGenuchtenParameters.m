function VanGenuchten = setVanGenuchtenParameters(SoilProperties)

    %{
        Update/define parameters of Van Genuchten model.
        Van Genuchten model Van Genuchten MTh, Leij FJ, Yates SR (1991) The RETC code
        for quantifying the hydraulic functions of unsaturated soils.
        EPA/600/2-91/065. In: Kerr RS (ed) Environmental Research Laboratory. US
        Environmental Protection Agency, Ada, OK, p 83

    %}

    VanGenuchten.Theta_s = SoilProperties.SaturatedMC;
    VanGenuchten.Theta_r = SoilProperties.ResidualMC;
    VanGenuchten.Theta_f = SoilProperties.fieldMC;
    VanGenuchten.Alpha = SoilProperties.Coefficient_Alpha;
    VanGenuchten.n = SoilProperties.Coefficient_n;
    VanGenuchten.m = 1-1./VanGenuchten.n;

end