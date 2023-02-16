function calcLambda(VPER, POR, Lamda_soc, XSOC)
    %{
        Calculate soil hydraulic properties according to equation 6c in
        Zheng, D., van der Velde, R., Su, Z., Wang, X., Wen, J., Booij, M. J.,
        Hoekstra, A. Y., and Chen, Y.: Augmentations to the Noah model physics
        for application to the Yellow River source area. Part I: Soil water
        flow, Journal of Hydrometeorology, 16, 2659-2676,
        https://doi.org/10.1175/JHM-D-14-0198.1, 2015

    %}

    Lamda = (2.91 + 0.159 * VPER / (1 - POR) *100);
    Lamda = 1 / (Lamda * (1 - XSOC) + XSOC * Lamda_soc);
end