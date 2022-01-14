function [rss,rbs] = calc_rssrbs(SMC,LAI,rbs)

%rss            = 10*exp(35.63*(0.25-SMC));
%if rss>1000,
    %rss=1000;
%elseif rss<30,
    %rss=30;
%end
rss = exp(7.6-1.5*(SMC-0.0875)/(0.25-0.0875));
%if  rss<70,
  %  rss=70;
%end
rbs            = rbs*LAI/4.3;