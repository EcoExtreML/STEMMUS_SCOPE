function [rss,rbs] = calc_rssrbs(SMC,LAI,rbs)
global SaturatedMC ResidualMC fieldMC
aa=3.8;
rss = exp((aa+4.1)-aa*(SMC-ResidualMC(1))/(fieldMC(1)-ResidualMC(1))); % rss: soil surface resistance [s m−1]; aa and 4.1 is a pre-defined input
rbs            = rbs*LAI/4.3; % rbs: resistances for leaf boundary layer