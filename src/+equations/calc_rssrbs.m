function [rss, rbs] = calc_rssrbs(SoilProperties, LAI, rbs)

    % an alias
    SP = SoilProperties;
    aa = 3.8;
    rss = exp((aa + 4.1) - aa * (SP.SMC - SP.ResidualMC(1)) / (SP.fieldMC(1) - SP.ResidualMC(1)));
    rbs            = rbs * LAI / 4.3;
