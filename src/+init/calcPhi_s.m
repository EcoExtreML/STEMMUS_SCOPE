function Phi_s = calcPhi_s(VPER, POR, Phi_soc, XSOC)
    %{
        Calculate soil hydraulic properties according to equation 6b in
        Zheng, D., van der Velde, R., Su, Z., Wang, X., Wen, J., Booij, M. J.,
        Hoekstra, A. Y., and Chen, Y.: Augmentations to the Noah model physics
        for application to the Yellow River source area. Part I: Soil water
        flow, Journal of Hydrometeorology, 16, 2659-2676,
        https://doi.org/10.1175/JHM-D-14-0198.1, 2015

    %}


    Phi_s = -0.01 * 10 ^ (1.88 - 0.0131 * VPER / (1 - POR) * 100);
    Phi_s = (Phi_s * (1 - XSOC) + XSOC * Phi_soc) * 100;

end