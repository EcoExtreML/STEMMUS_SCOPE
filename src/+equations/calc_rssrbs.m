function [rss, rbs] = calc_rssrbs(SMC, LAI, rbs, ResidualMC, fieldMC)
    %{
    This function is to calculate surface resistance, following C. van der Tol
    et al. 2014 (BG). The emperical parameters "aa, 4.1, and 4.3" are
    user-defined. And these parameters can be calibrated during winter season
    when LAI is low.
    %}
    aa = 3.8;
    bb = 4.1;
    cc = 4.3;

    rss = exp((aa + bb) - aa * (SMC - ResidualMC(1)) / (fieldMC(1) - ResidualMC(1)));
    rbs            = rbs * LAI / cc;
